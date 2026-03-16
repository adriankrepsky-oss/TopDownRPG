extends Node2D

var lifetime := 0.12
var max_lifetime := 0.12


func _ready() -> void:
	z_index = 20


func _process(delta: float) -> void:
	lifetime -= delta
	if lifetime <= 0.0:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var t := clampf(lifetime / max_lifetime, 0.0, 1.0)
	var r := 16.0 * t
	var alpha := t
	for i in 6:
		var angle := TAU * float(i) / 6.0 + PI * 0.16
		var end := Vector2.from_angle(angle) * r
		draw_line(Vector2.ZERO, end, Color(1.0, 0.95, 0.75, alpha), 2.5, true)
	draw_circle(Vector2.ZERO, 5.0 * t, Color(1.0, 1.0, 0.92, alpha * 0.9))
