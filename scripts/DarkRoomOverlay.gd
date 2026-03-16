extends Node2D
class_name DarkRoomOverlay

@export var darkness_color := Color(0.0, 0.0, 0.02, 0.92)
@export var light_radius := 120.0
@export var light_falloff := 60.0

var _player: Node2D


func _ready() -> void:
	z_index = 40


func _process(_delta: float) -> void:
	if _player == null or not is_instance_valid(_player):
		_player = get_tree().get_first_node_in_group("player") as Node2D
	queue_redraw()


func _draw() -> void:
	var center := Vector2.ZERO
	if _player != null and is_instance_valid(_player):
		center = _player.global_position - global_position

	# Draw dark overlay as a large rect with a circular gradient hole
	var extent := 2000.0
	var rect := Rect2(-extent, -extent, extent * 2, extent * 2)

	# Outer darkness (4 rectangles around the light circle)
	var total_radius := light_radius + light_falloff

	# Draw full dark overlay first
	draw_rect(rect, darkness_color, true)

	# Cut a transparent hole using layered circles (lighter toward center)
	var steps := 12
	for i in range(steps, -1, -1):
		var t := float(i) / float(steps)
		var r := light_radius + light_falloff * t
		var alpha := darkness_color.a * t
		var c := Color(darkness_color.r, darkness_color.g, darkness_color.b, alpha)
		_draw_circle_filled(center, r, c, 32)

	# Fully clear center
	_draw_circle_filled(center, light_radius * 0.7, Color(0, 0, 0, 0), 32)


func _draw_circle_filled(center: Vector2, radius: float, color: Color, segments: int) -> void:
	var points := PackedVector2Array()
	var colors := PackedColorArray()
	for i in segments:
		var angle := TAU * float(i) / float(segments)
		points.append(center + Vector2(cos(angle), sin(angle)) * radius)
		colors.append(color)
	draw_polygon(points, colors)
