extends Node

@export var theme: Theme

var turn: = 0
var game_completed: = false

var player_type: int

@export var WIN_CONDITION = 3

@onready var main: = get_parent()

signal turn_changed

func start_game(session: Session):
	var types: = [ Piece.Types.X, Piece.Types.O ]
	print("game starting")

	for player_id in session.player_ids:
		var type: int = types.pop_at(randi() % types.size())

		set_player_type.rpc_id(player_id, type)

@rpc("any_peer")
func set_turn(_turn: int):
	%Game.turn = _turn
	turn_changed.emit()

@rpc("any_peer")
func set_player_type(type: int):
	player_type = type

@rpc("any_peer")
func restart():
	game_completed = false
	turn = 0
	%Board.empty_board()
	%Strike.reset()

	main.show_text("X's turn.")
	main.show_hint("Click on any cell on the board.")

func _on_game_completed():
	game_completed = true
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

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and game_completed:
			restart.rpc()

	# ignore any further input processing if someone has won
	if game_completed:
		return

	# only take mouse inputs if the cursor is inside the board's area
	if event is InputEventMouseButton or event is InputEventScreenTouch:
		%Networking.poll_turn.rpc_id(1)

		await turn_changed

		var current_type: = turn % 2 + Piece.Types.X

		if player_type != current_type:
			return

		if (event.position.x >= %Board.position.x and
			event.position.x <= (%Board.position.x + %Board.BOARD_SIZE.x) and
			event.position.y >= %Board.position.y and
			event.position.y <= (%Board.position.y + %Board.BOARD_SIZE.y)):

			if event is InputEventMouseButton and event.is_pressed():
				var cell = ((event.position - %Board.position)/(%Board.CELL_SIZE)).floor()

				if not %Board.get_cell_type(cell):
					%Board.set_cell_type.rpc(cell, current_type)
					%Board.check()

					%Networking.request_turn_advance.rpc_id(1)

					# TODO: Sync text over server
					main.show_text(("O" if turn % 2 else "X") + "'s turn.")

func _ready():
	restart()

func _on_restart_pressed() -> void:
	restart.rpc()
