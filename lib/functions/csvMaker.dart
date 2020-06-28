import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';

  // --------csv file creation-----------


   Future<File> _write(String csvContent) async {
    final directory = await getExternalStorageDirectory();
    final File file = File('${directory.path}/Recording.csv');

    // Write the file.
    return file.writeAsString('$csvContent');
  }

   getCsv(rows) async { //rows contain all the acc data we picked 
    var headerTitle = List.from(["Date", "Axis X", "Axis Y", "Axis Z"]);// to make the gcsv head title
    rows.insert(0, headerTitle);
    String csv = const ListToCsvConverter().convert(rows);
    print(csv);
    _write(csv);
  }
