import 'dart:async';

import 'package:badges/badges.dart' as bd;
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:kasie_transie_library/messaging/fcm_bloc.dart';
import 'package:kasie_transie_library/utils/functions.dart';
import 'package:kasie_transie_library/utils/kasie_error.dart';

import '../services/kasie_error_service.dart';

class BackendErrors extends StatefulWidget {
  const BackendErrors({Key? key, required this.kasieErrors, required this.date}) : super(key: key);

  final List<KasieError> kasieErrors;
  final String date;

  @override
  BackendErrorsState createState() => BackendErrorsState();
}

class BackendErrorsState extends State<BackendErrors>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool busy = false;
  final kasieErrorService = GetIt.instance.get<ErrorService>();
  late StreamSubscription<Map<String, dynamic>> kasieErrorSub;
  static const mm = '🍐🍐🍐🍐 BackendErrors';
  @override
  void initState() {
    _controller = AnimationController(vsync: this);
    super.initState();
    _listen();
  }

  void _listen() async {

    kasieErrorSub = fcmBloc.kasieErrorStream.listen((event) {
      pp('$mm KasieError delivered on stream ... will just set state!');
      // widget.kasieErrors.add(KasieError.fromJson(event));
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
    // kasieErrorSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      appBar: AppBar(
        title: const Text('Backend Errors'),
      ),
      body: Stack(
        children: [
          Column(
            children: [
              gapH32,
              const Text('Backend Errors from date'),
              gapH8,
              Text(widget.date, style: myTextStyleMediumLargeWithColor(context, Colors.amber, 18),),
              gapH16,
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: bd.Badge(
                    badgeContent: Text('${widget.kasieErrors.length}'),
                    badgeStyle:  bd.BadgeStyle(
                      badgeColor: Colors.blue.shade800,
                        elevation: 16.0, padding: const EdgeInsets.all(12)),
                    child: ListView.builder(
                        itemCount: widget.kasieErrors.length,
                        itemBuilder: (_, index) {
                          final err = widget.kasieErrors.elementAt(index);
                          final date = DateTime.parse(err.date!).toLocal();
                          final mDate = getFormattedDateLong(date.toIso8601String());
                          return Card(
                            shape: getRoundedBorder(radius: 16),
                            elevation: 12,
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ListTile(
                                title: Text(
                                  mDate,
                                  style: myTextStyleSmallBoldPrimaryColor(context),
                                ),
                                subtitle: Text(
                                  '${err.request}',
                                  style: myTextStyleSmall(context),
                                ),
                              ),
                            ),
                          );
                        }),
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    ));
  }
}
