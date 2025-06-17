import "dart:io";
import "dart:async";
import "smd_schema.dart";

void main() async {
  var a = SmdInterpreter("../test.smd");
  var sections = a._sectionFinder(await a._readFile());
  print(sections);
}

class SmdInterpreter{
  String filePath;

  SmdInterpreter(this.filePath);

  Future<String> _readFile() async { // Pulling & sanitising data from file
    String fileContentsRaw = await File(filePath).readAsString();
    String fileContents = fileContentsRaw
        .replaceAll(RegExp(r'\s+'), '') // Remove whitespace
        .replaceAll(RegExp(r'//.*?//'), ''); // Remove comments
    return fileContents;
  }

  List<String> _sectionFinder(String fileContents){ // Returns list of sections
    List<String> sections = [];
    for (String section in baseSchema.keys){
      int sectStart = fileContents.indexOf("$section{"); // Find where section starts
      if (sectStart == -1){ // -1 = substring not found
        if (baseSchema[section]!.required == true){
          throw FormatException("Expected section '$section', but wasn't found");
        } else{
          continue; // Skip to next iter for not included optionals
        }
      }
      final contentsFromSect = fileContents.substring(sectStart); // Only need to search after the section starts
      int opens = 0, closes = 0, sectEnd = 0;
      for (int i = 0; i < contentsFromSect.length; i++){
        final char = contentsFromSect[i];
        switch (char){ // Protects from nested sections
          case "{":
            opens++;
            break;
          case "}":
            closes++;
            break;
        }

        if (opens == closes && opens != 0){ // End of the section
          sectEnd = i + sectStart;
          break;
        }
      }
      sections.add(fileContents.substring(sectStart, sectEnd + 1));
    }
    return sections;
  }

  void parse(){
  }
}