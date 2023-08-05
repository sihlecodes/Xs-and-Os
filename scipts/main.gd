extends Node

class_name Game

@export var theme: Theme

var turn: = 0
var game_completed: = false

@export var WIN_CONDITION = 3

func restart():
	game_completed = false
	turn = 0
	%Board.empty_board()
	%Strike.reset()

	show_text("X's turn.")
	show_hint("Click on any cell on the board.")

func show_hint(text: String):
	%hint.text = text

func show_text(text: String):
	%display.text = text

func _on_game_completed():
	game_completed = true
	show_hint("Press RESTART.")

func _on_game_tied():
	show_text("Game tied. :C")

func _on_game_won(_match: Board.Match):
	%Strike.animate(
		%Board.position + %Board.get_effective_cell_position(_match.start) + %Board.CELL_SIZE/2,
		%Board.position + %Board.get_effective_cell_position(_match.end) + %Board.CELL_SIZE/2)

	match _match.type:
		Piece.Types.X:
			show_text("X won the game!")
		Piece.Types.O:
			show_text("O won the game!")

func _input(event: InputEvent):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and game_completed:
			restart()

	# ignore any further input processing if someone has won
	if game_completed:
		return

	# only take mouse inputs if the cursor is inside the board's area
	if event is InputEventMouse or event is InputEventScreenTouch:
		if (event.position.x >= %Board.position.x and
			event.position.x <= (%Board.position.x + %Board.BOARD_SIZE.x) and
			event.position.y >= %Board.position.y and
			event.position.y <= (%Board.position.y + %Board.BOARD_SIZE.y)):

			if event is InputEventMouseButton and event.is_pressed():
				var cell = ((event.position - %Board.position)/(%Board.CELL_SIZE)).floor()

				if not %Board.get_cell_type(cell):
					%Board.set_cell_type(cell, turn % 2 + Piece.Types.X)

					turn += 1

					show_text(("O" if turn % 2 else "X") + "'s turn.")
					%Board.check()

func _ready():
	restart()
