extends Area2D
class_name RewardPedestal

@export var prompt_text := "Inspect"
@export var speaker_name := "Forge Core"
@export var required_flag := "boss_arcane_vault_defeated"
@export var reward_flag := "arc_blaster_claimed"
@export var reward_item_id := "arc_blaster"
@export var reward_amount := 1
@export var locked_lines: Array[String] = ["The forge core is sealed.", "A stronger presence still guards the vault."]
@export var reward_lines: Array[String] = ["The forge answers your victory.", "Arc energy floods the weapon frame in your hands."]
@export var repeat_lines: Array[String] = ["The forge core is quiet now.", "Its power already rests in your weapon."]
@export var reward_message := "Received Arc Blaster."


func _ready() -> void:
	add_to_group("interactable")


func get_prompt_text() -> String:
	return prompt_text


func interact(_player: Node) -> void:
	var lines := PackedStringArray(locked_lines)
	var callback := Callable()

	if GameState.get_flag(reward_flag):
		lines = PackedStringArray(repeat_lines)
	elif GameState.get_flag(required_flag):
		lines = PackedStringArray(reward_lines)
		callback = Callable(self, "_grant_reward")

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_dialogue"):
		current_scene.show_dialogue(speaker_name, lines, callback)


func _grant_reward() -> void:
	if GameState.get_flag(reward_flag):
		return

	if not GameState.add_item(reward_item_id, reward_amount):
		var current_scene_fail = get_tree().current_scene
		if current_scene_fail != null and current_scene_fail.has_method("show_status_message"):
			current_scene_fail.show_status_message(GameState.get_add_item_failure_reason(reward_item_id, reward_amount))
		return

	GameState.set_flag(reward_flag)
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_status_message"):
		current_scene.show_status_message(reward_message)
