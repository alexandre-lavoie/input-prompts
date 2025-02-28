@tool
extends Resource
class_name InputPromptsBuildKeyboard

@export_subgroup("Textures")
@export var texture_root = "res://addons/input_prompts/devices/keyboard/assets"

## Texture for device
@export var device_texture: Texture

@export_subgroup("Keys")
@export var key_root = "res://addons/input_prompts/devices/keyboard/key"

## Include Shift modifier for keys
@export var shift_modifier: bool = true

## Include Ctrl modifier for keys
@export var ctrl_modifier: bool = false

## Include Alt modifier for keys
@export var alt_modifier: bool = false

## Include Meta modifier for keys
@export var meta_modifier: bool = false

@export var run_build_keys: bool:
	set(value):
		run_build_keys = false
		self.build_keys()

@export_subgroup("Keyboard")
@export var device_root = "res://addons/input_prompts/devices/keyboard"

@export var input_sort_end: Array[String] = [
	"alt",
	"shift",
	"ctrl",
	"meta"
]

@export var run_build_keyboards: bool:
	set(value):
		run_build_keyboards = false
		self.build_keyboards()

func build_keys() -> void:
	var dir = DirAccess.open(self.texture_root)

	dir.list_dir_begin()

	var file_name = dir.get_next()
	while file_name:
		if file_name.ends_with(".svg"):
			if file_name.begins_with("keyboard_"):
				var v = file_name.substr(len("keyboard_"))
				var key = v.substr(0, len(v) - len(".svg"))
				var keycode = OS.find_keycode_from_string(key.to_upper())

				if keycode == KEY_NONE:
					print("Not found: ", key)
					continue

				var texture_path = self.texture_root.path_join(file_name)
				var input = self.build_key(keycode, texture_path)

				var resource_path = self.key_root.path_join(
					"keyboard_" + key + ".tres"
				)

				ResourceSaver.save(input, resource_path)

		file_name = dir.get_next()

	dir.list_dir_end()

func build_key(keycode: int, texture_path: String) -> DeviceInputResource:
	var input = DeviceInputResource.new()

	var texture: Texture = load(texture_path)
	input.textures.push_back(texture)

	var key_input = InputEventKey.new()
	key_input.physical_keycode = keycode

	input.events.push_back(key_input)

	match keycode:
		# Skip modifier keys
		KEY_SHIFT, KEY_CTRL, KEY_META, KEY_ALT: pass
		_:
			if self.shift_modifier:
				var shift_key_input = InputEventKey.new()
				shift_key_input.physical_keycode = keycode
				shift_key_input.shift_pressed = true

				input.events.push_back(shift_key_input)

			if self.ctrl_modifier:
				var ctrl_key_input = InputEventKey.new()
				ctrl_key_input.physical_keycode = keycode
				ctrl_key_input.ctrl_pressed = true

				input.events.push_back(ctrl_key_input)

			if self.alt_modifier:
				var alt_key_input = InputEventKey.new()
				alt_key_input.physical_keycode = keycode
				alt_key_input.alt_pressed = true

				input.events.push_back(alt_key_input)

			if self.meta_modifier:
				var meta_key_input = InputEventKey.new()
				meta_key_input.physical_keycode = keycode
				meta_key_input.meta_pressed = true

				input.events.push_back(meta_key_input)

	return input

func build_keyboards() -> void:
	var dir = DirAccess.open(self.key_root)

	dir.list_dir_begin()

	var input_paths: Array[String] = []

	var file_name = dir.get_next()
	while file_name:
		if not file_name.ends_with(".tres"):
			continue

		input_paths.push_back(self.key_root.path_join(file_name))

		file_name = dir.get_next()

	dir.list_dir_end()

	var device = self.build_keyboard(input_paths)

	var resource_path = self.device_root.path_join(
		"keyboard.tres"
	)

	ResourceSaver.save(device, resource_path)

func build_keyboard(input_paths: Array[String]) -> DeviceMappingResource:
	var device = DeviceMappingResource.new()

	device.names.push_back("Keyboard")
	device.textures.push_back(self.device_texture)

	var input_path_copy: Array[String] = input_paths.slice(0)

	input_path_copy.sort()
	input_path_copy.reverse()

	var ordered_input_paths: Array[String] = []
	for input_path in input_path_copy:
		var end = false

		for v in self.input_sort_end:
			if input_path.ends_with("_" + v + ".tres"):
				end = true
				break

		if end:
			ordered_input_paths.push_back(input_path)
		else:
			ordered_input_paths.push_front(input_path)

	for input_path in ordered_input_paths:
		var input: DeviceInputResource = load(input_path)

		device.inputs.push_back(input)

	return device
