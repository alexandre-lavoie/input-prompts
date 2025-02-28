extends Node

const AXIS_MIN = 0.5

## Device to listen to
@export var device: int = -2

@onready var device_prompt: DevicePrompt = $Device
@onready var input_preview: TextureRect = $Input
@onready var device_label: Label = $Name
@onready var action_label: Label = $Action

func _ready() -> void:
	self.device_label.text = ""
	self.action_label.text = ""
	self.input_preview.texture = null
	self.device_prompt.devices = [self.device]

func _input(event: InputEvent) -> void:
	if self.device < -1:
		return
	elif self.device == -1:
		match str(event.get_class()):
			"InputEventKey", "InputEventMouseButton":
				if not event.is_pressed():
					return
			_: return
	else:
		if self.device != event.device:
			return

		match str(event.get_class()):
			"InputEventJoypadButton":
				if not event.is_pressed():
					return
			"InputEventJoypadMotion":
				if abs(event.axis_value) <= AXIS_MIN:
					return
			_: return

	self.device_label.text = InputPrompts.get_device_name(self.device)

	var textures = InputPrompts.get_event_textures(self.device, event)
	if textures:
		self.input_preview.texture = textures[0]

		var actions = []
		for action in InputMap.get_actions():
			if InputMap.action_has_event(action, event):
				actions.push_back(action)

		self.action_label.text = ", ".join(actions)
