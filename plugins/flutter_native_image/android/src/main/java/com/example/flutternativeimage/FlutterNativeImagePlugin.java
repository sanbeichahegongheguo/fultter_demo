package com.example.flutternativeimage;

import android.app.Activity;
import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.util.Log;


import java.io.ByteArrayOutputStream;
import java.io.Closeable;
import java.io.File;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.MethodChannel.Result;
import io.flutter.plugin.common.PluginRegistry.Registrar;

/**
 * FlutterNativeImagePlugin
 */
public class FlutterNativeImagePlugin implements MethodCallHandler {
  private final Activity activity;
  /**
   * Plugin registration.
   */
  public static void registerWith(Registrar registrar) {
    final MethodChannel channel = new MethodChannel(registrar.messenger(), "flutter_native_image");
    channel.setMethodCallHandler(new FlutterNativeImagePlugin(registrar.activity()));
  }

  private FlutterNativeImagePlugin(Activity activity) {
    this.activity = activity;
  }

  @Override
  public void onMethodCall(MethodCall call, Result result) {
    if(call.method.equals("compressImage")) {
      String fileName = call.argument("file");
      int resizePercentage = call.argument("percentage");
      int targetWidth = call.argument("targetWidth") == null ? 0 : (int) call.argument("targetWidth");
      int targetHeight = call.argument("targetHeight") == null ? 0 : (int) call.argument("targetHeight");
      int quality = call.argument("quality");

      File file = new File(fileName);

      if(!file.exists()) {
        result.error("file does not exist", fileName, null);
        return;
      }

      Bitmap bmp = BitmapFactory.decodeFile(fileName);
      ByteArrayOutputStream bos = new ByteArrayOutputStream();

      int newWidth = targetWidth == 0 ? (bmp.getWidth() / 100 * resizePercentage) : targetWidth;
      int newHeight = targetHeight == 0 ? (bmp.getHeight() / 100 * resizePercentage) : targetHeight;
      bmp = Bitmap.createScaledBitmap(bmp, newWidth, newHeight, true);
      boolean isRotate = false;
      int exifDegrees = exifToDegrees(fileName);
      Matrix matrix = new Matrix();
      if (exifDegrees != 0) {
        matrix.preRotate(exifDegrees);
      }
      if (!matrix.isIdentity()) {
        isRotate = true;
        bmp = transformBitmap(bmp,matrix);
      }

      // reconfigure bitmap to use RGB_565 before compressing
      // fixes https://github.com/btastic/flutter_native_image/issues/47
      Bitmap newBmp = bmp.copy(Bitmap.Config.RGB_565, false);
      newBmp.compress(Bitmap.CompressFormat.JPEG, quality, bos);
      try {
        String outputFileName = File.createTempFile(
          getFilenameWithoutExtension(file).concat("_compressed"),
          ".jpg",
          activity.getExternalCacheDir()
        ).getPath();

        OutputStream outputStream = new FileOutputStream(outputFileName);
        bos.writeTo(outputStream);

        copyExif(fileName, outputFileName,isRotate);

        result.success(outputFileName);
      } catch (FileNotFoundException e) {
        e.printStackTrace();
        result.error("file does not exist", fileName, null);
      } catch (IOException e) {
        e.printStackTrace();
        result.error("something went wrong", fileName, null);
      }

      return;
    }
    if(call.method.equals("getImageProperties")) {
      String fileName = call.argument("file");
      File file = new File(fileName);

      if(!file.exists()) {
        result.error("file does not exist", fileName, null);
        return;
      }

      BitmapFactory.Options options = new BitmapFactory.Options();
      options.inJustDecodeBounds = true;
      BitmapFactory.decodeFile(fileName,options);
      HashMap<String, Integer> properties = new HashMap<String, Integer>();
      properties.put("width", options.outWidth);
      properties.put("height", options.outHeight);

      int orientation = ExifInterface.ORIENTATION_UNDEFINED;
      try {
        ExifInterface exif = new ExifInterface(fileName);
        orientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_UNDEFINED);
      } catch(IOException ex) {
        // EXIF could not be read from the file; ignore
      }
      properties.put("orientation", orientation);

      result.success(properties);
      return;
    }
    if(call.method.equals("cropImage")) {
    	String fileName = call.argument("file");
    	int originX = call.argument("originX");
    	int originY = call.argument("originY");
    	int width = call.argument("width");
    	int height = call.argument("height");

      File file = new File(fileName);

    	if(!file.exists()) {
  			result.error("file does not exist", fileName, null);
  			return;
  		}

    	Bitmap bmp = BitmapFactory.decodeFile(fileName);
      ByteArrayOutputStream bos = new ByteArrayOutputStream();

      try {
			 bmp = Bitmap.createBitmap(bmp, originX, originY, width, height);
      } catch(IllegalArgumentException e) {
        e.printStackTrace();
        result.error("bounds are outside of the dimensions of the source image", fileName, null);
      }

      bmp.compress(Bitmap.CompressFormat.JPEG, 100, bos);
      bmp.recycle();
        OutputStream outputStream = null;
    	try {
        String outputFileName = File.createTempFile(
          getFilenameWithoutExtension(file).concat("_cropped"),
          ".jpg",
          activity.getExternalCacheDir()
        ).getPath();
            outputStream = new FileOutputStream(outputFileName);
            bos.writeTo(outputStream);

        copyExif(fileName, outputFileName,false);

        result.success(outputFileName);
  		} catch (FileNotFoundException e) {
  			e.printStackTrace();
        result.error("file does not exist", fileName, null);
  		} catch (IOException e) {
            e.printStackTrace();
            result.error("something went wrong", fileName, null);
        }finally {
            if (outputStream != null) {
                try {
                    outputStream.close();
                } catch (IOException e) {
                    e.printStackTrace();
                }
            }
        }



  		return;
    }
    if (call.method.equals("getPlatformVersion")) {
      result.success("Android " + android.os.Build.VERSION.RELEASE);
    } else {
      result.notImplemented();
    }
  }

  private void copyExif(String filePathOri, String filePathDest,boolean isRotate) {
    try {
      ExifInterface oldExif = new ExifInterface(filePathOri);
      ExifInterface newExif = new ExifInterface(filePathDest);
      if (isRotate){
        oldExif.setAttribute(ExifInterface.TAG_ORIENTATION,ExifInterface.ORIENTATION_UNDEFINED+"");
      }
      List<String> attributes =
          Arrays.asList(
              "FNumber",
              "ExposureTime",
              "ISOSpeedRatings",
              "GPSAltitude",
              "GPSAltitudeRef",
              "FocalLength",
              "GPSDateStamp",
              "WhiteBalance",
              "GPSProcessingMethod",
              "GPSTimeStamp",
              "DateTime",
              "Flash",
              "GPSLatitude",
              "GPSLatitudeRef",
              "GPSLongitude",
              "GPSLongitudeRef",
              "Make",
              "Model",
              "Orientation");
      for (String attribute : attributes) {
        setIfNotNull(oldExif, newExif, attribute);
      }

      newExif.saveAttributes();

    } catch (Exception ex) {
      Log.e("FlutterNativeImagePlugin", "Error preserving Exif data on selected image: " + ex);
    }
  }

  private void setIfNotNull(ExifInterface oldExif, ExifInterface newExif, String property) {
    if (oldExif.getAttribute(property) != null) {
      newExif.setAttribute(property, oldExif.getAttribute(property));
    }
  }

  private static String pathComponent(String filename) {
    int i = filename.lastIndexOf(File.separator);
    return (i > -1) ? filename.substring(0, i) : filename;
  }

  private static String getFilenameWithoutExtension(File file) {
    String fileName = file.getName();

    if (fileName.indexOf(".") > 0) {
      return fileName.substring(0, fileName.lastIndexOf("."));
    } else {
      return fileName;
    }
  }

  public static int exifToDegrees(String fileName) {
    int rotation;
    ExifInterface exif = null;
    int exifOrientation = ExifInterface.ORIENTATION_UNDEFINED;
    try {
      exif = new ExifInterface(fileName);
      exifOrientation = exif.getAttributeInt(ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_UNDEFINED);
    } catch (IOException e) {
      e.printStackTrace();
    }
    switch (exifOrientation) {
      case ExifInterface.ORIENTATION_ROTATE_90:
      case ExifInterface.ORIENTATION_TRANSPOSE:
        rotation = 90;
        break;
      case ExifInterface.ORIENTATION_ROTATE_180:
      case ExifInterface.ORIENTATION_FLIP_VERTICAL:
        rotation = 180;
        break;
      case ExifInterface.ORIENTATION_ROTATE_270:
      case ExifInterface.ORIENTATION_TRANSVERSE:
        rotation = 270;
        break;
      default:
        rotation = 0;
    }
    return rotation;
  }

  public static Bitmap transformBitmap(Bitmap bitmap,Matrix transformMatrix) {
    try {
      Bitmap converted = Bitmap.createBitmap(bitmap, 0, 0, bitmap.getWidth(), bitmap.getHeight(), transformMatrix, true);
      if (!bitmap.sameAs(converted)) {
        bitmap = converted;
      }
    } catch (OutOfMemoryError error) {
      Log.e("FlutterNativeImagePlugin", "transformBitmap: ", error);
    }
    return bitmap;
  }
}
