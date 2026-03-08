extends Area2D
class_name RunPortal

@export_enum("static", "next_main", "previous_main") var target_mode := "static"
@export var static_target_room_id := ""
@export var static_target_spawn_id := ""
@export var label_override := ""
@export var portal_color := Color(0.44, 0.84, 1.0, 1.0)
@export var glow_color := Color(0.44, 0.84, 1.0, 0.22)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var glow: Polygon2D = $Glow
@onready var ring: Polygon2D = $Ring
@onready var core: Polygon2D = $Core
@onready var label: Label = $Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
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
	visible = is_enabled
	monitoring = is_enabled
	collision_shape.set_deferred("disabled", not is_enabled)
	if not is_enabled:
		return

	glow.color = glow_color
	ring.color = portal_color
	core.color = Color(portal_color.r, portal_color.g, portal_color.b, 0.78)
	label.text = label_override if not label_override.is_empty() else GameState.get_room_title(target_room)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var target_room := _resolve_target_room_id()
	if target_room.is_empty():
		return

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("request_room_change"):
		current_scene.request_room_change(target_room, _resolve_target_spawn_id())
