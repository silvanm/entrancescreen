// Copyright 2019 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// A basic digital clock.
///
/// You can do better than this!
class DigitalClock extends StatefulWidget {
  @override
  _DigitalClockState createState() => _DigitalClockState();
}

class _DigitalClockState extends State<DigitalClock> {
  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    _updateTime();
  }

  @override
  void didUpdateWidget(DigitalClock oldWidget) {
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // Update once per minute. If you want to update every second, use the
      // following code.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final hour = DateFormat('HH').format(_dateTime);
    final minute = DateFormat('mm').format(_dateTime);
    final day = new DateFormat('EEEE, d. MMMM y', 'de_CH').format(_dateTime);
    const textStyle = TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold);

    return Container(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              '$hour',
              style: textStyle,
            ),
            Text(
              ':',
              style: textStyle.apply(
                  color:
                  (_dateTime.second % 2) == 0 ? Colors.black : Colors.white),
            ),
            Text(
              '$minute',
              style: textStyle,
            ),
          ],
        ),
        Text(
          day.toUpperCase(),
          style: Theme.of(context).textTheme.title,
        )
      ],
    ));
  }
}
