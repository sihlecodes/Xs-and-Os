extends Node

class_name Main

# TODO: prune unused methods / properties in the code base

func show_hint(text: String):
	%hint.text = text

func show_text(text: String):
	%display.text = text

func _on_restart_pressed() -> void:
	%Server.request_restart.rpc_id(1)
