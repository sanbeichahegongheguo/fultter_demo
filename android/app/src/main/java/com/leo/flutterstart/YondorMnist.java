package com.leo.flutterstart;

import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Paint;
import android.util.Log;
import android.util.TypedValue;

import com.leo.flutterstart.widget.BmpUtil;
import com.leo.flutterstart.widget.PathObject;

import org.json.JSONArray;
import org.json.JSONObject;

import java.nio.ByteBuffer;
import java.util.List;

public class YondorMnist{
    private static YdMnistClassifierLite ydclassifierlite;
	private static YondorMnist instance = new YondorMnist();
	private static Boolean isUpload = true;
    private static Boolean isFirst = true;

    public static JSONObject detectxy(JSONArray pos, int thickness, Boolean isSave, Activity context){
        if(ydclassifierlite == null){
            AssetManager manager = context.getAssets();
            ydclassifierlite = new YdMnistClassifierLite(manager);
        }
        Log.i("java.hx:", "isSave:"+ isSave);
        int code = 200;
        String message ;
        final JSONArray uploadArr = new JSONArray();
        final String pathStr = pos.toString();


        Paint pt = new Paint();
        pt.setColor(Color.BLACK);
        pt.setStrokeWidth(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, TF.DRAW_THICKNESS, context.getResources().getDisplayMetrics()));
        pt.setStyle(Paint.Style.STROKE);

        StringBuilder builder = new StringBuilder();
        try{
            PathObject mP = null;
            List<PathObject> pObjs = BmpUtil.getPathObject(pos, ydclassifierlite, context);
            for(int i=0; i<pObjs.size(); i++){            
                PathObject tmpP = pObjs.get(i);
                Bitmap tmpBmp = tmpP.drawPathToSize(pt, TF.MNIST_SIZE);
                String str0 = "";
                if(tmpP.checked8){
                    str0 = "八";
                }
                if(tmpP.checked5){
                    str0 = "5";
                }
                //小数点判断
                if(str0.length() == 0 && tmpP.paths.size() == 1 && i >= 1){
                    PathObject lastObj = pObjs.get(i-1);
//                    Log.i("java.hx:", "i="+i +"PathObject:"+ lastObj);
                    int lastW = lastObj.maxX - lastObj.minX;
//                    Log.i("java.hx:", "lastW:"+ lastW);
                    int lastH = lastObj.maxY - lastObj.minY;
//                    Log.i("java.hx:", "lastH:"+ lastH);
                    float size1 = Math.max(lastObj.maxX-lastObj.minX, lastObj.maxY-lastObj.minY);
//                    Log.i("java.hx:", "size1:"+ size1);
                    float size2 = tmpP.maxX - tmpP.minX;
//                    Log.i("java.hx:", "size2:"+ size2);
//                    Log.i("java.hx:", "if::"+ String.valueOf(size2 < size1*0.3 && tmpP.minY > lastObj.minY + lastH/2));
                    if(size2 < size1*0.3
                                && tmpP.minY > lastObj.minY + lastH/2){
                        str0 = ".";
                    }                            
                }

                if(str0.length() == 0){
                    ByteBuffer imgData = ydclassifierlite.ImgData(tmpBmp);
                    ydclassifierlite.inference(imgData);
                    MnistData mnistResult = ydclassifierlite.inference(imgData);
                    int idx0 = mnistResult.topIndex();
//                    Log.i("java.hx:", "idx0:"+ idx0);
                    str0 = TF.labels.substring(idx0,idx0+1);
                    if(str0.equals("÷") && tmpP.paths.size() == 4){
                        str0 = "六";
                    }else if(str0.equals("<") && tmpP.paths.size() == 2){
                        str0 = "七";
                    }else if(str0.equals("m")){
                        mP = tmpP;
                        continue;
                    }else if(mP!=null){
                        boolean ism23 = false;
                        if(str0.equals("2")){
                            str0 = "㎡";       
                            ism23 = true;                            
                        }else if(str0.equals("3")){
                            str0 = "m³";
                            ism23 = true;
                        }else{
                            builder.append("m");
                            if(isSave){
                                Bitmap mBmp = mP.drawPathToSize(pt, TF.MNIST_SIZE);
                                String b64 = BmpUtil.bitmapToBase64(mBmp);
                                JSONObject tmpObj = new JSONObject();
                                tmpObj.put("mnist", "m");
                                tmpObj.put("b64", b64);
                                uploadArr.put(tmpObj);
                            }
                        }  
                        if(ism23 && isSave){
                            PathObject nP = new PathObject();
                            nP.addPaths(mP);
                            nP.addPaths(tmpP);
                            tmpP = nP;
                            tmpBmp = tmpP.drawPathToSize(pt, TF.MNIST_SIZE);
                        }
                        mP = null;                             
                    }

                }
//                Log.i("java.hx:", "str0:"+ str0);
                builder.append(str0);

                if(isSave){
                    String b64 = BmpUtil.bitmapToBase64(tmpBmp);
                    JSONObject tmpObj = new JSONObject();
                    tmpObj.put("mnist", str0);
                    tmpObj.put("b64", b64);
                    uploadArr.put(tmpObj);
                }
            }
            // builder.reverse();

            if(isSave){
                if(builder.toString().length() > 1){
                    Bitmap bigBmp = BmpUtil.DrawWholeByAxis(pos, TF.DRAW_THICKNESS, context.getResources().getDisplayMetrics());
                    String b64 = BmpUtil.bitmapToBase64(bigBmp);
                    JSONObject tmpObj = new JSONObject();
                    tmpObj.put("mnist", builder.toString());
                    tmpObj.put("b64", b64);
                    uploadArr.put(tmpObj);
                }

                new Thread(new Runnable() {//创建子线程
                    @Override
                    public void run() {
                        String ver = getVersionName(context);
                        ver = ver.replaceAll("\\.","");
                        DataUploader.upload(uploadArr, pathStr, ver);
                    }
                }).start();
            }


        }catch (Exception err){
            err.printStackTrace();
            code = 500;
        }
        Log.i("java.hx:", builder.toString());

        JSONObject result = new JSONObject();
        try{
            result.put("code", code);
            result.put("message", builder.toString());

        }catch (Exception err){
            err.printStackTrace();
        }
        return result;

    }

    public static void detectclose(){
        if(ydclassifierlite!=null){
            ydclassifierlite.dispose();
            ydclassifierlite = null;
        }
    }

    private static String detectHandlerLite(List<Bitmap> bmp, JSONArray uploadArr) throws Exception{
        StringBuilder builder = new StringBuilder();
        for(int i=0; i<bmp.size(); i++){
            Bitmap tmpBmp = ydclassifierlite.ResizeBmp(bmp.get(i));
            ByteBuffer imgData = ydclassifierlite.ImgData(tmpBmp);
            MnistData mnistResult = ydclassifierlite.inference(imgData);
            String str = mnistResult.topWithoutValue(1);
            String b64 = BmpUtil.bitmapToBase64(tmpBmp);
            JSONObject tmpObj = new JSONObject();
            tmpObj.put("mnist", str);
            tmpObj.put("b64", b64);
            uploadArr.put(tmpObj);

            builder.append(str);
        }
        return builder.toString();
    }

    public static String getVersion(){
        return "101";
    }

    /**
     * 返回版本名字
     * 对应build.gradle中的versionName
     *
     * @param context
     * @return
     */
    public static String getVersionName(Context context) {
        String versionName = "";
        try {
            PackageManager packageManager = context.getPackageManager();
            PackageInfo packInfo = packageManager.getPackageInfo(context.getPackageName(), 0);
            versionName = packInfo.versionName;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return versionName;
    }

}
