extends Area2D
class_name QuestPickup

signal objective_completed(completion_flag: String)

@export var prompt_text := "Search"
@export var speaker_name := "Clue"
@export var dialogue_lines: PackedStringArray = PackedStringArray(["You found something useful."])
@export var repeat_dialogue_lines: PackedStringArray = PackedStringArray(["This place is empty now."])
@export var locked_dialogue_lines: PackedStringArray = PackedStringArray(["You are missing something important."])
@export var required_flags: PackedStringArray = PackedStringArray()
@export var visible_after_flags: PackedStringArray = PackedStringArray()
@export var completion_flag := ""
@export var reward_coins := 0
@export var reward_item_id := ""
@export var reward_amount := 1
@export var completion_message := "Objective complete."
@export var primary_color := Color(0.75, 0.56, 0.24, 1.0)
@export var accent_color := Color(0.97, 0.87, 0.42, 1.0)
@export var glow_color := Color(1.0, 0.9, 0.5, 0.18)
@export var glyph_text := "!"
@export var auto_trigger := false
@export var consume_on_complete := true
@export var target_room_id := ""
@export var target_spawn_id := ""
@export var show_visuals := true

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var visuals: Node2D = $Visuals
@onready var shadow: Polygon2D = $Visuals/Shadow
@onready var glow: Polygon2D = $Visuals/Glow
@onready var body: Polygon2D = $Visuals/Body
@onready var accent: Polygon2D = $Visuals/Accent
@onready var glyph_label: Label = $Visuals/GlyphLabel

var base_visual_position := Vector2.ZERO
var time_passed := 0.0
var is_locked := false
var is_active := true
var touch_cooldown := false


func _ready() -> void:
	add_to_group("interactable")
	base_visual_position = visuals.position
	shadow.color = Color(0.03, 0.04, 0.06, 0.26)
	visuals.visible = show_visuals
	body_entered.connect(_on_body_entered)
	GameState.state_changed.connect(_refresh_state)
	_refresh_state()


func _process(delta: float) -> void:
	if not is_active or not show_visuals:
		return

	time_passed += delta
	var bob := sin(time_passed * 2.0) * 4.0
	var sway := sin(time_passed * 1.35) * 0.04
	visuals.position = base_visual_position + Vector2(0, bob)
	visuals.rotation = sway


func get_prompt_text() -> String:
	if auto_trigger or not is_active or not show_visuals:
		return ""
	return prompt_text


func interact(_player: Node) -> void:
	if not is_active:
		return

	if _is_completed():
		if not repeat_dialogue_lines.is_empty():
			_show_dialogue(repeat_dialogue_lines)
		return

	if is_locked:
		if not locked_dialogue_lines.is_empty():
			_show_dialogue(locked_dialogue_lines)
		return

	if dialogue_lines.is_empty():
		_complete_objective()
		return

	_show_dialogue(dialogue_lines, Callable(self, "_complete_objective"))


func _on_body_entered(node: Node2D) -> void:
	if not auto_trigger or touch_cooldown or not node.is_in_group("player") or not is_active:
		return

	if _is_completed():
		return

	if is_locked:
		if not locked_dialogue_lines.is_empty():
			_show_dialogue(locked_dialogue_lines)
		elif not completion_message.is_empty():
			var scene_root := get_tree().current_scene
			if scene_root != null and scene_root.has_method("show_status_message"):
				scene_root.show_status_message("This route is not ready yet.")
		return

	touch_cooldown = true
	_complete_objective()
	await get_tree().create_timer(0.35).timeout
	touch_cooldown = false


func _refresh_state() -> void:
	var visible_ready := _has_flags(visible_after_flags)
	var completed := _is_completed()
	is_active = visible_ready and (not completed or not consume_on_complete)
	visible = is_active
	set_deferred("monitoring", is_active)
	collision_shape.set_deferred("disabled", not is_active)

	if not is_active:
		return

	is_locked = not _has_flags(required_flags)
	glyph_label.text = glyph_text
	visuals.visible = show_visuals
	var body_target := primary_color
	var accent_target := accent_color
	var glow_target := glow_color
	if is_locked:
		body_target = Color(primary_color.r * 0.44, primary_color.g * 0.44, primary_color.b * 0.44, 0.76)
		accent_target = Color(accent_color.r * 0.5, accent_color.g * 0.5, accent_color.b * 0.5, 0.7)
		glow_target = Color(glow_color.r * 0.45, glow_color.g * 0.45, glow_color.b * 0.45, 0.1)
	elif completed and not consume_on_complete:
		body_target = Color(primary_color.r * 0.62, primary_color.g * 0.62, primary_color.b * 0.62, 0.9)
		accent_target = Color(accent_color.r * 0.7, accent_color.g * 0.7, accent_color.b * 0.7, 0.86)
		glow_target = Color(glow_color.r * 0.4, glow_color.g * 0.4, glow_color.b * 0.4, 0.08)

	body.color = body_target
	accent.color = accent_target
	glow.color = glow_target
	glyph_label.modulate = Color(1.0, 1.0, 1.0, 0.92 if not is_locked else 0.64)


func _complete_objective() -> void:
	if not completion_flag.is_empty():
		GameState.set_flag(completion_flag)

	if reward_coins > 0:
		GameState.add_coins(reward_coins)

	var reward_failed_reason := ""
	if not reward_item_id.is_empty() and reward_amount > 0:
		if not GameState.add_item(reward_item_id, reward_amount):
			reward_failed_reason = GameState.get_add_item_failure_reason(reward_item_id, reward_amount)

	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("show_status_message"):
		if not reward_failed_reason.is_empty() and not completion_message.is_empty():
			scene_root.show_status_message("%s %s" % [completion_message, reward_failed_reason])
		elif not reward_failed_reason.is_empty():
			scene_root.show_status_message(reward_failed_reason)
		elif not completion_message.is_empty():
			scene_root.show_status_message(completion_message)

	if not target_room_id.is_empty():
		if scene_root != null and scene_root.has_method("request_room_change"):
			scene_root.request_room_change(target_room_id, target_spawn_id if not target_spawn_id.is_empty() else "spawn_from_prev")

	objective_completed.emit(completion_flag)

	if consume_on_complete:
		queue_free()
	else:
		_refresh_state()


func _has_flags(flag_list: PackedStringArray) -> bool:
	for flag_name in flag_list:
		if not GameState.get_flag(flag_name):
			return false
	return true


func _is_completed() -> bool:
	return not completion_flag.is_empty() and GameState.get_flag(completion_flag)


func _show_dialogue(lines: PackedStringArray, callback: Callable = Callable()) -> void:
	var scene_root := get_tree().current_scene
	if scene_root != null and scene_root.has_method("show_dialogue"):
		scene_root.show_dialogue(speaker_name, lines, callback)
