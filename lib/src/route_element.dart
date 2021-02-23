part of 'main.dart';

@immutable
abstract class VRouteElement {
  /// The path accessible for with this VRouteClass will be displayed
  /// If the path is exactly matched, this will be the last [VRoutePass]
  /// of the route
  /// If the path of a subroute is exactly matched, this will be used in
  /// the route but might be covered by another [VRouteElement.widget]
  /// The value of the path ca have three form:
  ///     * starting with '/': The path will be treated as a route path,
  ///       this is useful to take full advantage of nested routes while
  ///       conserving the freedom of path naming
  ///     * not starting with '/': The path corresponding to this route
  ///       will be the path of the parent route + this path. If this is used
  ///       directly in the [VRouter] routes, a '/' will be added anyway
  ///     * be null: In this case you must specify one or more subroutes
  ///       otherwise this route will never be displayed
  /// Note we use the package [path_to_regexp](https://pub.dev/packages/path_to_regexp)
  /// so you can use naming such as /user/:id to get the id (see [VRouteElementData.pathParameters]
  /// You can also use more advance technique using regexp directly in your path, for example
  /// '.*' will match any route, '/user/:id(\d+)' will match any route starting with user
  /// and followed by a digit. Here is a recap:
  /// |     pattern 	  | matched path | 	[VRouteElementData.pathParameters]
  /// | /user/:username |  /user/evan  | 	    { username: 'evan' }
  /// | /user/:id(\d+)  |  /user/123   | 	        { id: '123' }
  /// |     .*          |  every path  |                 -
  String? get path;

  // TODO: write this
  Future<Map<String, String>> Function(BuildContext context)? get pathParametersBuilder;

  /// A name for the route which will allow you to easily navigate to it
  /// using [VRouterData.of(context).pushNamed]
  ///
  /// Note that [name] should be unique w.r.t every [VRouteElement]
  String? get name;

  /// An alternative path that will be matched to this route
  List<String>? get aliases;

  /// A list of subroutes composed of any type of [VRouteElement]
  List<VRouteElement>? get subroutes;

  /// The widget displayed in this route
  ///
  /// See [isChild] to see how this widget
  /// will be accessible/displayed
  Widget? get widget;

  /// A builder for the widget displayed in this route
  ///
  /// You can use the given context to access path parameters,
  /// query parameters, etc.
  ///
  /// See [isChild] to see how this widget
  /// will be accessible/displayed
  ///
  /// Note that you can either define this or [widget] but not both
  Widget Function(BuildContext context)? get widgetBuilder;

  /// Whether this [VRouteElement] is going to be displayed as a
  /// child or not.
  /// If false, the [widget] or [widgetBuilder] is displayed on top of
  /// the one of the previous route.
  /// If true, the [widget] or [widgetBuilder] will be accessible by using
  /// [VRouteElementWidgetData.of(context).vChild]
  bool get isChild;

  /// A key for the [VPage] that will host the widget
  /// You shouldn't care about using it unless you don't
  /// specify a path.
  LocalKey? get key;

  /// The duration of [VRouteElement.buildTransition]
  Duration? get transitionDuration;

  /// The reverse duration of [VRouteElement.buildTransition]
  Duration? get reverseTransitionDuration;

  /// Create a custom transition effect when coming to and
  /// going to this route
  /// This has the priority over [VRouter.buildTransition]
  ///
  /// Also see:
  ///   * [VRouter.buildTransition] for default transitions for all routes
  Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? get buildTransition;

  // TODO: write explanations
  Future<bool> Function(BuildContext context) get validate;

  /// This is called before the url is updated but after all beforeLeave are called
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouterData methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeEnter] for global level beforeEnter
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> Function(VRedirector vRedirector)? get beforeEnter;

  /// This is called before the url is updated if this [VRouteElement] is the
  /// last of the current route
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouterData methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// [saveHistoryState] can be used to save a history state before leaving
  /// This history state will be restored if the user uses the back button
  /// You will find the saved history state in the [VRouteData] using
  /// [VRouteData.of(context).historyState]
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.beforeLeave] for global level beforeLeave
  ///   * [VNavigationGuard.beforeLeave] for widget level beforeLeave
  ///   * [VRedirector] to known how to redirect and have access to route information
  Future<void> Function(
    VRedirector? vRedirector,
    void Function(String state) saveHistoryState,
  )? get beforeLeave;

  /// This is called after the url and the state is updated if this [VRouteElement]
  /// is the last of the current route
  /// You can't prevent the navigation anymore
  /// You can get the new route parameters, and queryParameters
  ///
  /// Note that you should consider the navigation cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Navigation%20Control/The%20Navigation%20Cycle]
  ///
  /// Also see:
  ///   * [VRouter.afterEnter] for global level afterEnter
  ///   * [VNavigationGuard.afterEnter] for widget level afterEnter
  void Function(BuildContext context, String? from, String to)? get afterEnter;

  /// This function is called after [VNavigationGuard.onPop] before [VRouter.onPop]
  /// when a pop event occurs and this [VRouteElement] is the last in the
  /// current route
  /// A pop event can be called programmatically (with [VRouterData.of(context).pop()])
  /// or by other widgets such as the appBar back button
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouterData methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// The route you go to is calculated based on [VRouterState._defaultPop]
  ///
  /// Note that you should consider the pop cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Pop%20Events/onPop]
  ///
  /// Also see:
  ///   * [VRouter.onPop] for global level onPop
  ///   * [VNavigationGuard.onPop] for widget level onPop
  ///   * [VRouterState._defaultPop] for the default onPop
  Future<void> Function(VRedirector vRedirector)? get onPop;

  /// This function is called after [VNavigationGuard.onSystemPop] before [VRouter.onSystemPop]
  /// when a system pop event occurs and this [VRouteElement] is the last in the
  /// current route
  /// This happens on android when the system back button is pressed.
  ///
  ///
  /// Use [vRedirector] if you want to redirect or stop the navigation.
  /// DO NOT use VRouterData methods to redirect.
  /// [vRedirector] also has information about the route you leave and the route you go to
  ///
  /// The route you go to is calculated based on [VRouterState._defaultPop]
  ///
  /// Note that you should consider the systemPop cycle to
  /// handle this precisely, see [https://vrouter.dev/guide/Advanced/Pop%20Events/onSystemPop]
  ///
  /// Also see:
  ///   * [VRouter.onSystemPop] for global level onSystemPop
  ///   * [VNavigationGuard.onSystemPop] for widget level onSystemPop
  Future<void> Function(VRedirector vRedirector)? get onSystemPop;

  /// RegExp version of the path
  /// It is created automatically
  /// If the path starts with '/', it is removed from
  /// this regExp.
  RegExp? get pathRegExp;

  /// RegExp version of the aliases
  /// It is created automatically
  /// If an alias starts with '/', it is removed from
  /// this regExp.
  List<RegExp>? get aliasesRegExp;

  /// Parameters of the path
  /// It is created automatically
  List<String> get parameters;

  /// Parameters of the aliases if any
  /// It is created automatically
  List<List<String>>? get aliasesParameters => null;

  /// A key for the navigator if needed
  /// It is created automatically when a subroute as a
  /// [VRouteElement] with [isChild] set to true
  GlobalKey<NavigatorState>? get navigatorKey;

  /// A hero controller for the navigator if needed
  /// It is created automatically when a subroute as a
  /// [VRouteElement] with [isChild] set to true
  HeroController? get heroController;

  /// A global key for the [VRouteElementWIdgetState] which will
  /// be the widget holding the data of this [VRouteElement]
  /// It is created automatically
  GlobalKey<_RouteElementWidgetState>? get stateKey;

  // TODO: describe this
  static Future<bool> _defaultCondition(BuildContext context) => Future.value(true);
}

@immutable
class VStacked extends VRouteElement {
  /// See [VRouteElement.subroutes]
  @override
  final List<VRouteElement>? subroutes;

  /// See [VRouteElement.widget]
  @override
  final Widget? widget;

  /// See [VRouteElement.widgetBuilder]
  @override
  final Widget Function(BuildContext context)? widgetBuilder;

  /// See [VRouteElement.path]
  @override
  final String? path;

  /// See [VRouteElement.pathParametersBuilder]
  @override
  final Future<Map<String, String>> Function(BuildContext context)? pathParametersBuilder;

  /// See [VRouteElement.name]
  @override
  final String? name;

  /// See [VRouteElement.aliases]
  @override
  final List<String>? aliases;

  /// See [VRouteElement.key]
  @override
  final LocalKey? key;

  /// See [VRouteElement.transitionDuration]
  @override
  final Duration? transitionDuration;

  /// See [VRouteElement.reverseTransitionDuration]
  @override
  final Duration? reverseTransitionDuration;

  /// See [VRouteElement.buildTransition]
  @override
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;

  /// See [VRouteElement.validate]
  @override
  final Future<bool> Function(BuildContext context) validate;

  /// See [VRouteElement.beforeEnter]
  @override
  final Future<void> Function(VRedirector vRedirector)? beforeEnter;

  /// See [VRouteElement.beforeLeave]
  @override
  final Future<void> Function(VRedirector? vRedirector,
      void Function(String state) saveHistoryState)? beforeLeave;

  /// See [VRouteElement.afterEnter]
  @override
  final void Function(BuildContext context, String? from, String to)?
      afterEnter;

  /// See [VRouteElement.onPop]
  @override
  final Future<void> Function(VRedirector vRedirector)? onPop;

  /// See [VRouteElement.onSystemPop]
  @override
  final Future<void> Function(VRedirector vRedirector)? onSystemPop;

  /// This is the only difference between [VStacked] and [VChild]
  /// setting [isChild] false has the consequences explained in [VRouter.isChild]
  @override
  bool get isChild => false;

  VStacked({
    this.widget,
    this.widgetBuilder,
    this.key,
    this.path,
    this.pathParametersBuilder,
    this.name,
    this.subroutes,
    this.aliases,
    this.validate = VRouteElement._defaultCondition,
    this.beforeEnter,
    this.beforeLeave,
    this.afterEnter,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.onPop,
    this.onSystemPop,
  })  : pathRegExp = (path != null)
            ? pathToRegExp(path.startsWith('/') ? path.substring(1) : path,
                prefix: true)
            : null,
        aliasesRegExp = (aliases != null)
            ? [
                for (var alias in aliases)
                  pathToRegExp(
                      alias.startsWith('/') ? alias.substring(1) : alias,
                      prefix: true)
              ]
            : null,
        parameters = <String>[],
        aliasesParameters = (aliases != null)
            ? List<List<String>>.filled(aliases.length, [])
            : null,
        navigatorKey = (subroutes != null &&
                subroutes.isNotEmpty &&
                subroutes.indexWhere((vChildClass) => vChildClass.isChild) !=
                    -1)
            ? GlobalKey<NavigatorState>()
            : null,
        heroController = (subroutes != null &&
                subroutes.isNotEmpty &&
                subroutes.indexWhere((vChildClass) => vChildClass.isChild) !=
                    -1)
            ? HeroController()
            : null,
        stateKey = GlobalKey<_RouteElementWidgetState>() {
    if (widget == null && widgetBuilder == null) {
      throw ArgumentError(
        'You must either provide a widget or a widgetBuilder but they can not both be null.',
      );
    }
    if (widget != null && widgetBuilder != null) {
      throw ArgumentError(
        'You must either provide a widget OR a widgetBuilder but they can not both be specified.',
      );
    }
    if (path == null && aliases != null) {
      throw ArgumentError(
        'You can not have a null path with an alias. Either remove the alias or add a path.',
      );
    }
    if (path == null && name != null) {
      throw ArgumentError(
        'You can not have a null path with a name. Either remove the name or add a path.',
      );
    }
    if (key == null && path == null) {
      throw Exception(
          'Having key AND path arguments being null can lead to issue with page transition. Please consider giving at least one of the two.');
    }
    if (path == null && subroutes == null) {
      throw Exception(
          'Having path AND subroutes arguments being null will lead to a route never been matched. Consider adding a path or subroutes.');
    }

    if (path != null) {
      // Get local parameters
      final localPath = path!.startsWith('/') ? path!.substring(1) : path!;
      pathToRegExp(localPath, parameters: parameters);
    }
    if (aliases != null) {
      for (var i = 0; i < aliases!.length; i++) {
        final alias = aliases![i];
        final localPath = alias[i].startsWith('/') ? alias.substring(1) : alias;
        pathToRegExp(localPath, parameters: aliasesParameters![i]);
      }
    }
  }

  /// See [VRouteElement.pathRegExp]
  @override
  final RegExp? pathRegExp;

  /// See [VRouteElement.aliasesRegExp]
  @override
  final List<RegExp>? aliasesRegExp;

  /// See [VRouteElement.parameters]
  @override
  final List<String> parameters;

  /// See [VRouteElement.aliasesParameters]
  @override
  final List<List<String>>? aliasesParameters;

  /// See [VRouteElement.navigatorKey]
  @override
  final GlobalKey<NavigatorState>? navigatorKey;

  /// See [VRouteElement.heroController]
  @override
  final HeroController? heroController;

  /// See [VRouteElement.stateKey]
  @override
  final GlobalKey<_RouteElementWidgetState> stateKey;
}

@immutable
class VChild extends VRouteElement {
  /// See [VRouteElement.subroutes]
  @override
  final List<VRouteElement>? subroutes;

  /// See [VRouteElement.widget]
  @override
  final Widget? widget;

  /// See [VRouteElement.widgetBuilder]
  @override
  final Widget Function(BuildContext context)? widgetBuilder;

  /// See [VRouteElement.path]
  @override
  final String? path;

  /// See [VRouteElement.pathParametersBuilder]
  @override
  final Future<Map<String, String>> Function(BuildContext context)? pathParametersBuilder;

  /// See [VRouteElement.name]
  @override
  final String? name;

  /// See [VRouteElement.aliases]
  @override
  final List<String>? aliases;

  /// See [VRouteElement.key]
  @override
  final LocalKey? key;

  /// See [VRouteElement.transitionDuration]
  @override
  final Duration? transitionDuration;

  /// See [VRouteElement.reverseTransitionDuration]
  @override
  final Duration? reverseTransitionDuration;

  /// See [VRouteElement.buildTransition]
  @override
  final Widget Function(Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child)? buildTransition;

  /// See [VRouteElement.validate]
  @override
  final Future<bool> Function(BuildContext context) validate;

  /// See [VRouteElement.beforeEnter]
  @override
  final Future<void> Function(VRedirector vRedirector)? beforeEnter;

  /// See [VRouteElement.beforeLeave]
  @override
  final Future<void> Function(VRedirector? vRedirector,
      void Function(String state) saveHistoryState)? beforeLeave;

  /// See [VRouteElement.afterEnter]
  @override
  final void Function(BuildContext context, String? from, String to)?
      afterEnter;

  /// See [VRouteElement.onPop]
  @override
  final Future<void> Function(VRedirector vRedirector)? onPop;

  /// See [VRouteElement.onSystemPop]
  @override
  final Future<void> Function(VRedirector vRedirector)? onSystemPop;

  /// This is the only difference between [VChild] and [VStacked]
  /// setting [isChild] true has the consequences explained in [VRouteElement.isChild]
  @override
  bool get isChild => true;

  VChild({
    this.widget,
    this.widgetBuilder,
    this.key,
    this.path,this.pathParametersBuilder,
    this.name,
    this.subroutes,
    this.aliases,
    this.validate = VRouteElement._defaultCondition,
    this.beforeEnter,
    this.beforeLeave,
    this.afterEnter,
    this.buildTransition,
    this.transitionDuration,
    this.reverseTransitionDuration,
    this.onPop,
    this.onSystemPop,
  })  : pathRegExp = (path != null)
            ? pathToRegExp(path.startsWith('/') ? path.substring(1) : path,
                prefix: true)
            : null,
        aliasesRegExp = (aliases != null)
            ? [
                for (var alias in aliases)
                  pathToRegExp(
                      alias.startsWith('/') ? alias.substring(1) : alias,
                      prefix: true)
              ]
            : null,
        parameters = <String>[],
        aliasesParameters = (aliases != null)
            ? List<List<String>>.filled(aliases.length, [])
            : null,
        navigatorKey = (subroutes != null &&
                subroutes.isNotEmpty &&
                subroutes.indexWhere((vChildClass) => vChildClass.isChild) !=
                    -1)
            ? GlobalKey<NavigatorState>()
            : null,
        heroController = (subroutes != null &&
                subroutes.isNotEmpty &&
                subroutes.indexWhere((vChildClass) => vChildClass.isChild) !=
                    -1)
            ? HeroController()
            : null,
        stateKey = GlobalKey<_RouteElementWidgetState>() {
    if (widget == null && widgetBuilder == null) {
      throw ArgumentError(
        'You must either provide a widget or a widgetBuilder but they can not both be null.',
      );
    }
    if (widget != null && widgetBuilder != null) {
      throw ArgumentError(
        'You must either provide a widget OR a widgetBuilder but they can not both be specified.',
      );
    }
    if (path == null && aliases != null) {
      throw ArgumentError(
        'You can not have a null path with an alias. Either remove the alias or add a path.',
      );
    }
    if (path == null && name != null) {
      throw ArgumentError(
        'You can not have a null path with a name. Either remove the name or add a path.',
      );
    }
    if (key == null && path == null) {
      throw Exception(
          'Having key AND path arguments being null can lead to issue with page transition. Please consider giving at least one of the two.');
    }
    if (path == null && subroutes == null) {
      throw Exception(
          'Having path AND subroutes arguments being null will lead to a route never been matched. Consider adding a path or subroutes.');
    }

    if (path != null) {
      // Get local parameters
      final localPath = path!.startsWith('/') ? path!.substring(1) : path!;
      pathToRegExp(localPath, parameters: parameters);
    }
    if (aliases != null) {
      for (var i = 0; i < aliases!.length; i++) {
        final alias = aliases![i];
        final localPath = alias[i].startsWith('/') ? alias.substring(1) : alias;
        pathToRegExp(localPath, parameters: aliasesParameters![i]);
      }
    }
  }

  /// See [VRouteElement.pathRegExp]
  @override
  final RegExp? pathRegExp;

  /// See [VRouteElement.aliasesRegExp]
  @override
  final List<RegExp>? aliasesRegExp;

  /// See [VRouteElement.parameters]
  @override
  final List<String> parameters;

  /// See [VRouteElement.aliasesParameters]
  @override
  final List<List<String>>? aliasesParameters;

  /// See [VRouteElement.navigatorKey]
  @override
  final GlobalKey<NavigatorState>? navigatorKey;

  /// See [VRouteElement.heroController]
  @override
  final HeroController? heroController;

  /// See [VRouteElement.stateKey]
  @override
  final GlobalKey<_RouteElementWidgetState> stateKey;
}

@immutable
class VRouteRedirector extends VRouteElement {
  /// See [VRouteElement.validate]
  @override
  final Future<bool> Function(BuildContext context) validate;

  /// See [VRouteElement.beforeEnter]
  @override
  final Future<void> Function(VRedirector vRedirector)? beforeEnter;

  /// See [VRouteElement.path]
  @override
  final String path;

  /// See [VRouteElement.pathParametersBuilder]
  @override
  Future<Map<String, String>> Function(BuildContext context)? get pathParametersBuilder => null;

  /// See [VRouteElement.name]
  @override
  final String? name;

  /// See [VRouteElement.aliases]
  @override
  final List<String>? aliases;

  @override
  final List<RegExp>? aliasesRegExp;

  /// This is a static version of [VRouteElement.beforeEnter]
  /// Providing this will redirect to the given url
  final String? redirectTo;

  @override
  final RegExp pathRegExp;

  VRouteRedirector({
    required this.path,
    this.redirectTo,
    this.validate = VRouteElement._defaultCondition,
    Future<void> Function(VRedirector vRedirector)? beforeEnter,
    this.name,
    this.aliases,
  })  : assert(redirectTo != null || beforeEnter != null),
        assert(redirectTo == null || beforeEnter == null,
            'You should specify redirectTo OR beforeEnter but not both'),
        pathRegExp = pathToRegExp(
            path.startsWith('/') ? path.substring(1) : path,
            prefix: true),
        aliasesRegExp = (aliases != null)
            ? [
                for (var alias in aliases)
                  pathToRegExp(
                      alias.startsWith('/') ? alias.substring(1) : alias,
                      prefix: true)
              ]
            : null,
        beforeEnter = beforeEnter ??
            ((vRedirector) async => vRedirector.push(redirectTo!));

  /// Not implemented, this class is only for redirection
  @override
  List<VRouteElement>? get subroutes => null;

  /// Not implemented, this class is only for redirection
  @override
  Widget? get widget => Container();

  /// See [VRouteElement.widgetBuilder]
  @override
  Widget Function(BuildContext context)? get widgetBuilder => null;

  /// Not implemented, this class is only for redirection
  @override
  LocalKey? get key => null;

  /// Not used, this class is only for redirection
  @override
  bool get isChild => false;

  /// Not implemented, this class is only for redirection
  @override
  Future<bool> Function(VRedirector? vRedirector,
      void Function(String state) saveHistoryState)? get beforeLeave => null;

  /// Not implemented, this class is only for redirection
  @override
  void Function(BuildContext context, String? from, String to)?
      get afterEnter => null;

  /// Not implemented, this class is only for redirection
  @override
  Duration? get transitionDuration => null;

  /// Not implemented, this class is only for redirection
  @override
  Duration? get reverseTransitionDuration => null;

  /// Not implemented, this class is only for redirection
  @override
  Widget Function(
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child)? get buildTransition => null;

  /// Not implemented, this class is only for redirection
  @override
  Future<void> Function(VRedirector vRedirector)? get onPop => null;

  /// Not implemented, this class is only for redirection
  @override
  Future<void> Function(VRedirector vRedirector)? get onSystemPop => null;

  /// Not implemented, this class is only for redirection
  @override
  List<String> get parameters => <String>[];

  /// Not implemented, this class is only for redirection
  @override
  List<List<String>>? get aliasesParameters => null;

  /// Not implemented, this class is only for redirection
  @override
  GlobalKey<NavigatorState>? get navigatorKey => null;

  /// Not implemented, this class is only for redirection
  @override
  HeroController? get heroController => null;

  /// Not implemented, this class is only for redirection
  @override
  GlobalKey<_RouteElementWidgetState>? get stateKey => null;
}
