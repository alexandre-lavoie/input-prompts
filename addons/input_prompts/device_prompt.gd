@icon("res://addons/input_prompts/icons/device.svg")

extends Node
class_name DevicePrompt

## List of device indices to display
@export var devices: Array[int]:
	set(value):
		devices = value
		self.reset()

## Rate of change in seconds of the textures
@export_range(0, 4096, 0.001) var switch_rate: float = 1:
	set(value):
		switch_rate = value

		if self._timer:
			self._timer.wait_time = switch_rate

## (Optional) Sprite to update with texture
@export var sprite_2d: Sprite2D

## (Optional) TextureRect to change with texture
@export var texture_rect: TextureRect

## (Optional) Default texture to show if there is no texture for devices
@export var default_texture: Texture

## Device textures
var _textures: Array[Texture]

## Current device texture to show
var _texture_index: int

## Timer to switch texture
var _timer: Timer

## Checks if this was initialized
var _initialized = false

func _ready() -> void:
	self._initialized = true

	self._timer = Timer.new()
	self._timer.wait_time = self.switch_rate
	self._timer.timeout.connect(self.next_texture)

	self.add_child(self._timer)
	self._timer.start()

	Input.joy_connection_changed.connect(self._joy_connection_changed)

	self.reset()

## Resets the display
func reset() -> void:
	if not self._initialized:
		return

	self._textures = []

	var connected_devices = [-1]
	connected_devices.append_array(
		Input.get_connected_joypads()
	)

	for device in connected_devices:
		if device >= -1 and device not in self.devices:
			continue

		self._textures.append_array(
			InputPrompts.get_device_textures(device)
		)

	self._texture_index = 0
	self.update_textures()

## Switches to the next texture
func next_texture() -> void:
	if self._texture_index < 0:
		self._texture_index = 0

	if len(self._textures) == 0:
		self._texture_index = 0
		return

	self._texture_index = (self._texture_index + 1) % len(self._textures)
	self.update_textures()

## Updates the textures
func update_textures() -> void:
	var texture: Texture

	if self._texture_index < 0 or self._texture_index >= len(self._textures):
		texture = self.default_texture
	else:
		texture = self._textures[self._texture_index]

	if self.sprite_2d:
		self.sprite_2d.texture = texture

	if self.texture_rect:
		self.texture_rect.texture = texture

func _joy_connection_changed(device: int, connected: bool) -> void:
	for dev in self.devices:
		if dev == device:
			self.reset()
			return
