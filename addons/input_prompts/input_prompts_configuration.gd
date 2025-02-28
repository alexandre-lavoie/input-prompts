@icon("res://addons/input_prompts/icons/device.svg")
extends Resource
class_name InputPromptsConfiguration
## Configuration for Input Prompts plugin
## This will be loaded from `res://input_prompts_configuration.tres`

## Device used if no device mapping is found
@export var fallback_device: DeviceMappingResource

## List of supported devices
@export var devices: Array[DeviceMappingResource]
