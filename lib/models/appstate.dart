import 'package:scoped_model/scoped_model.dart';

class Appstate extends Model {
  bool _debug=false;

  get debug {
    return _debug;
  }

  toggleDebug() {
    this._debug = !this._debug;
    notifyListeners();
    return this._debug;
  }
}