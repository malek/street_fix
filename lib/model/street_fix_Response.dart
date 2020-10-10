


import 'dart:convert';

List<StreetfixResponse> streetfixFromJson(String str) => List<StreetfixResponse>.from(json.decode(str).map((x) => StreetfixResponse.fromJson(x)));




class StreetfixResponse{

  double score;
  int anomaliesNumber;

  StreetfixResponse({
    this.score,
    this.anomaliesNumber,
  });

  factory StreetfixResponse.fromJson(Map<String, dynamic> json) => StreetfixResponse(
    
    score: json["score"],
    anomaliesNumber: json["anomaliesNumber"],
  );


}