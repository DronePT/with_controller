import 'package:mobx/mobx.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:flutter/widgets.dart';
import 'package:with_controller/typedefs.dart';

/// A [WithController] widget is a convenience widget. It avoids the need of managing a controller's lifecycle,
/// its dispose and also its reactions, since most of the times it's just boilerplate burden.
class WithController<C> extends StatefulWidget {
  /// List of reaction creators.
  /// You can use any type of reaction you want to: `when`, `autorun`, `reaction` and so on.
  ///
  /// ```dart
  /// reactions: [
  ///   (controller) => autorun((r) => print(controller.someValue)),
  ///   (controller) => autorun((r) => print(controller.someotherValue)),
  /// ]
  /// ```
  final List<ReactionCreator<C>> reactions;

  /// Controller creator. This instance is used in every callback that takes a controller, such as [disposer].
  /// It takes a [BuildContext] as argument in case you need it.
  final ControllerCreator<C> controller;

  /// Disposer function of the controller.
  ///
  /// ```dart
  /// (controller) => controller.disposeSomething();
  /// ```
  final ControllerDisposer<C> disposer;

  /// Initiater function of the controller.
  ///
  /// ```dart
  /// (context, controller) => controller.getSomethingFromAPI();
  /// ```
  final ControllerInitiater<C> init;

  /// Builder function. Takes a [BuildContext] and a controller;
  final WidgetControllerBuilder<C> builder;

  /// If true, the builder function will be wrapped by an Observer widget;
  final bool observable;

  const WithController({
    @required this.controller,
    @required this.builder,
    this.observable = true,
    this.reactions = const [],
    this.disposer,
    this.init,
    Key key,
  }) : super(key: key);

  @override
  WithControllerState<C> createState() => WithControllerState();
}

@visibleForTesting
class WithControllerState<C> extends State<WithController<C>> {
  List<ReactionDisposer> reactionDisposers;
  C controller;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    reactionDisposers.forEach((disposer) => disposer());

    if (widget.disposer != null) widget.disposer(controller);

    super.dispose();
  }

  @override
  void didChangeDependencies() {
    if (controller == null) {
      controller = widget.controller(context);

      if (widget.init != null) widget.init(context, controller);
    }

    if (reactionDisposers == null) {
      reactionDisposers = widget.reactions
          .map((creator) => creator(context, controller))
          .toList();
    }

    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) => widget.observable
      ? Observer(builder: (_) => widget.builder(context, controller))
      : widget.builder(context, controller);
}
