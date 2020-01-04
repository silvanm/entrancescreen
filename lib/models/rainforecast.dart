import 'package:entrancescreen/api/apis.dart';
import 'package:scoped_model/scoped_model.dart';

class Rainforecast extends Model {
  List<RainforecastEntry> _millimeters = <RainforecastEntry>[];

  Rainforecast() {
    notifyListeners();
  }

  double maxMillimeters([int hours=24]) {
    if (_millimeters.length == 0) {
      return null;
    } else {
      return _millimeters
          .reduce((value, element) =>
              (element.millimeters > value.millimeters) ? element : value)
          .millimeters;
    }
  }

  refresh() async {
    var result = await KachelmannApi().getMeasurements();
    List<String> items = result.split(',');
    // the list first 2 items are the current time and a threshold for ESP32. Discard that.
    items.removeRange(0, 2);
    items.removeRange(8, items.length);
    var i = 0;
    var now = DateTime.now();
    var rainforecastEntries = <RainforecastEntry>[];
    for (String item in items) {
      rainforecastEntries.add(new RainforecastEntry(
          now.add(new Duration(hours: i)), double.parse(item)));
      i += 3;
    }
    _millimeters = rainforecastEntries;
    notifyListeners();
  }

  List<RainforecastEntry> get millimeters {
    return _millimeters;
  }
}

class RainforecastEntry {
  final DateTime date;
  final double millimeters;

  RainforecastEntry(this.date, this.millimeters);
}
