package com.yondor.yondor_whiteboard;

import android.content.Context;
import android.os.Looper;
import android.text.TextUtils;
import android.view.View;
import android.os.Handler;
import androidx.annotation.NonNull;

import com.google.gson.Gson;
import com.herewhite.sdk.AbstractPlayerEventListener;
import com.herewhite.sdk.Player;
import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.WhiteboardView;
import com.herewhite.sdk.domain.MemberState;
import com.herewhite.sdk.domain.PlayerConfiguration;
import com.herewhite.sdk.domain.PlayerObserverMode;
import com.herewhite.sdk.domain.PlayerPhase;
import com.herewhite.sdk.domain.PlayerState;
import com.herewhite.sdk.domain.Promise;
import com.herewhite.sdk.domain.RoomPhase;
import com.herewhite.sdk.domain.SDKError;
import com.herewhite.sdk.domain.SceneState;
import com.yondor.yondor_whiteboard.listener.BoardEventListener;
import com.yondor.yondor_whiteboard.manager.BoardManager;
import com.yondor.yondor_whiteboard.manager.LogManager;

import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.TimeUnit;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.platform.PlatformView;

class MyWhiteboardView implements PlatformView, BoardEventListener, MethodCallHandler {

    private final LogManager log = new LogManager(this.getClass().getSimpleName());

    private final long uid;
    private final WhiteboardView whiteboardView;
    private Context context;
    private WhiteSdk whiteSdk;
    private BoardManager boardManager = new BoardManager();
    private String uuid;
    private String roomToken;
    private String appIdentifier;
    private MethodChannel methodChannel;
    private Gson gson = new Gson();
    private int isReplay = 0;
    private Player player;
    private Handler handler;
    MyWhiteboardView(Context context, BinaryMessenger messenger, long uid, Map<String, Object> params) {
        handler = new Handler(Looper.getMainLooper());
        methodChannel = new MethodChannel(messenger, "com.yondor.live/whiteboard_" + uid);
        methodChannel.setMethodCallHandler(this);

        this.uid = uid;
        if(params.containsKey("uuid")){
            uuid = (String)params.get("uuid");
        }
        if(params.containsKey("roomToken")){
            roomToken = (String)params.get("roomToken");
        }
        if(params.containsKey("appIdentifier")){
            appIdentifier = (String)params.get("appIdentifier");
        }
        if(params.containsKey("isReplay")){
            isReplay = (int)params.get("isReplay");
        }
        this.context = context;
        whiteboardView = new WhiteboardView(context);
        whiteboardView.setBackgroundColor(0x00000000);
        init();
        if (isReplay ==1){
            Map<String, Object> map = new HashMap<>();
            map.put("created", true);
            methodChannel.invokeMethod("onCreated",map);
        }else{
            initView();
        }

    }

    @Override
    public View getView() {
        return whiteboardView;
    }

    @Override
    public void dispose() {
        releaseBoard();
    }
    private void init(){
        WhiteSdkConfiguration configuration = new WhiteSdkConfiguration(appIdentifier);
//        configuration.setDisableDeviceInputs(true);
        whiteSdk = new WhiteSdk(whiteboardView, context, configuration);
        boardManager.setListener(this);
//        whiteboardView.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> {
//            boardManager.refreshViewSize();
//        });
    }
    private void initView(){
        initBoardWithRoomToken(uuid,roomToken);
//        boardManager.setViewMode(ViewMode.Follower);
        disableDeviceInputs(true);
        setWritable(false);
        disableCameraTransform(true);
    }

    public void initBoardWithRoomToken(String uuid, String roomToken) {
        if (TextUtils.isEmpty(uuid) || TextUtils.isEmpty(roomToken)) return;
        boardManager.getRoomPhase(new Promise<RoomPhase>() {
            @Override
            public void then(RoomPhase phase) {
                if (phase != RoomPhase.connected) {
                    Map<String, Object> map = new HashMap<>();
                    map.put("created", true);
                    methodChannel.invokeMethod("onCreated",map);
                    RoomParams params = new RoomParams(uuid, roomToken);
                    params.setTimeout(2,TimeUnit.HOURS);
                    boardManager.init(whiteSdk, params);
                }
            }

            @Override
            public void catchEx(SDKError t) {
                log.e("初始化错误",t.getMessage());
                initView();
//                ToastManager.showShort(t.getMessage());
            }
        });
    }
    @Override
    public void onRoomPhaseChanged(RoomPhase phase) {
        log.i("onRoomPhaseChanged %s",phase.name());
    }

    @Override
    public void onSceneStateChanged(SceneState state) {
        log.i("onSceneStateChanged %d",state.getIndex());
    }

    @Override
    public void onMemberStateChanged(MemberState state) {
        log.i("onMemberStateChanged %s",state.getCurrentApplianceName());
    }

    public void setWritable(boolean writable) {
        boardManager.setWritable(writable);
    }
    public void releaseBoard() {
         log.i("releaseBoard ");
        boardManager.disconnect();
    }

    public void disableDeviceInputs(boolean disabled) {
//        if (disabled != boardManager.isDisableDeviceInputs()) {
//            ToastManager.showShort(disabled ? R.string.revoke_board : R.string.authorize_board);
//        }
//        if (appliance_view != null) {
//            appliance_view.setVisibility(disabled ? View.GONE : View.VISIBLE);
//        }
        boardManager.disableDeviceInputs(disabled);
    }
    public void disableCameraTransform(boolean disabled) {
        if (disabled != boardManager.isDisableCameraTransform()) {
            if (disabled) {
//                ToastManager.showShort("老师正在控制白板，请勿书写");
                boardManager.disableDeviceInputsTemporary(true);
            } else {
                boardManager.disableDeviceInputsTemporary(boardManager.isDisableDeviceInputs());
            }
        }
        boardManager.disableCameraTransform(disabled);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        switch (call.method) {
            case "updateRoom":
                updateRoom(call,result);
                break;
            case "setWritable":
                Map<String, Object> writableRequest = (Map<String, Object>) call.arguments;
                int isWritable = (int) writableRequest.get("isWritable");
                boolean canWrite = isWritable==1;
                setWritable(canWrite);
                disableDeviceInputs(!canWrite);
                result.success(null);
                break;
            case "start":
                startReplay(call,result);
                result.success(null);
                break;
            case "pause":
                pause();
                result.success(null);
                break;
            case "play":
                play();
                result.success(null);
                break;
            case "replay":
                replay();
                result.success(null);
                break;
            case "seekToScheduleTime":
                Map<String, Object> request = (Map<String, Object>) call.arguments;
                Long time = Long.parseLong((String) request.get("data"));
                seekToScheduleTime(time);
                result.success(null);
                break;
            default:
                result.notImplemented();
        }
    }
    private void updateRoom(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Map<String, Object> request = (Map<String, Object>) call.arguments;
        if(request.containsKey("isBoardLock")){
            int isBoardLock = (int) request.get("isBoardLock");
            disableCameraTransform(isBoardLock==1);
        }
        result.success("");
    }

    private void startReplay(MethodCall call,  MethodChannel.Result result){
        Map<String, Object> request = (Map<String, Object>) call.arguments;

        Long beginTimestamp = Long.parseLong((String) request.get("beginTimestamp"));
        Long  duration = Long.parseLong((String) request.get("duration"));
        String mediaUrl = (String)request.get("mediaURL");
        PlayerConfiguration playerConfiguration = new PlayerConfiguration(uuid, roomToken);
        playerConfiguration.setBeginTimestamp(beginTimestamp);
//        playerConfiguration.setMediaURL(mediaUrl);
        playerConfiguration.setDuration(duration);

        whiteSdk.createPlayer(playerConfiguration, new AbstractPlayerEventListener() {
            // 以下为房间状态回调，可以查看 [状态管理] 文档

            //播放状态切换回调
            @Override
            public void onPhaseChanged(PlayerPhase phase) {
                log.i("onPhaseChanged %s",gson.toJson(phase));
                replayOnPhaseChanged(phase);
            }
            //首帧加载回调
            @Override
            public void onLoadFirstFrame() {
                log.i("onLoadFirstFrame");
            }
            // 分片切换回调，需要了解分片机制。目前无实际用途
            @Override
            public void onSliceChanged(String slice) {
                log.i("slice %s",slice);
            }
            //播放中，状态出现变化的回调
            @Override
            public void onPlayerStateChanged(PlayerState modifyState) {
                log.i("onPlayerStateChanged %s",gson.toJson(modifyState));
            }
            //出错暂停
            @Override
            public void onStoppedWithError(SDKError error) {
                log.i("onStoppedWithError %s",error.getJsStack());
            }
            //进度时间变化
            @Override
            public void onScheduleTimeChanged(long time) {
                log.i("onScheduleTimeChanged %d",time);
                replayOnScheduleTimeChanged(time);
            }
            //添加帧出错
            @Override
            public void onCatchErrorWhenAppendFrame(SDKError error) {
                log.i("onCatchErrorWhenAppendFrame %s",error.getJsStack());
            }
            //渲染时，出错
            @Override
            public void onCatchErrorWhenRender(SDKError error) {
                log.i("onCatchErrorWhenRender %s",error.getJsStack());
            }
        }, new Promise<Player>() {
            @Override
            public void then(Player p) {
                log.i("then player");
//                p.setObserverMode(PlayerObserverMode.directory);
                player = p;
                play();
            }

            @Override
            public void catchEx(SDKError t) {
                log.e("create player error, ", t);
            }
        });
    }


    //开始播放
    private void play(){
        if (this.player==null){
            Map<String, Object> map = new HashMap<>();
            map.put("data", "player is null");
            postMsg("error",map);
            return;
        }

        this.player.play();
    }

    private void pause(){
        if (this.player==null){
            Map<String, Object> map = new HashMap<>();
            map.put("data", "player is null");
            postMsg("error",map);
            return;
        }
        this.player.pause();
    }
    //重新播放
    private void replay(){
        if (this.player==null){
            Map<String, Object> map = new HashMap<>();
            map.put("data", "player is null");
            postMsg("error",map);
            return;
        }
        this.player.seekToScheduleTime(0);
        this.player.play();
    }

    //状态变化
    private void replayOnPhaseChanged(PlayerPhase phase){
        if (this.player==null){
            Map<String, Object> map = new HashMap<>();
            map.put("data", "player is null");
            postMsg("error",map);
            return;
        }
        Map<String, Object> map = new HashMap<>();
        map.put("data", phase.name().toString());
        postMsg("onPhaseChanged",map);
    }
    //时间变化
    private void replayOnScheduleTimeChanged(long time){
        if (this.player==null){
            Map<String, Object> map = new HashMap<>();
            map.put("data", "player is null");
            postMsg("error",map);
            return;
        }
        Map<String, Object> map = new HashMap<>();
        map.put("data", time);
        postMsg("onScheduleTimeChanged",map);
    }
    private void seekToScheduleTime(long seekTime){
        if (this.player==null){
            Map<String, Object> map = new HashMap<>();
            map.put("data", "player is null");
            postMsg("error",map);
            return;
        }
        this.player.seekToScheduleTime(seekTime);
    }
    private void postMsg(String method,Map<String, Object> map){
        handler.post(new Runnable() {
            @Override
            public void run() {
                methodChannel.invokeMethod(method,map);
            }
        });
    }
}
