import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/data/schemas.dart';
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/parsers.dart';

import '../services/kasie_error_service.dart';
import 'package:badges/badges.dart' as bd;

class AppErrors extends StatefulWidget {
  const AppErrors({Key? key, required this.appErrors, required this.date}) : super(key: key);

  final List<AppError> appErrors;
  final String date;
  @override
  AppErrorsState createState() => AppErrorsState();
}

class AppErrorsState extends State<AppErrors>
    with SingleTickerProviderStateMixin {
  static const mm = '🍎🍎🍎🍎 AppErrors';
  late AnimationController _controller;
  bool busy = false;
  final kasieErrorService = GetIt.instance.get<ErrorService>();
  late StreamSubscription<Map<String, dynamic>> appErrorSub;
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
  }

  void _listen() async {
    appErrorSub = fcmBloc.appErrorStream.listen((event) {
      pp('$mm AppError delivered on stream ... will just set state!');
      // widget.appErrors.add(buildAppError(event));
      _refreshState();

    });

  }
  void _refreshState() {
    if (mounted) {
      setState(() {

      });
    }
  }
  int days = 0;
  @override
  void dispose() {
    _controller.dispose();
    // appErrorSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('App Errors'),
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: getDefaultRoundedBorder(),
              elevation: 4,
              child: Column(
                children: [
                  gapH32,
                  const Text('App Error from date'),
                  gapH8,
                  Text(widget.date, style: myTextStyleMediumLargeWithColor(context, Colors.pink.shade300, 18),),
                  gapH16,
                  Expanded(
                    child: bd.Badge(
                      badgeContent: Text('${widget.appErrors.length}'),
                      badgeStyle: const bd.BadgeStyle(
                        elevation: 16.0,badgeColor: Colors.pink,
                        padding: EdgeInsets.all(12),
                      ),
                      child: ListView.builder(
                          itemCount: widget.appErrors.length,
                          itemBuilder: (_, index) {
                            final err = widget.appErrors.elementAt(index);
                            final date = DateTime.parse(err.created!).toLocal();
                            final mDate = getFormattedDateLong(date.toIso8601String());
                            return Card(
                              shape: getRoundedBorder(radius: 16),
                              elevation: 12,
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(mDate,
                                    style: myTextStyleSmallBoldPrimaryColor(context),),
                                  subtitle: Text('${err.errorMessage}', style: myTextStyleSmall(context),),
                                )
                              ),
                            );
                          }),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    ));
  }
}
