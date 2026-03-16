extends Area2D
class_name RunPortal

@export_enum("static", "next_main", "previous_main") var target_mode := "static"
@export var static_target_room_id := ""
@export var static_target_spawn_id := ""
@export var label_override := ""
@export var portal_color := Color(0.44, 0.84, 1.0, 1.0)
@export var glow_color := Color(0.44, 0.84, 1.0, 0.22)
@export var required_flag := ""
@export var locked_label := "Finish mission"
@export var locked_message := "Complete this room's objective before you leave."
@export var hide_when_locked := false

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var glow: Polygon2D = $Glow
@onready var ring: Polygon2D = $Ring
@onready var core: Polygon2D = $Core
@onready var label: Label = $Label

var is_locked := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameState.state_changed.connect(_refresh_portal)
	_refresh_portal()


func _resolve_target_room_id() -> String:
	match target_mode:
		"next_main":
			return GameState.get_next_main_room(GameState.current_room_id)
		"previous_main":
			return GameState.get_previous_main_room(GameState.current_room_id)
		_:
			return static_target_room_id


func _resolve_target_spawn_id() -> String:
	if not static_target_spawn_id.is_empty():
		return static_target_spawn_id

	match target_mode:
		"next_main":
			return "spawn_from_prev"
		"previous_main":
			var target_room := _resolve_target_room_id()
			if target_room == GameState.DEFAULT_ROOM_ID:
				return "spawn_from_main_route"
			return "spawn_from_next"
		_:
			return "spawn_home"


func _refresh_portal() -> void:
	var target_room := _resolve_target_room_id()
	var is_enabled := not target_room.is_empty()
	is_locked = not required_flag.is_empty() and not GameState.get_flag(required_flag)
	var should_show := is_enabled and (not hide_when_locked or not is_locked)
	visible = should_show
	monitoring = is_enabled
	collision_shape.set_deferred("disabled", not is_enabled)
	if not is_enabled:
		return

	if is_locked:
		glow.color = Color(glow_color.r * 0.45, glow_color.g * 0.45, glow_color.b * 0.45, 0.12)
		ring.color = Color(0.34, 0.34, 0.38, 0.72)
		core.color = Color(0.18, 0.18, 0.2, 0.56)
		label.text = locked_label
		return

	glow.color = glow_color
	ring.color = portal_color
	core.color = Color(portal_color.r, portal_color.g, portal_color.b, 0.78)
	label.text = label_override if not label_override.is_empty() else GameState.get_room_title(target_room)


func refresh_portal() -> void:
	_refresh_portal()


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var target_room := _resolve_target_room_id()
	if target_room.is_empty():
		return

	if is_locked:
		var locked_scene_root = get_tree().current_scene
		if locked_scene_root != null and locked_scene_root.has_method("show_status_message"):
			locked_scene_root.show_status_message(locked_message)
		return

	var change_scene_root = get_tree().current_scene
	if change_scene_root != null and change_scene_root.has_method("request_room_change"):
		change_scene_root.request_room_change(target_room, _resolve_target_spawn_id())

