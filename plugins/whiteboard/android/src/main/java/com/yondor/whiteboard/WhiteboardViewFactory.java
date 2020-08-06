package com.yondor.whiteboard;

import android.app.Activity;
import android.content.Context;

import java.util.Map;

import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;

class WhiteboardViewFactory extends PlatformViewFactory {
    final private BinaryMessenger messenger;
    /**
     * @param createArgsCodec the codec used to decode the args parameter of {@link #create}.
     * @param messenger
     */
    public WhiteboardViewFactory(MessageCodec<Object> createArgsCodec, BinaryMessenger messenger) {
        super(createArgsCodec);
        this.messenger = messenger;
    }

    @Override
    public PlatformView create(Context context, int viewId, Object args) {
        Map<String, Object> params = (Map<String, Object>) args;
        return new MyWhiteboardView(context,messenger,viewId,params);
    }
}
