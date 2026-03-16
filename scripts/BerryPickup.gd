extends Area2D
class_name BerryPickup

@export var item_id := "berry"
@export var amount := 1
@export var saved_flag := "berry_picked"


func _ready() -> void:
	if GameState.get_flag(saved_flag):
		queue_free()
		return
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	var current_scene = get_tree().current_scene
	if not GameState.add_item(item_id, amount):
		if current_scene != null and current_scene.has_method("show_status_message"):
			current_scene.show_status_message(GameState.get_add_item_failure_reason(item_id, amount))
		return

	GameState.set_flag(saved_flag)

	if current_scene != null and current_scene.has_method("show_status_message"):
		current_scene.show_status_message("Picked up a Berry.")

	queue_free()
