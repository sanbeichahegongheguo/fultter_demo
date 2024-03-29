import 'AdBloc.dart';
import 'AdminBloc.dart';
import 'BlocBase.dart';
import 'CoachBloc.dart';
import 'LearningEmotionBloc.dart';
import 'ModuleBloc.dart';
import 'ParentRewardBloc.dart';
import 'TabbarBloc.dart';

class HomeBloc extends BlocBase {

  ///模块
  final ModuleBloc moduleBloc = new ModuleBloc();
  final ModuleBloc jzModuleBloc = new ModuleBloc();
  final ModuleBloc xqModuleBloc = new ModuleBloc();
  final ModuleBloc parentModuleBloc = new ModuleBloc();
  final ModuleBloc studyModuleBloc = new ModuleBloc();
  ///广告
  final AdBloc adBloc = new AdBloc();
  ///学情
  final LearningEmotionBloc  learningEmotionBloc = new LearningEmotionBloc();
  ///家长奖励
  final ParentRewardBloc parentRewardBloc = new ParentRewardBloc();
  ///辅导页面（公告）
  final CoachBloc coachBloc = new CoachBloc();
  ///新版学情

  final TabbarBloc tabbarBloc = TabbarBloc();
  final AdminBloc adminBloc = new AdminBloc();
  @override
  void dispose() {
    moduleBloc?.dispose();
    jzModuleBloc?.dispose();
    adBloc?.dispose();
    xqModuleBloc?.dispose();
    learningEmotionBloc?.dispose();
    parentModuleBloc?.dispose();
    parentRewardBloc?.dispose();
    coachBloc?.dispose();
    tabbarBloc?.dispose();
    studyModuleBloc?.dispose();

  }
}