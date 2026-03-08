extends Area2D
class_name Interactable

@export var prompt_text := "Interact"
@export var speaker_name := "Sign"
@export var dialogue_lines: PackedStringArray = PackedStringArray()
@export var repeat_dialogue_lines: PackedStringArray = PackedStringArray()
@export var one_time_flag := ""
@export var reward_item_id := ""
@export var reward_amount := 1
@export var reward_message := ""


func _ready() -> void:
	add_to_group("interactable")


func get_prompt_text() -> String:
	return prompt_text


func interact(_player: Node) -> void:
	var first_time: bool = one_time_flag.is_empty() or not GameState.get_flag(one_time_flag)
	var lines: PackedStringArray = dialogue_lines
	if not first_time and not repeat_dialogue_lines.is_empty():
		lines = repeat_dialogue_lines

	var callback: Callable = Callable()
	if first_time and (not one_time_flag.is_empty() or not reward_item_id.is_empty()):
		callback = Callable(self, "_complete_one_time_interaction")

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_dialogue"):
		current_scene.show_dialogue(speaker_name, lines, callback)


func _complete_one_time_interaction() -> void:
	if not one_time_flag.is_empty():
		GameState.set_flag(one_time_flag)

	if not reward_item_id.is_empty():
		GameState.add_item(reward_item_id, reward_amount)
		if not reward_message.is_empty():
			var current_scene = get_tree().current_scene
			if current_scene != null and current_scene.has_method("show_status_message"):
				current_scene.show_status_message(reward_message)

