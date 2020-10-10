import 'dart:convert';

import 'package:http/http.dart';
import 'package:street_fix/model/street_fix_Request.dart';
class StreetfixUtils{


static final String _baseUrl = "http://192.168.43.238:5000/api/";

//Post
static Future<Response> postData(StreetfixRequest streetfixRequest) async{

    String apiUrl = _baseUrl + "process_data";

    Response response = await post(apiUrl,
      headers: {
        'Content-Type' : 'application/json'
      },
     
      body: json.encode(streetfixRequest.toJson()),
    );

    return response;
  }
}