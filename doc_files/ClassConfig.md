# Class Config

If you want to customize how the plugin interacts with certain individual classes you can write a ClassConfig.  
This is a simple json file of which you can find an example at the bottom of this page.  

To set up your own config all you need to do is create it like the example and add it into the plugin folder under ClassConfigs.  
Don't forget to add the class information you can find at the top of the example file.

### Base Terminology

In this Document I use these Terms that might not be standard or understandable for everyone.  
So here I will add a short table explaining the meaning:  

|Term|Explanation|Example (if possible)|
|-----|-----|-----|
|Rule | This means a variable in the json class_config that defines plugin behavior for a certain input. | ```"disable_editing" = true,``` <br> This rule for example will make editing impossible for a certain input property |
|RuleSet| A dictionary in the class_config that contains all Rules for a certain Type/Class/Property |```"TYPE_INT": { "disable_editing" = true }``` <br> This RuleSet would disable editing for all int Properties unless overridden by another Rule|


## Rule Categories

Rule Categories define where a certain Rule/RuleSet is applied to and are created as Dictionaries in the class_config.  
The config is in a way similar to css, since there are different levels of specificity for each rule.  
The order is like this:  
CLASS_GENERAL_CONFIG < TYPE_CONFIGS < PROPERTY_CONFIGS

### CLASS_GENERAL_CONFIG:  

  Rules in this Category will apply to all properties in this class if not redefined by another Rule
  Some Rules cannot be applied to all types and will be ignored for those Types.  
  Also some Rules work differently for different Types.
  range_max/range_min define the numerical ranges for int/float types but when used for arrays, dictionaries or Strings will describe the size.

### TYPE_CONFIGS:  

  Rules in this Category will apply to all properties of a certain Type.
  You define a RuleSet for a type by creating a Dict with the godot Variant.Type name of the Type as Key.  
  This only works for supported Types like TYPE_INT, TYPE_ARRAY not TYPE_CALLABLE  

  If you want to make rules for a specific custom Class as an Input (so a sub_resource), you just define a RuleSet "TYPE_OBJECT" and then in that set you define another RuleSet with either the godot class_name if defined or the resource_path of the script as key.  
  That way you can make specific Rules like constructor Arguments for certain classes and not all.

### PROPERTY_CONFIGS

  In this category you can define RuleSets for singular Properties of a class.  
  This is the most specific Rule-Category and will thus overwrite all other Rules.  

  To write Rules for your properties you simply create a RuleSet in this Category with the property_name as Key.

## Rule Types:

Here a table listing all different Rules you can set and what they do:

|Rule Name|Explanation|Default Value|Exceptions further information|
|-----|-----|-----|-----|
|range_max/range_min|sets the max/min range of the input|null|for int/float this describes the numerical Range <br> However for Array/Dictionaries/String this describes the size/length|
|accept_empty| defines whether the plugin will allow this input to remain empty|true|Per default this will result in the property simply not being changed in the object. If the script has a default value defined, it will apply|
|change_empty_default|if set to true, empty values will be changed to the types default value: <br> - int/float => 0 <br> - String => "" <br> - bool => false <br> - Array => [] <br> - Dictionary => {}|false|for this to apply accept_empty must be true|
|default_value|sets a default value for the property|unfilled|if default value doesn't match the type it will simply be ignored|
|disable_editing|will make it impossible to edit this property in the plugin|false|For Arrays/Dictionaries this will not disable the editing of the sub_items. For this you need to define "SUB_ARRAY_CONFIG"|
|hide_input|if true this will hide the property in the plugin view|false| useful together with disable_editing or default_value |