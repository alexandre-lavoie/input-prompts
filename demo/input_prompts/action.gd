extends ActionPrompt

@export var label: Label

func _ready() -> void:
	self.label.text = self.action

	super._ready()
