package com.leo.flutterstart.widget;

import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.Color;
import android.graphics.Matrix;
import android.graphics.Paint;
import android.graphics.Path;

import org.json.JSONArray;

import java.util.ArrayList;
import java.util.List;

public class PathObject {
    public List<Path> paths;
    public int maxX = -1;
    public int maxY = -1;
    public int minX = -1;
    public int minY = -1;
    public PathObject(){
        paths = new ArrayList<>();
    }

    public void addPath(Path p, int x1, int y1, int x2, int y2){
        paths.add(p);
        minX = (minX==-1)?x1:Math.min(x1,minX);
        minY = (minY==-1)?y1:Math.min(y1,minY);
        maxX = (maxX==-1)?x2:Math.max(x2,maxX);
        maxY = (maxY==-1)?y2:Math.max(y2,maxY);
    }

    public boolean addPaths(PathObject obj){
        if(paths.size()>=2){
            return false;
        }
        paths.addAll(obj.paths);
        minX = (minX==-1)?obj.minX:Math.min(obj.minX,minX);
        minY = (minY==-1)?obj.minY:Math.min(obj.minY,minY);
        maxX = (maxX==-1)?obj.maxX:Math.max(obj.maxX,maxX);
        maxY = (maxY==-1)?obj.maxY:Math.max(obj.maxY,maxY);
        return true;
    }

    public boolean mustAddPaths(PathObject obj){
        paths.addAll(obj.paths);
        minX = (minX==-1)?obj.minX:Math.min(obj.minX,minX);
        minY = (minY==-1)?obj.minY:Math.min(obj.minY,minY);
        maxX = (maxX==-1)?obj.maxX:Math.max(obj.maxX,maxX);
        maxY = (maxY==-1)?obj.maxY:Math.max(obj.maxY,maxY);
        return true;
    }

    public boolean checkConnect(PathObject obj){
        int minx = obj.minX;
        int maxx = obj.maxX;
        int miny = obj.minY;
        int maxy = obj.maxY;
        boolean judgeTotIn = (maxx<maxX && minx>minX) || (maxx>maxX && minx < minX);
        if(judgeTotIn){
            return true;
        }
        return false;
    }

    public boolean check5(PathObject obj) {
        int minx = obj.minX;
        int maxx = obj.maxX;
        int miny = obj.minY;
        int maxy = obj.maxY;
        boolean judge5 = (miny < minY + (maxY - minY) / 2) && ((maxy - miny) < (maxY - minY) / 2);
        if (minx > maxX) {
            judge5 = judge5 && (minx - maxX) < (maxx - minx);
        } else {
            boolean judgeUpleft = minx < maxX && maxy < maxY;
            judge5 = judge5 && judgeUpleft;
        }
        if (judge5) {
            return true;
        }
        return false;
    }

    public boolean checkCross(PathObject obj){
        boolean check1 = obj.maxX > minX && obj.minX < maxX;
        return  check1;
    }


    public Bitmap drawPath(Paint paint){
        int size = Math.max((maxX-minX), (maxY-minY));
        size = (int)paint.getStrokeWidth()*2 + size;

        Bitmap b = Bitmap.createBitmap(size, size, Bitmap.Config.ARGB_8888);
        b.eraseColor(Color.parseColor("#FFFFFF"));
        Canvas c = new Canvas(b);

        int offsetX = (size - (maxX - minX))/2;
        int offsetY = (size - (maxY - minY))/2;

        for(int i=0; i<paths.size(); i++){
            Path p = paths.get(i);
            p.offset(-minX + offsetX, -minY + offsetY);
            c.drawPath(p, paint);
        }
        return b;
    }


    public Bitmap drawPathToSize(Paint paint, int psize){
        Bitmap b = Bitmap.createBitmap(psize, psize, Bitmap.Config.ARGB_8888);
        b.eraseColor(Color.parseColor("#FFFFFF"));
        Canvas c = new Canvas(b);

        float scaleWidth = (float) (psize * 0.9) / (maxX - minX);
        float scaleHeight = (float) (psize * 0.9) / (maxY - minY);
        float scale = Math.min(scaleHeight, scaleWidth);
        Matrix matrix = new Matrix();
        matrix.setScale(scale,scale);

        float offsetX = (psize - (maxX-minX)*scale)/2;
        float offsetY = (psize - (maxY-minY)*scale)/2;
        float startX = minX*scale;
        float startY = minY*scale;

        for(int i=0; i<paths.size(); i++){
            Path p = new Path(paths.get(i));
            p.transform(matrix);
            p.offset(-startX+offsetX, -startY+offsetY);
            c.drawPath(p, paint);
        }
        return b;
    }


    public static PathObject getPathFromAxis(JSONArray points) throws Exception{
        PathObject obj = new PathObject();
        int minX = -1;
        int minY = -1;
        int maxX = -1;
        int maxY = -1;
        Path p = new Path();
        for(int j=0; j<points.length() ; j++){
            JSONArray point = points.getJSONArray(j);
            int x = point.getInt(0);
            int y = point.getInt(1);
            if(j == 0){
                p.moveTo(x, y);
            }else{
                p.lineTo(x, y);
            }
            minX = (minX==-1)?x:Math.min(x,minX);
            minY = (minY==-1)?y:Math.min(y,minY);
            maxX = (maxX==-1)?x:Math.max(x,maxX);
            maxY = (maxY==-1)?y:Math.max(y,maxY);
        }
        obj.paths.add(p);
        obj.minX = minX;
        obj.minY = minY;
        obj.maxX = maxX;
        obj.maxY = maxY;
        return obj;
    }

}