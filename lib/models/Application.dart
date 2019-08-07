class Application{
  final String version;
  final bool canUpdate;
  Application({this.version,this.canUpdate});

  factory Application.initial() {
    return Application(
      version: "",
      canUpdate:false,
    );
  }

  Application copyWith({String version,bool canUpdate}) {
    return Application(
      version: version ?? this.version,
      canUpdate:canUpdate??this.canUpdate,
    );
  }
}