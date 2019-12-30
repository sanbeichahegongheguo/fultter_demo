package com.leo.flutterstart;

import android.media.MediaPlayer;
import android.net.Uri;
import android.os.Bundle;
import android.view.View;
import android.widget.MediaController;
import android.widget.VideoView;

import androidx.annotation.Nullable;
import androidx.appcompat.app.AppCompatActivity;

public class VideoShowActivity extends AppCompatActivity {
    //视频背景框
    private View videoPlayBoxView;
    //视频
    private VideoView videoPlayView;
    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.video);
        videoPlayBoxView = findViewById(R.id.video_play_box);
        videoPlayView = findViewById(R.id.video_play);
        findViewById(R.id.close_button).setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                finish();
            }
        });
        setupVideo();
    }
    private void setupVideo() {



        videoPlayView.setOnPreparedListener(new MediaPlayer.OnPreparedListener() {
            @Override
            public void onPrepared(MediaPlayer mp) {
                videoPlayView.start();
            }
        });
        videoPlayView.setOnCompletionListener(new MediaPlayer.OnCompletionListener() {
            @Override
            public void onCompletion(MediaPlayer mp) {
                stopPlaybackVideo();
            }
        });
        videoPlayView.setOnErrorListener(new MediaPlayer.OnErrorListener() {
            @Override
            public boolean onError(MediaPlayer mp, int what, int extra) {
                stopPlaybackVideo();
                return true;
            }
        });

        try {
            String videoUrl = "android.resource://" + getPackageName() + "/" + R.raw.demo;
            //设置视频控制器
            videoPlayView.setMediaController(new MediaController(this));
            //播放完成回调
            //videoView.setOnCompletionListener(new MyPlayerOnCompletionListener());
            //设置视频路径
            videoPlayView.setVideoPath(videoUrl);
            videoPlayView.start();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @Override
    protected void onResume() {
        super.onResume();
        if (!videoPlayView.isPlaying()) {
            videoPlayView.resume();
        }
    }

    @Override
    protected void onPause() {
        super.onPause();
        if (videoPlayView.canPause()) {
            videoPlayView.pause();
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        stopPlaybackVideo();
    }

    private void stopPlaybackVideo() {
        try {
            videoPlayView.stopPlayback();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

}
