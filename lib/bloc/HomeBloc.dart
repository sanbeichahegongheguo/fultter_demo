import 'AdBloc.dart';
import 'BlocBase.dart';
import 'LearningEmotionBloc.dart';
import 'ModuleBloc.dart';
import 'ParentRewardBloc.dart';

class HomeBloc extends BlocBase {

  ///模块
  final ModuleBloc moduleBloc = new ModuleBloc();
  final ModuleBloc jzModuleBloc = new ModuleBloc();
  final ModuleBloc xqModuleBloc = new ModuleBloc();
  final ModuleBloc parentModuleBloc = new ModuleBloc();
  ///广告
  final AdBloc adBloc = new AdBloc();
  ///学情
  final LearningEmotionBloc  learningEmotionBloc = new LearningEmotionBloc();
  ///家长奖励
  final ParentRewardBloc parentRewardBloc = new ParentRewardBloc();

  @override
  void dispose() {
    moduleBloc?.dispose();
    jzModuleBloc?.dispose();
    adBloc?.dispose();
    xqModuleBloc?.dispose();
    learningEmotionBloc?.dispose();
    parentModuleBloc?.dispose();
    parentRewardBloc?.dispose();
  }
}