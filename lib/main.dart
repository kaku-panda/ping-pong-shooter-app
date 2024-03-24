////////////////////////////////////////////////////////////////////////////////////////////
/// import
////////////////////////////////////////////////////////////////////////////////////////////
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

// my screens
import 'package:flutter_yolov5_app/app_navigation_bar.dart';
import 'package:flutter_yolov5_app/screens/detection.dart';
import 'package:flutter_yolov5_app/screens/splash.dart';
import 'package:flutter_yolov5_app/screens/parameters.dart';
// import 'package:robo_debug_app/screens/joystick.dart';
// import 'package:robo_debug_app/screens/motor.dart';

// my components
import 'package:flutter_yolov5_app/components/style.dart';
import 'package:flutter_yolov5_app/providers/deep_link_mixin.dart';
import 'package:flutter_yolov5_app/providers/setting_provider.dart';


final settingProvider  = ChangeNotifierProvider((ref) => SettingProvider());
final deepLinkProvider = ChangeNotifierProvider((ref) => DeepLinkProvider());
final rootNavigatorKey = GlobalKey<NavigatorState>();

final routerProvider   = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (BuildContext context, GoRouterState state) {
      if (state.uri.path == '/splash') {
        return null;
      }
      return;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        parentNavigatorKey: rootNavigatorKey,
        builder:(context, state, navigationShell){
          return AppNavigationBar(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes:[
              GoRoute(
                name: 'viewer',
                path: '/viewer',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const DetectionScreen(),
                ),
              ),
            ],
          ),
          // StatefulShellBranch(
          //   routes:[
          //     GoRoute(
          //       name: 'console',
          //       path: '/console',
          //       pageBuilder: (context, state) => NoTransitionPage(
          //         key: state.pageKey,
          //         child: const ConsoleScreen(),
          //       ),
          //     ),
          //   ],
          // ),
          // StatefulShellBranch(
          //   routes:[
          //     GoRoute(
          //       name: 'joystick',
          //       path: '/joystick',
          //       pageBuilder: (context, state) => NoTransitionPage(
          //         key: state.pageKey,
          //         child: const JoystickScreen(),
          //       ),
          //     ),
          //   ],
          // ),
          StatefulShellBranch(
            routes:[
              GoRoute(
                name: 'parameters',
                path: '/parameters',
                pageBuilder: (context, state) => NoTransitionPage(
                  key: state.pageKey,
                  child: const ParametersScreen(),
                ),
              ),
            ],
          ),
        ]
      ),
      GoRoute(
      name: 'spalash',
      path: '/splash',
      pageBuilder: (context, state) => MaterialPage(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
    ],
  );
},);


void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp()
    )
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});
  @override
  MyAppState createState() => MyAppState();
}
class MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingProvider).appBarHeight = AppBar().preferredSize.height;
      ref.read(settingProvider).navigationBarHeight = 56.0;
      ref.read(settingProvider).screenPaddingTop = MediaQuery.of(context).padding.top;
      ref.read(settingProvider).screenPaddingBottom = MediaQuery.of(context).padding.bottom;
      WidgetsBinding.instance.addObserver(this);
    },);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeMetrics() {
    super.didChangeMetrics();
    ref.read(settingProvider).isRotating = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(settingProvider).appBarHeight = AppBar().preferredSize.height;
      ref.read(settingProvider).navigationBarHeight = 56.0;
      ref.read(settingProvider).screenPaddingTop = MediaQuery.of(context).padding.top;
      ref.read(settingProvider).screenPaddingBottom = MediaQuery.of(context).padding.bottom;
      ref.read(settingProvider).isRotating = false;
    });
  }

  @override
  Widget build(BuildContext context) {

    ref.read(settingProvider).loadPreferences();
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'YOLOv5',
      theme: ThemeData.from(
        colorScheme: const ColorScheme.dark(),
      ),
      
      debugShowCheckedModeBanner: false,
      localizationsDelegates:const  [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('ja', ''),],

      routeInformationProvider: router.routeInformationProvider,
      routeInformationParser: router.routeInformationParser,
      routerDelegate: router.routerDelegate,

      scrollBehavior: const MaterialScrollBehavior().copyWith(
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
        },
      ),
    );
  }
}