import 'dart:io';
import 'package:csv/csv.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';
import 'package:street_fix/model/street_fix_Request.dart';
import 'package:street_fix/model/street_fix_Response.dart';
import 'package:street_fix/network_utils/street_fix_utils.dart';

// --------csv file creation-----------

Future<File> _write(String csvContent) async {
  final directory = await getExternalStorageDirectory();
  var filename = 'Recording ' +
      DateTime.now().toString().replaceAll(RegExp(r"[:\.]"), "-");
  //+ DateTime.now().toString();
  //
  final file = File('${directory.path}/$filename.csv');

  // Write the file.
  return file.writeAsString('$csvContent');
}

saveToCsv(rows, header) async {
  //rows contain all the sensors data we picked
  rows.insert(0, header);
  String csv = const ListToCsvConverter().convert(rows);
  print(csv);
  _write(csv);
  
  return csv;
}


