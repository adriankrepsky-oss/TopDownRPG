extends Node2D
class_name BoundaryOverlay

@export var outer_extent := Vector2(960.0, 720.0)
@export var inner_extent := Vector2(850.0, 640.0)
@export var top_gap_width := 0.0
@export var top_gap_offset := 0.0
@export var bottom_gap_width := 0.0
@export var bottom_gap_offset := 0.0
@export var left_gap_height := 0.0
@export var left_gap_offset := 0.0
@export var right_gap_height := 0.0
@export var right_gap_offset := 0.0
@export var fill_color := Color(0.01, 0.01, 0.02, 0.92)
@export var line_color := Color(0.14, 0.15, 0.18, 0.95)
@export var line_width := 6.0


func _ready() -> void:
	z_index = 10
	queue_redraw()


func _draw() -> void:
	_draw_horizontal_band(-outer_extent.y, -inner_extent.y, top_gap_width, top_gap_offset)
	_draw_horizontal_band(inner_extent.y, outer_extent.y, bottom_gap_width, bottom_gap_offset)
	_draw_vertical_band(-outer_extent.x, -inner_extent.x, left_gap_height, left_gap_offset)
	_draw_vertical_band(inner_extent.x, outer_extent.x, right_gap_height, right_gap_offset)
	_draw_inner_outline()


func _draw_horizontal_band(y0: float, y1: float, gap_width: float, gap_offset: float) -> void:
	if gap_width <= 0.0:
		draw_rect(Rect2(Vector2(-outer_extent.x, y0), Vector2(outer_extent.x * 2.0, y1 - y0)), fill_color, true)
		return

	var gap_half := gap_width * 0.5
	var gap_left := clampf(gap_offset - gap_half, -outer_extent.x, outer_extent.x)
	var gap_right := clampf(gap_offset + gap_half, -outer_extent.x, outer_extent.x)
	draw_rect(Rect2(Vector2(-outer_extent.x, y0), Vector2(gap_left + outer_extent.x, y1 - y0)), fill_color, true)
	draw_rect(Rect2(Vector2(gap_right, y0), Vector2(outer_extent.x - gap_right, y1 - y0)), fill_color, true)


func _draw_vertical_band(x0: float, x1: float, gap_height: float, gap_offset: float) -> void:
	if gap_height <= 0.0:
		draw_rect(Rect2(Vector2(x0, -outer_extent.y), Vector2(x1 - x0, outer_extent.y * 2.0)), fill_color, true)
		return

	var gap_half := gap_height * 0.5
	var gap_top := clampf(gap_offset - gap_half, -outer_extent.y, outer_extent.y)
	var gap_bottom := clampf(gap_offset + gap_half, -outer_extent.y, outer_extent.y)
	draw_rect(Rect2(Vector2(x0, -outer_extent.y), Vector2(x1 - x0, gap_top + outer_extent.y)), fill_color, true)
	draw_rect(Rect2(Vector2(x0, gap_bottom), Vector2(x1 - x0, outer_extent.y - gap_bottom)), fill_color, true)


func _draw_inner_outline() -> void:
	if top_gap_width <= 0.0:
		draw_line(Vector2(-inner_extent.x, -inner_extent.y), Vector2(inner_extent.x, -inner_extent.y), line_color, line_width)
	else:
		var gap_half := top_gap_width * 0.5
		var gap_left := clampf(top_gap_offset - gap_half, -inner_extent.x, inner_extent.x)
		var gap_right := clampf(top_gap_offset + gap_half, -inner_extent.x, inner_extent.x)
		draw_line(Vector2(-inner_extent.x, -inner_extent.y), Vector2(gap_left, -inner_extent.y), line_color, line_width)
		draw_line(Vector2(gap_right, -inner_extent.y), Vector2(inner_extent.x, -inner_extent.y), line_color, line_width)

	if bottom_gap_width <= 0.0:
		draw_line(Vector2(-inner_extent.x, inner_extent.y), Vector2(inner_extent.x, inner_extent.y), line_color, line_width)
	else:
		var bottom_gap_half := bottom_gap_width * 0.5
		var bottom_gap_left := clampf(bottom_gap_offset - bottom_gap_half, -inner_extent.x, inner_extent.x)
		var bottom_gap_right := clampf(bottom_gap_offset + bottom_gap_half, -inner_extent.x, inner_extent.x)
		draw_line(Vector2(-inner_extent.x, inner_extent.y), Vector2(bottom_gap_left, inner_extent.y), line_color, line_width)
		draw_line(Vector2(bottom_gap_right, inner_extent.y), Vector2(inner_extent.x, inner_extent.y), line_color, line_width)

	if left_gap_height <= 0.0:
		draw_line(Vector2(-inner_extent.x, -inner_extent.y), Vector2(-inner_extent.x, inner_extent.y), line_color, line_width)
	else:
		var left_gap_half := left_gap_height * 0.5
		var left_gap_top := clampf(left_gap_offset - left_gap_half, -inner_extent.y, inner_extent.y)
		var left_gap_bottom := clampf(left_gap_offset + left_gap_half, -inner_extent.y, inner_extent.y)
		draw_line(Vector2(-inner_extent.x, -inner_extent.y), Vector2(-inner_extent.x, left_gap_top), line_color, line_width)
		draw_line(Vector2(-inner_extent.x, left_gap_bottom), Vector2(-inner_extent.x, inner_extent.y), line_color, line_width)

	if right_gap_height <= 0.0:
		draw_line(Vector2(inner_extent.x, -inner_extent.y), Vector2(inner_extent.x, inner_extent.y), line_color, line_width)
	else:
		var right_gap_half := right_gap_height * 0.5
		var right_gap_top := clampf(right_gap_offset - right_gap_half, -inner_extent.y, inner_extent.y)
		var right_gap_bottom := clampf(right_gap_offset + right_gap_half, -inner_extent.y, inner_extent.y)
		draw_line(Vector2(inner_extent.x, -inner_extent.y), Vector2(inner_extent.x, right_gap_top), line_color, line_width)
		draw_line(Vector2(inner_extent.x, right_gap_bottom), Vector2(inner_extent.x, inner_extent.y), line_color, line_width)
