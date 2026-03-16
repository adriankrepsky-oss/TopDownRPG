extends Node

# ─── LEADERBOARD ─────────────────────────────────────────
# Works fully offline. When a server URL is configured,
# also syncs with the online leaderboard.

const SERVER_URL := ""  # Set to your server URL to enable online mode (e.g. "https://myserver.com/api")
const IDENTITY_PATH := "user://online_identity.json"

var player_id: String = ""
var player_name: String = ""
var cached_leaderboard: Array = []
var is_fetching: bool = false
var last_fetch_time: int = 0
const FETCH_COOLDOWN_MS := 5000

signal leaderboard_fetched


func _ready() -> void:
	_load_identity()
	if player_id == "":
		player_id = _generate_id()
		player_name = "Player"
		_save_identity()


func _is_online_enabled() -> bool:
	return SERVER_URL != "" and not SERVER_URL.begins_with("https://your-server")


# ─── IDENTITY ────────────────────────────────────────────

func _generate_id() -> String:
	var chars := "abcdefghijklmnopqrstuvwxyz0123456789"
	var result := ""
	for i in range(20):
		result += chars[randi() % chars.length()]
	return result


func _load_identity() -> void:
	if not FileAccess.file_exists(IDENTITY_PATH):
		return
	var f := FileAccess.open(IDENTITY_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		player_id = str(parsed.get("player_id", ""))
		player_name = str(parsed.get("player_name", ""))


func _save_identity() -> void:
	var f := FileAccess.open(IDENTITY_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"player_id": player_id,
			"player_name": player_name,
		}))


func set_player_name(new_name: String) -> void:
	player_name = new_name.strip_edges().substr(0, 16)
	if player_name == "":
		player_name = "Player"
	_save_identity()


# ─── SUBMIT SCORE ────────────────────────────────────────

func submit_score() -> void:
	if not _is_online_enabled():
		return

	var weapon_trophies: Dictionary = {}
	for wid in GameState.fighter_weapon_trophies:
		weapon_trophies[wid] = GameState.fighter_weapon_trophies[wid]

	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_submit_complete.bind(http))

	var payload := JSON.stringify({
		"player_id": player_id,
		"player_name": player_name,
		"total_trophies": GameState.get_total_trophies(),
		"weapon_trophies": weapon_trophies,
		"body_skin": GameState.fighter_body_skin,
	})
	var headers := ["Content-Type: application/json"]
	var err := http.request(SERVER_URL + "/submit", headers, HTTPClient.METHOD_POST, payload)
	if err != OK:
		http.queue_free()


func _on_submit_complete(_result: int, _code: int, _headers: PackedStringArray, _body: PackedByteArray, http: HTTPRequest) -> void:
	http.queue_free()


# ─── FETCH LEADERBOARD ───────────────────────────────────

func fetch_leaderboard(weapon_filter: String = "") -> void:
	# If no server configured, just build local immediately
	if not _is_online_enabled():
		_build_local_leaderboard(weapon_filter)
		leaderboard_fetched.emit()
		return

	var now := Time.get_ticks_msec()
	if is_fetching or (now - last_fetch_time < FETCH_COOLDOWN_MS):
		leaderboard_fetched.emit()
		return

	is_fetching = true
	last_fetch_time = now

	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_fetch_complete.bind(http, weapon_filter))

	var url := SERVER_URL + "/leaderboard"
	if weapon_filter != "":
		url += "?weapon=" + weapon_filter.uri_encode()
	var err := http.request(url)
	if err != OK:
		is_fetching = false
		http.queue_free()
		_build_local_leaderboard(weapon_filter)
		leaderboard_fetched.emit()


func _on_fetch_complete(result: int, code: int, _headers: PackedStringArray, body: PackedByteArray, http: HTTPRequest, weapon_filter: String) -> void:
	is_fetching = false
	http.queue_free()

	if result == HTTPRequest.RESULT_SUCCESS and code == 200:
		var parsed: Variant = JSON.parse_string(body.get_string_from_utf8())
		if typeof(parsed) == TYPE_ARRAY:
			cached_leaderboard = []
			var rank := 1
			for entry in parsed:
				if typeof(entry) == TYPE_DICTIONARY:
					var is_me: bool = str(entry.get("player_id", "")) == player_id
					cached_leaderboard.append({
						"rank": rank,
						"name": str(entry.get("player_name", "???")),
						"trophies": int(entry.get("trophies", 0)),
						"body_skin": str(entry.get("body_skin", "default")),
						"is_player": is_me,
					})
					rank += 1
			leaderboard_fetched.emit()
			return

	_build_local_leaderboard(weapon_filter)
	leaderboard_fetched.emit()


func _build_local_leaderboard(weapon_filter: String) -> void:
	var trophies: int = 0
	if weapon_filter == "":
		trophies = GameState.get_total_trophies()
	else:
		trophies = GameState.get_weapon_trophies(weapon_filter)
	cached_leaderboard = [{
		"rank": 1,
		"name": GameState.profile_name,
		"trophies": trophies,
		"body_skin": GameState.fighter_body_skin,
		"is_player": true,
	}]


func get_player_rank() -> int:
	for entry in cached_leaderboard:
		if entry.get("is_player", false):
			return entry.get("rank", 0)
	return 0
