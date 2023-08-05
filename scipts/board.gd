@tool
extends Control

class_name Board

@export var ROWS = 3
@export var COLS = 3

var _board  = []
var _pieces = []

# values derived from the board art asset
@export var border_width_inner: = 2
@export var border_width_outer: = 4

@export var BOARD_SIZE: = Vector2(376, 376) :
	set(value):
		BOARD_SIZE = value
		size = value

@export var CELL_SIZE: Vector2 :
	get:
		return get_effective_cell_size()

signal game_completed
signal game_won(match_)
signal game_tied

func generate_empty_board():
	var new_board = []

	for y in range(ROWS):
		new_board.append([])
		for x in range(COLS):
			new_board[y].append(Piece.Types.EMPTY)
	return new_board

func empty_board():
	_board = generate_empty_board()

	for piece in _pieces:
		piece.queue_free()

	_pieces = []

func is_within_bounds(cell:Vector2) -> bool:
	return cell.x >= 0 and cell.x < COLS and cell.y >= 0 and cell.y < ROWS

func set_cell_type(cell:Vector2, type:int):
	if is_within_bounds(cell):
		_board[cell.y][cell.x] = type

		var piece = Piece.new(type, get_effective_cell_position(cell) + CELL_SIZE/2)

		_pieces.append(piece)
		add_child(piece)

func get_effective_cell_size() -> Vector2:
	var effective_board_size: = BOARD_SIZE - (Vector2.ONE * border_width_outer * 2)

	effective_board_size.x -= border_width_inner * (COLS - 1)
	effective_board_size.y -= border_width_inner * (ROWS - 1)

	return effective_board_size / Vector2(COLS, ROWS)

func get_effective_cell_position(cell: Vector2) -> Vector2:
	var effective_cell_size: = get_effective_cell_size()
	var border_size_outer: = Vector2.ONE * border_width_outer / 2
	var effective_cell_position: = border_size_outer

	effective_cell_position.x += (effective_cell_size.x + border_width_inner) * cell.x
	effective_cell_position.y += (effective_cell_size.y + border_width_inner) * cell.y

	if cell.x == COLS:
		effective_cell_position.x += border_size_outer.x

	if cell.y == ROWS:
		effective_cell_position.y += border_size_outer.y

	return effective_cell_position

func get_cell_type(cell:Vector2) -> int:
	if is_within_bounds(cell):
		return _board[cell.y][cell.x]
	return Piece.Types.NULL

class Match extends RefCounted:
	var start: Vector2
	var end: Vector2
	var direction: Vector2
	var type: int

	@warning_ignore("shadowed_variable")
	func _init(type: int, start: Vector2, end: Vector2, direction: Vector2):
		self.type = type
		self.start = start
		self.end = end
		self.direction = direction

	# DEBGGING HELPER
	func _to_string():
		return "%s %s -> %s" % ["X" if type == Piece.Types.X else "O", start, end]

func check():
	var empty_count = 0
	for y in COLS:
		for x in ROWS:
			var cell = Vector2(x, y)

			if not get_cell_type(cell):
				empty_count += 1

			var matches = [
				check_type_on_board(cell, Piece.Types.X),
				check_type_on_board(cell, Piece.Types.O)]

			for match_ in matches:
				if match_:
					game_completed.emit()
					game_won.emit(match_)
					return

	if empty_count == 0:
		game_completed.emit()
		game_tied.emit()

# returns true if a win condition for a type at a cell is found on the board
func check_type_on_board(cell: Vector2, type: int) -> Match:
	if not is_within_bounds(cell) or not get_cell_type(cell) == type:
		return

	var directions = [
		Vector2.RIGHT, Vector2.DOWN,
		Vector2.DOWN + Vector2.LEFT,
		Vector2.DOWN + Vector2.RIGHT,
		Vector2.UP   + Vector2.RIGHT,
		Vector2.UP   + Vector2.LEFT]

	for direction in directions:
		if check_type_in_direction(cell, direction, type):
			return Match.new(type, cell, cell + direction * (get_parent().WIN_CONDITION-1), direction)

	return

# returns true if a win condition is met in the direction given on the board
func check_type_in_direction(cell: Vector2, direction: Vector2, type: int, streak: = 1) -> bool:
	if streak == get_parent().WIN_CONDITION:
		return true

	if not is_within_bounds(cell):
		return false

	if get_cell_type(cell + direction) == type:
		return check_type_in_direction(cell + direction, direction, type, streak+1)

	return false

func _ready():
	_board = generate_empty_board()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw():
	var points = [Vector2(), Vector2.RIGHT * BOARD_SIZE, BOARD_SIZE, Vector2.DOWN * BOARD_SIZE, Vector2()]

	var border_color: = theme.get_color("border", "Board")
	var background_color: = theme.get_color("background", "Board")

	# fill and outer border
	draw_rect(Rect2(points[0], points[2]), background_color, true)
	draw_polyline(points, border_color, border_width_outer)

	# inner horizontal border lines
	for y in range(1, ROWS):
		var start: = get_effective_cell_position(Vector2(0, y))
		var end: = get_effective_cell_position(Vector2(COLS, y))

		draw_line(start, end, border_color, border_width_inner)

	# inner vertical border lines
	for x in range(1, COLS):
		var start: = get_effective_cell_position(Vector2(x, 0))
		var end: = get_effective_cell_position(Vector2(x, ROWS))

		draw_line(start, end, border_color, border_width_inner)
