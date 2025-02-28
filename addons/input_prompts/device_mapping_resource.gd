extends Resource
class_name DeviceMappingResource
## Resource to define a device's input prompt mapping

## List of names this mapping supports
## This can be partial names and is case-insensitive
@export var names: Array[String]

## Textures that represent this device
@export var textures: Array[Texture]

## List of inputs this device maps to
@export var inputs: Array[DeviceInputResource]
