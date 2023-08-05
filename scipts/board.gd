extends Node2D

class_name Board

var ROWS = 3
var COLS = 3

var _board  = []
var _pieces = []

@onready var theme: Theme = get_parent().theme

const TYPES = Types.TYPES

# values derived from the board art asset
const PADDING: = Vector2(4, 4)
const SPACING: = PADDING/2
const BOARD_SIZE: = Vector2(376, 376)
const CELL_SIZE: = Vector2(120, 120) + PADDING

signal game_completed
signal game_won(match_)
signal game_tied

func get_board():
	return _board

func generate_empty_board():
	var new_board = []

	for y in range(ROWS):
		new_board.append([])
		for x in range(COLS):
			new_board[y].append(TYPES.EMPTY)
	return new_board

func empty_board():
	_board = generate_empty_board()

	for piece in _pieces:
		piece.queue_free()

	_pieces = []

func is_valid_cell(cell:Vector2) -> bool:
	return  cell.x >= 0 and cell.x < COLS and cell.y >= 0 and cell.y < ROWS

func set_cell_type(cell:Vector2, type:int):
	if is_valid_cell(cell):
		_board[cell.y][cell.x] = type

		var piece = Piece.new(type, CELL_SIZE * cell + CELL_SIZE/2 + SPACING)
		_pieces.append(piece)
		add_child(piece)

func get_cell_type(cell:Vector2) -> int:
	if is_valid_cell(cell):
		return _board[cell.y][cell.x]
	return TYPES.NULL

class Match:
	var start: Vector2
	var end: Vector2
	var direction: Vector2
	var type: int

	func _init(type:int, start:Vector2, end:Vector2, direction:Vector2):
		self.type = type
		self.start = start
		self.end = end
		self.direction = direction

	# DEBGGING HELPER
	func _to_string():
		return "%s %s -> %s" % ["X" if type == Piece.TYPES.X else "O", start, end]

func check():
	var empty_count = 0
	for y in COLS:
		for x in ROWS:
			var cell = Vector2(x, y)
			empty_count += 1 if get_cell_type(cell) == TYPES.EMPTY else 0

			var matches = [
				check_type_on_board(cell, TYPES.X),
				check_type_on_board(cell, TYPES.O)]

			for match_ in matches:
				if match_:
					emit_signal("game_completed")
					emit_signal("game_won", match_)
					return

	if empty_count == 0:
		emit_signal("game_completed")
		emit_signal("game_tied")

# returns true if a win condition for a type at a cell is found on the board
func check_type_on_board(cell:Vector2, type:int) -> Match:
	if not is_valid_cell(cell) or not get_cell_type(cell) == type:
		return null

	var directions = [
		Vector2.RIGHT, Vector2.DOWN,
		Vector2.DOWN + Vector2.LEFT,
		Vector2.DOWN + Vector2.RIGHT,
		Vector2.UP   + Vector2.RIGHT,
		Vector2.UP   + Vector2.LEFT]

	for direction in directions:
		if check_type_in_direction(cell, direction, type):
			return Match.new(type, cell, cell + direction * (get_parent().WIN_CONDITION-1), direction)

	return null

# returns true if a win condition is met in the direction given on the board
func check_type_in_direction(cell:Vector2, direction:Vector2, type:int, streak:=1) -> bool:
	if streak == get_parent().WIN_CONDITION:
		return true
	if not is_valid_cell(cell):
		return false

	if get_cell_type(cell + direction) == type:
		return check_type_in_direction(cell + direction, direction, type, streak+1)
	return false

func _ready():
	_board = generate_empty_board()

func _draw():
	var points = [Vector2(), Vector2.RIGHT * BOARD_SIZE, BOARD_SIZE, Vector2.DOWN * BOARD_SIZE, Vector2()]

	var border_color: = theme.get_color("border", "Board")
	var background_color: = theme.get_color("background", "Board")

	draw_rect(Rect2(points[0], points[2]), background_color, true)

	for n in (points.size()-1):
		draw_line(points[n], points[n+1], border_color, 4)

	draw_line(Vector2.RIGHT * CELL_SIZE, Vector2(CELL_SIZE.x, BOARD_SIZE.y), border_color, 2)
	draw_line(Vector2.RIGHT * CELL_SIZE * 2, Vector2(CELL_SIZE.x*2, BOARD_SIZE.y), border_color, 2)

	draw_line(Vector2.DOWN * CELL_SIZE, Vector2(BOARD_SIZE.x, CELL_SIZE.y), border_color, 2)
	draw_line(Vector2.DOWN * CELL_SIZE * 2, Vector2(BOARD_SIZE.x, CELL_SIZE.y*2), border_color, 2)
