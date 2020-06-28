import 'dart:async';

// get the actuall time
now() {
  return DateTime.now().millisecondsSinceEpoch;
}

//timer from N second to zero
void startCountDown({initialValue, onTick, onEnd}) {
  Timer _timer;
  if (_timer != null) {
    _timer.cancel();
  }
  var cpt = initialValue;

  _timer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (cpt > 0) {
      cpt--;
      onTick(cpt);
    } else {
      _timer.cancel();

      onEnd();
    }
  });
}
