extends Area2D
class_name ShopStand

@export var prompt_text := "Shop"
@export var speaker_name := "Merchant"
@export var item_id := ""
@export var item_amount := 1
@export var heal_amount := 0
@export var cost := 3
@export var unique_purchase := false
@export var sold_out_flag := ""
@export var intro_lines: Array[String] = ["Fresh goods.", "Pay the price and they are yours."]
@export var success_message := "Purchase complete."
@export var sold_out_lines: Array[String] = ["That one is sold out."]
@export var not_enough_lines: Array[String] = ["You need more coins."]


func _ready() -> void:
	add_to_group("interactable")


func get_prompt_text() -> String:
	return "%s (%d coins)" % [prompt_text, cost]


func interact(_player: Node) -> void:
	var current_scene = get_tree().current_scene
	if current_scene == null or not current_scene.has_method("show_dialogue"):
		return

	if heal_amount > 0 and GameState.player_hp >= GameState.player_max_hp:
		current_scene.show_dialogue(speaker_name, PackedStringArray(["You are already at full health."]))
		return

	if unique_purchase and not sold_out_flag.is_empty() and GameState.get_flag(sold_out_flag):
		current_scene.show_dialogue(speaker_name, PackedStringArray(sold_out_lines))
		return

	if GameState.coins < cost:
		current_scene.show_dialogue(speaker_name, PackedStringArray(not_enough_lines))
		return

	current_scene.show_dialogue(speaker_name, PackedStringArray(intro_lines), Callable(self, "_complete_purchase"))


func _complete_purchase() -> void:
	if unique_purchase and not sold_out_flag.is_empty() and GameState.get_flag(sold_out_flag):
		return
	if not GameState.spend_coins(cost):
		return

	if heal_amount > 0:
		GameState.set_player_hp(min(GameState.player_hp + heal_amount, GameState.player_max_hp), true)
	if not item_id.is_empty():
		GameState.add_item(item_id, item_amount)
	if unique_purchase and not sold_out_flag.is_empty():
		GameState.set_flag(sold_out_flag)

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_status_message"):
		current_scene.show_status_message(success_message)
