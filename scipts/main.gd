extends Node

@export var theme: Theme

var turn: = 0
var game_completed: = false

const TYPES = Types.TYPES
const WIN_CONDITION = 3

func restart():
	game_completed = false
	turn = 0
	$board.empty_board()
	$canvas/strike.reset()

	show_text("X's turn.")
	show_hint("Click on any cell on the board.")

func show_hint(text:String):
	$labels/hint.text = text

func show_text(text:String):
	$labels/display.text = text

func _on_game_completed():
	game_completed = true
	show_hint("Press RESTART.")

func _on_game_tied():
	_on_game_completed()
	show_text("Game tied. :C")

func _on_game_won(_match: Board.Match):
	_on_game_completed()

	$canvas/strike.set_positions(
		Board.CELL_SIZE * _match.start + Board.CELL_SIZE/2 + Board.SPACING + $board.position - _match.direction * 20,
		Board.CELL_SIZE * _match.end + Board.CELL_SIZE/2 + Board.SPACING + $board.position + _match.direction * 20)
	$canvas/strike.play()

	match _match.type:
		TYPES.X:
			show_text("X won the game!")
		TYPES.O:
			show_text("O won the game!")

func _input(event:InputEvent):
	if event is InputEventKey:
		if event.keycode == KEY_SPACE and event.is_pressed() and game_completed:
			restart()

	# ignore any further input processing if someone has won
	if game_completed:
		return

	# only take mouse inputs if the cursor is inside the board's area
	if event is InputEventMouse or event is InputEventScreenTouch:
		if (event.position.x >= $board.position.x and
			event.position.x <= ($board.position.x + Board.BOARD_SIZE.x) and
			event.position.y >= $board.position.y and
			event.position.y <= ($board.position.y + Board.BOARD_SIZE.y)):

			if event is InputEventMouseButton and event.is_pressed():
				var cell = ((event.position - $board.position)/(Board.CELL_SIZE)).floor()

				if  $board.get_cell_type(cell) == TYPES.EMPTY:
					$board.set_cell_type(cell, turn % 2 + TYPES.X)

					turn += 1
					if turn % 2:
						show_text("O's turn.")
					else:
						show_text("X's turn.")
					$board.check()

func _ready():
	$board.connect("game_completed", Callable(self, "_on_game_completed"))
	$board.connect("game_won", Callable(self, "_on_game_won"))
	$board.connect("game_tied", Callable(self, "_on_game_tied"))
	$button.connect("button_up", Callable(self, "restart"))

	$canvas/strike/tween.connect("tween_all_completed", Callable(self, "_on_animation_end"))

	var screen_size = Vector2(get_viewport().size)

	# center labels
	$labels.position = Vector2()
	$labels.size = Vector2(screen_size.x, ((screen_size - $board.BOARD_SIZE)/2).y)

	# center the button at the bottom area
	$button.position.x = ((screen_size - $button.size)/2).x
	$button.position.y = (screen_size - ($labels.size+$button.size)/2).y

	# center board
	$board.position = (screen_size - $board.BOARD_SIZE)/2

	restart()
