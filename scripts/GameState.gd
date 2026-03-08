extends Node

signal room_change_requested(room_id: String, spawn_id: String)
signal state_changed

const SAVE_PATH := "user://save_1.json"
const DEFAULT_ROOM_ID := "home_clearing"
const DEFAULT_SPAWN_ID := "spawn_home"
const GUN_ROOM_ID := "forest_path"
const SHOP_ROOM_ID := "market_crossroads"
const FINAL_ROOM_ID := "sky_keep"
const EXPECTED_MAIN_ROUTE_LENGTH := 15
const EASY_ROUTE_POOL := ["echo_cave", "sunstone_ruins", "bloom_marsh"]
const MID_ROUTE_POOL := ["ember_fields", "iron_docks", "verdant_garden", "dune_courtyard", "ashen_keep"]
const HARD_ROUTE_POOL := ["storm_sanctum", "obsidian_hall", "frost_labyrinth", "void_bastion"]
const LEVEL_DIFFICULTY_BY_SLOT := {
	1: 1.0,
	2: 1.04,
	3: 1.08,
	4: 1.14,
	5: 1.22,
	6: 1.34,
	7: 1.42,
	8: 1.5,
	9: 1.58,
	10: 1.66,
	11: 1.82,
	12: 1.94,
	13: 2.08,
	14: 2.22,
	15: 2.38,
}
const WEAPON_ITEM_IDS := ["slime_blaster", "iron_repeater", "sun_lance", "arc_blaster"]
const WEAPON_PRIORITY := ["arc_blaster", "sun_lance", "iron_repeater", "slime_blaster"]
const ROOM_SCENES := {
	"home_clearing": "res://scenes/World.tscn",
	"forest_path": "res://scenes/ForestPath.tscn",
	"market_crossroads": "res://scenes/MarketCrossroads.tscn",
	"echo_cave": "res://scenes/EchoCave.tscn",
	"sunstone_ruins": "res://scenes/SunstoneRuins.tscn",
	"ember_fields": "res://scenes/EmberFields.tscn",
	"bloom_marsh": "res://scenes/BloomMarsh.tscn",
	"iron_docks": "res://scenes/IronDocks.tscn",
	"verdant_garden": "res://scenes/VerdantGarden.tscn",
	"dune_courtyard": "res://scenes/DuneCourtyard.tscn",
	"ashen_keep": "res://scenes/AshenKeep.tscn",
	"storm_sanctum": "res://scenes/StormSanctum.tscn",
	"obsidian_hall": "res://scenes/ObsidianHall.tscn",
	"frost_labyrinth": "res://scenes/FrostLabyrinth.tscn",
	"void_bastion": "res://scenes/VoidBastion.tscn",
	"sky_keep": "res://scenes/SkyKeep.tscn",
	"forge_hall": "res://scenes/ForgeHall.tscn",
	"arcane_vault": "res://scenes/ArcaneVault.tscn",
}
const ROOM_TITLES := {
	"home_clearing": "Lantern City",
	"forest_path": "Lakeside Quarter",
	"market_crossroads": "Crossroads Bazaar",
	"echo_cave": "Echo Cave",
	"sunstone_ruins": "Sunstone Ruins",
	"ember_fields": "Ember Fields",
	"bloom_marsh": "Bloom Marsh",
	"iron_docks": "Iron Docks",
	"verdant_garden": "Verdant Garden",
	"dune_courtyard": "Dune Courtyard",
	"ashen_keep": "Ashen Keep",
	"storm_sanctum": "Storm Sanctum",
	"obsidian_hall": "Obsidian Hall",
	"frost_labyrinth": "Frost Labyrinth",
	"void_bastion": "Void Bastion",
	"sky_keep": "Sky Keep",
	"forge_hall": "Forge Hall",
	"arcane_vault": "Arcane Vault",
}
const ITEM_DEFS := {
	"berry": {
		"display_name": "Berry",
		"description": "A sweet berry that restores 1 HP.",
		"kind": "consumable",
		"usable": true,
	},
	"forest_token": {
		"display_name": "Forest Token",
		"description": "A keepsake from the forest ranger.",
		"kind": "key_item",
		"usable": false,
	},
	"slime_blaster": {
		"display_name": "Slime Blaster",
		"description": "A basic pistol dropped by slimes.",
		"kind": "weapon",
		"usable": false,
	},
	"iron_repeater": {
		"display_name": "Iron Repeater",
		"description": "A shop gun with faster shots and steadier aim.",
		"kind": "weapon",
		"usable": false,
	},
	"sun_lance": {
		"display_name": "Sun Lance",
		"description": "A twin-shot relic pistol sold at the bazaar.",
		"kind": "weapon",
		"usable": false,
	},
	"arc_blaster": {
		"display_name": "Arc Blaster",
		"description": "A forged upgrade that fires a faster, wider burst of arc rounds.",
		"kind": "weapon",
		"usable": false,
	},
}
const POWER_DEFS := {
	"blink_dash": {
		"display_name": "Blink Dash",
		"tutorial": [
			"Step 1: Aim your escape path with the mouse.",
			"Step 2: Press Right Click or Shift to blink forward.",
			"Step 3: Use it to cut through bullet spreads or close the gap."
		],
	},
	"shock_ring": {
		"display_name": "Shock Ring",
		"tutorial": [
			"Step 1: Let enemies crowd around you.",
			"Step 2: Press Q to fire a shock ring.",
			"Step 3: The ring hits nearby enemies and creates space."
		],
	},
	"trail_haste": {
		"display_name": "Trail Haste",
		"tutorial": [
			"Step 1: This power is always active after the boss falls.",
			"Step 2: Your movement speed increases in every room.",
			"Step 3: Use the extra speed to kite enemies and reach portals faster."
		],
	},
	"guardian_heart": {
		"display_name": "Guardian Heart",
		"tutorial": [
			"Step 1: This power is always active once you earn it.",
			"Step 2: Your maximum health rises by 1 instantly.",
			"Step 3: Play more aggressively now that you can survive one more hit."
		],
	},
	"overdrive": {
		"display_name": "Overdrive",
		"tutorial": [
			"Step 1: Keep your gun trained on the target.",
			"Step 2: Your shots now travel faster and cooldowns recover quicker.",
			"Step 3: Use the extra tempo to finish late-game fights before they snowball."
		],
	},
}

var current_room_id: String = DEFAULT_ROOM_ID
var current_spawn_id: String = DEFAULT_SPAWN_ID
var player_hp: int = 3
var player_max_hp: int = 3
var inventory: Dictionary = {}
var flags: Dictionary = {}
var coins: int = 0
var powers: Array[String] = []
var main_route: Array[String] = []


func _ready() -> void:
	setup_input_actions()
	load_game()


func setup_input_actions() -> void:
	_ensure_key_action("ui_left", KEY_A)
	_ensure_key_action("ui_right", KEY_D)
	_ensure_key_action("ui_up", KEY_W)
	_ensure_key_action("ui_down", KEY_S)
	_ensure_key_action("interact", KEY_E)
	_ensure_joypad_action("interact", JOY_BUTTON_A)
	_ensure_key_action("attack", KEY_SPACE)
	_ensure_joypad_action("attack", JOY_BUTTON_X)
	_ensure_mouse_action("shoot", MOUSE_BUTTON_LEFT)
	_ensure_mouse_action("ability", MOUSE_BUTTON_RIGHT)
	_ensure_key_action("ability", KEY_SHIFT)
	_ensure_key_action("power_secondary", KEY_Q)
	_ensure_key_action("inventory", KEY_I)
	_ensure_joypad_action("inventory", JOY_BUTTON_Y)


func reset_defaults() -> void:
	current_room_id = DEFAULT_ROOM_ID
	current_spawn_id = DEFAULT_SPAWN_ID
	player_max_hp = 3
	player_hp = player_max_hp
	inventory = {}
	flags = {}
	coins = 0
	powers = []
	_generate_main_route()


func reset_run_after_death() -> void:
	reset_defaults()
	save_game()
	state_changed.emit()


func load_game() -> void:
	reset_defaults()

	if not FileAccess.file_exists(SAVE_PATH):
		state_changed.emit()
		return

	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if save_file == null:
		push_warning("Unable to open save file at %s." % SAVE_PATH)
		state_changed.emit()
		return

	var parsed: Variant = JSON.parse_string(save_file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		push_warning("Save data was not a dictionary. Starting fresh.")
		state_changed.emit()
		return

	current_room_id = str(parsed.get("current_room_id", DEFAULT_ROOM_ID))
	current_spawn_id = str(parsed.get("current_spawn_id", DEFAULT_SPAWN_ID))
	player_max_hp = int(parsed.get("player_max_hp", 3))
	player_hp = clampi(int(parsed.get("player_hp", player_max_hp)), 0, player_max_hp)
	inventory = parsed.get("inventory", {}).duplicate(true)
	flags = parsed.get("flags", {}).duplicate(true)
	coins = maxi(int(parsed.get("coins", 0)), 0)
	powers = _ensure_string_array(parsed.get("powers", []))
	main_route = _ensure_string_array(parsed.get("main_route", []))
	if not _is_valid_main_route(main_route):
		_generate_main_route()
	state_changed.emit()


func save_game() -> void:
	var save_file: FileAccess = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if save_file == null:
		push_warning("Unable to write save file at %s." % SAVE_PATH)
		return

	var data: Dictionary = {
		"current_room_id": current_room_id,
		"current_spawn_id": current_spawn_id,
		"player_hp": player_hp,
		"player_max_hp": player_max_hp,
		"inventory": inventory,
		"flags": flags,
		"coins": coins,
		"powers": powers,
		"main_route": main_route,
	}
	save_file.store_string(JSON.stringify(data))


func change_room(room_id: String, spawn_id: String) -> void:
	current_room_id = room_id
	current_spawn_id = spawn_id
	save_game()
	state_changed.emit()
	room_change_requested.emit(room_id, spawn_id)


func add_item(item_id: String, amount: int = 1) -> void:
	if amount <= 0:
		return

	var current_amount: int = get_item_count(item_id)
	inventory[item_id] = current_amount + amount
	save_game()
	state_changed.emit()


func consume_item(item_id: String) -> bool:
	if not ITEM_DEFS.has(item_id):
		return false
	if not bool(ITEM_DEFS[item_id].get("usable", false)):
		return false
	if get_item_count(item_id) <= 0:
		return false

	var next_amount: int = get_item_count(item_id) - 1
	if next_amount <= 0:
		inventory.erase(item_id)
	else:
		inventory[item_id] = next_amount

	save_game()
	state_changed.emit()
	return true


func add_coins(amount: int = 1) -> void:
	if amount <= 0:
		return
	coins += amount
	save_game()
	state_changed.emit()


func spend_coins(amount: int) -> bool:
	if amount <= 0:
		return true
	if coins < amount:
		return false
	coins -= amount
	save_game()
	state_changed.emit()
	return true


func unlock_power(power_id: String) -> bool:
	if power_id.is_empty() or powers.has(power_id):
		return false

	powers.append(power_id)
	if power_id == "guardian_heart":
		player_max_hp += 1
		player_hp = player_max_hp

	save_game()
	state_changed.emit()
	return true


func has_power(power_id: String) -> bool:
	return powers.has(power_id)


func get_power_name(power_id: String) -> String:
	return str(POWER_DEFS.get(power_id, {}).get("display_name", power_id))


func get_power_tutorial(power_id: String) -> PackedStringArray:
	return PackedStringArray(POWER_DEFS.get(power_id, {}).get("tutorial", []))


func set_flag(flag_name: String, value: bool = true, should_save: bool = true) -> void:
	if flag_name.is_empty():
		return

	flags[flag_name] = value
	if should_save:
		save_game()
	state_changed.emit()


func get_flag(flag_name: String) -> bool:
	return bool(flags.get(flag_name, false))


func get_item_count(item_id: String) -> int:
	return int(inventory.get(item_id, 0))


func get_best_gun_id() -> String:
	for item_id in WEAPON_PRIORITY:
		if get_item_count(item_id) > 0:
			return item_id
	return ""


func set_player_hp(value: int, should_save: bool = false) -> void:
	player_hp = clampi(value, 0, player_max_hp)
	if should_save:
		save_game()
	state_changed.emit()


func heal_player(amount: int) -> bool:
	if amount <= 0:
		return false
	if player_hp >= player_max_hp:
		return false

	set_player_hp(player_hp + amount, true)
	return true


func get_room_scene_path(room_id: String) -> String:
	return str(ROOM_SCENES.get(room_id, ROOM_SCENES[DEFAULT_ROOM_ID]))


func get_room_title(room_id: String) -> String:
	return str(ROOM_TITLES.get(room_id, room_id.capitalize()))


func get_item_def(item_id: String) -> Dictionary:
	return ITEM_DEFS.get(item_id, {})


func get_main_route() -> Array[String]:
	if not _is_valid_main_route(main_route):
		_generate_main_route()
	return main_route.duplicate()


func get_level_number(room_id: String) -> int:
	var index := main_route.find(room_id)
	return index + 1 if index >= 0 else 0


func get_room_difficulty_multiplier(room_id: String) -> float:
	var level_number := get_level_number(room_id)
	if level_number <= 0:
		return 1.0
	return float(LEVEL_DIFFICULTY_BY_SLOT.get(level_number, 1.0))


func get_next_main_room(room_id: String) -> String:
	if room_id == DEFAULT_ROOM_ID:
		return main_route[0] if not main_route.is_empty() else ""

	var index := main_route.find(room_id)
	if index == -1 or index >= main_route.size() - 1:
		return ""
	return main_route[index + 1]


func get_previous_main_room(room_id: String) -> String:
	var index := main_route.find(room_id)
	if index == -1:
		return ""
	if index == 0:
		return DEFAULT_ROOM_ID
	return main_route[index - 1]


func is_shop_level(room_id: String) -> bool:
	return room_id == SHOP_ROOM_ID


func is_final_level(room_id: String) -> bool:
	return room_id == FINAL_ROOM_ID


func _generate_main_route() -> void:
	var easy_rooms := _shuffle_rooms(EASY_ROUTE_POOL)
	var mid_rooms := _shuffle_rooms(MID_ROUTE_POOL)
	var hard_rooms := _shuffle_rooms(HARD_ROUTE_POOL)

	main_route.clear()
	main_route.append(GUN_ROOM_ID)
	for room_id in easy_rooms:
		main_route.append(room_id)
	main_route.append(SHOP_ROOM_ID)
	for room_id in mid_rooms:
		main_route.append(room_id)
	for room_id in hard_rooms:
		main_route.append(room_id)
	main_route.append(FINAL_ROOM_ID)


func _ensure_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		result.append(str(entry))
	return result


func _shuffle_rooms(room_ids: Array) -> Array[String]:
	var shuffled: Array[String] = []
	for room_id in room_ids:
		shuffled.append(str(room_id))
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	for index in range(shuffled.size() - 1, 0, -1):
		var swap_index := rng.randi_range(0, index)
		var temp: String = shuffled[index]
		shuffled[index] = shuffled[swap_index]
		shuffled[swap_index] = temp
	return shuffled


func _is_valid_main_route(route: Array[String]) -> bool:
	if route.size() != EXPECTED_MAIN_ROUTE_LENGTH:
		return false
	if route[0] != GUN_ROOM_ID:
		return false
	if route[4] != SHOP_ROOM_ID:
		return false
	if route[route.size() - 1] != FINAL_ROOM_ID:
		return false
	return true


func _ensure_key_action(action_name: String, keycode: Key) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var event: InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	if not InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)


func _ensure_joypad_action(action_name: String, button_index: JoyButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var event: InputEventJoypadButton = InputEventJoypadButton.new()
	event.button_index = button_index
	if not InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)


func _ensure_mouse_action(action_name: String, button_index: MouseButton) -> void:
	if not InputMap.has_action(action_name):
		InputMap.add_action(action_name)

	var event := InputEventMouseButton.new()
	event.button_index = button_index
	if not InputMap.action_has_event(action_name, event):
		InputMap.action_add_event(action_name, event)
