class AccelRecord {
  ///A class to make object with all the accel Data i need such as x y z time
  double axeX;
  double axeY;
  double axeZ;
  var tim;
    AccelRecord({this.axeX,this.axeY,this.axeZ,this.tim});
      List toList() {
      List row = List();
      row.add(this.tim);
      row.add(this.axeX);
      row.add(this.axeY);
      row.add(this.axeZ);

      return row;
    }


}