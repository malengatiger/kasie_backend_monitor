import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_core/firebase_core.dart' as fb;
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/bloc/getit_initializer.dart';
import 'package:kasie_transie_library/bloc/theme_bloc.dart';
import 'package:kasie_transie_library/utils/error_handler.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/widgets/splash_page.dart';
import 'package:kasiemonitor/dashboard/dashboard.dart';
import 'package:kasiemonitor/services/http_service.dart';
import 'package:kasiemonitor/services/kasie_error_service.dart';
import 'package:page_transition/page_transition.dart';

import 'firebase_options.dart';

const mx = '🔵🔵🔵🔵🔵🔵🔵🔵🔵🔵 KasieTransie Backend Monitor : main 🔵🔵';
const projectId = '';
fb.User? fbAuthedUser;
int themeIndex = 0;
final FlutterLocalNotificationsPlugin plugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  pp('$mx app is starting .....');
  WidgetsFlutterBinding.ensureInitialized();
  var app = await fb.Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform);
  pp('$mx '
      ' Firebase App has been initialized: ${app.name}, checking for authed current user\n');
  final mLoc = LocatorInitializer();
  mLoc.setup();
  fbAuthedUser = fb.FirebaseAuth.instance.currentUser;
  if (fbAuthedUser != null) {
    pp('$mx fbAuthUser: ${fbAuthedUser!.uid}');
    pp("$mx .... fbAuthUser is cool! ........ on to the party!!");
  } else {
    pp('$mx fbAuthUser: is null. Need to authenticate the app!');
  }

  GetIt.instance
      .registerLazySingleton<ErrorService>(() => ErrorService());
  pp('$mx registerLazySingleton: KasieErrorService ');

  setupNetworkService();
  final networkService = getNetworkService();
  networkService.initialize();

  errorHandler.sendErrors();
  runApp(const KasieBackendMonitor());
}

class KasieBackendMonitor extends StatelessWidget {
  const KasieBackendMonitor({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        pp('$mx 🌀🌀🌀🌀 Tap detected; should dismiss keyboard ...');
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: StreamBuilder(
          stream: themeBloc.localeAndThemeStream,
          builder: (ctx, snapshot) {
            if (snapshot.hasData) {
              pp(' 🔵 🔵 🔵'
                  'build: theme index has changed to ${snapshot.data!.themeIndex}'
                  '  and locale is ${snapshot.data!.locale.toString()}');
              themeIndex = snapshot.data!.themeIndex;
            }

            return MaterialApp(
                debugShowCheckedModeBanner: false,
                title: 'KTBackendMon',
                theme: themeBloc.getTheme(themeIndex).lightTheme,
                darkTheme: themeBloc.getTheme(themeIndex).darkTheme,
                themeMode: ThemeMode.system,
                home: AnimatedSplashScreen(
                  splash: const SplashWidget(),
                  animationDuration: const Duration(milliseconds: 2000),
                  curve: Curves.easeInCirc,
                  splashIconSize: 160.0,
                  nextScreen: const Dashboard(),
                  splashTransition: SplashTransition.fadeTransition,
                  pageTransitionType: PageTransitionType.leftToRight,
                  backgroundColor: Colors.orange.shade900,
                ));
          }),
    );
  }
}
