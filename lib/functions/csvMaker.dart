import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';


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


