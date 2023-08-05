extends Node2D

var start: Vector2
var end: Vector2

@onready var theme: Theme = get_node("/root/main").theme

func set_positions(start, end):
	self.start = start
	self.end = end

func reset():
	start = Vector2()
	end = Vector2()

func play():
	var tween: = create_tween()
	var target := end

	end = start
	tween.tween_property(self, "end", target, 0.35).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.play()

func _draw():
	draw_line(start, end, theme.get_color("stroke", "Strike"), theme.get_constant("stroke_width", "Strike"))

func _process(delta: float):
	queue_redraw()
