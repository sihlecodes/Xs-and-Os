extends Node2D

class_name Piece

var type: int

@onready var theme: Theme = get_parent().theme

const TYPES = Types.TYPES

func _init(type:int, position):
	self.position = position
	self.type = type

func _draw():
	if type == TYPES.O:
		var diameter = theme.get_constant("diameter", "O")
		draw_arc(Vector2(), diameter/2, 0, TAU, diameter, theme.get_color("stroke", "O"), theme.get_constant("stroke_width", "O"), true)
	elif type == TYPES.X:
		var width = theme.get_constant("width", "X")
		var height = theme.get_constant("height", "X")

		draw_line(Vector2(-width/2, -height/2), Vector2(width/2, height/2), theme.get_color("stroke", "X"), theme.get_constant("stroke_width", "X"))
		draw_line(Vector2(width/2, -height/2), Vector2(-width/2, height/2), theme.get_color("stroke", "X"), theme.get_constant("stroke_width", "X"))
