class GyroRecord {
  ///A class to make object with all the accel Data i need such as x y z time
  double axeX;
  double axeY;
  double axeZ;

  // to make the gcsv head title
  static List getHeader() {
    //return List.from(["Time", "Gyro X", "Gyro Y", "Gyro Z"]);
    return List.from(["Gyro X", "Gyro Y", "Gyro Z"]);
  }

  GyroRecord({this.axeX, this.axeY, this.axeZ});
  
  List toList() {
    List row = List();
    row.add(this.axeX);
    row.add(this.axeY);
    row.add(this.axeZ);
    return row;
  }
}