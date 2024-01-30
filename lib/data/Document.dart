import 'package:path/path.dart' as p;

class Document {
  // full path of document
  String path;
  bool isDirectory;

  String get fileName {
    return p.basename(path);
  }
  
  Document({required this.path, required this.isDirectory});
}