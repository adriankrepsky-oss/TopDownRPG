extends Area2D
class_name GunPickup

@export var item_id := "slime_blaster"
@export var amount := 1
@export var saved_flag := "slime_blaster_collected"
@export var appear_flag := "enemy_forest_slime_defeated"
@export var pickup_message := "Picked up the Slime Blaster. Aim with the mouse and shoot with left click."

@onready var collision_shape: CollisionShape2D = $CollisionShape2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	GameState.state_changed.connect(_refresh_visibility)
	_refresh_visibility()


func _on_body_entered(body: Node2D) -> void:
	if collision_shape.disabled or not body.is_in_group("player"):
		return

	if not GameState.add_item(item_id, amount):
		var current_scene_fail = get_tree().current_scene
		if current_scene_fail != null and current_scene_fail.has_method("show_status_message"):
			current_scene_fail.show_status_message(GameState.get_add_item_failure_reason(item_id, amount))
		return

	GameState.set_flag(saved_flag)

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_status_message"):
		current_scene.show_status_message(pickup_message)

	queue_free()


func _refresh_visibility() -> void:
	if GameState.get_flag(saved_flag):
		queue_free()
		return

	var should_show := GameState.get_flag(appear_flag)
	visible = should_show
	collision_shape.set_deferred("disabled", not should_show)
