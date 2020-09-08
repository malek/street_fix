class GpsRecord {
  ///A class to make object with all the gps Data 
  double lat;
  double long;
  double speed; //In meters/second


  // to make the gcsv head title
  static List getHeader() {
    return List.from(["Lat", "Long", "Speed"]);
  }

  GpsRecord({this.lat, this.long, this.speed});
  
  List toList() {
    List row = List();
    row.add(this.lat);
    row.add(this.long);
    row.add(this.speed);
    return row;
  }
}