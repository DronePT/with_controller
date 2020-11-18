import 'package:flutter/widgets.dart';
import 'package:mobx/mobx.dart';

typedef T ControllerCreator<T>(BuildContext context);
typedef void ControllerInitiater<T>(BuildContext contex, T controller);
typedef void ControllerDisposer<T>(T controler);
typedef Widget WidgetControllerBuilder<T>(BuildContext contex, T controller);
typedef ReactionDisposer ReactionCreator<T>(BuildContext contex, T controller);
