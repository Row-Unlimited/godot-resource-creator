# godot-resource-creator

Plugin for the godot engine to improve the creation of custom resources.  
Creates a GUI on the main editor screen to create resources from custom resource scripts.  
With custom settings/configs/plugin-integration it makes it possible for users to streamline their resource creation process.

For Integration information look [here](doc_files/Integration.md)

For information on configs look [here](doc_files/ClassConfig.md)

## Supported Types

Since each type needs custom GUI implementation and integration into the creation process currently not all datatypes are supported by this plugin.
If you have any datatype in particular you would like to see added, please reach out and let us know.
Here is a list of all types we currently support:
- TYPE_BOOL
- TYPE_INT 
- TYPE_FLOAT 
- All vector Types (TYPE_VECTOR2-TYPE_VECTOR4, TYPE_VECTOR2I-TYPE_VECTOR4I)
- TYPE_OBJECT (Since saving Objects only works with Resources, only scripts that inherit from Resource can be created via this type)
- TYPE_DICTIONARY
- TYPE_ARRAY (including Typed Arrays)


## Current Limitations

- Currently enum values can only be created if a set enum variable is defined in the class.  
  This means you cannot create Enum Values in Arrays or Dictionaries for now.