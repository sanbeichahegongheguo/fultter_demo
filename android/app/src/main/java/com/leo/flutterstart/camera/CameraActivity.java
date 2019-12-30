package com.leo.flutterstart.camera;

import android.Manifest;
import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.database.Cursor;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.ImageFormat;
import android.graphics.PointF;
import android.graphics.Rect;
import android.graphics.YuvImage;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.provider.MediaStore;
import android.util.Log;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;
import android.widget.ImageView;
import android.widget.MediaController;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.VideoView;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;
import androidx.core.app.ActivityCompat;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.leo.flutterstart.R;
import com.leo.flutterstart.VideoShowActivity;
import com.otaliastudios.cameraview.CameraException;
import com.otaliastudios.cameraview.CameraListener;
import com.otaliastudios.cameraview.CameraLogger;
import com.otaliastudios.cameraview.CameraOptions;
import com.otaliastudios.cameraview.CameraView;
import com.otaliastudios.cameraview.FileCallback;
import com.otaliastudios.cameraview.PictureResult;
import com.otaliastudios.cameraview.VideoResult;
import com.otaliastudios.cameraview.controls.Flash;
import com.otaliastudios.cameraview.controls.Mode;
import com.otaliastudios.cameraview.controls.Preview;
import com.otaliastudios.cameraview.filter.Filters;
import com.otaliastudios.cameraview.frame.Frame;
import com.otaliastudios.cameraview.frame.FrameProcessor;

import java.io.ByteArrayOutputStream;
import java.io.File;
import java.util.Arrays;
import java.util.List;

import es.dmoral.toasty.Toasty;


public class CameraActivity extends AppCompatActivity implements View.OnClickListener, OptionView.Callback {

    private final static CameraLogger LOG = CameraLogger.create("DemoApp");
    private final static boolean USE_FRAME_PROCESSOR = false;
    private final static boolean DECODE_BITMAP = true;

    private CameraView camera;
    private ViewGroup controlPanel;
    private ImageView light_button;
    /**
     * 整页拍
     */
    private TextView take_all;
    private TextView take_all_shape;
    /**
     * 单页拍
     */
    private TextView take_single;
    private TextView take_single_shape;
    /*记录选择了哪种收录方式*/
    private int COLLECTION_METHOD = 0; //默认整页收录
    //视频
    private VideoView videoPlayView;
    private ImageView demon_button;
    //视频背景框
    private View videoPlayBoxView;
    /*记录是否打开了拍照示范*/
    private int videoOpen = 0; //默认没有打开拍照示范

    private static final String VIDEO_FILE = "flutter_assets/assets/demon.mp4";

    private long mCaptureTime;
    private File outputFile;
    private int mCurrentFilter = 0;
    private final Filters[] mAllFilters = Filters.values();

    public static final String KEY_OUTPUT_FILE_PATH = "outputFilePath";
    private static final int PERMISSIONS_EXTERNAL_STORAGE = 801;
    public  static  final int REQUEST_CODE_PICK_IMAGE = 100;
    public  static  final int REQUEST_CODE_PICK_M = 101;



    @Override
    protected void onCreate(Bundle savedInstanceState) {

        super.onCreate(savedInstanceState);
        Log.i("CameraActivity","初始化：");
        String outputPath ="";
        if(getIntent()!= null && getIntent().getExtras() != null){
            outputPath = getIntent().getExtras().getString(KEY_OUTPUT_FILE_PATH,"");
        }
        if(outputPath.equals("") || outputPath == null){
            outputPath =  new File(this.getCacheDir(), "pic.jpg").getPath();
            Log.i("CameraActivity","使用默认地址："+outputPath);
        }
        if (outputPath != null) {
            Log.i("CameraActivity","使用地址："+outputPath);
            outputFile = new File(outputPath);
        }


        setContentView(R.layout.activity_camera);
        CameraLogger.setLogLevel(CameraLogger.LEVEL_VERBOSE);
        camera = findViewById(R.id.camera);

        camera.setLifecycleOwner(this);
        camera.addCameraListener(new Listener());
        if (USE_FRAME_PROCESSOR) {
            camera.addFrameProcessor(new FrameProcessor() {
                private long lastTime = System.currentTimeMillis();

                @Override
                public void process(@NonNull Frame frame) {
                    long newTime = frame.getTime();
                    long delay = newTime - lastTime;
                    lastTime = newTime;
                    LOG.e("Frame delayMillis:", delay, "FPS:", 1000 / delay);
                    if (DECODE_BITMAP) {
                        YuvImage yuvImage = new YuvImage(frame.getData(), ImageFormat.NV21,
                                frame.getSize().getWidth(),
                                frame.getSize().getHeight(),
                                null);
                        ByteArrayOutputStream jpegStream = new ByteArrayOutputStream();
                        yuvImage.compressToJpeg(new Rect(0, 0,
                                frame.getSize().getWidth(),
                                frame.getSize().getHeight()), 100, jpegStream);
                        byte[] jpegByteArray = jpegStream.toByteArray();
                        Bitmap bitmap = BitmapFactory.decodeByteArray(jpegByteArray, 0, jpegByteArray.length);
                        //noinspection ResultOfMethodCallIgnored
                        bitmap.toString();
                    }
                }
            });
        }

        //监听点击事件
        if (getIntent().getExtras().getBoolean("isSingle",false)) {
            findViewById(R.id.take_all_linear).setVisibility(View.INVISIBLE);
            findViewById(R.id.take_single_linear).setVisibility(View.INVISIBLE);
        }else{
            findViewById(R.id.take_all_linear).setOnClickListener(this);
            findViewById(R.id.take_single_linear).setOnClickListener(this);
        }

        demon_button = findViewById(R.id.demon_button);
        demon_button.setOnClickListener(this);
        findViewById(R.id.capturePictureSnapshot).setOnClickListener(this);
        findViewById(R.id.close_button).setOnClickListener(this);
        findViewById(R.id.album_button).setOnClickListener(this);
        light_button = findViewById(R.id.light_button);
        light_button.setOnClickListener(this);
//        findViewById(R.id.captureVideoSnapshot).setOnClickListener(this);
//        findViewById(R.id.toggleCamera).setOnClickListener(this);
//        findViewById(R.id.changeFilter).setOnClickListener(this);
        take_all = findViewById(R.id.take_all);
        take_all_shape = findViewById(R.id.take_all_shape);
        take_single = findViewById(R.id.take_single);
        take_single_shape = findViewById(R.id.take_single_shape);
        controlPanel = findViewById(R.id.controls);
        /*拍照示范背景框*/

//        videoPlayView = findViewById(R.id.video_play);
//        videoPlayBoxView = findViewById(R.id.video_play_box);
//        videoPlayView.setVisibility(View.INVISIBLE);
//        videoPlayBoxView.setVisibility(View.INVISIBLE);


        //处理入参
        int type = getIntent().getExtras().getInt("type",0);
        switchTake(type);
        String msg = getIntent().getExtras().getString("msg");
        if (null!=msg && !"".equals(msg)){
            Toasty.normal(this, msg).show();
        }
        ViewGroup group = (ViewGroup) controlPanel.getChildAt(0);
        camera.setOnTouchListener(takePictureSlideListen);
        List<Option<?>> options = Arrays.asList(
                // Layout
                new Option.Width(), new Option.Height(),
                // Engine and preview
                new Option.Mode(), new Option.Engine(), new Option.Preview(),
                // Some controls
                new Option.Flash(), new Option.WhiteBalance(), new Option.Hdr(),
                new Option.PictureMetering(), new Option.PictureSnapshotMetering(),
                // Video recording
                new Option.VideoCodec(), new Option.Audio(),
                // Gestures
                new Option.Pinch(), new Option.HorizontalScroll(), new Option.VerticalScroll(),
                new Option.Tap(), new Option.LongTap(),
                // Watermarks
//                new Option.OverlayInPreview(watermark),
//                new Option.OverlayInPictureSnapshot(watermark),
//                new Option.OverlayInVideoSnapshot(watermark),
                // Other
                new Option.Grid(), new Option.GridColor(), new Option.UseDeviceOrientation()
        );
        List<Boolean> dividers = Arrays.asList(
                false, true,
                false, false, true,
                false, false, false, false, true,
                false, true,
                false, false, false, false, true,
                false, false, true,
                false, false, true
        );
        for (int i = 0; i < options.size(); i++) {
            OptionView view = new OptionView(this);
            //noinspection unchecked
            view.setOption(options.get(i), this);
            view.setHasDivider(dividers.get(i));
            group.addView(view,
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.WRAP_CONTENT);
        }

        controlPanel.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
            @Override
            public void onGlobalLayout() {
                BottomSheetBehavior b = BottomSheetBehavior.from(controlPanel);
                b.setState(BottomSheetBehavior.STATE_HIDDEN);
            }
        });

        // Animate the watermark just to show we record the animation in video snapshots
//        ValueAnimator animator = ValueAnimator.ofFloat(1F, 0.8F);
//        animator.setDuration(300);
//        animator.setRepeatCount(ValueAnimator.INFINITE);
//        animator.setRepeatMode(ValueAnimator.REVERSE);
//        animator.addUpdateListener(new ValueAnimator.AnimatorUpdateListener() {
//            @Override
//            public void onAnimationUpdate(ValueAnimator animation) {
//                float scale = (float) animation.getAnimatedValue();
//                watermark.setScaleX(scale);
//                watermark.setScaleY(scale);
//                watermark.setRotation(watermark.getRotation() + 2);
//            }
//        });
//        animator.start();
    }

    float mPosX;
    float mPosY;
    float mCurPosX;
    float mCurPosY;
    //左右滑动选择
    private View.OnTouchListener takePictureSlideListen = new View.OnTouchListener() {
        @Override
        public boolean onTouch(View v, MotionEvent event) {
            // TODO Auto-generated method stub
            switch (event.getAction()) {
                case MotionEvent.ACTION_DOWN:
                    mPosX = event.getX();
                    mPosY = event.getY();
                    break;
                case MotionEvent.ACTION_MOVE:
                    mCurPosX = event.getX();
                    mCurPosY = event.getY();
                    break;
                case MotionEvent.ACTION_UP:
                    if (mCurPosX - mPosX > 0 && (Math.abs(mCurPosX - mPosX) > 25)) {
                        //向右滑動
                        switchTake(0);
                    } else if (mCurPosX - mPosX < 0 && (Math.abs(mCurPosX - mPosX) > 25)) {
                        //向左滑动
                        switchTake(1);
                    }
                    break;
            }
            return true;
        }
    };

    private void message(@NonNull String content, boolean important) {
        if (important) {
            LOG.w(content);
//            Toast.makeText(this, content, Toast.LENGTH_LONG).show();
        } else {
            LOG.i(content);
//            Toast.makeText(this, content, Toast.LENGTH_SHORT).show();
        }
    }

    private class Listener extends CameraListener {

        @Override
        public void onCameraOpened(@NonNull CameraOptions options) {
            ViewGroup group = (ViewGroup) controlPanel.getChildAt(0);
            for (int i = 0; i < group.getChildCount(); i++) {
                OptionView view = (OptionView) group.getChildAt(i);
                view.onCameraOpened(camera, options);
            }
        }

        @Override
        public void onCameraError(@NonNull CameraException exception) {
            super.onCameraError(exception);
            message("Got CameraException #" + exception.getReason(), true);
        }

        @Override
        public void onPictureTaken(@NonNull PictureResult result) {
            super.onPictureTaken(result);
            if (camera.isTakingVideo()) {
                message("Captured while taking video. Size=" + result.getSize(), false);
                return;
            }

            // This can happen if picture was taken with a gesture.
            long callbackTime = System.currentTimeMillis();
            if (mCaptureTime == 0) mCaptureTime = callbackTime - 300;
            LOG.w("onPictureTaken called! Launching activity. Delay:", callbackTime - mCaptureTime);
//            PicturePreviewActivity.setPictureResult(result);
//            Intent intent = new Intent(CameraActivity.this, PicturePreviewActivity.class);
//            intent.putExtra("delay", callbackTime - mCaptureTime);
//            startActivity(intent);
            mCaptureTime = 0;
            LOG.w("onPictureTaken called! Launched activity.");
            setResultCamera(result);
        }

        @Override
        public void onVideoTaken(@NonNull VideoResult result) {
            super.onVideoTaken(result);
            LOG.w("onVideoTaken called! Launching activity.");
//            VideoPreviewActivity.setVideoResult(result);
//            Intent intent = new Intent(CameraActivity.this, VideoPreviewActivity.class);
//            startActivity(intent);
            LOG.w("onVideoTaken called! Launched activity.");
        }

        @Override
        public void onVideoRecordingStart() {
            super.onVideoRecordingStart();
            LOG.w("onVideoRecordingStart!");
        }

        @Override
        public void onVideoRecordingEnd() {
            super.onVideoRecordingEnd();
            message("Video taken. Processing...", false);
            LOG.w("onVideoRecordingEnd!");
        }

        @Override
        public void onExposureCorrectionChanged(float newValue, @NonNull float[] bounds, @Nullable PointF[] fingers) {
            super.onExposureCorrectionChanged(newValue, bounds, fingers);
            message("Exposure correction:" + newValue, false);
        }

        @Override
        public void onZoomChanged(float newValue, @NonNull float[] bounds, @Nullable PointF[] fingers) {
            super.onZoomChanged(newValue, bounds, fingers);
            message("Zoom:" + newValue, false);
        }
    }

    @Override
    public void onClick(View view) {
        switch (view.getId()) {
//            case R.id.edit: edit(); break;
            case R.id.take_all_linear: take_all_linear(); break;
            case R.id.take_single_linear: take_single_linear(); break;
            case R.id.capturePictureSnapshot: capturePictureSnapshot(); break;
            case R.id.close_button: closeButton(); break;
            case R.id.light_button: light_button(); break;
            case R.id.album_button: album_button(); break;
            case R.id.demon_button: demon_button(); break;
//            case R.id.toggleCamera: toggleCamera(); break;
//            case R.id.changeFilter: changeCurrentFilter(); break;
        }
    }

    @Override
    public void onBackPressed() {
        BottomSheetBehavior b = BottomSheetBehavior.from(controlPanel);
        if (b.getState() != BottomSheetBehavior.STATE_HIDDEN) {
            b.setState(BottomSheetBehavior.STATE_HIDDEN);
            return;
        }
        super.onBackPressed();
    }

    private void edit() {
        BottomSheetBehavior b = BottomSheetBehavior.from(controlPanel);
        b.setState(BottomSheetBehavior.STATE_COLLAPSED);
    }

    private void capturePicture() {
        if (camera.getMode() == Mode.VIDEO) {
            message("Can't take HQ pictures while in VIDEO mode.", false);
            return;
        }
        if (camera.isTakingPicture()) return;
        mCaptureTime = System.currentTimeMillis();
        message("Capturing picture...", false);
        camera.takePicture();
    }

    private void capturePictureSnapshot() {
        if (camera.isTakingPicture()) return;
        if (camera.getPreview() != Preview.GL_SURFACE) {
            message("Picture snapshots are only allowed with the GL_SURFACE preview.", true);
            return;
        }
        mCaptureTime = System.currentTimeMillis();
        message("Capturing picture snapshot...", false);
        camera.takePictureSnapshot();
    }
    //关闭相机按钮
    private void closeButton(){
        //两种情况，一种是在没有打开拍照示范的时候，另一种是打开拍照示范的时候
        if(videoOpen == 1){
            videoOpen = 0;
            System.out.println("@关闭视频：");
//            videoPlayView.setVisibility(View.INVISIBLE);
//            videoPlayBoxView.setVisibility(View.INVISIBLE);
//            videoPlayView.stopPlayback();
        }else{
            System.out.println("@关闭总相机按钮：");
            closeCamera();
            setResult(Activity.RESULT_CANCELED);
            finish();
        }
    }
    private void closeCamera(){
        outputFile = null;
    }
    //手电筒按钮
    private void light_button(){
        System.out.println("@手电筒按钮：");
        Flash flashMode = camera.getFlash();
        if (flashMode == Flash.TORCH) {
            camera.setFlash(Flash.OFF);
        }else{
            camera.setFlash(Flash.TORCH);
        }
        updateFlashMode();
    }

    //打开图库
    private void album_button(){
        if (ActivityCompat.checkSelfPermission(getApplicationContext(), Manifest.permission.READ_EXTERNAL_STORAGE)
                != PackageManager.PERMISSION_GRANTED) {
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN) {
                ActivityCompat.requestPermissions(CameraActivity.this,
                        new String[] {Manifest.permission.READ_EXTERNAL_STORAGE},
                        PERMISSIONS_EXTERNAL_STORAGE);
                return;
            }
        }
        Intent intent = new Intent(Intent.ACTION_PICK);
        intent.setType("image/*");
        startActivityForResult(intent, REQUEST_CODE_PICK_IMAGE);
    }

    //拍照示例
    private void demon_button(){
        Intent camera = new Intent(this, VideoShowActivity.class);
        startActivityForResult(camera,REQUEST_CODE_PICK_M);
//       message("拍照示例",false);
//        videoOpen = 1;
//        videoPlayView.setVisibility(View.VISIBLE);
//        videoPlayBoxView.setVisibility(View.VISIBLE);
//        // 加载视屏
//        String videoUrl = "android.resource://" + getPackageName() + "/" + R.raw.demo;
//        //设置视频控制器
//        videoPlayView.setMediaController(new MediaController(this));
//        //播放完成回调
//        //videoView.setOnCompletionListener(new MyPlayerOnCompletionListener());
//        //设置视频路径
//        videoPlayView.setVideoPath(videoUrl);
//        //开始播放视频
//        videoPlayView.start();
    }

    //整页拍
    private void take_all_linear(){
        switchTake(0);
    }
    //单页拍
    private void take_single_linear(){
        switchTake(1);
    }
    private boolean toastFlag = true;
    private void switchTake(int model){
        if(model==0 && COLLECTION_METHOD!=0){
            if (toastFlag){
                Toasty.normal(this, "请拍下试卷的标题").show();
                toastFlag = false;
            }
            COLLECTION_METHOD = 0;
            System.out.println("@点击整页拍：");
            System.out.println(COLLECTION_METHOD);
            take_all.setTextColor(0xFF3BBBF5);
            take_single.setTextColor(0xFF666666);
            take_all_shape.setEnabled(true);
            take_single_shape.setEnabled(false);
            demon_button.setVisibility(View.VISIBLE);
        }else if(model==1&& COLLECTION_METHOD!=1){
            COLLECTION_METHOD = 1;
            System.out.println("@点击单页拍：");
            System.out.println(COLLECTION_METHOD);
            take_all.setTextColor(0xFF666666);
            take_single.setTextColor(0xFF3BBBF5);
            take_all_shape.setEnabled(false);
            take_single_shape.setEnabled(true);
            demon_button.setVisibility(View.INVISIBLE);
        }
    }
    @Override
    protected void onStop() {
        super.onStop();
        camera.setFlash(Flash.OFF);
    }

    // 拍完照后将灯光关闭;
    private void updateFlashMode() {
        Flash flashMode = camera.getFlash();
        if (flashMode == Flash.TORCH) {
             light_button.setImageResource(R.drawable.bd_ocr_light_on);
        } else {
            light_button.setImageResource(R.drawable.bd_ocr_light_off);
        }
    }

    private void changeCurrentFilter() {
        if (camera.getPreview() != Preview.GL_SURFACE) {
            message("Filters are supported only when preview is Preview.GL_SURFACE.", true);
            return;
        }
        if (mCurrentFilter < mAllFilters.length - 1) {
            mCurrentFilter++;
        } else {
            mCurrentFilter = 0;
        }
        Filters filter = mAllFilters[mCurrentFilter];
        camera.setFilter(filter.newInstance());
        message(filter.toString(), false);

        // To test MultiFilter:
        // DuotoneFilter duotone = new DuotoneFilter();
        // duotone.setFirstColor(Color.RED);
        // duotone.setSecondColor(Color.GREEN);
        // camera.setFilter(new MultiFilter(duotone, filter.newInstance()));
    }

    @Override
    public <T> boolean onValueChanged(@NonNull Option<T> option, @NonNull T value, @NonNull String name) {
        if ((option instanceof Option.Width || option instanceof Option.Height)) {
            Preview preview = camera.getPreview();
            boolean wrapContent = (Integer) value == ViewGroup.LayoutParams.WRAP_CONTENT;
            if (preview == Preview.SURFACE && !wrapContent) {
                message("The SurfaceView preview does not support width or height changes. " +
                        "The view will act as WRAP_CONTENT by default.", true);
                return false;
            }
        }
        option.set(camera, value);
        BottomSheetBehavior b = BottomSheetBehavior.from(controlPanel);
        b.setState(BottomSheetBehavior.STATE_HIDDEN);
        message("Changed " + option.getName() + " to " + name, false);
        return true;
    }

    //region Permissions

    @Override
    public void onRequestPermissionsResult(int requestCode, @NonNull String[] permissions, @NonNull int[] grantResults) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults);
        boolean valid = true;
        for (int grantResult : grantResults) {
            valid = valid && grantResult == PackageManager.PERMISSION_GRANTED;
        }
        if (valid && !camera.isOpened()) {
            camera.open();
        }
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        /*相册回调*/
        if (requestCode == REQUEST_CODE_PICK_IMAGE && resultCode == Activity.RESULT_OK) {
            Uri uri = data.getData();
            Intent result = new Intent();
            result.putExtra("data", getRealPathFromURI(uri));
            result.putExtra("type",COLLECTION_METHOD);
            setResult(RESULT_OK,result);
            finish();
        }
    }

    protected void setResultCamera(PictureResult result) {
        result.toFile(outputFile, new FileCallback() {
            @Override
            public void onFileReady(@Nullable File file) {
                message("onFileReady:"+file.getAbsolutePath(),false);
                Intent data = new Intent();
                data.putExtra("data", file.getAbsolutePath());
                data.putExtra("type",COLLECTION_METHOD);
                setResult(RESULT_OK, data);
                finish();
            }
        });
    }

    private String getRealPathFromURI(Uri contentURI) {
        String result;
        Cursor cursor = this.getContentResolver().query(contentURI, null, null, null, null);
        if (cursor == null) {
            result = contentURI.getPath();
        } else {
            cursor.moveToFirst();
            int idx = cursor.getColumnIndex(MediaStore.Images.ImageColumns.DATA);
            result = cursor.getString(idx);
            cursor.close();
        }
        return result;
    }
}
