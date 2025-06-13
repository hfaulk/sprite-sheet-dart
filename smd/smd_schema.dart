enum SchemaType{ // Basically like a custom type
  flat,
  nested
}

class SchemaField{
  final String name;
  final String type;
  final List<dynamic>? limit; // Provide specific values it can be

  SchemaField(this.name, this.type, {this.limit});
}

class SchemaSection{
  final SchemaType type;
  final bool required;
  final List<SchemaField> fields;

  SchemaSection({
    required this.type,
    required this.required,
    required this.fields});
}

Map<String, SchemaSection> baseSchema = {
  "sheet": SchemaSection(
    type: SchemaType.flat,
    required: true,
    fields: [
      SchemaField("image_file", "string"),
      SchemaField("dim", "tuple<int, int>"),
      SchemaField("animation", "bool")
    ]
  ),
  "sprite": SchemaSection(
    type: SchemaType.nested,
    required: true,
    fields: [
      SchemaField("name", "string"),
      SchemaField("x", "int"),
      SchemaField("y", "int"),
      SchemaField("dim", "tuple<int, int>")
    ]
  ),
  "animation": SchemaSection(
    type: SchemaType.nested,
    required: false,
    fields: [
      SchemaField("name", "string"),
      SchemaField("frame_duration", "int"),
      SchemaField("orientation", "string", limit: ["horizontal", "vertical"]),
      SchemaField("frames", "list<string>")
    ]
  )
};