extends PanelContainer

signal on_response(response: bool)

var explicit_response: = false

func _ready() -> void:
	%yes.pressed.connect(func(): _on_response_button_pressed(true))
	%no.pressed.connect(func(): _on_response_button_pressed(false))

func async_popup(success: Callable, failure: Callable):
	if not success:
		success = func(): pass

	if not failure:
		failure = func(): pass

	var callback: = func(accepted: bool): (success if accepted else failure).call()
	on_response.connect(callback, CONNECT_ONE_SHOT)

	show()

	print("no response yet")
	await on_response
	print("response came")

func _on_response_button_pressed(accepted: bool):
	explicit_response = true
	on_response.emit(accepted)
	print("explicit")
	hide()

func _on_close_requested() -> void:
	print("implicit")
