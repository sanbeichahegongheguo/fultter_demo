package com.leo.flutterstart;
import android.app.Activity;
import android.content.pm.PackageInfo;
import android.content.pm.PackageManager;
import android.graphics.Bitmap;
import android.graphics.Color;
import android.graphics.Paint;
import android.os.Environment;
import android.content.Context;
import android.content.res.Resources;
import com.leo.flutterstart.widget.BmpUtil;
import android.content.res.AssetManager;
import org.json.JSONArray;
import org.json.JSONObject;
import com.leo.flutterstart.TF;
import com.leo.flutterstart.widget.PathObject;

import android.util.DisplayMetrics;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.security.cert.Extension;
import java.util.List;
import android.util.Log;
import android.os.Bundle;
import android.util.TypedValue;

public class YondorMnist{
    private static YdMnistClassifierLite ydclassifierlite;
	private static YondorMnist instance = new YondorMnist();
	private static Boolean isUpload = false;
    private static Boolean isFirst = true;

    public static JSONObject detectxy(JSONArray pos, int thickness, Boolean isSave,Context context){
        if(ydclassifierlite == null){
            AssetManager manager = context.getAssets();
            ydclassifierlite = new YdMnistClassifierLite(manager);
        }
        int code = 200;
        String message ;
        final JSONArray uploadArr = new JSONArray();
        final String pathStr = pos.toString();


        Paint pt = new Paint();
        pt.setColor(Color.BLACK);

        pt.setStrokeWidth(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, TF.DRAW_THICKNESS, context.getResources().getDisplayMetrics()));
        pt.setStyle(Paint.Style.STROKE);

        boolean skip = false;
        StringBuilder builder = new StringBuilder();
        try{
            List<PathObject> pObjs = BmpUtil.getPathObject(pos);
            for(int i=0; i<pObjs.size(); i++){
                if(skip==true){
                    skip = false;
                    continue;
                }

                PathObject tmpP = pObjs.get(i);

                if(i < pObjs.size()-1){
                    PathObject tmpP2 = pObjs.get(i+1);
                    if(tmpP2.check5(tmpP)){
                        tmpP2.addPaths(tmpP);
                        pObjs.set(i+1, tmpP2);
                        continue;
                    }
                }


                Bitmap tmpBmp = tmpP.drawPathToSize(pt, TF.MNIST_SIZE);
                ByteBuffer imgData = ydclassifierlite.ImgData(tmpBmp);
                if(isFirst){
                    ydclassifierlite.inference(imgData);
                    isFirst = false;
                }
                MnistData mnistResult = ydclassifierlite.inference(imgData);
                String str0 = mnistResult.topWithoutValue(1);

                if(str0.equals("9") && tmpP.paths.size() >= 2){
                    str0 = "4";
                }
                if((str0.equals("1") || str0.equals("6")) && i < pObjs.size()-1){
                    PathObject tmpP2 = pObjs.get(i+1);
                    if(tmpP2.checkCross(tmpP)){
                        PathObject tmpP3 = new PathObject();
                        boolean added = tmpP3.addPaths(tmpP);
                        added = tmpP3.addPaths(tmpP2);
                        if (!added){
                            break;
                        }

                        Bitmap tmpBmp2 = tmpP3.drawPathToSize(pt, TF.MNIST_SIZE);
                        ByteBuffer imgData2 = ydclassifierlite.ImgData(tmpBmp2);
                        MnistData mnistResult2 = ydclassifierlite.inference(imgData2);
                        String str1 = mnistResult2.topWithoutValue(1);
                        if(str1.equals("4") || str1.equals("9")){
                            tmpBmp = tmpBmp2;
                            mnistResult = mnistResult2;
                            imgData = imgData2;
                            //str0 = str1;
                            str0 = "4";
                            skip = true;
                        }
                    }
                }

                builder.append(str0);

                if(isUpload){
                    String b64 = BmpUtil.bitmapToBase64(tmpBmp);
                    JSONObject tmpObj = new JSONObject();
                    tmpObj.put("mnist", str0);
                    tmpObj.put("b64", b64);
                    uploadArr.put(tmpObj);
                }
            }
            builder.reverse();

            if(isUpload){
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
            code = 500;
            message = err.getMessage();
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
