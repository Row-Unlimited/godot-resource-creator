# godot-resource-creator

godot plugin to create Resource files from custom User classes
Gives a UI Window where a class, inputs and an export path can be chosen.
Process should later on be able to be shortened and integrated into other projects or specific project workflows.

For Integration information look [here](doc_files/Integration.md)

## Project-Goals:

- [x] Finish basic Object creation functionality
- [x] Add reset button
- [x] Add Vector Data Types
- [x] Add Array/Dictionary Data Types
- [x] Add back button after choosing class
- [ ] Add custom Objects as possible Data Type
- [ ] Improve UX by sorting classes or paths by how often they were created etc.
- [ ] Add Integration functionality

## Immediate Goals

- Implement sub-object creation
- Re-Implement Settings Menu
- Implement Type compatibility with enums
- Improve Config Functionality (constructor vars, reduce types for dict/arr)
- Implement Button in the export menu that can be used to duplicate already created resources
