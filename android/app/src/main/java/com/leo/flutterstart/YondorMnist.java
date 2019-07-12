package com.leo.flutterstart;
import android.app.Activity;
import android.graphics.Bitmap;
import android.os.Environment;
import android.content.Context;
import android.content.res.Resources;
import com.leo.flutterstart.widget.BmpUtil;
import android.content.res.AssetManager;
import org.json.JSONArray;
import org.json.JSONObject;
import com.leo.flutterstart.TF;
import android.util.DisplayMetrics;
import java.io.File;
import java.io.FileOutputStream;
import java.nio.ByteBuffer;
import java.util.List;
import android.util.Log;
import android.os.Bundle;

public class YondorMnist{
    private static YdMnistClassifierLite ydclassifierlite;
	private static YondorMnist instance = new YondorMnist();
	private static Boolean isUpload = false;

    public static JSONObject detectxy(JSONArray pos, int thickness, Boolean isSave,Context context){
        if(ydclassifierlite == null){
            AssetManager manager = context.getAssets();
            ydclassifierlite = new YdMnistClassifierLite(manager);
        }
        int code = 200;
        String message ;
		final JSONArray uploadArr = new JSONArray();
		final String pathStr = pos.toString();
        try{
            List<Bitmap> bmps = BmpUtil.DrawByAxis(pos, TF.DRAW_THICKNESS, context.getResources().getDisplayMetrics());
            if(isSave){
                for(int i=0 ; i<bmps.size() ; i++){
					Bitmap tmpBmp = ydclassifierlite.ResizeBmp(bmps.get(i));
                    File extDir = Environment.getExternalStorageDirectory();
                    File file = new File(extDir, "test_pic" + i + ".jpg");
                    if(file.exists()){
                        file.delete();
                    }
                    FileOutputStream out;
                    out = new FileOutputStream(file);
                    if(tmpBmp.compress(Bitmap.CompressFormat.JPEG, 100, out))
                    {
                        out.flush();
                        out.close();
                    }
                }
            }
            message = detectHandlerLite(bmps, uploadArr);
			
			if(isUpload){
				if(message.length() > 1){
					Bitmap bigBmp = BmpUtil.DrawWholeByAxis(pos, TF.DRAW_THICKNESS, context.getResources().getDisplayMetrics());
					String b64 = BmpUtil.bitmapToBase64(bigBmp);
					JSONObject tmpObj = new JSONObject();
					tmpObj.put("mnist", message);
					tmpObj.put("b64", b64);
					uploadArr.put(tmpObj);
				}
				
				new Thread(new Runnable() {//创建子线程
					@Override
					public void run() {
						DataUploader.upload(uploadArr, pathStr);
					}
				}).start();			
			}
			
			
        }catch (Exception err){
            code = 500;
            message = err.getMessage();
        }
		Log.i("java.hx:", message);

        JSONObject result = new JSONObject();
        try{
            result.put("code", code);
            result.put("message", message);
			
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
			ByteBuffer imgData = ydclassifierlite.ImgData(bmp.get(i), tmpBmp);
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
        return "1.0.0";
    }

}
