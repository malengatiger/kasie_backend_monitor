import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/kasie_error.dart';
import 'package:kasie_transie_library/utils/navigator_utils.dart';
import 'package:kasie_transie_library/utils/parsers.dart';
import 'package:kasie_transie_library/widgets/timer_widget.dart';
import 'package:kasiemonitor/dashboard/app_errors.dart';
import 'package:kasiemonitor/dashboard/backend_errors.dart';
import 'package:kasiemonitor/services/auth.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:kasie_transie_library/widgets/dash_widgets/generic.dart';
import 'package:kasie_transie_library/widgets/drop_down_widgets.dart';
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';

import '../services/kasie_error_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  DashboardState createState() => DashboardState();
}

class DashboardState extends State<Dashboard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  static const mm = '🌀🌀🌀🌀Dashboard';
  final kasieErrorService = GetIt.instance.get<ErrorService>();
  var appErrors = <AppError>[];
  var kasieErrors = <KasieError>[];
  late StreamSubscription<Map<String, dynamic>> appErrorSub;
  late StreamSubscription<Map<String, dynamic>> kasieErrorSub;
  String? date;

  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    date = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    _listen();
    _checkAuth();
  }

  void _listen() async {
    await fcmBloc.subscribeForBackendMonitor('BackendMonitor');
    appErrorSub = fcmBloc.appErrorStream.listen((event) {
      pp('$mm AppError delivered on stream');
      appErrors.add(buildAppError(event));
      _refreshState();

    });
    kasieErrorSub = fcmBloc.kasieErrorStream.listen((event) {
      pp('$mm KasieError delivered on stream');
      kasieErrors.add(KasieError.fromJson(event));
      _refreshState();
    });
  }
  void _refreshState() {
    if (mounted) {
      pp('$mm _refreshState: .......... set state ...');
      setState(() {

      });
    }
  }
  void _checkAuth() async {
    final fbAuthedUser = FirebaseAuth.instance.currentUser;
    if (fbAuthedUser != null) {
      pp('$mm fbAuthUser email: ${fbAuthedUser.email}');
      await _getPermission();
      _getData();
    } else {
      pp('$mm fbAuthUser: is null. Need to authenticate the app!');
      final ok = await auth.signIn();
      pp('$mm ... user signed in ?? $ok');
      if (ok) {
        await _getPermission();
        _getData();
      }
    }
  }
  int days = 14;

  void _getData() async {
    setState(() {
      busy = true;
    });
    date =
        DateTime.now().toUtc().subtract(Duration(days: days)).toIso8601String();
    pp('$mm ... getting kasieErrors and appErrors ....');

    try {
      kasieErrors = await kasieErrorService.getKasieErrors(date!);
      appErrors = await kasieErrorService.getAppErrors(date!);
      pp('$mm ... kasieErrors: ${kasieErrors.length} - appErrors: ${appErrors.length}');
    } catch (e, stack) {
      pp('$e - $stack');
      if (mounted) {
        showErrorSnackBar(message: "$e", context: context);
      }
    }
    setState(() {
      busy = false;
    });
  }

  Future _getPermission() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.location,
      Permission.storage,
      Permission.camera,
    ].request();
    pp('$mm PermissionStatus: statuses: $statuses');
  }

  _navigateToBackendErrors() async {
    date = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final rDate = getFormattedDateLong(date!);

    if (mounted) {
      navigateWithScale(
          BackendErrors(
            kasieErrors: kasieErrors,
            date: rDate,
          ),
          context);
    }
  }

  _navigateToAppErrors() async {
    date = DateTime.now().subtract(Duration(days: days)).toIso8601String();
    final rDate = getFormattedDateLong(date!);
    if (mounted) {
      navigateWithScale(
          AppErrors(
            appErrors: appErrors,
            date: rDate,
          ),
          context);
    }
  }

  bool busy = false;
  @override
  void dispose() {
    _controller.dispose();
    appErrorSub.cancel();
    kasieErrorSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: Text(
          'Backend Monitor',
          style: myTextStyleMediumLargeWithColor(
              context, Theme.of(context).primaryColor, 24),
        ),
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(160),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 40.0),
                  child: Text(
                    'Monitor errors and exceptions that occur on Kasie Transie Backend services in near real-time',
                    style: myTextStyleMediumLargeWithColor(
                        context, Colors.grey, 14),
                  ),
                ),
                gapH32,
                gapH32,
              ],
            )),
        actions: [
          IconButton(
              onPressed: () {
                _navigateToBackendErrors();
              },
              icon: const Icon(
                Icons.error_outline,
                color: Colors.yellow,
              )),
          IconButton(
              onPressed: () {
                _navigateToAppErrors();
              },
              icon: const Icon(
                Icons.app_blocking,
                color: Colors.pink,
              ))
        ],
      ),
      body: Stack(
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                shape: getRoundedBorder(radius: 16),
                elevation: 8,
                child: Column(
                  children: [
                    gapH32,
                    gapH32,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Number of Days',
                          style: myTextStyleMediumLargeWithColor(
                              context, Theme.of(context).primaryColor, 18),
                        ),
                        gapW16,
                        NumberDropDown(
                          color: Theme.of(context).primaryColorLight,
                          fontSize: 14,
                          count: 30,
                          onNumberPicked: (mDays) {
                            setState(() {
                              days = mDays;
                            });
                            _getData();
                          },
                        ),
                        gapW32,
                        Text(
                          '$days',
                          style: myTextStyleMediumLargeWithColor(
                              context, Theme.of(context).primaryColor, 28),
                        ),
                      ],
                    ),
                    gapH32,
                    date == null
                        ? gapW32
                        : Text(
                            getFormattedDateLong(date!),
                            style: myTextStyleMediumLargeWithColor(
                                context, Colors.grey, 18),
                          ),
                    gapH32,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: GestureDetector(
                            onTap: () {
                              _navigateToBackendErrors();
                            },
                            child: Card(
                                shape: getRoundedBorder(radius: 16),
                                elevation: 12,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Center(
                                    child: NumberAndCaption(
                                      caption: 'Backend Errors',
                                      number: kasieErrors.length,
                                      color: Colors.yellow,
                                      fontSize: 36,
                                    ),
                                  ),
                                )),
                          ),
                        ),
                        SizedBox(
                          width: 160,
                          height: 160,
                          child: GestureDetector(
                            onTap: () {
                              _navigateToAppErrors();
                            },
                            child: Card(
                              shape: getRoundedBorder(radius: 16),
                              elevation: 12,
                              child: Center(
                                child: NumberAndCaption(
                                  caption: 'App Errors',
                                  number: appErrors.length,
                                  color: Colors.pink,
                                  fontSize: 36,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    gapH32,
                    SizedBox(
                      width: 300,
                      height: 60,
                      child: ElevatedButton(
                          style: ButtonStyle(
                              elevation: const MaterialStatePropertyAll(16),
                              shape: MaterialStatePropertyAll(
                                  getDefaultRoundedBorder())),
                          onPressed: () {
                            _getData();
                          },
                          child: const Text('Refresh Errors')),
                    )
                  ],
                ),
              ),
            ),
          ),
          busy
              ? const Positioned(
                  child: Center(
                  child: TimerWidget(
                      title: 'Refreshing errors ...', isSmallSize: true),
                ))
              : gapH32,
        ],
      ),
    ));
  }
}
