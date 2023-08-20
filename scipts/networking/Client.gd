extends Node

class_name Client

@export var main: Main

var player_type: int
var session_id: int # TODO: implement logic

@rpc
func check():
	%Board.check()

@rpc
func show_restart_confirmation():
	# TODO: send respond back to the server
	var success: = func(): %Server.request_restart.rpc_id(1)
	await %RestartConfirmation.async_popup(success, func(): pass)

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
