package com.leo.flutterstart;

import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.graphics.Bitmap;
import android.graphics.Matrix;
import android.util.Log;
import org.tensorflow.lite.Interpreter;
import java.io.FileInputStream;
import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.MappedByteBuffer;
import java.nio.channels.FileChannel;
import java.util.Arrays;

public class YdMnistClassifierLite {
    private final Interpreter mInterpreter;
    public YdMnistClassifierLite(AssetManager manager) {
        MappedByteBuffer mbb = null;
        try{
            AssetFileDescriptor fileDescriptor = manager.openFd(TF.YD_MODEL_LITE);
            FileInputStream inputStream = new FileInputStream(fileDescriptor.getFileDescriptor());
            FileChannel fileChannel = inputStream.getChannel();
            long startOffset = fileDescriptor.getStartOffset();
            long declaredLength = fileDescriptor.getDeclaredLength();
            mbb = fileChannel.map(FileChannel.MapMode.READ_ONLY, startOffset, declaredLength);
        }catch (Exception err){
            err.printStackTrace();
        }
        mInterpreter = new Interpreter(mbb);

    }

    public MnistData inference(ByteBuffer input){
        float[][] mResult = new float[1][TF.labels.length()];
        mInterpreter.run(input, mResult);
        // Log.i("mnist:", Arrays.toString(mResult[0]));
        return new MnistData(mResult[0]);
    }

    public void dispose(){
        mInterpreter.close();
    }

    public Bitmap ResizeBmp(Bitmap bm){
        // 获得图片的宽高
        int width = bm.getWidth();
        int height = bm.getHeight();
        // 计算缩放比例
        float scaleWidth = ((float) TF.MNIST_SIZE) / width;
        float scaleHeight = ((float) TF.MNIST_SIZE) / height;
        // 取得想要缩放的matrix参数
        Matrix matrix = new Matrix();
        matrix.postScale(scaleWidth, scaleHeight);
        // 得到新的图片
        Bitmap newbm = Bitmap.createBitmap(bm, 0, 0, width, height, matrix, true);
        return newbm;
    }

    public ByteBuffer ImgData(Bitmap newbm) {
        ByteBuffer mImgData = ByteBuffer.allocateDirect(4 * 1 * TF.MNIST_SIZE * TF.MNIST_SIZE * 1);
        mImgData.order(ByteOrder.nativeOrder());
        mImgData.rewind();
        int[] mImagePixels = new int[TF.MNIST_SIZE * TF.MNIST_SIZE];
        newbm.getPixels(mImagePixels, 0, newbm.getWidth(), 0, 0,
                newbm.getWidth(), newbm.getHeight());

        int pixel = 0;
        for (int i = 0; i < TF.MNIST_SIZE; ++i) {
            StringBuilder b = new StringBuilder();
            for (int j = 0; j < TF.MNIST_SIZE; ++j) {
                if(mImagePixels[pixel]==-1){
                    b.append(0);
                }else{
                    b.append(1);
                }
                final int val = mImagePixels[pixel++];
                mImgData.putFloat(1-convertToGreyScale(val));
            }
            Log.i("mnist", b.toString());
        }

        return mImgData;
    }

    private float convertToGreyScale(int color) {
        return (((color >> 16) & 0xFF) + ((color >> 8) & 0xFF) + (color & 0xFF)) / 3.0f / 255.0f;
    }

}