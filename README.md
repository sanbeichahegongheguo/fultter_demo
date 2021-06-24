DEBUG:
cmd执行
flutter  build apk --debug --target-platform=android-arm

Release-正式版打包:
cmd执行
flutter build apk --no-shrink

```
目录结构:
├── android    //安卓目录
├── assets     //静态资源
├── build      //编译目录
├── images     //图片资源
├── ios        //ios目录
├── lib
│         ├── bloc                              //bloc状态管理类
│         ├── common                            //公共工具类/配置类
│         │         ├── channel                 //与原生通讯
│         │         ├── config                  //配置类（DUBUG日志日否开启）
│         │         ├── const                   //常量类
│         │         ├── dao                     //http请求类
│         │         ├── event                   //自定义通讯
│         │         ├── local                   //历史账号存储类
│         │         ├── net                     //dio封装
│         │         ├── redux                   //工程使用的redux状态管理
│         │         └── utils                   //工具类
│         ├── main.dart                         //主入口
│         ├── models                            //结构体类
│         ├── page                              //页面
│         ├── provider                          //provider状态管理类
│         └── widget                            //小组件存放目录
├── plugins                                     //插件功能不完善，修改过的插件
│         ├── agora_rtc_engine-1.0.15           //声网（主要改变声网SDK版本号为教育专用版）
│         ├── better_socket-1.1.4               //socket链接（修复bug）
│         ├── device_info                       //设备信息（增加远大统计需要的信息）
│         ├── flutter_audio_recorder-0.5.5      //声音录制
│         ├── flutter_inapp_purchase-2.2.0      //IOS内购支付
│         ├── flutter_native_image              //压缩图像（修复bug）
│         ├── flutter_webview_plugin-0.3.11     //webview（完善功能使支持正常使用）
│         ├── tencent_cos                       //腾讯cos上传功能
│         ├── webview_flutter                   //已经遗弃
│         ├── webview_flutter_plus-0.1.1+9      //修复BUG
│         └── yondor_whiteboard                 //直播平台白板接入
├── pubspec.lock                                //flutter版本管理
├── pubspec.yaml                                //flutter版本管理
└── test
```
