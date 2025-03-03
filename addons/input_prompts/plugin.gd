@tool
extends EditorPlugin

const AUTOLOAD_NAME = "InputPrompts"

func _enter_tree():
	add_autoload_singleton(
		AUTOLOAD_NAME,
		"res://addons/input_prompts/input_prompts.gd"
	)

func _exit_tree():
	remove_autoload_singleton(AUTOLOAD_NAME)
