extends Node2D

class_name Piece

enum Types { NULL = -1, EMPTY, X, O }
var type: int

@onready var theme: Theme = get_parent().theme

@warning_ignore("shadowed_variable", "shadowed_variable_base_class")
func _init(type: int, position: Vector2):
	self.position = position
	self.type = type

func _draw():
	if type == Types.O:
		var diameter: float = theme.get_constant("diameter", "O")
		draw_arc(Vector2(), diameter/2, 0, TAU, diameter, theme.get_color("stroke", "O"), theme.get_constant("stroke_width", "O"), true)

	elif type == Types.X:
		var width: float = theme.get_constant("width", "X")
		var height: float = theme.get_constant("height", "X")

		draw_line(Vector2(-width/2, -height/2), Vector2(width/2, height/2), theme.get_color("stroke", "X"), theme.get_constant("stroke_width", "X"))
		draw_line(Vector2(width/2, -height/2), Vector2(-width/2, height/2), theme.get_color("stroke", "X"), theme.get_constant("stroke_width", "X"))
