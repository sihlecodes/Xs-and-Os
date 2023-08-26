extends Node

class_name Client

@export var main: Main

var player_type: int
var session_id: int # TODO: implement logic

@rpc
func check():
	# TODO: show winner text
	if %Board.check():
		pass
#		%Server.request_game_completed()

@rpc
func show_restart_confirmation():
	var success: = func(): %Server.request_restart.rpc_id(1)
	var failure: = func(): %Server.request_restart_cancel.rpc_id(1)

	await %RestartConfirmation.async_popup(success, failure)

@rpc
func show_current_player(current_player_type: int):
	if %Game.is_over:
		return

	var current_player_name: String = "%s's" % Piece.Types.find_key(current_player_type)

	if current_player_type == player_type:
		current_player_name = "YOUR"

	show_text("%s turn" % current_player_name)

@rpc
func show_text(text: String):
	main.show_text(text)

@rpc
func show_hint(text: String):
	main.show_hint(text)

@rpc
func set_cell_type(cell: Vector2, type: int):
	%Board.set_cell_type(cell, type)

@rpc
func restart():
	%Game.restart()

@rpc
func set_turn(_turn: int):
	%Game.set_turn(_turn)

@rpc
func set_player_type(type: int):
	player_type = type

func _on_connection_success():
	print("Connection was successful")

func _on_connection_failed():
	print("Connection error")
