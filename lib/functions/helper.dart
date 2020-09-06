import 'dart:async';

// get the actuall time
now() {
  return DateTime.now().millisecondsSinceEpoch;
}

//timer from N second to zero
void startCountDown({declaredValue, initialValue, onTick, onEnd}) {
 // Timer _timer;
  if (declaredValue != null) {
    declaredValue.cancel();
  }
  var cpt = initialValue;
  
  declaredValue = Timer.periodic(Duration(seconds: 1), (timer) {
    if (cpt > 0) {
      cpt--;
      onTick(cpt);
    } else {
      declaredValue.cancel();
      onEnd();
    }
  });
}
