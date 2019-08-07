import 'package:flutter_start/models/Application.dart';
import 'package:redux/redux.dart';


final ApplicationReducer = combineReducers<Application>([
  TypedReducer<Application, RefreshApplicationAction>(_refresh),
]);

Application _refresh(Application application, RefreshApplicationAction action) {
  application = action.application;
  return application;
}

class RefreshApplicationAction {
  final Application application;

  RefreshApplicationAction(this.application);
}
