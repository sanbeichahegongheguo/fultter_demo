package com.yondor.yondor_whiteboard.manager;

import android.os.Handler;
import android.os.Looper;

import com.herewhite.sdk.Room;
import com.herewhite.sdk.RoomCallbacks;
import com.herewhite.sdk.RoomParams;
import com.herewhite.sdk.WhiteSdk;
import com.herewhite.sdk.domain.BroadcastState;
import com.herewhite.sdk.domain.MemberState;
import com.herewhite.sdk.domain.Promise;
import com.herewhite.sdk.domain.RoomPhase;
import com.herewhite.sdk.domain.RoomState;
import com.herewhite.sdk.domain.SDKError;
import com.herewhite.sdk.domain.SceneState;
import com.herewhite.sdk.domain.ViewMode;
import com.yondor.yondor_whiteboard.annotation.Appliance;
import com.yondor.yondor_whiteboard.listener.BoardEventListener;

import org.jetbrains.annotations.NotNull;


public class BoardManager extends NetlessManager<Room> implements RoomCallbacks {

    private final LogManager log = new LogManager(this.getClass().getSimpleName());

    private String appliance;
    private int[] strokeColor;
    private Boolean disableDeviceInputs;
    private Boolean disableCameraTransform;
    private Boolean writable;
    private ViewMode viewMode;
    private long canUndoSteps = 0;
    private Handler handler = new Handler(Looper.getMainLooper());
    private BoardEventListener listener;

    public void setListener(BoardEventListener listener) {
        this.listener = listener;
    }

    public void init(WhiteSdk sdk, RoomParams params) {
        log.d("init");
        sdk.joinRoom(params, this, promise);
    }

    public void setAppliance(@Appliance String appliance) {
        if (t != null) {
            MemberState state = new MemberState();
            state.setCurrentApplianceName(appliance);
            t.setMemberState(state);
        } else {
            this.appliance = appliance;
        }
    }

    public void undo() {
        if (t != null) {
//            if(canUndoSteps>0){
                t.undo();
//            }
        }
    }

    public String getAppliance() {
        if (t != null) {
            return t.getMemberState().getCurrentApplianceName();
        }
        return null;
    }

    public void setStrokeColor(int[] color) {
        if (t != null) {
            MemberState state = new MemberState();
            state.setStrokeColor(color);
            t.setMemberState(state);
        } else {
            this.strokeColor = color;
        }
    }

    public int[] getStrokeColor() {
        if (t != null) {
            t.getMemberState().getStrokeColor();
        }
        return null;
    }

    public void setSceneIndex(int index) {
        if (t != null && !isDisableDeviceInputs()) {
            t.setSceneIndex(index, new Promise<Boolean>() {
                @Override
                public void then(Boolean aBoolean) {
                }

                @Override
                public void catchEx(SDKError t) {
                }
            });
        }
    }

    public int getSceneCount() {
        if (t != null) {
            return t.getScenes().length;
        }
        return 0;
    }

    public void pptPreviousStep() {
        if (t != null && !isDisableDeviceInputs()) {
            t.pptPreviousStep();
        }
    }

    public void pptNextStep() {
        if (t != null && !isDisableDeviceInputs()) {
            t.pptNextStep();
        }
    }

    public void getRoomPhase(Promise<RoomPhase> promise) {
        if (t != null) {
            t.getRoomPhase(promise);
        } else {
            if (promise != null) {
                promise.then(RoomPhase.disconnected);
            }
        }
    }

    public void refreshViewSize() {
        if (t != null) {
            t.refreshViewSize();
        }
    }

    public void disableDeviceInputs(boolean disabled) {
        if (t != null) {
            t.disableDeviceInputs(disabled);
        }
        disableDeviceInputs = disabled;
    }

    public void disableDeviceInputsTemporary(boolean disabled) {
        if (t != null) {
                t.disableDeviceInputs(disabled);
        }
    }

    public boolean isDisableDeviceInputs() {
        return disableDeviceInputs == null ? false : disableDeviceInputs;
    }

    public void disableCameraTransform(boolean disabled) {
        if (t != null) {
            t.disableCameraTransform(disabled);
        }
        disableCameraTransform = disabled;
    }

    public boolean isDisableCameraTransform() {
        return disableCameraTransform == null ? false : disableCameraTransform;
    }

    public void setWritable(boolean writable) {
        if (t != null) {
            t.setWritable(writable, new Promise<Boolean>() {
                @Override
                public void then(Boolean aBoolean) {
                }

                @Override
                public void catchEx(SDKError t) {
                }
            });
        }
        this.writable = writable;
    }

    public void disconnect() {
        if (t != null) {
            t.disconnect();
        }
    }

    @Override
    public void onPhaseChanged(RoomPhase phase) {
        if (listener != null) {
            handler.post(() -> listener.onRoomPhaseChanged(phase));
        }
    }


    @Override
    public void onDisconnectWithError(@NotNull Exception e) {
        e.printStackTrace();
        log.e("onDisconnectWithError %s", e.toString());
        handler.post(() -> listener.onRoomPhaseChanged(RoomPhase.disconnected));
    }

    @Override
    public void onKickedWithReason(String reason) {
        log.i("onKickedWithReason %s", reason);
        handler.post(() -> listener.onRoomPhaseChanged(RoomPhase.disconnected));
    }


    public void setViewMode(ViewMode viewMode) {
        if (t != null) {
            t.setViewMode(viewMode);
        }
        this.viewMode = viewMode;
    }

    @Override
    public void onRoomStateChanged(RoomState modifyState) {
        if (listener != null) {
            MemberState memberState = modifyState.getMemberState();
            if (memberState != null) {
                handler.post(() -> listener.onMemberStateChanged(memberState));
            }
            SceneState sceneState = modifyState.getSceneState();
            if (sceneState != null) {
                handler.post(() -> listener.onSceneStateChanged(sceneState));
            }
            BroadcastState broadcastState = modifyState.getBroadcastState();
            if (broadcastState!=null){
                handler.post(() -> listener.onBroadcastStateChanged(broadcastState));
            }
        }
    }

    @Override
    public void onCanUndoStepsUpdate(long canUndoSteps) {
        this.canUndoSteps = canUndoSteps;
        log.i("onCanUndoStepsUpdate %d", canUndoSteps);
    }

    @Override
    public void onCanRedoStepsUpdate(long canRedoSteps) {
        log.i("onCanRedoStepsUpdate %d", canRedoSteps);
    }

    @Override
    public void onCatchErrorWhenAppendFrame(long userId, Exception error) {
        log.e("onCatchErrorWhenAppendFrame userId %d %s", userId,error.toString());
    }

    @Override
    void onSuccess(Room room) {
        log.i("onSuccess");
        this.canUndoSteps = 0;
        if (appliance != null) {
            setAppliance(appliance);
        }
        if (strokeColor != null) {
            setStrokeColor(strokeColor);
        }
        if (disableDeviceInputs != null) {
            disableDeviceInputs(disableDeviceInputs);
        }
        if (disableCameraTransform != null) {
            disableCameraTransform(disableCameraTransform);
        }
        if (writable != null) {
            setWritable(writable);
        }
        if (listener != null) {
            listener.onSceneStateChanged(room.getSceneState());
        }
        if (viewMode !=null ){
            setViewMode(viewMode);
        }
        setDisableSerialization(false);
    }

    /**
     * 是否禁止如下方法（默认值是 true）。可修改。
     * room.redo
     * room.undo
     * room.duplicate
     * room.copy
     * room.paste
     * @param disableSerialization
     */
    public void setDisableSerialization(boolean disableSerialization) {
        if (t != null) {
            log.i("setDisableSerialization %b", disableSerialization);
            t.disableSerialization(disableSerialization);
        }
    }

    @Override
    void onFail(SDKError error) {
        log.e("onFail %s", error.toString());
    }

}
