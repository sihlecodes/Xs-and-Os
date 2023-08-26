extends Node

class_name Game

@export var theme: Theme
@export var WIN_CONDITION = 3

var turn: = 0
var is_over: = false

@onready var main: = get_parent()

signal game_completed
signal game_won(match_)
signal game_tied
signal turn_changed

func declare_winner(match_: Board.Match):
	game_completed.emit()
	game_won.emit(match_)

func declare_draw():
	game_completed.emit()
	game_tied.emit()

func set_turn(_turn: int):
	turn = _turn
	turn_changed.emit()

func restart():
	is_over = false
	%Board.empty_board()
	%Strike.reset()

	%Server.request_update_display.rpc_id(1)
	main.show_hint("Click on any cell on the board.")

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and is_over:
			main._on_restart_pressed()

	# ignore any further input processing if someone has won
	if is_over:
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

func _on_game_completed():
	is_over = true
	main.show_hint("Press RESTART.")

func _on_game_tied():
	main.show_text("Game tied. :C")

func _on_game_won(_match: Board.Match):
	%Strike.animate(
		%Board.position + %Board.get_effective_cell_position(_match.start) + %Board.CELL_SIZE/2,
		%Board.position + %Board.get_effective_cell_position(_match.end) + %Board.CELL_SIZE/2)

	match _match.type:
		Piece.Types.X:
			main.show_text("X won the game!")
		Piece.Types.O:
			main.show_text("O won the game!")
