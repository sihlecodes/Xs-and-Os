extends Node2D

var start: Vector2
var end: Vector2

@export var theme: Theme

@export_group("rendering")
@export var overshoot: = 20
@export var duration: = 0.35

func reset():
	start = Vector2()
	end = Vector2()

@warning_ignore("shadowed_variable")
func animate(start: Vector2, end: Vector2):
	var tween: = create_tween()

	var overshoot = start.direction_to(end) * self.overshoot

	self.start = start - overshoot
	self.end = self.start

	tween.tween_property(self, "end", end + overshoot, duration).set_trans(Tween.TRANS_QUART).set_ease(Tween.EASE_IN)
	tween.play()

func _draw():
	draw_line(start, end, theme.get_color("stroke", "Strike"), theme.get_constant("stroke_width", "Strike"))

func _process(_delta: float):
	queue_redraw()
