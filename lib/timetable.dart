import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:entrancescreen/api/apis.dart';
import 'package:entrancescreen/models/models.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';

class TimetableWidget extends StatefulWidget {
  @override
  _TimetableWidgetState createState() => _TimetableWidgetState();
}

class _TimetableWidgetState extends State<TimetableWidget> {
  Timetable timetable = Timetable();
  Timer _timer;

  void getTimetable() async {
    var result = await TimetableApi().getTimetable();
    var timetableMap = json.decode(result);
    setState(() {
      timetable = Timetable.fromJson(timetableMap);
      print(timetable);
    });
  }

  void refreshData() {
    getTimetable();
    setState(() {
      DateTime _dateTime = DateTime.now();
      _timer = Timer(
        Duration(minutes: 1) -
            Duration(seconds: _dateTime.second) -
            Duration(milliseconds: _dateTime.millisecond),
        refreshData,
      );
    });
  }

  @override
  void initState() {
    super.initState();
    refreshData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Container _timeTableRow(
      String line, int timeDiff, Color color, bool reverse) {
    TextStyle s = TextStyle(fontSize: 30.0, fontWeight: FontWeight.normal);
    Container busLine = Container(
      child: Text('${line}',
          style: TextStyle(
              fontSize: 30.0,
              fontWeight: FontWeight.bold,
              color: Colors.black)),
      color: color,
      padding: const EdgeInsets.all(6.0),
      margin: const EdgeInsets.all(6.0),
    );
    Text duration = Text('${timeDiff}\'', style: s);
    var widgets = <Widget>[];

    if (reverse) {
      widgets = [duration, busLine];
    } else {
      widgets = [busLine, duration];
    }

    return Container(
        padding: const EdgeInsets.all(6.0),
        child: Row(
            mainAxisAlignment:
                reverse ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: widgets));
  }

  @override
  Widget build(BuildContext context) {
    if (timetable.down == null) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          SpinKitRing(
            color: Colors.white,
            size: 50.0,
          )
        ],
      );
    } else {
      var downCol = <Widget>[];
      var upCol = <Widget>[];

      downCol.add(Container(
          padding: const EdgeInsets.fromLTRB(12.0, 6, 12.0, 0),
          child: Text('HERUNTER')));
      upCol.add(Container(
          padding: const EdgeInsets.fromLTRB(12.0, 6, 12.0, 0),
          child: Text('HINAUF')));

      const hideRidesLeavingInLessThan = 2;

      var i = 0, displayedItems = 0;
      while (displayedItems < 2 && i < timetable.down.length) {
        if (timetable.down[i]['timeDiff'] > hideRidesLeavingInLessThan) {
          downCol.add(_timeTableRow(timetable.down[i]['line'],
              timetable.down[i]['timeDiff'], timetable.down[i]['color'], true));
          displayedItems++;
        }
        i++;
      }

      i = 0;
      displayedItems = 0;
      while (displayedItems < 2 && i < timetable.up.length) {
        if (timetable.up[i]['timeDiff'] > hideRidesLeavingInLessThan) {
          upCol.add(_timeTableRow(timetable.up[i]['line'],
              timetable.up[i]['timeDiff'], timetable.up[i]['color'], false));
          displayedItems++;
        }
        i++;
      }

      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
              width: 200,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: downCol,
              )),
          SizedBox(
              width: 200,
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: upCol)),
          /*RaisedButton(
          onPressed: refreshData,
          child: const Text(
            'Refresh',
          ),
        ),*/
        ],
      );
    }
  }
}
