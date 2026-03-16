extends Interactable
class_name ChoiceNPC

@export var choice_prompt := "What do you say?"
## Each entry: {text: String, response_lines: PackedStringArray, flag: String}
@export var choices: Array[Dictionary] = []


func interact(_player: Node) -> void:
	var first_time: bool = one_time_flag.is_empty() or not GameState.get_flag(one_time_flag)

	if not first_time and not repeat_dialogue_lines.is_empty():
		var current_scene = get_tree().current_scene
		if current_scene != null and current_scene.has_method("show_dialogue"):
			current_scene.show_dialogue(speaker_name, repeat_dialogue_lines, Callable(), _get_bubble_position())
		return

	if not dialogue_lines.is_empty():
		var current_scene = get_tree().current_scene
		if current_scene != null and current_scene.has_method("show_dialogue"):
			current_scene.show_dialogue(speaker_name, dialogue_lines, Callable(self, "_show_choices"), _get_bubble_position())
		return

	_show_choices()


func _show_choices() -> void:
	var formatted: Array = []
	for choice in choices:
		formatted.append({
			"text": choice.get("text", "..."),
			"callback": Callable(self, "_handle_choice").bind(choice),
		})
	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_dialogue_with_choices"):
		current_scene.show_dialogue_with_choices(speaker_name, choice_prompt, formatted, _get_bubble_position())


func _handle_choice(choice: Dictionary) -> void:
	var response_lines: PackedStringArray = choice.get("response_lines", PackedStringArray())
	var flag_to_set: String = choice.get("flag", "")

	if not flag_to_set.is_empty():
		GameState.set_flag(flag_to_set)

	if not one_time_flag.is_empty():
		GameState.set_flag(one_time_flag)

	if not response_lines.is_empty():
		var current_scene = get_tree().current_scene
		if current_scene != null and current_scene.has_method("show_dialogue"):
			current_scene.show_dialogue(speaker_name, response_lines, Callable(), _get_bubble_position())
