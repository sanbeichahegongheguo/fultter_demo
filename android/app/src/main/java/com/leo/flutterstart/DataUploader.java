package com.leo.flutterstart;

import android.util.Log;

import org.json.JSONArray;

import java.io.DataInputStream;
import java.io.DataOutputStream;
import java.io.IOException;
import java.net.HttpURLConnection;
import java.net.MalformedURLException;
import java.net.URL;

public class DataUploader {
    public static boolean upload(JSONArray arr, String pathStr, String versionName){
        //String upload_url = "http://192.168.20.18:8080/pyocr/savemnistdata";
//        String upload_url = "http://192.168.6.30:30956/pyocr/savemnistdata";
        String upload_url = "http://api.k12china.com/pyocr/savemnistdata";
        HttpURLConnection connection = null;
        try{
            String dataJson = arr.toString();
            Log.i("mnist:","上传信息："+dataJson);

            URL url = new URL(upload_url);
            HttpURLConnection httpURLConnection = (HttpURLConnection) url.openConnection();
            httpURLConnection.setDoInput(true);
            httpURLConnection.setDoOutput(true);
            httpURLConnection.setRequestMethod("POST");
            httpURLConnection.setRequestProperty("Content-Type", "application/x-www-form-urlencoded");
            httpURLConnection.setRequestProperty("Charset", "utf-8");

            DataOutputStream dop = new DataOutputStream(
                    httpURLConnection.getOutputStream());
            dop.writeBytes("mnistresult="+dataJson+"&paths="+pathStr+"&ver="+versionName);
            int responseCode = httpURLConnection.getResponseCode();
            Log.i("mnist:","upload code :"+responseCode);
            if(responseCode != 200){
                return false;
            }
            DataInputStream dip = new DataInputStream(
                    httpURLConnection.getInputStream());
            Log.i("mnist:","result:"+dip.toString());
            dop.flush();
            dop.close();

        }catch (MalformedURLException e) {
            Log.i("mnist:", "MalformedURLException : " + e.toString());
            e.printStackTrace();
            return false;
        } catch (IOException e) {
            Log.i("mnist:", "IOException : " + e.toString());
            e.printStackTrace();
            return false;
        }catch (Exception e){
            Log.i("mnist:", "Exception : " + e.toString());
            e.printStackTrace();
            return false;
        }
        return true;
    }
}
