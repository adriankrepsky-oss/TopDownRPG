extends Area2D
class_name DoorPortal

@export var target_room_id := ""
@export var target_spawn_id := "spawn_from_door"
@export var label_text := "Enter"
@export var required_flag := ""

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var label: Label = $Label


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	if label != null:
		label.text = label_text
	if not required_flag.is_empty():
		if GameState.has_signal("state_changed"):
			GameState.state_changed.connect(_refresh_visibility)
		_refresh_visibility()


func _refresh_visibility() -> void:
	var unlocked := GameState.get_flag(required_flag)
	visible = unlocked
	collision_shape.set_deferred("disabled", not unlocked)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if target_room_id.is_empty():
		return
	if not required_flag.is_empty() and not GameState.get_flag(required_flag):
		return

	var scene_root = get_tree().current_scene
	if scene_root != null and scene_root.has_method("request_room_change"):
		scene_root.request_room_change(target_room_id, target_spawn_id)
