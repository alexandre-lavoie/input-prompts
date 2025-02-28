extends Node
## A globally accessible manager for input prompts

# --- Configuration ---

## Configuration for plugin
var _config = preload("res://input_prompts_configuration.tres")

## Get the action name per-device
## Replace this if using MultiplayerInput
func get_device_action_name(_device: int, action: String) -> String:
	return action

# --- Code ----

## List of supported devices
var _devices: Array[DeviceMappingResource]

## Device used if no device mapping is found
var _fallback_device: DeviceMappingResource

func _init() -> void:
	self.reset()

## Reloads the manager if there is a change to configuration
func reset() -> void:
	self._fallback_device = self._config.fallback_device
	self._devices = []

	for device in self._config.devices:
		self.add_device(device)

## Adds a new DeviceMappingResource
func add_device(device: DeviceMappingResource) -> void:
	self._devices.push_back(device)

## Gets the DeviceMappingResource associate to a device name
func get_device_from_name(device: String) -> DeviceMappingResource:
	for dev in self._devices:
		for dev_name in dev.names:
			if dev_name.to_lower() in device.to_lower():
				return dev

	return self._fallback_device

## Gets the DeviceMappingResource associate to the device index
func get_device_from_index(device: int) -> DeviceMappingResource:
	if device > 7:
		return null

	var device_name: String = self.get_device_name(device)

	if len(device_name) <= 1:
		return self._fallback_device

	return self.get_device_from_name(device_name)

## Gets the Textures used to represent the device
func get_device_textures(device: int) -> Array[Texture]:
	var dev = self.get_device_from_index(device)
	if dev == null:
		return []

	return dev.textures

## Gets the DeviceInputResource associated to the event
func get_event_input(device: int, event: InputEvent) -> DeviceInputResource:
	var dev = self.get_device_from_index(device)
	if dev == null:
		return null

	if event is InputEventKey:
		if not event.physical_keycode:
			event.physical_keycode = event.keycode

	for inp in dev.inputs:
		for inp_event in inp.events:
			if inp_event.is_match(event):
				return inp

	return null

## Gets the Textures assoicated to the input name
func get_event_textures(device: int, event: InputEvent) -> Array[Texture]:
	var inp = self.get_event_input(device, event)
	if inp == null:
		return []

	return inp.textures

## Gets the DeviceInputResources associated to the action
func get_action_inputs(device: int, action: String) -> Array[DeviceInputResource]:
	var inputs: Array[DeviceInputResource] = []

	for event in InputMap.action_get_events(action):
		var input = self.get_event_input(device, event)
		if input == null:
			continue

		inputs.push_back(input)

	return inputs

## Gets the Textures associate to the action
func get_action_textures(device: int, action: String) -> Array[Texture]:
	var textures: Array[Texture] = []

	for inp in self.get_action_inputs(device, action):
		textures.append_array(inp.textures)

	return textures

## Gets the device name
## Includes a hack to get gamepad name on web
func get_device_name(device: int) -> String:
	if device < -1:
		return "Invalid"

	if device == -1:
		return "Keyboard"

	if OS.get_name() == "Web":
		return str(JavaScriptBridge.eval(
			"navigator.getGamepads()[%s].id" % (device)
		))
	else:
		return Input.get_joy_name(device)
