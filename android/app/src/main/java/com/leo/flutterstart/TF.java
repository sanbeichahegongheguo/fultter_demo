package com.leo.flutterstart;

public class TF {
	public static final String MODEL = "file:///android_asset/mnist.pb";
    public static final String YD_MODEL = "file:///android_asset/20190118v4.pb";

    public static final String YD_MODEL_LITE = "flutter_assets/assets/model.tflite";
    public static final int MNIST_SIZE = 28;
    public static final int DRAW_SIZE = 56;
	public static final int DRAW_FULL_SIZE = 224;

    public static final int THICKNESS = 20;
    public static final int DRAW_THICKNESS = 1;

    public static final int[] INPUT_TYPE = new int[]{1, 28 * 28};
    public static final int[] INPUT_TYPE2 = new int[]{1, 28 , 28, 1};
    public static final String INPUT_NAME = "input";
    public static final String YD_INPUT_NAME = "conv2d_1_input";
    public static final String KEEP_PROB_NAME = "keep_prob";
    public static final String OUTPUT_NAME = "dense_3/Softmax";

}
