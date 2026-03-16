extends Node2D
class_name Main

const PLAYER_SCENE := preload("res://scenes/Player.tscn")
const QUEST_PICKUP_SCENE := preload("res://scenes/QuestPickup.tscn")
const EARLY_QUEST_DATA := preload("res://scripts/EarlyQuestData.gd").DATA
const WEAPON_HUD_ORDER := ["knife", "slime_blaster", "iron_repeater", "sun_lance", "arc_blaster"]
const WEAPON_HUD_META := {
	"knife": {
		"display_name": "Knife",
		"short_label": "KNF",
		"accent": Color(0.98, 0.66, 0.2, 1.0),
		"background": Color(0.16, 0.18, 0.22, 0.95),
	},
	"slime_blaster": {
		"display_name": "Blaster",
		"short_label": "SB",
		"accent": Color(0.56, 0.88, 1.0, 1.0),
		"background": Color(0.14, 0.18, 0.22, 0.95),
	},
	"iron_repeater": {
		"display_name": "Repeater",
		"short_label": "IR",
		"accent": Color(0.88, 0.92, 1.0, 1.0),
		"background": Color(0.16, 0.18, 0.22, 0.95),
	},
	"sun_lance": {
		"display_name": "Sun Lance",
		"short_label": "SUN",
		"accent": Color(1.0, 0.84, 0.36, 1.0),
		"background": Color(0.22, 0.18, 0.12, 0.95),
	},
	"arc_blaster": {
		"display_name": "Arc Blaster",
		"short_label": "ARC",
		"accent": Color(0.44, 0.94, 1.0, 1.0),
		"background": Color(0.1, 0.18, 0.22, 0.95),
	},
}
const MAP_HOME_POINT := Vector2(132, 126)
const MAP_FORGE_POINT := Vector2(34, 126)
const MAP_VAULT_POINT := Vector2(34, 92)
const MAP_ROUTE_SLOT_POINTS := [
	Vector2(132, 106),
	Vector2(86, 92),
	Vector2(132, 92),
	Vector2(178, 92),
	Vector2(178, 72),
	Vector2(132, 72),
	Vector2(86, 72),
	Vector2(86, 52),
	Vector2(132, 52),
	Vector2(178, 52),
	Vector2(178, 32),
	Vector2(132, 32),
	Vector2(86, 32),
	Vector2(86, 14),
	Vector2(132, 14),
]
const MAP_MARKER_SIZE := Vector2(22, 22)
const MAP_RIFT_OFFSETS := {
	"echo_rift": Vector2(28, 0),
	"ashen_rift": Vector2(28, 0),
}
const EARLY_ROOM_JOBS := {
	"forest_path": {
		"flag": "job_forest_satchel_taken",
		"title": "Recover the ranger satchel",
		"objective": "Find the ranger satchel in the quarter plaza and grab it before you leave.",
		"prompt": "Take satchel",
		"speaker": "Ranger Satchel",
		"dialogue_lines": [
			"The satchel is still warm from the campfire.",
			"Inside is a sketched route map, a few coins, and a note saying the next gate should stay open."
		],
		"message": "Job complete: Ranger satchel recovered. Portal unlocked. +3 coins.",
		"coins": 3,
		"position": Vector2(292, 150),
		"primary_color": Color(0.58, 0.38, 0.2, 1.0),
		"accent_color": Color(0.95, 0.84, 0.44, 1.0),
		"glow_color": Color(1.0, 0.82, 0.42, 0.18),
	},
	"echo_cave": {
		"flag": "job_echo_compass_taken",
		"title": "Find the smuggler compass",
		"objective": "Search the crystal shelf for the smuggler compass hidden in Echo Cave.",
		"prompt": "Take compass",
		"speaker": "Smuggler Compass",
		"dialogue_lines": [
			"A magnetic compass sits wedged between old crystal shards.",
			"It looks valuable and points deeper into the route. You pocket it before anyone else can."
		],
		"message": "Job complete: Smuggler compass found. Portal unlocked. +3 coins and a berry.",
		"coins": 3,
		"reward_item_id": "berry",
		"position": Vector2(-292, -140),
		"primary_color": Color(0.2, 0.42, 0.54, 1.0),
		"accent_color": Color(0.72, 0.94, 1.0, 1.0),
		"glow_color": Color(0.54, 0.92, 1.0, 0.18),
	},
	"sunstone_ruins": {
		"flag": "job_sun_tablet_stolen",
		"title": "Steal the sun tablet",
		"objective": "Slip past the ruin center and steal the sun tablet from the altar ledge.",
		"prompt": "Steal tablet",
		"speaker": "Sun Tablet",
		"dialogue_lines": [
			"The carved tablet is lighter than it looks.",
			"You tuck it under your arm and the ruin route starts to feel more like a real job than a patrol."
		],
		"message": "Job complete: Sun tablet stolen. Portal unlocked. +4 coins.",
		"coins": 4,
		"position": Vector2(252, -156),
		"primary_color": Color(0.78, 0.56, 0.16, 1.0),
		"accent_color": Color(1.0, 0.92, 0.58, 1.0),
		"glow_color": Color(1.0, 0.84, 0.34, 0.18),
	},
	"bloom_marsh": {
		"flag": "job_bloom_cache_found",
		"title": "Find the courier cache",
		"objective": "Search the dry rise and recover the courier cache hidden above the marsh water.",
		"prompt": "Open cache",
		"speaker": "Courier Cache",
		"dialogue_lines": [
			"The cache holds wrapped herbs, a route chit, and a clean berry.",
			"It is exactly the kind of quiet reward that keeps a runner moving one room further."
		],
		"message": "Job complete: Courier cache found. Portal unlocked. +4 coins and a berry.",
		"coins": 4,
		"reward_item_id": "berry",
		"position": Vector2(248, -144),
		"primary_color": Color(0.36, 0.52, 0.24, 1.0),
		"accent_color": Color(0.86, 0.98, 0.62, 1.0),
		"glow_color": Color(0.68, 1.0, 0.7, 0.18),
	},
	"market_crossroads": {
		"flag": "job_market_contract_taken",
		"title": "Take the fixer contract",
		"objective": "Visit the back board in the bazaar and take the next contract before you leave town.",
		"prompt": "Take contract",
		"speaker": "Fixer Board",
		"dialogue_lines": [
			"A fresh contract is pinned under a knife: stolen ledgers, dock cash, and quiet extractions.",
			"You take the slip and the run suddenly feels like a string of side jobs, not just another arena chain."
		],
		"message": "Contract taken. Mid-route jobs unlocked. Portal unlocked. +4 coins.",
		"coins": 4,
		"position": Vector2(0, -138),
		"primary_color": Color(0.42, 0.2, 0.52, 1.0),
		"accent_color": Color(0.96, 0.84, 0.36, 1.0),
		"glow_color": Color(0.92, 0.5, 1.0, 0.18),
	},
	"ember_fields": {
		"flag": "job_ember_plans_taken",
		"title": "Grab the burned forge plans",
		"objective": "Search the upper ash shelf and steal the burned forge plans before the field closes in.",
		"prompt": "Take plans",
		"speaker": "Forge Plans",
		"dialogue_lines": [
			"Half-burned blueprints survive under a sheet of ash.",
			"They still mention an old gun workshop, which is enough to make them worth carrying out."
		],
		"message": "Job complete: Forge plans stolen. Portal unlocked. +5 coins.",
		"coins": 5,
		"position": Vector2(246, -182),
		"primary_color": Color(0.54, 0.26, 0.12, 1.0),
		"accent_color": Color(1.0, 0.7, 0.32, 1.0),
		"glow_color": Color(1.0, 0.56, 0.22, 0.18),
	},
	"iron_docks": {
		"flag": "job_docks_strongbox_robbed",
		"title": "Rob the dock strongbox",
		"objective": "Hit the dock strongbox on the upper gantry and steal the payout before you leave.",
		"prompt": "Rob strongbox",
		"speaker": "Dock Strongbox",
		"dialogue_lines": [
			"The strongbox clicks open with a satisfying snap.",
			"Now it feels like a real score: quick, dirty, and worth enough to make you chase the next one."
		],
		"message": "Job complete: Dock strongbox robbed. Portal unlocked. +6 coins.",
		"coins": 6,
		"position": Vector2(-258, -172),
		"primary_color": Color(0.32, 0.38, 0.46, 1.0),
		"accent_color": Color(0.88, 0.96, 1.0, 1.0),
		"glow_color": Color(0.62, 0.84, 1.0, 0.18),
	},
	"verdant_garden": {
		"flag": "job_garden_key_found",
		"title": "Find the brass garden key",
		"objective": "Search the lit hedge lane and recover the brass key hidden in the garden.",
		"prompt": "Take key",
		"speaker": "Brass Key",
		"dialogue_lines": [
			"A polished brass key sits behind the flowers.",
			"Taking it feels less like looting and more like slipping deeper into a place you were never meant to own."
		],
		"message": "Job complete: Brass key found. Portal unlocked. +5 coins and a berry.",
		"coins": 5,
		"reward_item_id": "berry",
		"position": Vector2(250, -166),
		"primary_color": Color(0.36, 0.52, 0.28, 1.0),
		"accent_color": Color(1.0, 0.94, 0.58, 1.0),
		"glow_color": Color(0.7, 1.0, 0.74, 0.18),
	},
	"dune_courtyard": {
		"flag": "job_ledger_stolen",
		"title": "Steal the magistrate ledger",
		"objective": "Push into the upper court and steal the magistrate ledger from the archive chest.",
		"prompt": "Steal ledger",
		"speaker": "Magistrate Ledger",
		"dialogue_lines": [
			"The ledger is thick with names, debts, and route payments.",
			"It feels like exactly the kind of thing a player keeps chasing because every room promises one more secret."
		],
		"message": "Job complete: Magistrate ledger stolen. Portal unlocked. +6 coins.",
		"coins": 6,
		"position": Vector2(252, -178),
		"primary_color": Color(0.6, 0.34, 0.14, 1.0),
		"accent_color": Color(1.0, 0.86, 0.46, 1.0),
		"glow_color": Color(1.0, 0.8, 0.38, 0.18),
	},
	"ashen_keep": {
		"flag": "job_black_seal_taken",
		"title": "Take the black seal",
		"objective": "Reach the upper war room and lift the black seal before the keep locks down.",
		"prompt": "Take black seal",
		"speaker": "Black Seal",
		"dialogue_lines": [
			"The seal is cold, heavy, and clearly not meant to leave the keep.",
			"That makes it the best kind of reward: risky, direct, and impossible not to pocket."
		],
		"message": "Job complete: Black seal taken. Portal unlocked. +7 coins.",
		"coins": 7,
		"position": Vector2(0, -176),
		"primary_color": Color(0.28, 0.16, 0.18, 1.0),
		"accent_color": Color(0.94, 0.46, 0.34, 1.0),
		"glow_color": Color(1.0, 0.48, 0.34, 0.18),
	},
}

@onready var room_container: Node2D = $Rooms
@onready var actor_container: Node2D = $Actors
@onready var health_label: Label = $CanvasLayer/HealthLabel
@onready var coins_label: Label = $CanvasLayer/CoinsLabel
@onready var map_panel: Panel = $CanvasLayer/MapPanel
@onready var map_title_label: Label = $CanvasLayer/MapPanel/MapTitleLabel
@onready var map_current_label: Label = $CanvasLayer/MapPanel/MapCurrentLabel
@onready var map_canvas: Control = $CanvasLayer/MapPanel/MapCanvas
@onready var map_legend_label: Label = $CanvasLayer/MapPanel/MapLegendLabel
@onready var prompt_label: Label = $CanvasLayer/PromptLabel
@onready var status_label: Label = $CanvasLayer/StatusLabel
@onready var area_label: Label = $CanvasLayer/ObjectiveCard/AreaLabel
@onready var objective_label: Label = $CanvasLayer/ObjectiveCard/ObjectiveLabel
@onready var dialogue_panel: Panel = $CanvasLayer/DialoguePanel
@onready var speaker_label: Label = $CanvasLayer/DialoguePanel/SpeakerLabel
@onready var dialogue_label: Label = $CanvasLayer/DialoguePanel/DialogueLabel
@onready var dialogue_hint_label: Label = $CanvasLayer/DialoguePanel/HintLabel
@onready var choice_container: VBoxContainer = $CanvasLayer/DialoguePanel/ChoiceContainer
@onready var inventory_panel: Panel = $CanvasLayer/InventoryPanel
@onready var backpack_stats_label: Label = $CanvasLayer/InventoryPanel/BackpackStatsLabel
@onready var inventory_list_label: Label = $CanvasLayer/InventoryPanel/InventoryListLabel
@onready var inventory_description_label: Label = $CanvasLayer/InventoryPanel/InventoryDescriptionLabel
@onready var inventory_hint_label: Label = $CanvasLayer/InventoryPanel/HintLabel
@onready var weapon_hud_panel: Panel = $CanvasLayer/WeaponHudPanel
@onready var weapon_slots: HBoxContainer = $CanvasLayer/WeaponHudPanel/WeaponSlots
@onready var fade_rect: ColorRect = $CanvasLayer/FadeRect
@onready var victory_panel: Panel = $CanvasLayer/VictoryPanel
@onready var pause_panel: Panel = $CanvasLayer/PausePanel
@onready var pause_title_label: Label = $CanvasLayer/PausePanel/PauseTitle
@onready var pause_status_label: Label = $CanvasLayer/PausePanel/PauseStatus
@onready var chat_history: TextEdit = $CanvasLayer/PausePanel/ChatHistory
@onready var chat_input: LineEdit = $CanvasLayer/PausePanel/ChatInput
@onready var chat_send_button: Button = $CanvasLayer/PausePanel/SendButton
@onready var chat_resume_button: Button = $CanvasLayer/PausePanel/ResumeButton
@onready var chat_request: HTTPRequest = $ChatRequest

var current_room: Node2D
var player: Node2D
var is_transitioning := false
var dialogue_pages: PackedStringArray = PackedStringArray()
var dialogue_index := 0
var dialogue_callback: Callable = Callable()
var choice_mode := false
var dialogue_choices: Array = []
var active_speech_bubble: Node2D
var inventory_open := false
var inventory_selection := 0
var status_timer: SceneTreeTimer
var interact_release_lock := false
var pending_victory := false
var pause_menu_open := false
var pending_defeat_message := ""
var chat_waiting := false
var chat_transcript: Array[String] = []
var pending_chat_bubble_text := ""
var pending_chat_bubble_speaker := ""


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	$CanvasLayer.process_mode = Node.PROCESS_MODE_ALWAYS
	chat_request.process_mode = Node.PROCESS_MODE_ALWAYS
	_apply_map_panel_style()
	_apply_weapon_hud_panel_style()
	fade_rect.color.a = 1.0
	dialogue_panel.visible = false
	choice_container.visible = false
	choice_mode = false
	inventory_panel.visible = false
	status_label.visible = false
	prompt_label.visible = false
	victory_panel.visible = false
	pause_panel.visible = false
	chat_send_button.pressed.connect(_send_chat_message)
	chat_resume_button.pressed.connect(_resume_from_pause)
	chat_input.text_submitted.connect(_on_chat_text_submitted)
	chat_request.request_completed.connect(_on_chat_request_completed)

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
	if event.is_action_pressed("map_toggle"):
		map_panel.visible = not map_panel.visible
		get_viewport().set_input_as_handled()
		return

	if event.is_action_pressed("pause_menu"):
		if not is_transitioning and not victory_panel.visible:
			_toggle_pause_menu()
			get_viewport().set_input_as_handled()
		return

	if pause_menu_open:
		if event.is_action_pressed("ui_cancel"):
			_toggle_pause_menu(false)
			get_viewport().set_input_as_handled()
		return

	if event.is_action_released("interact"):
		interact_release_lock = false

	if event.is_action_pressed("interact"):
		if dialogue_panel.visible and not choice_mode:
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
		inventory_selection = min(inventory_selection + 1, max(_get_backpack_item_ids().size() - 1, 0))
		_refresh_inventory()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_cancel"):
		_toggle_inventory(false)
		get_viewport().set_input_as_handled()


func can_accept_player_input() -> bool:
	return not is_transitioning and not dialogue_panel.visible and not inventory_open and not victory_panel.visible and not pause_menu_open


func is_interact_locked() -> bool:
	return interact_release_lock


func request_room_change(room_id: String, spawn_id: String) -> void:
	if is_transitioning:
		return
	if room_id == GameState.current_room_id and spawn_id == GameState.current_spawn_id:
		return
	GameState.change_room(room_id, spawn_id)


func show_dialogue(speaker_name: String, lines: PackedStringArray, callback: Callable = Callable(), bubble_position: Vector2 = Vector2.INF) -> void:
	if lines.is_empty():
		return

	if pause_menu_open:
		_toggle_pause_menu(false)

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

	_remove_speech_bubble()
	if bubble_position != Vector2.INF and is_instance_valid(room_container):
		var bubble_script := load("res://scripts/SpeechBubble.gd")
		active_speech_bubble = Node2D.new()
		active_speech_bubble.set_script(bubble_script)
		room_container.add_child(active_speech_bubble)
		active_speech_bubble.global_position = bubble_position
		active_speech_bubble.setup(speaker_name + ": " + dialogue_pages[dialogue_index])

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


func show_dialogue_with_choices(speaker: String, prompt_text: String, choices: Array, bubble_position: Vector2 = Vector2.INF) -> void:
	if choices.is_empty():
		return
	if pause_menu_open:
		_toggle_pause_menu(false)
	inventory_open = false
	inventory_panel.visible = false
	interact_release_lock = true
	choice_mode = true
	dialogue_choices = choices
	dialogue_panel.visible = true
	speaker_label.text = speaker
	dialogue_label.text = prompt_text
	dialogue_hint_label.text = ""
	choice_container.visible = true
	for i in choice_container.get_child_count():
		var btn: Button = choice_container.get_child(i) as Button
		if btn == null:
			continue
		if i < choices.size():
			btn.text = choices[i].get("text", "...")
			btn.visible = true
			if btn.pressed.is_connected(_on_choice_pressed):
				btn.pressed.disconnect(_on_choice_pressed)
			btn.pressed.connect(_on_choice_pressed.bind(i))
		else:
			btn.visible = false
			if btn.pressed.is_connected(_on_choice_pressed):
				btn.pressed.disconnect(_on_choice_pressed)
	_remove_speech_bubble()
	if bubble_position != Vector2.INF and is_instance_valid(room_container):
		var bubble_script := load("res://scripts/SpeechBubble.gd")
		active_speech_bubble = Node2D.new()
		active_speech_bubble.set_script(bubble_script)
		room_container.add_child(active_speech_bubble)
		active_speech_bubble.global_position = bubble_position
		active_speech_bubble.setup(speaker + ": " + prompt_text)
	_refresh_prompt()


func _on_choice_pressed(choice_index: int) -> void:
	if not choice_mode or choice_index >= dialogue_choices.size():
		return
	var chosen: Dictionary = dialogue_choices[choice_index]
	choice_mode = false
	dialogue_choices.clear()
	choice_container.visible = false
	dialogue_panel.visible = false
	for i in choice_container.get_child_count():
		var btn: Button = choice_container.get_child(i) as Button
		if btn == null:
			continue
		btn.visible = false
		if btn.pressed.is_connected(_on_choice_pressed):
			btn.pressed.disconnect(_on_choice_pressed)
	interact_release_lock = true
	_remove_speech_bubble()
	var callback: Callable = chosen.get("callback", Callable())
	if callback.is_valid():
		callback.call()
	_refresh_ui()


func fail_mission(message: String) -> void:
	if is_transitioning:
		return
	pending_defeat_message = message
	call_deferred("_handle_player_defeat")


func is_room_silent_mission() -> bool:
	match GameState.current_room_id:
		"sunstone_ruins":
			return not GameState.get_flag("quest_sun_tablet_extracted")
		"market_crossroads":
			return not GameState.get_flag("quest_market_contract_built")
		_:
			return false


func get_room_silent_failure_message() -> String:
	match GameState.current_room_id:
		"sunstone_ruins":
			return "The bank heard you. Guards close in and the heist is dead."
		"market_crossroads":
			return "You made noise in the jeweler house. The family wakes up and the theft is over."
		_:
			return "You made enough noise to blow the mission."


func _toggle_pause_menu(force_visible: Variant = null) -> void:
	var should_show := not pause_menu_open
	if force_visible != null:
		should_show = bool(force_visible)

	pause_menu_open = should_show
	pause_panel.visible = should_show
	get_tree().paused = should_show
	if should_show:
		_refresh_pause_panel()
		chat_input.call_deferred("grab_focus")
	else:
		chat_input.release_focus()
		if not pending_chat_bubble_text.is_empty():
			_show_chat_bubble_on_nearest_npc()
	chat_waiting = false
	_refresh_prompt()


func _resume_from_pause() -> void:
	_toggle_pause_menu(false)


func _refresh_pause_panel() -> void:
	var context := _get_chat_context()
	pause_title_label.text = "Paused: %s" % context.get("speaker", "Mission Contact")
	pause_status_label.text = "Mission contact: %s\n%s" % [context.get("speaker", "Mission Contact"), context.get("summary", "Use the chat to ask for hints or roleplay while the game is paused.")]
	if chat_transcript.is_empty():
		chat_transcript.append("%s: %s" % [context.get("speaker", "Mission Contact"), context.get("intro", "I'm here. Ask what you need.")])
	chat_history.text = "\n\n".join(chat_transcript)
	chat_history.scroll_vertical = chat_history.get_line_count()


func _on_chat_text_submitted(_text: String) -> void:
	_send_chat_message()


func _send_chat_message() -> void:
	if not pause_menu_open or chat_waiting:
		return

	var user_text := chat_input.text.strip_edges()
	if user_text.is_empty():
		return

	var context := _get_chat_context()
	chat_transcript.append("You: %s" % user_text)
	chat_input.clear()
	_refresh_pause_panel()

	var api_key := OS.get_environment("OPENAI_API_KEY").strip_edges()
	if api_key.is_empty():
		var fallback_reply := _build_fallback_chat_reply(user_text, context)
		var speaker_name: String = context.get("speaker", "Mission Contact")
		chat_transcript.append("%s: %s" % [speaker_name, fallback_reply])
		pending_chat_bubble_text = fallback_reply
		pending_chat_bubble_speaker = speaker_name
		_refresh_pause_panel()
		return

	chat_waiting = true
	var system_prompt := str(context.get("system_prompt", "You are a grounded village NPC in a top-down RPG. Reply briefly and helpfully."))
	var request_body := {
		"model": "gpt-4.1-mini",
		"messages": [
			{"role": "system", "content": system_prompt},
			{"role": "user", "content": "Room: %s\nObjective:\n%s\nPlayer message: %s" % [GameState.get_room_title(GameState.current_room_id), _get_objective_text(), user_text]}
		],
		"max_tokens": 120,
		"temperature": 0.8
	}
	var headers := PackedStringArray([
		"Content-Type: application/json",
		"Authorization: Bearer %s" % api_key
	])
	var error := chat_request.request("https://api.openai.com/v1/chat/completions", headers, HTTPClient.METHOD_POST, JSON.stringify(request_body))
	if error != OK:
		chat_waiting = false
		var fallback_reply := _build_fallback_chat_reply(user_text, context)
		var speaker_name: String = context.get("speaker", "Mission Contact")
		chat_transcript.append("%s: %s" % [speaker_name, fallback_reply])
		pending_chat_bubble_text = fallback_reply
		pending_chat_bubble_speaker = speaker_name
		_refresh_pause_panel()


func _on_chat_request_completed(_result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if not pause_menu_open:
		chat_waiting = false
		return

	var context := _get_chat_context()
	var reply_text := ""
	var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
	if response_code >= 200 and response_code < 300 and typeof(parsed) == TYPE_DICTIONARY:
		var choices: Array = parsed.get("choices", [])
		if not choices.is_empty():
			var message: Dictionary = choices[0].get("message", {})
			reply_text = str(message.get("content", "")).strip_edges()

	if reply_text.is_empty():
		reply_text = _build_fallback_chat_reply("", context)

	chat_waiting = false
	var speaker_name: String = context.get("speaker", "Mission Contact")
	chat_transcript.append("%s: %s" % [speaker_name, reply_text])
	pending_chat_bubble_text = reply_text
	pending_chat_bubble_speaker = speaker_name
	_refresh_pause_panel()


func _get_chat_context() -> Dictionary:
	match GameState.current_room_id:
		"forest_path":
			return {
				"speaker": "Marta",
				"summary": "An old villager hiding near the square. She knows where the creatures came from.",
				"intro": "Those things came in from the plaza. If you keep calm, I will tell you what I saw.",
				"system_prompt": "You are Marta, an older village woman in Willow Village. Reply like a real frightened but sharp person. Stay grounded, concise, and talk about the current mission, nearby streets, the old plaza, and survival."
			}
		"echo_cave":
			return {
				"speaker": "Farmer Tomas",
				"summary": "A tired farmer trying to recover his eggs and chickens before the day collapses.",
				"intro": "If you can get my chickens and the eggs back, I can still salvage the morning.",
				"system_prompt": "You are Farmer Tomas in a village farm mission. Reply naturally, talk like a practical farmer, and give grounded hints about eggs, chickens, fences, and the farmyard."
			}
		"sunstone_ruins":
			return {
				"speaker": "Nico",
				"summary": "Your inside contact near the village bank. He talks in a low voice and expects stealth.",
				"intro": "Quiet now. No shots, no panic, no hero stuff. In and out.",
				"system_prompt": "You are Nico, an inside contact helping with a stealth bank robbery in a village. Reply briefly, realistically, and always reinforce stealth, timing, silence, and escape routes."
			}
		"bloom_marsh":
			return {
				"speaker": "Ivo",
				"summary": "A neighbor pinned outside the occupied lane house while robbers hold the upstairs rooms.",
				"intro": "Two gunmen are still inside. Get into the house, clear them, and get the family out.",
				"system_prompt": "You are Ivo, a grounded villager outside a house taken by armed robbers. Reply briefly and realistically. Talk about room layout, gunfire, cover, upstairs halls, and getting the family out."
			}
		"market_crossroads":
			return {
				"speaker": "Sera",
				"summary": "A quiet market contact helping you steal jewelry from the house above the square without waking the family.",
				"intro": "Balcony first. Cabinet second. Roofline out. If they wake up, the whole square turns on you.",
				"system_prompt": "You are Sera, a grounded lookout assisting a stealth jewelry theft over a village market. Reply briefly and naturally. Talk about balcony entry, quiet floors, sleeping family, and the rooftop escape."
			}
		"ember_fields":
			return {
				"speaker": "Miro",
				"summary": "A prisoner waiting inside the upper cells while guards control the yard and corridors.",
				"intro": "Get through the yard, reach my cell, and do not leave me here.",
				"system_prompt": "You are Miro, a prisoner in a village jail break mission. Reply briefly and realistically. Talk about guards, cell blocks, roof gates, patrol angles, and escape pressure."
			}
		_:
			return {
				"speaker": "Mission Contact",
				"summary": "A local contact tied to the current operation.",
				"intro": "I am on the line. Ask what you need.",
				"system_prompt": "You are a grounded village mission contact in a top-down RPG. Reply briefly, naturally, and helpfully."
			}


func _build_fallback_chat_reply(user_text: String, context: Dictionary) -> String:
	var lowered := user_text.to_lower()
	if lowered.contains("help") or lowered.contains("hint") or lowered.contains("what do i do"):
		return _get_short_room_hint()
	if lowered.contains("hello") or lowered.contains("hi"):
		return "Focus first. %s" % context.get("summary", "Keep the mission moving.")
	if lowered.contains("sorry") or lowered.contains("scared"):
		return "That is normal. Stay quiet, keep moving, and do not force the room."
	if lowered.contains("bank"):
		return "No shots. Work the side route, take the cash, and leave before anyone fixes their eyes on you."
	if lowered.contains("chicken") or lowered.contains("egg"):
		return "Cut the angle and herd them back toward the fence. Do not chase in a straight line."
	if lowered.contains("old lady") or lowered.contains("marta"):
		return "Clear the pressure in the square first. People talk after they feel safe."
	if lowered.contains("jewelry") or lowered.contains("family"):
		return "Use the blind side of the room and do not linger near the beds."
	if lowered.contains("robber") or lowered.contains("bandit"):
		return "Push the house with cover, clear the upstairs gunmen, and do not stand in the middle of the hall."
	if lowered.contains("robber") or lowered.contains("gunmen") or lowered.contains("market"):
		return "Use the balcony, steal the jewelry, and get across the roof before anyone inside wakes up."
	if lowered.contains("prison") or lowered.contains("cell"):
		return "Break the yard first, hit the cell block, then clear the guards before you run for the roof gate."
	return "Keep your head. %s" % _get_short_room_hint()


func _get_short_room_hint() -> String:
	match GameState.current_room_id:
		"forest_path":
			return "Kill the creature in the square, then get to Marta's porch."
		"echo_cave":
			return "Get the eggs first, then cut off the chickens as they try to break around the fence."
		"sunstone_ruins":
			return "Use the side lanes, stay out of the open bank lines, touch the vault, and leave with the cash without firing."
		"bloom_marsh":
			return "Push through the side door, clear the robbers upstairs, and secure the family room."
		"market_crossroads":
			return "Climb in from the balcony, hit the jewelry room, and escape across the roofline without waking the family."
		"ember_fields":
			return "Break into the yard, reach the cell block, free the prisoner, and clear the guards before the roof exit."
		_:
			return "Read the top-right objective panel and finish the current phase before forcing the exit."
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

	if pause_menu_open:
		_toggle_pause_menu(false)

	GameState.reset_run_after_death()
	await _load_room(GameState.current_room_id, GameState.current_spawn_id, true)
	var defeat_message := pending_defeat_message if not pending_defeat_message.is_empty() else "You were defeated. You wake in the clearing without your guns."
	pending_defeat_message = ""
	show_status_message(defeat_message)


func _on_room_change_requested(room_id: String, spawn_id: String) -> void:
	call_deferred("_start_room_change", room_id, spawn_id)


func _start_room_change(room_id: String, spawn_id: String) -> void:
	await _load_room(room_id, spawn_id, true)


func _load_room(room_id: String, spawn_id: String, with_fade: bool) -> void:
	is_transitioning = true
	get_tree().paused = false
	dialogue_panel.visible = false
	inventory_open = false
	inventory_panel.visible = false
	pause_menu_open = false
	pause_panel.visible = false
	chat_waiting = false
	chat_transcript.clear()
	pending_chat_bubble_text = ""
	pending_chat_bubble_speaker = ""
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

	_spawn_room_quest(room_id)
	_configure_room_portals(room_id)
	player.global_position = _get_spawn_position(spawn_id)
	GameState.mark_room_discovered(room_id)
	var beginner_bonus_message := _apply_beginner_room_bonus(room_id)
	_refresh_navigation_ui()
	_refresh_map()

	if with_fade:
		await _fade_to(0.0)
		var room_name: String = _get_room_name()
		if not beginner_bonus_message.is_empty():
			show_status_message(beginner_bonus_message)
		elif not room_name.is_empty():
			show_status_message("Entered %s" % room_name)

	is_transitioning = false
	_refresh_ui()
	_maybe_show_mission_brief(room_id)


func _get_spawn_position(spawn_id: String) -> Vector2:
	if is_instance_valid(current_room):
		return current_room.get_spawn_position(spawn_id)
	return Vector2.ZERO


func _advance_dialogue() -> void:
	dialogue_index += 1
	if dialogue_index < dialogue_pages.size():
		dialogue_label.text = dialogue_pages[dialogue_index]
		if is_instance_valid(active_speech_bubble) and active_speech_bubble.has_method("setup"):
			active_speech_bubble.setup(speaker_label.text + ": " + dialogue_pages[dialogue_index])
		return

	dialogue_panel.visible = false
	_remove_speech_bubble()
	interact_release_lock = true
	var callback: Callable = dialogue_callback
	dialogue_callback = Callable()
	if callback.is_valid():
		callback.call()
	if pending_victory:
		pending_victory = false
		_show_victory()
	_refresh_ui()


func _remove_speech_bubble() -> void:
	if is_instance_valid(active_speech_bubble):
		active_speech_bubble.queue_free()
	active_speech_bubble = null


func _show_chat_bubble_on_nearest_npc() -> void:
	if pending_chat_bubble_text.is_empty():
		return
	var bubble_text := pending_chat_bubble_speaker + ": " + pending_chat_bubble_text
	pending_chat_bubble_text = ""
	pending_chat_bubble_speaker = ""

	# Find the nearest NPC (interactable) to the player
	var bubble_pos := Vector2.INF
	if is_instance_valid(player) and is_instance_valid(current_room):
		var nearest_dist := INF
		for node in get_tree().get_nodes_in_group("interactable"):
			if not (node is Node2D):
				continue
			var npc_node := node as Node2D
			var parent_node := npc_node.get_parent()
			var npc_pos: Vector2
			if parent_node is Node2D:
				npc_pos = (parent_node as Node2D).global_position
			else:
				npc_pos = npc_node.global_position
			var dist := player.global_position.distance_squared_to(npc_pos)
			if dist < nearest_dist:
				nearest_dist = dist
				bubble_pos = npc_pos + Vector2(0, -42)

	if bubble_pos == Vector2.INF and is_instance_valid(player):
		bubble_pos = player.global_position + Vector2(0, -60)

	_remove_speech_bubble()
	if is_instance_valid(room_container):
		var bubble_script := load("res://scripts/SpeechBubble.gd")
		active_speech_bubble = Node2D.new()
		active_speech_bubble.set_script(bubble_script)
		room_container.add_child(active_speech_bubble)
		active_speech_bubble.global_position = bubble_pos
		active_speech_bubble.setup(bubble_text, 4.0)


func _toggle_inventory(force_visible: Variant = null) -> void:
	var should_show: bool = not inventory_open
	if force_visible != null:
		should_show = bool(force_visible)

	inventory_open = should_show
	inventory_panel.visible = should_show
	if should_show:
		inventory_selection = clampi(inventory_selection, 0, max(_get_backpack_item_ids().size() - 1, 0))
		_refresh_inventory()
	_refresh_prompt()


func _refresh_ui() -> void:
	health_label.text = "HP: %d/%d" % [GameState.player_hp, GameState.player_max_hp]
	coins_label.text = "Coins: %d" % GameState.coins
	_refresh_navigation_ui()
	_refresh_map()
	_refresh_weapon_hud()
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
			return "Objective: Enter the forge house for the side weapon or start the main run through the portal to %s.\nThe opening route is mission-based: rescue, farm work, silent heist, house assault, jewelry theft, and prison break." % GameState.get_room_title(first_room)
		return "Objective: Start the operation run through the portal to %s.\nThe early route is built around village missions inside buildings, not generic pickup chains." % GameState.get_room_title(first_room)

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

	var room_quest := _get_room_quest(room_id)
	if not room_quest.is_empty():
		return _get_room_quest_status_text(room_id, room_quest)

	if GameState.is_shop_level(room_id):
		var next_shop_room := GameState.get_next_main_room(room_id)
		return "Level %d/%d shop.\nTier: Beginner.\nOperation Hub: Spend coins, rearm, finish the market theft, then deploy to %s.\nBosses still do not appear in the first 10 levels." % [GameState.get_level_number(room_id), GameState.get_main_route().size(), GameState.get_room_title(next_shop_room)]

	var route_level := GameState.get_level_number(room_id)
	var route_total_count := GameState.get_main_route().size()
	if GameState.is_final_level(room_id):
		return "Level %d/%d.\nObjective: Defeat the final boss in the hardest room." % [route_level, route_total_count]

	var next_room_id := GameState.get_next_main_room(room_id)
	if next_room_id.is_empty():
		return "Objective: Explore freely."
	var enemy_hint := "Early rooms mix creatures, stealth, robbers, and guards. Bosses still start later." if route_level <= 10 else "Bosses can appear from here on."
	return "Level %d/%d.\n%s\n%s\nObjective: Clear this area, gather coins, and push through the portal to %s." % [route_level, route_total_count, _get_tier_text(route_level), enemy_hint, GameState.get_room_title(next_room_id)]


func _apply_beginner_room_bonus(room_id: String) -> String:
	if not GameState.is_beginner_level(room_id):
		return ""

	var reward_flag := "beginner_bonus_%s" % room_id
	if GameState.get_flag(reward_flag):
		return ""

	var rewards: Array[String] = []
	if GameState.player_hp < GameState.player_max_hp:
		GameState.set_player_hp(GameState.player_max_hp, true)
		rewards.append("full heal")

	if GameState.add_item("berry", 1):
		rewards.append("+1 berry")

	var bonus_coins := GameState.get_beginner_bonus_coins(room_id)
	if bonus_coins > 0:
		GameState.add_coins(bonus_coins)
		rewards.append("+%d coins" % bonus_coins)

	GameState.set_flag(reward_flag)
	return "Beginner bonus: %s." % ", ".join(rewards)


func _maybe_show_mission_brief(room_id: String) -> void:
	var room_quest := _get_room_quest(room_id)
	if room_quest.is_empty():
		return

	var briefing_lines := PackedStringArray(room_quest.get("briefing_lines", []))
	if briefing_lines.is_empty():
		return

	var briefing_flag := "mission_brief_seen_%s" % room_id
	if GameState.get_flag(briefing_flag):
		return

	GameState.set_flag(briefing_flag)
	show_dialogue(str(room_quest.get("title", "Mission Brief")), briefing_lines)


func _get_room_quest(room_id: String) -> Dictionary:
	if EARLY_QUEST_DATA.has(room_id):
		return EARLY_QUEST_DATA[room_id]
	return {}


func _spawn_room_quest(room_id: String) -> void:
	var room_quest := _get_room_quest(room_id)
	if room_quest.is_empty() or not is_instance_valid(current_room):
		return

	var step_list: Array = room_quest.get("steps", [])
	for step_variant in step_list:
		var step: Dictionary = step_variant
		var quest_pickup := QUEST_PICKUP_SCENE.instantiate()
		current_room.add_child(quest_pickup)
		quest_pickup.position = step.get("position", Vector2.ZERO)
		quest_pickup.prompt_text = str(step.get("prompt", "Search"))
		quest_pickup.speaker_name = str(step.get("speaker", "Clue"))
		quest_pickup.dialogue_lines = PackedStringArray(step.get("dialogue_lines", []))
		quest_pickup.repeat_dialogue_lines = PackedStringArray(step.get("repeat_dialogue_lines", ["This step is already complete."]))
		quest_pickup.locked_dialogue_lines = PackedStringArray(step.get("locked_dialogue_lines", ["You still need to finish another part of this mission first."]))
		quest_pickup.required_flags = PackedStringArray(step.get("required_flags", []))
		quest_pickup.visible_after_flags = PackedStringArray(step.get("visible_after_flags", []))
		quest_pickup.completion_flag = str(step.get("flag", ""))
		quest_pickup.reward_coins = int(step.get("reward_coins", 0))
		quest_pickup.reward_item_id = str(step.get("reward_item_id", ""))
		quest_pickup.reward_amount = int(step.get("reward_amount", 1))
		quest_pickup.completion_message = str(step.get("completion_message", "Objective complete."))
		quest_pickup.primary_color = step.get("primary_color", Color(0.75, 0.56, 0.24, 1.0))
		quest_pickup.accent_color = step.get("accent_color", Color(0.97, 0.87, 0.42, 1.0))
		quest_pickup.glow_color = step.get("glow_color", Color(1.0, 0.9, 0.5, 0.18))
		quest_pickup.glyph_text = str(step.get("glyph_text", "!"))
		quest_pickup.auto_trigger = bool(step.get("auto_trigger", false))
		quest_pickup.consume_on_complete = bool(step.get("consume_on_complete", true))
		quest_pickup.target_room_id = str(step.get("target_room_id", ""))
		quest_pickup.target_spawn_id = str(step.get("target_spawn_id", ""))
		quest_pickup.show_visuals = bool(step.get("show_visuals", true))


func _configure_room_portals(room_id: String) -> void:
	if not is_instance_valid(current_room):
		return

	var portal_forward := current_room.get_node_or_null("PortalForward")
	if portal_forward == null:
		return

	var room_quest := _get_room_quest(room_id)
	if room_quest.is_empty():
		portal_forward.required_flag = ""
		portal_forward.locked_label = ""
		portal_forward.locked_message = ""
	else:
		portal_forward.required_flag = str(room_quest.get("completion_flag", ""))
		portal_forward.locked_label = "Finish mission"
		portal_forward.locked_message = "You still need to finish this room's mission."

	if portal_forward.has_method("refresh_portal"):
		portal_forward.refresh_portal()


func _get_room_quest_status_text(room_id: String, room_quest: Dictionary) -> String:
	var level_number := GameState.get_level_number(room_id)
	var route_total := GameState.get_main_route().size()
	var completion_flag := str(room_quest.get("completion_flag", ""))
	var mission_header := _get_mission_header(level_number, route_total, room_quest)
	if not completion_flag.is_empty() and GameState.get_flag(completion_flag):
		var next_room := GameState.get_next_main_room(room_id)
		if next_room.is_empty():
			return "%s\nMission clear: %s." % [mission_header, str(room_quest.get("title", "Mission"))]
		return "%s\nMission clear: %s.\nObjective: Take the portal to %s." % [mission_header, str(room_quest.get("title", "Mission")), GameState.get_room_title(next_room)]

	match room_id:
		"forest_path":
			if not GameState.get_flag("enemy_forest_slime_defeated"):
				return "%s\nPhase: Kill the creature outside Marta's lane before it reaches her house." % mission_header
			return "%s\nPhase: Reach Marta's porch and bring her out." % mission_header
		"echo_cave":
			if not GameState.get_flag("quest_echo_crystal_west"):
				return "%s\nPhase: Collect the first egg from the north nest." % mission_header
			if not GameState.get_flag("quest_echo_crystal_east"):
				return "%s\nPhase: Collect the second egg before it gets crushed." % mission_header
			var chicken_count := _count_flags(["quest_echo_chicken_white", "quest_echo_chicken_brown"])
			if chicken_count < 2:
				return "%s\nPhase: Catch the runaway chickens in the yard.\nProgress: %d/2 chickens." % [mission_header, chicken_count]
			return "%s\nPhase: Return the eggs and chickens to Farmer Tomas." % mission_header
		"echo_rift":
			var rift_count := _count_flags(["enemy_echo_rift_slime_a_defeated", "enemy_echo_rift_slime_b_defeated", "enemy_echo_rift_slime_c_defeated"])
			if rift_count < 3:
				return "%s\nPhase: Clear the void slimes before the rift heart seals itself.\nProgress: %d/3 void slimes." % [mission_header, rift_count]
			return "%s\nPhase: Seize the void core and force the pocket back into Echo Cave." % mission_header
		"sunstone_ruins":
			if not GameState.get_flag("quest_sun_key_taken"):
				return "%s\nPhase: Slip into the bank through the side office." % mission_header
			if not GameState.get_flag("quest_sun_archive_open"):
				return "%s\nPhase: Cross the open bank floor without entering a guard lane." % mission_header
			if not GameState.get_flag("quest_sun_tablet_taken"):
				return "%s\nPhase: Reach the vault shelf and grab the cash." % mission_header
			if not GameState.get_flag("quest_sun_cash_second"):
				return "%s\nPhase: Cross the back hall and line up the alley exit." % mission_header
			return "%s\nPhase: Slip out through the back alley without being seen." % mission_header
		"bloom_marsh":
			if not GameState.get_flag("quest_marsh_herb_north"):
				return "%s\nPhase: Breach the side door and get into the house." % mission_header
			if not GameState.get_flag("quest_marsh_herb_mid"):
				return "%s\nPhase: Push into the upper hall." % mission_header
			var robber_clear := _count_flags(["enemy_bloom_robber_a_defeated", "enemy_bloom_robber_b_defeated"])
			if robber_clear < 2:
				return "%s\nPhase: Kill the robbers holding the house.\nProgress: %d/2 robbers." % [mission_header, robber_clear]
			return "%s\nPhase: Secure the family room upstairs." % mission_header
		"market_crossroads":
			if not GameState.get_flag("quest_market_rumor_west"):
				return "%s\nPhase: Climb into the jeweler house from the market balcony." % mission_header
			if not GameState.get_flag("quest_market_rumor_mid"):
				return "%s\nPhase: Reach the jewelry room without waking the family." % mission_header
			if not GameState.get_flag("quest_market_rumor_east"):
				return "%s\nPhase: Get the jewelry to the roofline without making noise." % mission_header
			return "%s\nPhase: Escape across the rooftop line before the square wakes up." % mission_header
		"ember_fields":
			if not GameState.get_flag("quest_ember_valve_left"):
				return "%s\nPhase: Breach the prison yard." % mission_header
			if not GameState.get_flag("quest_ember_valve_right"):
				return "%s\nPhase: Reach the cell block through the inner corridor." % mission_header
			if not GameState.get_flag("quest_ember_lift_raised"):
				return "%s\nPhase: Free the prisoner from the upper cell." % mission_header
			var guard_clear := _count_flags(["enemy_ember_guard_a_defeated", "enemy_ember_guard_b_defeated", "enemy_ember_guard_c_defeated"])
			if guard_clear < 3:
				return "%s\nPhase: Clear the prison guards before you run for the roof gate.\nProgress: %d/3 guards." % [mission_header, guard_clear]
			return "%s\nPhase: Escape through the roof gate with the prisoner." % mission_header
		"iron_docks":
			if not GameState.get_flag("quest_dock_cutters_taken"):
				return "%s\nPhase: Secure the bolt cutters on the lower gantry." % mission_header
			if not GameState.get_flag("quest_dock_chain_cut"):
				return "%s\nPhase: Cut the payroll chain in the center lane." % mission_header
			if not GameState.get_flag("quest_dock_strongbox_taken"):
				return "%s\nPhase: Crack the upper strongbox and seize the harbor payroll." % mission_header
			var dock_clear := _count_flags(["enemy_iron_docks_slime_a_defeated", "enemy_iron_docks_slime_b_defeated", "enemy_iron_docks_slime_c_defeated"])
			if dock_clear < 3:
				return "%s\nPhase: Hold the rope-lift exit by clearing the dock slimes.\nProgress: %d/3 dock slimes." % [mission_header, dock_clear]
			return "%s\nPhase: Escape with the payroll before the harbor locks down." % mission_header
		"verdant_garden":
			var clue_count := _count_flags(["quest_garden_clue_left", "quest_garden_clue_top", "quest_garden_clue_right"])
			if clue_count < 3:
				return "%s\nPhase: Trace the greenhouse vault trail through the hedge clues.\nProgress: %d/3 clues." % [mission_header, clue_count]
			var garden_clear := _count_flags(["enemy_verdant_garden_slime_a_defeated", "enemy_verdant_garden_slime_b_defeated", "enemy_verdant_garden_slime_c_defeated"])
			if garden_clear < 3:
				return "%s\nPhase: Clear the greenhouse guards before the key route opens.\nProgress: %d/3 garden slimes." % [mission_header, garden_clear]
			if not GameState.get_flag("quest_garden_key_taken"):
				return "%s\nPhase: Recover the buried brass key from the center lane." % mission_header
			return "%s\nPhase: Open the greenhouse vault and seize the medical stockpile." % mission_header
		"dune_courtyard":
			if not GameState.get_flag("quest_dune_notes_taken"):
				return "%s\nPhase: Steal the scout notes from the lower court." % mission_header
			if not GameState.get_flag("quest_dune_sundial_aligned"):
				return "%s\nPhase: Align the sun dial to expose the archive code." % mission_header
			if not GameState.get_flag("quest_dune_pass_forged"):
				return "%s\nPhase: Forge the archive pass at the east desk." % mission_header
			var dune_clear := _count_flags(["enemy_dune_courtyard_slime_a_defeated", "enemy_dune_courtyard_slime_b_defeated", "enemy_dune_courtyard_slime_c_defeated"])
			if dune_clear < 3:
				return "%s\nPhase: Clear the courtyard before the archive chest can be forced.\nProgress: %d/3 courtyard slimes." % [mission_header, dune_clear]
			return "%s\nPhase: Steal the magistrate ledger and expose the route debt chain." % mission_header
		"ashen_keep":
			var ward_count := _count_flags(["quest_keep_brazier_left", "quest_keep_brazier_right"])
			if ward_count < 2:
				return "%s\nPhase: Snuff both ward braziers and break the prison seal line.\nProgress: %d/2 braziers." % [mission_header, ward_count]
			if not GameState.get_flag("quest_keep_black_seal_taken"):
				return "%s\nPhase: Seize the black seal from the war room." % mission_header
			var keep_clear := _count_flags(["enemy_ashen_keep_slime_a_defeated", "enemy_ashen_keep_slime_b_defeated", "enemy_ashen_keep_slime_c_defeated"])
			if keep_clear < 3:
				return "%s\nPhase: Clear the keep before the burning breach can be entered.\nProgress: %d/3 keep slimes." % [mission_header, keep_clear]
			return "%s\nPhase: Enter the burning zero-gravity breach and finish the seal collapse." % mission_header
		"ashen_rift":
			var shadow_count := _count_flags(["enemy_ashen_rift_slime_a_defeated", "enemy_ashen_rift_slime_b_defeated", "enemy_ashen_rift_slime_c_defeated"])
			if shadow_count < 3:
				return "%s\nPhase: Clear the shadow slimes inside the burning breach.\nProgress: %d/3 shadow slimes." % [mission_header, shadow_count]
			return "%s\nPhase: Claim the seal core and crash the breach shut." % mission_header
		_:
			return "%s\nPhase: Finish the room operation." % mission_header


func _get_mission_header(level_number: int, route_total: int, room_quest: Dictionary = {}) -> String:
	var operation_name := str(room_quest.get("title", "Unnamed Operation"))
	var purpose := str(room_quest.get("purpose", "Push the route forward."))
	var stakes := str(room_quest.get("stakes", "Failure keeps the corridor locked."))
	return "Level %d/%d.\n%s\nOp: %s\nGoal: %s\nRisk: %s" % [level_number, route_total, _get_tier_text(level_number), operation_name, purpose, stakes]


func _count_flags(flag_names: Array) -> int:
	var count := 0
	for flag_name in flag_names:
		if GameState.get_flag(str(flag_name)):
			count += 1
	return count


func _refresh_prompt() -> void:
	if inventory_open or dialogue_panel.visible or is_transitioning or victory_panel.visible or pause_menu_open:
		prompt_label.visible = false
		return

	var prompt_text: String = player.get_interaction_prompt()
	prompt_label.text = prompt_text
	prompt_label.visible = not prompt_text.is_empty()


func _refresh_inventory() -> void:
	var item_ids := _get_backpack_item_ids()
	backpack_stats_label.text = "Load %.1f / %.1f kg" % [GameState.get_backpack_load(), GameState.get_backpack_capacity()]
	if item_ids.is_empty():
		inventory_list_label.text = "Backpack is empty."
		inventory_description_label.text = "Food, tools, loot, and mission items you can realistically carry will appear here."
		inventory_hint_label.text = "[I] Close"
		return

	inventory_selection = clampi(inventory_selection, 0, item_ids.size() - 1)
	var lines: Array[String] = []
	for index in range(item_ids.size()):
		var item_id: String = item_ids[index]
		var item_def: Dictionary = GameState.get_item_def(item_id)
		var prefix := ">" if index == inventory_selection else " "
		lines.append("%s [%s] %s x%d" % [
			prefix,
			GameState.get_item_category_label(item_id),
			item_def.get("display_name", item_id),
			GameState.get_item_count(item_id)
		])
	inventory_list_label.text = "\n".join(lines)

	var selected_id: String = item_ids[inventory_selection]
	var selected_def: Dictionary = GameState.get_item_def(selected_id)
	var detail_lines: Array[String] = [
		"%s • %.1f kg each" % [GameState.get_item_category_label(selected_id), GameState.get_item_weight(selected_id)],
		str(selected_def.get("description", "")),
	]
	if GameState.get_item_heal_amount(selected_id) > 0:
		detail_lines.append("Use: restores %d HP." % GameState.get_item_heal_amount(selected_id))
	inventory_description_label.text = "\n".join(detail_lines)
	if bool(selected_def.get("usable", false)):
		inventory_hint_label.text = "[E] Use  [I] Close"
	else:
		inventory_hint_label.text = "[I] Close"


func _use_selected_item() -> void:
	var item_ids := _get_backpack_item_ids()
	if item_ids.is_empty():
		return

	var selected_id: String = item_ids[inventory_selection]
	var heal_amount := GameState.get_item_heal_amount(selected_id)
	if heal_amount > 0:
		if GameState.player_hp >= GameState.player_max_hp:
			show_status_message("You are already at full health.")
			return
		if GameState.consume_item(selected_id) and GameState.heal_player(heal_amount):
			var item_name := str(GameState.get_item_def(selected_id).get("display_name", selected_id))
			show_status_message("You use %s and recover %d HP." % [item_name, heal_amount])
			_refresh_inventory()
		return

	show_status_message("That item cannot be used right now.")


func _refresh_weapon_hud() -> void:
	for child in weapon_slots.get_children():
		child.free()

	var equipped_weapon_id := GameState.get_best_gun_id()
	if equipped_weapon_id.is_empty():
		equipped_weapon_id = "knife"

	for item_id in _get_owned_weapon_ids():
		var slot_data: Dictionary = WEAPON_HUD_META.get(item_id, {})
		var slot := Panel.new()
		slot.custom_minimum_size = Vector2(66, 58)
		slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		slot.add_theme_stylebox_override("panel", _make_weapon_slot_style(item_id == equipped_weapon_id, slot_data))

		var margin := MarginContainer.new()
		margin.mouse_filter = Control.MOUSE_FILTER_IGNORE
		margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		margin.add_theme_constant_override("margin_left", 7)
		margin.add_theme_constant_override("margin_top", 6)
		margin.add_theme_constant_override("margin_right", 7)
		margin.add_theme_constant_override("margin_bottom", 6)
		slot.add_child(margin)

		var column := VBoxContainer.new()
		column.mouse_filter = Control.MOUSE_FILTER_IGNORE
		column.alignment = BoxContainer.ALIGNMENT_CENTER
		column.add_theme_constant_override("separation", 0)
		margin.add_child(column)

		var short_label := Label.new()
		short_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		short_label.text = str(slot_data.get("short_label", item_id.left(3).to_upper()))
		short_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		short_label.add_theme_font_size_override("font_size", 15)
		short_label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
		column.add_child(short_label)

		var name_label := Label.new()
		name_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
		name_label.text = str(slot_data.get("display_name", item_id))
		name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name_label.clip_text = true
		name_label.add_theme_font_size_override("font_size", 9)
		name_label.add_theme_color_override("font_color", Color(0.9, 0.95, 0.98, 0.92))
		column.add_child(name_label)

		if item_id == equipped_weapon_id:
			var equipped_label := Label.new()
			equipped_label.mouse_filter = Control.MOUSE_FILTER_IGNORE
			equipped_label.text = "EQ"
			equipped_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			equipped_label.add_theme_font_size_override("font_size", 8)
			equipped_label.add_theme_color_override("font_color", Color(1.0, 0.95, 0.8, 1.0))
			column.add_child(equipped_label)

		weapon_slots.add_child(slot)


func _get_owned_weapon_ids() -> Array[String]:
	var owned_weapons: Array[String] = ["knife"]
	for item_id in WEAPON_HUD_ORDER:
		if item_id == "knife":
			continue
		if GameState.get_item_count(item_id) > 0:
			owned_weapons.append(item_id)
	return owned_weapons


func _apply_weapon_hud_panel_style() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.08, 0.12, 0.72)
	panel_style.corner_radius_top_left = 14
	panel_style.corner_radius_top_right = 14
	panel_style.corner_radius_bottom_left = 14
	panel_style.corner_radius_bottom_right = 14
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.3, 0.42, 0.52, 0.5)
	weapon_hud_panel.add_theme_stylebox_override("panel", panel_style)


func _apply_map_panel_style() -> void:
	var panel_style := StyleBoxFlat.new()
	panel_style.bg_color = Color(0.05, 0.08, 0.12, 0.74)
	panel_style.corner_radius_top_left = 14
	panel_style.corner_radius_top_right = 14
	panel_style.corner_radius_bottom_left = 14
	panel_style.corner_radius_bottom_right = 14
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Color(0.3, 0.42, 0.52, 0.52)
	map_panel.add_theme_stylebox_override("panel", panel_style)
	map_title_label.text = "Route Map"
	map_legend_label.text = "Gold = you • Lit = discovered • Dark = unknown • [M] toggle"


func _refresh_map() -> void:
	map_current_label.text = GameState.get_room_title(GameState.current_room_id)

	for child in map_canvas.get_children():
		child.free()

	var room_points := _build_map_room_points()
	var main_route := GameState.get_main_route()
	if not main_route.is_empty():
		_add_map_connection("home_clearing", main_route[0], room_points)
	for index in range(main_route.size() - 1):
		_add_map_connection(main_route[index], main_route[index + 1], room_points)

	_add_map_connection("home_clearing", "forge_hall", room_points)
	_add_map_connection("forge_hall", "arcane_vault", room_points)
	if room_points.has("echo_rift"):
		_add_map_connection("echo_cave", "echo_rift", room_points)
	if room_points.has("ashen_rift"):
		_add_map_connection("ashen_keep", "ashen_rift", room_points)

	_add_map_room_marker("home_clearing", room_points.get("home_clearing", MAP_HOME_POINT))
	for room_id in main_route:
		_add_map_room_marker(room_id, room_points.get(room_id, MAP_HOME_POINT))
	_add_map_room_marker("forge_hall", room_points.get("forge_hall", MAP_FORGE_POINT))
	_add_map_room_marker("arcane_vault", room_points.get("arcane_vault", MAP_VAULT_POINT))
	if room_points.has("echo_rift"):
		_add_map_room_marker("echo_rift", room_points["echo_rift"])
	if room_points.has("ashen_rift"):
		_add_map_room_marker("ashen_rift", room_points["ashen_rift"])


func _build_map_room_points() -> Dictionary:
	var room_points := {
		"home_clearing": MAP_HOME_POINT,
		"forge_hall": MAP_FORGE_POINT,
		"arcane_vault": MAP_VAULT_POINT,
	}
	var main_route := GameState.get_main_route()
	for index in range(min(main_route.size(), MAP_ROUTE_SLOT_POINTS.size())):
		room_points[main_route[index]] = MAP_ROUTE_SLOT_POINTS[index]

	if room_points.has("echo_cave") and (GameState.is_room_discovered("echo_rift") or GameState.current_room_id == "echo_rift"):
		room_points["echo_rift"] = room_points["echo_cave"] + MAP_RIFT_OFFSETS["echo_rift"]
	if room_points.has("ashen_keep") and (GameState.is_room_discovered("ashen_rift") or GameState.current_room_id == "ashen_rift"):
		room_points["ashen_rift"] = room_points["ashen_keep"] + MAP_RIFT_OFFSETS["ashen_rift"]

	return room_points


func _add_map_connection(from_room_id: String, to_room_id: String, room_points: Dictionary) -> void:
	if not room_points.has(from_room_id) or not room_points.has(to_room_id):
		return

	var from_point: Vector2 = room_points[from_room_id]
	var to_point: Vector2 = room_points[to_room_id]
	var from_known := GameState.is_room_discovered(from_room_id) or from_room_id == GameState.current_room_id
	var to_known := GameState.is_room_discovered(to_room_id) or to_room_id == GameState.current_room_id
	var line_color := Color(0.18, 0.24, 0.3, 0.82)
	if from_known and to_known:
		line_color = Color(0.42, 0.82, 1.0, 0.82)
	elif from_known or to_known:
		line_color = Color(0.3, 0.54, 0.68, 0.74)

	var elbow := Vector2(to_point.x, from_point.y)
	_add_map_segment(from_point, elbow, line_color)
	_add_map_segment(elbow, to_point, line_color)


func _add_map_segment(start_point: Vector2, end_point: Vector2, color: Color) -> void:
	if start_point == end_point:
		return

	var segment := ColorRect.new()
	segment.mouse_filter = Control.MOUSE_FILTER_IGNORE
	segment.color = color
	if is_equal_approx(start_point.x, end_point.x):
		segment.position = Vector2(start_point.x - 2.0, min(start_point.y, end_point.y))
		segment.size = Vector2(4.0, absf(end_point.y - start_point.y))
	else:
		segment.position = Vector2(min(start_point.x, end_point.x), start_point.y - 2.0)
		segment.size = Vector2(absf(end_point.x - start_point.x), 4.0)
	map_canvas.add_child(segment)


func _add_map_room_marker(room_id: String, point: Vector2) -> void:
	var marker := Panel.new()
	marker.mouse_filter = Control.MOUSE_FILTER_IGNORE
	marker.custom_minimum_size = MAP_MARKER_SIZE
	marker.position = point - MAP_MARKER_SIZE * 0.5
	var is_current := room_id == GameState.current_room_id
	var is_discovered := GameState.is_room_discovered(room_id) or is_current
	marker.add_theme_stylebox_override("panel", _make_map_marker_style(room_id, is_current, is_discovered))

	var label := Label.new()
	label.mouse_filter = Control.MOUSE_FILTER_IGNORE
	label.text = _get_map_marker_text(room_id)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	label.add_theme_font_size_override("font_size", 9 if room_id.ends_with("_rift") else 10)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1) if is_discovered else Color(0.6, 0.68, 0.74, 0.86))
	marker.add_child(label)

	map_canvas.add_child(marker)


func _make_map_marker_style(room_id: String, is_current: bool, is_discovered: bool) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.corner_radius_top_left = 10
	style.corner_radius_top_right = 10
	style.corner_radius_bottom_left = 10
	style.corner_radius_bottom_right = 10
	style.border_width_left = 2 if is_current else 1
	style.border_width_top = 2 if is_current else 1
	style.border_width_right = 2 if is_current else 1
	style.border_width_bottom = 2 if is_current else 1
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.2)
	style.shadow_size = 4

	if is_current:
		style.bg_color = Color(0.92, 0.66, 0.22, 1.0)
		style.border_color = Color(1.0, 0.95, 0.78, 1.0)
		return style

	if not is_discovered:
		style.bg_color = Color(0.1, 0.13, 0.17, 0.96)
		style.border_color = Color(0.26, 0.3, 0.36, 0.72)
		return style

	style.bg_color = _get_map_accent_color(room_id)
	style.border_color = Color(0.94, 0.97, 1.0, 0.86)
	return style


func _get_map_accent_color(room_id: String) -> Color:
	if room_id == "home_clearing":
		return Color(0.88, 0.54, 0.22, 0.98)
	if room_id == "forge_hall" or room_id == "arcane_vault":
		return Color(0.94, 0.58, 0.24, 0.98)
	if room_id.ends_with("_rift"):
		return Color(0.68, 0.42, 1.0, 0.98)

	var level_number := GameState.get_level_number(room_id)
	if level_number <= 5:
		return Color(0.32, 0.72, 0.44, 0.98)
	if level_number <= 10:
		return Color(0.28, 0.62, 0.88, 0.98)
	return Color(0.86, 0.4, 0.34, 0.98)


func _get_map_marker_text(room_id: String) -> String:
	match room_id:
		"home_clearing":
			return "H"
		"forge_hall":
			return "F"
		"arcane_vault":
			return "V"
		"echo_rift", "ashen_rift":
			return "R"
		_:
			var level_number := GameState.get_level_number(room_id)
			return str(level_number) if level_number > 0 else "?"


func _make_weapon_slot_style(is_equipped: bool, slot_data: Dictionary) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	var background: Color = slot_data.get("background", Color(0.16, 0.18, 0.22, 0.95))
	var accent: Color = slot_data.get("accent", Color(0.72, 0.82, 0.9, 1.0))
	style.bg_color = background.lightened(0.12) if is_equipped else background
	style.corner_radius_top_left = 12
	style.corner_radius_top_right = 12
	style.corner_radius_bottom_left = 12
	style.corner_radius_bottom_right = 12
	style.border_width_left = 2 if is_equipped else 1
	style.border_width_top = 2 if is_equipped else 1
	style.border_width_right = 2 if is_equipped else 1
	style.border_width_bottom = 2 if is_equipped else 1
	style.border_color = accent if is_equipped else Color(accent.r, accent.g, accent.b, 0.36)
	style.shadow_color = Color(0.0, 0.0, 0.0, 0.18)
	style.shadow_size = 4
	return style


func _get_backpack_item_ids() -> Array[String]:
	var item_ids: Array[String] = []
	for item_id in GameState.inventory.keys():
		var item_id_string := str(item_id)
		if not GameState.is_backpack_item(item_id_string):
			continue
		item_ids.append(item_id_string)
	item_ids.sort_custom(Callable(self, "_sort_backpack_items"))
	return item_ids


func _sort_backpack_items(a: String, b: String) -> bool:
	var category_a := GameState.get_item_category_label(a)
	var category_b := GameState.get_item_category_label(b)
	if category_a == category_b:
		var name_a := str(GameState.get_item_def(a).get("display_name", a))
		var name_b := str(GameState.get_item_def(b).get("display_name", b))
		return name_a.naturalnocasecmp_to(name_b) < 0
	return category_a.naturalnocasecmp_to(category_b) < 0


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
		return "Tier: Beginner."
	if level_number <= 10:
		return "Tier: Mid."
	return "Tier: Hard."



