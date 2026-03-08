extends Area2D
class_name RoomTransition

@export var target_room_id: String = ""
@export var target_spawn_id: String = ""


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("request_room_change"):
		current_scene.request_room_change(target_room_id, target_spawn_id)
