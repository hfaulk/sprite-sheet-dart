import "smd_schema.dart";

void main(){
  String test = "sprite{(name:ball_1;x:0;y:0;dim:(64,64););(name:ball_2;x:64;y:0;dim:(64,64););(name:ball_3;x:128;y:0;dim:(64,64););(name:ball_4;x:192;y:0;dim:(64,64););(name:ball_5;x:256;y:0;dim:(64,64););(name:ball_6;x:320;y:0;dim:(64,64););(name:ball_7;x:384;y:0;dim:(64,64););(name:ball_8;x:448;y:0;dim:(64,64););(name:ball_9;x:512;y:0;dim:(64,64););(name:ball_10;x:576;y:0;dim:(64,64););}";
  var a = SmdParser();
  a.parseSection(test);

  a._parseField("name:ball_1", baseSchema["sprite"]!);
}

class SmdParser{
  SmdParser();

  void _parseField(String field, SchemaSection schema){ // expects (e.g.) field = "name:ball_1"
    String? fieldName = null;
    List<String> fieldInfo = field.split(":");
    for (SchemaField validField in schema.fields){
      if (fieldInfo[0] == validField.name){
        fieldName = validField.name;
        break;
      }
    }
    if (fieldName == null){
      String schemaSectionName = baseSchema.keys.firstWhere((k) => baseSchema[k] == schema, orElse: () => "");
      throw FormatException("'${fieldInfo[0]}' not a valid field within '$schemaSectionName' section");
    }
  }

  void _parseNested(String sectionFields, SchemaSection schema){
    List<String> subSections = [];

    int opens = 0, closes = 0, startIndex = 0;
    for (int i = 0; i < sectionFields.length; i++){
      final char = sectionFields[i];
      switch (char){
        case "(":
          if (opens == 0){startIndex = i;}
          opens++;
          break;
        case ")":
          closes++;
          break;
      }
      if (opens == closes && opens != 0){
        opens = 0; closes = 0;
        subSections.add(sectionFields.substring(startIndex, i));
      }
    }


  }

  void parseSection(String section){
    List<String> sectionBroken = section.replaceRange(section.length - 1, null, "").split("{");
    Map<String, String> sectionInfo = {
      "sectionName": sectionBroken[0],
      "sectionFields": sectionBroken[1]};

    SchemaSection schema = baseSchema[sectionInfo["sectionName"]]!;

    if (schema.type == SchemaType.nested){
      _parseNested(sectionInfo["sectionFields"]!, schema);
    }
  }
}