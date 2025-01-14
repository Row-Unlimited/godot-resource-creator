# Integration

## Main-screen Integration

The default main-screen, as in the class/export trees + the export button can be replaced by a custom scene to allow for even more precise integration into your workflow.
To successfully replace the main-screen you must fulfill the following requirements:
- You have to add the instantiated scene to the CreationManager object before it is ready so it does not load the default screen.
- Your scene must be able to call the ```create_new_creation_screen``` method with a correctly setup ObjectWrapper object as an argument.
- Your scene must define a signal ```signal export_activated(path_dict: Dictionary)``` where when used path_dict has the to be exported wrapper ids as keys, and their export directory path as values. Example: ```{ "obj1": "res://test-file-folder/" }```

## Class Configs

via ClassConfigs you can customize plugin behavior for every property/type in a certain class.  
For more Information on ClassConfigs look [here](ClassConfig.md)