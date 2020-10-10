
import 'dart:convert';


String streetfixToJson(List<StreetfixRequest> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));



class StreetfixRequest{

  String csv;

  StreetfixRequest({
    this.csv,

  });



   Map<String, dynamic> toJson() => {
    "content": csv,
  };
}