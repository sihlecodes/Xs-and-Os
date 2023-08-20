extends PopupPanel

signal on_response(response: bool)

var explicit_response: = false

func _ready() -> void:
	%yes.pressed.connect(func(): _on_response_button_pressed(true))
	%no.pressed.connect(func(): _on_response_button_pressed(false))

func async_popup(success: Callable, failure: Callable):
	# TODO: fix logic
	# TODO: account for null callbacks
	var callback: = func(accepted: bool): (success if accepted else failure).call()
	on_response.connect(callback, CONNECT_ONE_SHOT)

	popup()

	await on_response

func _on_response_button_pressed(accepted: bool):
	explicit_response = true
	on_response.emit(accepted)
	print("explicit")

func _on_close_requested() -> void:
	if not explicit_response:
		on_response.emit(false)

	print("implicit")
