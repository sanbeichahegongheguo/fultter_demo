package com.leo.flutterstart.widget;

import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.util.Base64;
import android.util.DisplayMetrics;
import android.util.TypedValue;

import com.leo.flutterstart.TF;

import org.json.JSONArray;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

/**
 * Created by yondor_74 on 2019/3/21.
 */

public class BmpUtil {

    public static List<PathObject> getPathObject(JSONArray pos)throws Exception{
        List<PathObject> pObjs = new ArrayList<>();
        List<PathObject> tmpPObjs = new ArrayList<>();
        for(int i=0 ; i<pos.length() ; i++){
            JSONArray points = pos.getJSONArray(i);
            if(points.length() < 3){
                continue;
            }
            PathObject tmpObj = PathObject.getPathFromAxis(points);
            if(tmpObj.maxX==tmpObj.minX && tmpObj.maxY == tmpObj.minY){
                continue;
            }
            tmpPObjs.add(tmpObj);
        }
        Collections.sort(tmpPObjs, new Comparator< PathObject >() {
            @Override
            public int compare(PathObject obj1, PathObject obj2) {
                if ( obj1.minX > obj2.minX) {
                    return 1;
                } else {
                    return -1;
                }
            }
        });
        for(int i=0 ; i<tmpPObjs.size(); i++){
            PathObject tmpObj = tmpPObjs.get(i);
            boolean isAdded = false;
            for(int j=pObjs.size()-1 ; j>=0 ; j--){
                PathObject tmpObj2 = pObjs.get(j);
                if(tmpObj2.checkConnect(tmpObj)){
                    tmpObj2.addPaths(tmpObj);
                    pObjs.set(j, tmpObj2);
                    isAdded = true;
                    break;
                }
            }
            if(!isAdded){
                pObjs.add(tmpObj);
            }
        }

        Collections.reverse(pObjs);
        return pObjs;
    }

    public static Bitmap DrawWholeByAxis(JSONArray pos, int thickness, DisplayMetrics metrics) throws Exception{
        Paint pt = new Paint();
        pt.setColor(Color.BLACK);
        pt.setStrokeWidth(TypedValue.applyDimension(TypedValue.COMPLEX_UNIT_DIP, TF.DRAW_THICKNESS, metrics));
        pt.setStyle(Paint.Style.STROKE);

        JSONArray points = pos.getJSONArray(0);
        PathObject pObj = PathObject.getPathFromAxis(points);

        for(int i=1 ; i<pos.length() ; i++){
            points = pos.getJSONArray(i);
            PathObject tmpObj = PathObject.getPathFromAxis(points);
            pObj.mustAddPaths(tmpObj);
        }
        Bitmap result = pObj.drawPathToSize(pt, TF.DRAW_FULL_SIZE);
        return result;
    }

    public static Bitmap ResizeBitmap(Bitmap bm, int newWidth, int newHeight) {
        // 获得图片的宽高
        int width = bm.getWidth();
        int height = bm.getHeight();
        // 计算缩放比例
        float scaleWidth = ((float) newWidth) / width;
        float scaleHeight = ((float) newHeight) / height;
        // 取得想要缩放的matrix参数
        Matrix matrix = new Matrix();
        matrix.postScale(scaleWidth, scaleHeight);
        // 得到新的图片
        Bitmap newbm = Bitmap.createBitmap(bm, 0, 0, width, height, matrix, true);
        return newbm;
    }

    /**
     * bitmap转为base64
     *
     * @param bitmap
     * @return
     */
    public static String bitmapToBase64(Bitmap bitmap) {
        String result = null;
        ByteArrayOutputStream baos = null;
        try {
            if (bitmap != null) {
                baos = new ByteArrayOutputStream();
                bitmap.compress(Bitmap.CompressFormat.JPEG, 100, baos);
                baos.flush();
                baos.close();
                byte[] bitmapBytes = baos.toByteArray();
                result = Base64.encodeToString(bitmapBytes, Base64.DEFAULT);
            }
        } catch (IOException e) {
            e.printStackTrace();
        } finally {
            try {
                if (baos != null) {
                    baos.flush();
                    baos.close();
                }
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
        // Log.i("mnist:", result);
        return result;
    }

    public static Bitmap Base64ToBitmap(String b64){
        byte[] bytes = Base64.decode(b64, Base64.DEFAULT);
        return BitmapFactory.decodeByteArray(bytes, 0, bytes.length);
    }
}