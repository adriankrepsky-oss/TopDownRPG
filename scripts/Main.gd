extends Node2D
class_name Main

const PLAYER_SCENE := preload("res://scenes/Player.tscn")

@onready var room_container: Node2D = $Rooms
@onready var actor_container: Node2D = $Actors
@onready var health_label: Label = $CanvasLayer/HealthLabel
@onready var coins_label: Label = $CanvasLayer/CoinsLabel
@onready var prompt_label: Label = $CanvasLayer/PromptLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var area_label: Label = $CanvasLayer/ObjectiveCard/AreaLabel
@onready var objective_label: Label = $CanvasLayer/ObjectiveCard/ObjectiveLabel
@onready var dialogue_panel: Panel = $CanvasLayer/DialoguePanel
@onready var speaker_label: Label = $CanvasLayer/DialoguePanel/SpeakerLabel
@onready var dialogue_label: Label = $CanvasLayer/DialoguePanel/DialogueLabel
@onready var dialogue_hint_label: Label = $CanvasLayer/DialoguePanel/HintLabel
@onready var inventory_panel: Panel = $CanvasLayer/InventoryPanel
@onready var inventory_list_label: Label = $CanvasLayer/InventoryPanel/InventoryListLabel
@onready var inventory_description_label: Label = $CanvasLayer/InventoryPanel/InventoryDescriptionLabel
@onready var inventory_hint_label: Label = $CanvasLayer/InventoryPanel/HintLabel
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var victory_panel: Panel = $CanvasLayer/VictoryPanel

var current_room: Node2D
var player: Node2D
var is_transitioning := false
var dialogue_pages: PackedStringArray = PackedStringArray()
var dialogue_index := 0
var dialogue_callback: Callable = Callable()
var inventory_open := false
var inventory_selection := 0
var status_timer: SceneTreeTimer
var interact_release_lock := false
var pending_victory := false


func _ready() -> void:
	fade_rect.color.a = 1.0
	dialogue_panel.visible = false
	inventory_panel.visible = false
	status_label.visible = false
	prompt_label.visible = false
	victory_panel.visible = false

	GameState.room_change_requested.connect(_on_room_change_requested)
	GameState.state_changed.connect(_refresh_ui)

	player = PLAYER_SCENE.instantiate() as Node2D
	actor_container.add_child(player)

	await _load_room(GameState.current_room_id, GameState.current_spawn_id, false)
	await _fade_to(0.0)
	_refresh_ui()


func _process(_delta: float) -> void:
	_refresh_prompt()


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_released("interact"):
		interact_release_lock = false

	if event.is_action_pressed("interact"):
		if dialogue_panel.visible:
			_advance_dialogue()
			get_viewport().set_input_as_handled()
			return
		if inventory_open:
			_use_selected_item()
			get_viewport().set_input_as_handled()
			return

	if event.is_action_pressed("inventory"):
		if dialogue_panel.visible or is_transitioning or victory_panel.visible:
			return
		_toggle_inventory()
		get_viewport().set_input_as_handled()
		return

	if not inventory_open:
		return

	if event.is_action_pressed("ui_up"):
		inventory_selection = max(inventory_selection - 1, 0)
		_refresh_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down"):
		inventory_selection = min(inventory_selection + 1, max(_get_inventory_item_ids().size() - 1, 0))
		_refresh_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_toggle_inventory(false)
		get_viewport().set_input_as_handled()


func can_accept_player_input() -> bool:
	return not is_transitioning and not dialogue_panel.visible and not inventory_open and not victory_panel.visible


func is_interact_locked() -> bool:
	return interact_release_lock


func request_room_change(room_id: String, spawn_id: String) -> void:
	if is_transitioning:
		return
	if room_id == GameState.current_room_id and spawn_id == GameState.current_spawn_id:
		return
	GameState.change_room(room_id, spawn_id)


func show_dialogue(speaker_name: String, lines: PackedStringArray, callback: Callable = Callable()) -> void:
	if lines.is_empty():
		return

	inventory_open = false
	inventory_panel.visible = false
	interact_release_lock = true
	dialogue_pages = lines
	dialogue_index = 0
	dialogue_callback = callback
	dialogue_panel.visible = true
	speaker_label.text = speaker_name
	dialogue_label.text = dialogue_pages[dialogue_index]
	dialogue_hint_label.text = "[E] Next"
	_refresh_prompt()


func show_status_message(message: String) -> void:
	status_label.text = message
	status_label.visible = true
	status_timer = get_tree().create_timer(1.6)
	_clear_status_later(status_timer)


func show_power_unlock(power_id: String) -> void:
	var lines := PackedStringArray(["%s unlocked." % GameState.get_power_name(power_id)])
	for step in GameState.get_power_tutorial(power_id):
		lines.append(step)
	show_dialogue("Power Unlocked", lines)


func queue_victory() -> void:
	if dialogue_panel.visible:
		pending_victory = true
		return
	_show_victory()


func respawn_player() -> void:
	if is_transitioning:
		return
	call_deferred("_handle_player_defeat")


func _handle_player_defeat() -> void:
	if is_transitioning:
		return

	GameState.reset_run_after_death()
	await _load_room(GameState.current_room_id, GameState.current_spawn_id, true)
	show_status_message("You were defeated. You wake in the clearing without your guns.")


func _on_room_change_requested(room_id: String, spawn_id: String) -> void:
	call_deferred("_start_room_change", room_id, spawn_id)


func _start_room_change(room_id: String, spawn_id: String) -> void:
	await _load_room(room_id, spawn_id, true)


func _load_room(room_id: String, spawn_id: String, with_fade: bool) -> void:
	is_transitioning = true
	dialogue_panel.visible = false
	inventory_open = false
	inventory_panel.visible = false
	interact_release_lock = false
	pending_victory = false
	victory_panel.visible = false

	if with_fade:
		await _fade_to(1.0)

	if is_instance_valid(current_room):
		current_room.queue_free()
		await get_tree().process_frame

	var room_scene: PackedScene = load(GameState.get_room_scene_path(room_id)) as PackedScene
	current_room = room_scene.instantiate() as Node2D
	room_container.add_child(current_room)
	await get_tree().process_frame

	player.global_position = _get_spawn_position(spawn_id)
	_refresh_navigation_ui()

	if with_fade:
		await _fade_to(0.0)
		var room_name: String = _get_room_name()
		if not room_name.is_empty():
			show_status_message("Entered %s" % room_name)

	is_transitioning = false
	_refresh_ui()


func _get_spawn_position(spawn_id: String) -> Vector2:
	if is_instance_valid(current_room):
		return current_room.get_spawn_position(spawn_id)
	return Vector2.ZERO


func _advance_dialogue() -> void:
	dialogue_index += 1
	if dialogue_index < dialogue_pages.size():
		dialogue_label.text = dialogue_pages[dialogue_index]
		return

	dialogue_panel.visible = false
	interact_release_lock = true
	var callback: Callable = dialogue_callback
	dialogue_callback = Callable()
	if callback.is_valid():
		callback.call()
	if pending_victory:
		pending_victory = false
		_show_victory()
	_refresh_ui()


func _toggle_inventory(force_visible: Variant = null) -> void:
	var should_show: bool = not inventory_open
	if force_visible != null:
		should_show = bool(force_visible)

	inventory_open = should_show
	inventory_panel.visible = should_show
	if should_show:
		inventory_selection = clampi(inventory_selection, 0, max(_get_inventory_item_ids().size() - 1, 0))
		_refresh_inventory()
	_refresh_prompt()


func _refresh_ui() -> void:
	health_label.text = "HP: %d/%d" % [GameState.player_hp, GameState.player_max_hp]
	coins_label.text = "Coins: %d" % GameState.coins
	_refresh_navigation_ui()
	if inventory_open:
		_refresh_inventory()
	_refresh_prompt()


func _refresh_navigation_ui() -> void:
	area_label.text = _get_room_name()
	objective_label.text = _build_navigation_text()


func _get_room_name() -> String:
	if not is_instance_valid(current_room):
		return ""
	if current_room.has_method("get_room_name"):
		return str(current_room.call("get_room_name"))
	return ""


func _build_navigation_text() -> String:
	var route_hint := ""
	if is_instance_valid(current_room) and current_room.has_method("get_navigation_hint"):
		route_hint = str(current_room.call("get_navigation_hint"))

	var objective_text := _get_objective_text()
	if route_hint.is_empty():
		return objective_text
	if objective_text.is_empty():
		return route_hint
	return "%s\n%s" % [route_hint, objective_text]


func _get_objective_text() -> String:
	var room_id := GameState.current_room_id
	if room_id == "home_clearing":
		var first_room := GameState.get_next_main_room(room_id)
		if not GameState.get_flag("arc_blaster_claimed"):
			return "Objective: Enter the forge house for the side weapon or step into the portal to %s.\nThe full run is 15 levels: first 5 easy, next 5 mid, last 5 hard." % GameState.get_room_title(first_room)
		return "Objective: Start the run through the portal to %s.\nThe full run is 15 levels: first 5 easy, next 5 mid, last 5 hard." % GameState.get_room_title(first_room)

	if room_id == "forge_hall":
		if not GameState.get_flag("boss_arcane_vault_defeated"):
			return "Objective: Clear the forge and descend into the vault."
		if not GameState.get_flag("arc_blaster_claimed"):
			return "Objective: Claim the Arc Blaster from the forge core."
		return "Objective: Return to Lantern City with your forge weapon."

	if room_id == "arcane_vault":
		if not GameState.get_flag("boss_arcane_vault_defeated"):
			return "Objective: Defeat the Vault Warden and wake the forge core."
		if not GameState.get_flag("arc_blaster_claimed"):
			return "Objective: Claim the Arc Blaster reward."
		return "Objective: Portal back to the forge hall."

	if GameState.is_shop_level(room_id):
		var next_room := GameState.get_next_main_room(room_id)
		return "Level %d/%d shop.\nTier: Easy.\nObjective: Spend coins, heal up, then take the portal to %s." % [GameState.get_level_number(room_id), GameState.get_main_route().size(), GameState.get_room_title(next_room)]

	var level_number := GameState.get_level_number(room_id)
	var route_total := GameState.get_main_route().size()
	if GameState.is_final_level(room_id):
		return "Level %d/%d.\nObjective: Defeat the final boss in the hardest room." % [level_number, route_total]

	var next_room_id := GameState.get_next_main_room(room_id)
	if next_room_id.is_empty():
		return "Objective: Explore freely."
	return "Level %d/%d.\n%s\nObjective: Clear this area, gather coins, and push through the portal to %s." % [level_number, route_total, _get_tier_text(level_number), GameState.get_room_title(next_room_id)]


func _refresh_prompt() -> void:
	if inventory_open or dialogue_panel.visible or is_transitioning or victory_panel.visible:
		prompt_label.visible = false
		return

	var prompt_text: String = player.get_interaction_prompt()
	prompt_label.text = prompt_text
	prompt_label.visible = not prompt_text.is_empty()


func _refresh_inventory() -> void:
	var item_ids := _get_inventory_item_ids()
	if item_ids.is_empty():
		inventory_list_label.text = "Inventory is empty."
		inventory_description_label.text = ""
		inventory_hint_label.text = "[I] Close"
		return

	inventory_selection = clampi(inventory_selection, 0, item_ids.size() - 1)
	var lines: Array[String] = []
	for index in range(item_ids.size()):
		var item_id: String = item_ids[index]
		var item_def: Dictionary = GameState.get_item_def(item_id)
		var prefix := ">" if index == inventory_selection else " "
		lines.append("%s %s x%d" % [prefix, item_def.get("display_name", item_id), GameState.get_item_count(item_id)])
	inventory_list_label.text = "\n".join(lines)

	var selected_id: String = item_ids[inventory_selection]
	var selected_def: Dictionary = GameState.get_item_def(selected_id)
	inventory_description_label.text = selected_def.get("description", "")
	if bool(selected_def.get("usable", false)):
		inventory_hint_label.text = "[E] Use  [I] Close"
	else:
		inventory_hint_label.text = "[I] Close"


func _use_selected_item() -> void:
	var item_ids := _get_inventory_item_ids()
	if item_ids.is_empty():
		return

	var selected_id: String = item_ids[inventory_selection]
	if selected_id == "berry":
		if GameState.player_hp >= GameState.player_max_hp:
			show_status_message("You are already at full health.")
			return
		if GameState.consume_item("berry") and GameState.heal_player(1):
			show_status_message("You eat the berry and recover 1 HP.")
			_refresh_inventory()


func _get_inventory_item_ids() -> Array[String]:
	var item_ids: Array[String] = []
	for item_id in GameState.inventory.keys():
		item_ids.append(str(item_id))
	item_ids.sort()
	return item_ids


func _fade_to(target_alpha: float) -> void:
	var tween: Tween = create_tween()
	tween.tween_property(fade_rect, "color:a", target_alpha, 0.2)
	await tween.finished


func _clear_status_later(timer: SceneTreeTimer) -> void:
	await timer.timeout
	if status_timer == timer:
		status_label.visible = false


func _show_victory() -> void:
	victory_panel.visible = true
	show_status_message("YOU WON!!!")


func _get_tier_text(level_number: int) -> String:
	if level_number <= 5:
		return "Tier: Easy."
	if level_number <= 10:
		return "Tier: Mid."
	return "Tier: Hard."


