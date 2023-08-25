extends Node

class_name Game

@export var theme: Theme
@export var WIN_CONDITION = 3

var turn: = 0
var game_completed: = false

@onready var main: = get_parent()

signal turn_changed

func set_turn(_turn: int):
	turn = _turn
	turn_changed.emit()

func restart():
	game_completed = false
	%Board.empty_board()
	%Strike.reset()

	%Server.request_update_display.rpc_id(1)
	main.show_hint("Click on any cell on the board.")

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and game_completed:
			main._on_restart_pressed()

	# ignore any further input processing if someone has won
	if game_completed:
		return

	# only take mouse inputs if the cursor is inside the board's area
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		%Server.request_turn.rpc_id(1)

		await turn_changed

		var current_type: = turn % 2 + Piece.Types.X

		if %Client.player_type != current_type:
			return

		if (event.position.x >= %Board.position.x and
			event.position.x <= (%Board.position.x + %Board.BOARD_SIZE.x) and
			event.position.y >= %Board.position.y and
			event.position.y <= (%Board.position.y + %Board.BOARD_SIZE.y)):

			if event is InputEventMouseButton and event.is_pressed():
				var cell = ((event.position - %Board.position)/(%Board.CELL_SIZE)).floor()

				if not %Board.get_cell_type(cell):
					%Server.request_set_cell_type.rpc_id(1, cell, %Client.player_type)

					await %Board.cell_type_changed

					%Server.request_check.rpc_id(1)
					%Server.request_turn_advance.rpc_id(1)
