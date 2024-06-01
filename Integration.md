# Integration

This plugin can be integrated into other plugins or workflows. <br>
This file should give a broad overview over how Users can integrate this plugin

Integration mainly happens with the help of the PluginConfig.tres file in the plugin folder, which is a resource file of the plugin_config.gd class. <br>

## PluginConfig variables:

- usedClassPaths: Array of inner project class paths which can be used to limit the classes in the class selection screen. <br> If only a single path is given, this will skip the Class choice Screen in its entirety.

- setExportPath: String var which immediately sets a hard export path, which skips the Window where Users have to pick the export path

- disableNavigator to disable the navigator UI

- ignoredDirectories: to add directory names of directories whose classes should be ignored in the class choice screen

## Code API

- If you want to integrate the plugin into your own code and maybe want to handle the export process manually you can use the <strong> set_external_creation_handler </strong> method to set an object and method to connect the <strong> object_created </strong> signal to. <br>
  This signal hands over the created Object and allows manual handling of the creation process.
- You can connect the navigator signal <strong> navigator_pressed </strong> to customize the navigator UI
