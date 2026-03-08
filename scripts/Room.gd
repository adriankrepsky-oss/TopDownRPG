extends Node2D
class_name Room

@export var room_id: String = ""
@export var room_name: String = ""
@export var navigation_hint: String = ""


func get_spawn_position(spawn_id: String) -> Vector2:
	var spawn_root := get_node_or_null("SpawnPoints")
	if spawn_root == null:
		return global_position

	var marker := spawn_root.get_node_or_null(spawn_id) as Marker2D
	if marker == null:
		return global_position
	return marker.global_position


func get_room_name() -> String:
	return room_name


func get_navigation_hint() -> String:
	return navigation_hint
