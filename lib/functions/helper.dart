import 'dart:async';

// get the actuall time
int now() {
  ///TODO: change it to mnts
  return DateTime.now().millisecondsSinceEpoch;
}

//timer from N second to zero
 Timer startCountDown({timer, initialValue, onTick, onEnd}) {
  Timer newTimer;
  if (timer != null) {
    timer.cancel();
  }
  var cpt = initialValue;
  
  newTimer = Timer.periodic(Duration(seconds: 1), (timer) {
    if (cpt > 0) {
      cpt--;
      onTick(cpt);
    } else {
      timer.cancel();
      onEnd();
    }
  });
  return newTimer;
}
