class Application{
  final String version;
  final bool canUpdate;
  final int showBanner;
  final int showCoachBanner;
  final int showRewardBanner;
  final int showH5Banner;
  final String minAndroidVersion;
  final String minIosVersion;
  Application({this.version,this.canUpdate,this.showBanner,this.showCoachBanner,this.showRewardBanner,this.showH5Banner,this.minAndroidVersion,this.minIosVersion});

  factory Application.initial() {
    return Application(
      version: "",
      canUpdate:false,
      showBanner:0,
      showCoachBanner:0,
      showRewardBanner:0,
      showH5Banner:0,
      minAndroidVersion:"",
      minIosVersion:""
    );
  }

  Application copyWith({String version,bool canUpdate,int showBanner,int showCoachBanner,int showRewardBanner,int showH5Banner,String minAndroidVersion,String minIosVersion}) {
    return Application(
      version: version ?? this.version,
      canUpdate:canUpdate??this.canUpdate,
      showBanner:showBanner??this.showBanner,
      showCoachBanner:showCoachBanner??this.showCoachBanner,
      showRewardBanner:showRewardBanner??this.showRewardBanner,
      showH5Banner:showH5Banner??this.showH5Banner,
      minAndroidVersion:minAndroidVersion??this.minAndroidVersion,
      minIosVersion:minIosVersion??this.minIosVersion
    );
  }
}