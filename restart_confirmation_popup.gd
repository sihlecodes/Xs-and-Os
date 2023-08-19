extends PopupPanel

signal accepted
signal declined

func _ready() -> void:
	%yes.pressed.connect(func(): accepted.emit())
	%no.pressed.connect(func(): declined.emit())
