extends Area2D
class_name CoinPickup

@export var amount := 1
@export var pickup_message := "+1 coin"


func _ready() -> void:
	body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return

	GameState.add_coins(amount)
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_status_message"):
		current_scene.show_status_message("+%d coin%s" % [amount, "" if amount == 1 else "s"])
	queue_free()
