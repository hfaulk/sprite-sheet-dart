import "dart:io";
import "dart:async";

void main() async {
  var a = SmdInterpret("test.smd");
  var sections = a._sectionFinder(await a._readFile());
  print(sections);
}

class SmdInterpret{
  String filePath;
  final Map<String,String> validSections = { // Will only search for these sections
    "sheet":"req",
    "sprite":"req",
    "animation":"opt"};

  SmdInterpret(this.filePath);

  Future<String> _readFile() async { // Pulling & sanitising data from file
    String fileContentsRaw = await File(filePath).readAsString();
    String fileContents = fileContentsRaw
        .replaceAll(RegExp(r'\s+'), '') // Remove whitespace
        .replaceAll(RegExp(r'//.*?//'), ''); // Remove comments
    return fileContents;
  }

  List<String> _sectionFinder(String fileContents){
    List<String> sections = [];
    for (String section in validSections.keys){
      int sectStart = fileContents.indexOf("$section{"); // Find where section starts
      if (sectStart == -1){ // -1 = substring not found
        if (validSections[section] == "req"){
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


}