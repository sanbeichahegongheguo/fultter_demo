package com.yondor.yondor_whiteboard;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;

import androidx.annotation.NonNull;

import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.WhiteSdkConfiguration;
import com.herewhite.sdk.WhiteboardView;
import com.herewhite.sdk.domain.MemberState;
import com.herewhite.sdk.domain.Promise;
import com.herewhite.sdk.domain.RoomPhase;
import com.herewhite.sdk.domain.SDKError;
import com.herewhite.sdk.domain.SceneState;
import com.yondor.whiteboard.listener.BoardEventListener;
import com.yondor.whiteboard.manager.BoardManager;
import com.yondor.whiteboard.manager.LogManager;

import java.util.Map;

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
    private final MethodChannel methodChannel;

    MyWhiteboardView(Context context, BinaryMessenger messenger, long uid, Map<String, Object> params) {
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
        this.context = context;
        whiteboardView = new WhiteboardView(context);
        whiteboardView.setBackgroundColor(0x00000000);
        init();
        initView();
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
        whiteSdk = new WhiteSdk(whiteboardView, context, configuration);
        boardManager.setListener(this);
    }
    private void initView(){
        whiteboardView.addOnLayoutChangeListener((v, left, top, right, bottom, oldLeft, oldTop, oldRight, oldBottom) -> {
            boardManager.refreshViewSize();
        });
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
//                    pb_loading.setVisibility(View.VISIBLE);
                    RoomParams params = new RoomParams(uuid, roomToken);
                    boardManager.init(whiteSdk, params);
                }
            }

            @Override
            public void catchEx(SDKError t) {
                log.e(t.getMessage());
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
}
