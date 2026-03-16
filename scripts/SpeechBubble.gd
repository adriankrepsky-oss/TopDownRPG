extends Node2D
class_name SpeechBubble

var text := ""
var max_width := 260.0
var padding := Vector2(14, 10)
var font_size := 16
var tail_height := 12.0
var bg_color := Color(0.04, 0.06, 0.1, 0.95)
var border_color := Color(0.45, 0.55, 0.7, 0.9)
var text_color := Color(1.0, 1.0, 1.0, 1.0)
var lifetime := -1.0


func _ready() -> void:
	z_index = 100


func _process(delta: float) -> void:
	if lifetime > 0.0:
		lifetime -= delta
		if lifetime <= 0.0:
			queue_free()
			return
	queue_redraw()


func setup(message: String, duration: float = -1.0) -> void:
	text = message
	lifetime = duration
	queue_redraw()


func _draw() -> void:
	if text.is_empty():
		return

	var font := ThemeDB.fallback_font
	if font == null:
		return

	var lines := _wrap_text(font, text, max_width - padding.x * 2)
	var line_height := font.get_height(font_size)
	var text_height := float(lines.size()) * line_height
	var text_width := 0.0
	for line in lines:
		text_width = maxf(text_width, font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x)

	var box_width := text_width + padding.x * 2
	var box_height := text_height + padding.y * 2
	var box_x := -box_width * 0.5
	var box_y := -box_height - tail_height

	# Background with rounded corners
	var bg_rect := Rect2(box_x, box_y, box_width, box_height)
	_draw_rounded_rect(bg_rect, bg_color, 6.0)
	_draw_rounded_rect_outline(bg_rect, border_color, 6.0, 2.0)

	# Tail pointer
	var tail_points := PackedVector2Array([
		Vector2(-6, box_y + box_height),
		Vector2(6, box_y + box_height),
		Vector2(0, 0)
	])
	draw_colored_polygon(tail_points, bg_color)

	# Text
	var y_offset := box_y + padding.y + line_height * 0.75
	for line in lines:
		var line_width := font.get_string_size(line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		var lx := -line_width * 0.5
		draw_string(font, Vector2(lx, y_offset), line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)
		y_offset += line_height


func _wrap_text(font: Font, full_text: String, width: float) -> PackedStringArray:
	var result: PackedStringArray = PackedStringArray()
	var words := full_text.split(" ")
	var current_line := ""
	for word in words:
		var test_line := (current_line + " " + word).strip_edges() if not current_line.is_empty() else word
		var test_width := font.get_string_size(test_line, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size).x
		if test_width > width and not current_line.is_empty():
			result.append(current_line)
			current_line = word
		else:
			current_line = test_line
	if not current_line.is_empty():
		result.append(current_line)
	if result.is_empty():
		result.append(full_text)
	return result


func _draw_rounded_rect(rect: Rect2, color: Color, radius: float) -> void:
	var points := PackedVector2Array()
	var corners := [
		[Vector2(rect.position.x + radius, rect.position.y + radius), PI, PI * 1.5],
		[Vector2(rect.end.x - radius, rect.position.y + radius), PI * 1.5, TAU],
		[Vector2(rect.end.x - radius, rect.end.y - radius), 0.0, PI * 0.5],
		[Vector2(rect.position.x + radius, rect.end.y - radius), PI * 0.5, PI],
	]
	for corner in corners:
		var center: Vector2 = corner[0]
		var start_angle: float = corner[1]
		var end_angle: float = corner[2]
		for i in 6:
			var angle := start_angle + (end_angle - start_angle) * float(i) / 5.0
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	draw_colored_polygon(points, color)


func _draw_rounded_rect_outline(rect: Rect2, color: Color, radius: float, width: float) -> void:
	var points := PackedVector2Array()
	var corners := [
		[Vector2(rect.position.x + radius, rect.position.y + radius), PI, PI * 1.5],
		[Vector2(rect.end.x - radius, rect.position.y + radius), PI * 1.5, TAU],
		[Vector2(rect.end.x - radius, rect.end.y - radius), 0.0, PI * 0.5],
		[Vector2(rect.position.x + radius, rect.end.y - radius), PI * 0.5, PI],
	]
	for corner in corners:
		var center: Vector2 = corner[0]
		var start_angle: float = corner[1]
		var end_angle: float = corner[2]
		for i in 6:
			var angle := start_angle + (end_angle - start_angle) * float(i) / 5.0
			points.append(center + Vector2(cos(angle), sin(angle)) * radius)
	points.append(points[0])
	draw_polyline(points, color, width, true)
