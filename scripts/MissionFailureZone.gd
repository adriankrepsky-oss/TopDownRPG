extends Area2D
class_name MissionFailureZone

@export var size := Vector2(140.0, 72.0)
@export var active_until_flag := ""
@export var failure_message := "The mission collapsed."
@export var tint := Color(1.0, 0.16, 0.12, 0.14)

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var fill: Polygon2D = $Fill


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameState.state_changed.connect(_refresh_state)
	_refresh_shape()
	_refresh_state()


func _refresh_shape() -> void:
	var shape := collision_shape.shape as RectangleShape2D
	if shape != null:
		shape.size = size
	fill.color = tint
	fill.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5),
	])


func _refresh_state() -> void:
	var active := active_until_flag.is_empty() or not GameState.get_flag(active_until_flag)
	visible = active
	monitoring = active
	collision_shape.set_deferred("disabled", not active)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if not active_until_flag.is_empty() and GameState.get_flag(active_until_flag):
		return
	var current_scene := get_tree().current_scene
	if current_scene != null and current_scene.has_method("fail_mission"):
		current_scene.fail_mission(failure_message)
