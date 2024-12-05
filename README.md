# godot-resource-creator

godot plugin to create Resource files from custom User classes
Gives a UI Window where a class, inputs and an export path can be chosen.
Process should later on be able to be shortened and integrated into other projects or specific project workflows.

For Integration information look [here](doc_files/Integration.md)

## Immediate Goals

- ~~Issue with editing sub_objects when the parent object is already saved. The new sub_object values would not be written into the parent_object~~
  - Issue above should be addressed, however I have not properly tested it yet with regards to the object_wrapper obj_dict_insert_objects function
  - there might be constellations of dict/arr objects combined that could lead to issues.
- Implement JSON export of Objects
- Improve Config Functionality (reduce types for dict/arr)
- Implement Button in the export menu that can be used to duplicate already created resources
- Implement Button in export menu that can delete objects