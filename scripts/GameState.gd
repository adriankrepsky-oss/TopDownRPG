extends Node

signal room_change_requested(room_id: String, spawn_id: String)
signal state_changed

# --- Fighter mode state ---
var fighter_weapon_id: String = "fists"
var fighter_game_mode: String = "normal"  # "normal" or "practice"
var fighter_weapon_trophies: Dictionary = {}  # weapon_id -> int (per-weapon trophies)
var fighter_unlocked_weapons: Array[String] = ["fists", "shadow_blade"]  # permanently unlocked weapons

# --- Fighter currencies ---
var fighter_coins: int = 0
var fighter_gems: int = 0
var fighter_power_ups: int = 0

# --- Skins ---
var fighter_char_skin: String = "default"
var fighter_weapon_skin: String = "default"
var fighter_owned_char_skins: Array[String] = ["default"]
var fighter_owned_weapon_skins: Array[String] = ["default"]

# --- Lose streak mercy ---
var fighter_lose_streak: int = 0  # consecutive losses, resets on win

# --- Weapon Levels & RAGE ---
var fighter_weapon_levels: Dictionary = {}  # weapon_id -> int (1-11)

# --- Key Bindings ---
var fighter_key_bindings: Dictionary = {}  # action -> keycode (int)

# --- Touch Control Settings ---
var touch_button_scale: float = 1.0  # 0.5 to 2.0
var touch_joystick_x: float = 120.0
var touch_joystick_y: float = 500.0
var touch_attack_x: float = 1050.0
var touch_attack_y: float = 460.0

# --- Body Skins (full character replacements) ---
var fighter_body_skin: String = "default"
var fighter_owned_body_skins: Array[String] = ["default"]
var fighter_show_hair: bool = false  # Whether to display spiky hair (default: bald)

# --- Battle Pass ---
var fighter_pass_purchased: bool = false
var fighter_pass_progress: int = 0  # 0-10, each win adds 1
var fighter_pass_free_claimed: Array[int] = []
var fighter_pass_paid_claimed: Array[int] = []

# --- Profile ---
var profile_name: String = "Player"
var profile_fav_skin: String = "default"  # favorite body skin to show on profile/leaderboard
var profile_fav_weapon: String = "fists"  # favorite weapon to display on profile

# --- Trophy Road ---
var fighter_trophy_road_claimed: Array[int] = []  # indices of claimed milestones

# --- Win Streak ---
var fighter_win_streak: int = 0  # consecutive wins (resets on loss)
var fighter_best_win_streak: int = 0  # all-time best streak

# --- Daily Challenges ---
var daily_challenges: Array = []  # [{id, desc, target, progress, reward_type, reward_amount, completed}]
var daily_challenge_date: String = ""  # "YYYY-MM-DD" of last generation
var daily_challenges_claimed: Array[int] = []  # indices of claimed challenge rewards

# --- First Win of the Day ---
var first_win_date: String = ""  # "YYYY-MM-DD" of last first-win bonus
var first_win_claimed: bool = false

# --- Login Streak ---
var login_streak: int = 0
var best_login_streak: int = 0
var last_login_date: String = ""  # "YYYY-MM-DD"
var login_reward_claimed_today: bool = false

# --- Seasons ---
var current_season: int = 1
var season_start_date: String = ""
var season_peak_trophies: int = 0
var season_rewards_claimed: bool = false

# --- Achievements ---
var unlocked_achievements: Array[String] = []  # list of achievement IDs

# --- Ranked Tiers ---
const RANK_TIERS := [
	{"name": "Bronze III",   "min": 0,     "color": Color(0.72, 0.45, 0.2)},
	{"name": "Bronze II",    "min": 500,   "color": Color(0.72, 0.45, 0.2)},
	{"name": "Bronze I",     "min": 1000,  "color": Color(0.72, 0.45, 0.2)},
	{"name": "Silver III",   "min": 2000,  "color": Color(0.7, 0.72, 0.75)},
	{"name": "Silver II",    "min": 3500,  "color": Color(0.7, 0.72, 0.75)},
	{"name": "Silver I",     "min": 5000,  "color": Color(0.7, 0.72, 0.75)},
	{"name": "Gold III",     "min": 7500,  "color": Color(1.0, 0.85, 0.2)},
	{"name": "Gold II",      "min": 10000, "color": Color(1.0, 0.85, 0.2)},
	{"name": "Gold I",       "min": 14000, "color": Color(1.0, 0.85, 0.2)},
	{"name": "Platinum III", "min": 18000, "color": Color(0.4, 0.85, 0.85)},
	{"name": "Platinum II",  "min": 22000, "color": Color(0.4, 0.85, 0.85)},
	{"name": "Platinum I",   "min": 26000, "color": Color(0.4, 0.85, 0.85)},
	{"name": "Diamond III",  "min": 32000, "color": Color(0.5, 0.7, 1.0)},
	{"name": "Diamond II",   "min": 38000, "color": Color(0.5, 0.7, 1.0)},
	{"name": "Diamond I",    "min": 45000, "color": Color(0.5, 0.7, 1.0)},
	{"name": "Legend",        "min": 50000, "color": Color(1.0, 0.5, 0.9)},
]

# Win streak bonus multipliers: streak 1=x1, 2=x1.2, 3=x1.5, 4=x1.8, 5+=x2.0
const STREAK_MULTIPLIERS := [1.0, 1.0, 1.2, 1.5, 1.8, 2.0]

# Daily challenge templates
const CHALLENGE_TEMPLATES := [
	{"id": "win_any", "desc": "Win %d matches", "targets": [3, 5], "reward_type": "coins", "reward_amount": 15},
	{"id": "win_streak", "desc": "Win %d in a row", "targets": [2, 3], "reward_type": "gems", "reward_amount": 10},
	{"id": "win_weapon", "desc": "Win with %s", "targets": [2, 3], "reward_type": "coins", "reward_amount": 20},
	{"id": "trophies", "desc": "Earn %d trophies", "targets": [30, 50], "reward_type": "gems", "reward_amount": 15},
	{"id": "kills", "desc": "Get %d kills", "targets": [10, 15], "reward_type": "power_ups", "reward_amount": 5},
	{"id": "win_2v2", "desc": "Win %d 2v2 matches", "targets": [2, 3], "reward_type": "coins", "reward_amount": 25},
]

# Login streak reward tiers: [required_days, reward_type, reward_amount, description]
const LOGIN_STREAK_REWARDS := [
	[1, "coins", 10, "Day 1: 10 Coins"],
	[2, "coins", 15, "Day 2: 15 Coins"],
	[3, "gems", 5, "Day 3: 5 Gems"],
	[5, "coins", 30, "Day 5: 30 Coins"],
	[7, "gems", 15, "Day 7: 15 Gems"],
	[14, "gems", 25, "Day 14: 25 Gems"],
	[30, "power_ups", 10, "Day 30: 10 Power-Ups"],
]

# Achievement definitions: {id, name, desc, condition_type, target, reward_type, reward_amount}
const ACHIEVEMENTS := [
	{"id": "first_blood", "name": "First Blood", "desc": "Win your first match", "type": "total_wins", "target": 1, "reward": "coins", "amount": 20},
	{"id": "warrior", "name": "Warrior", "desc": "Win 50 matches", "type": "total_wins", "target": 50, "reward": "gems", "amount": 25},
	{"id": "champion", "name": "Champion", "desc": "Win 200 matches", "type": "total_wins", "target": 200, "reward": "gems", "amount": 50},
	{"id": "streak_3", "name": "On Fire", "desc": "Get a 3-win streak", "type": "best_streak", "target": 3, "reward": "coins", "amount": 30},
	{"id": "streak_5", "name": "Unstoppable", "desc": "Get a 5-win streak", "type": "best_streak", "target": 5, "reward": "gems", "amount": 20},
	{"id": "streak_10", "name": "Legendary Streak", "desc": "Get a 10-win streak", "type": "best_streak", "target": 10, "reward": "gems", "amount": 50},
	{"id": "bronze", "name": "Bronze Fighter", "desc": "Reach Bronze I", "type": "rank", "target": 1000, "reward": "coins", "amount": 50},
	{"id": "silver", "name": "Silver Fighter", "desc": "Reach Silver III", "type": "rank", "target": 2000, "reward": "gems", "amount": 15},
	{"id": "gold", "name": "Gold Fighter", "desc": "Reach Gold III", "type": "rank", "target": 7500, "reward": "gems", "amount": 30},
	{"id": "platinum", "name": "Platinum Fighter", "desc": "Reach Platinum III", "type": "rank", "target": 18000, "reward": "gems", "amount": 50},
	{"id": "diamond", "name": "Diamond Fighter", "desc": "Reach Diamond III", "type": "rank", "target": 32000, "reward": "gems", "amount": 75},
	{"id": "legend", "name": "Legend", "desc": "Reach Legend rank", "type": "rank", "target": 50000, "reward": "gems", "amount": 100},
	{"id": "arsenal_5", "name": "Arsenal", "desc": "Unlock 5 weapons", "type": "weapons_owned", "target": 5, "reward": "coins", "amount": 40},
	{"id": "arsenal_10", "name": "Armory", "desc": "Unlock 10 weapons", "type": "weapons_owned", "target": 10, "reward": "gems", "amount": 30},
	{"id": "arsenal_all", "name": "Collector", "desc": "Unlock all weapons", "type": "weapons_owned", "target": 18, "reward": "gems", "amount": 75},
	{"id": "no_damage", "name": "Untouchable", "desc": "Win without taking damage", "type": "flawless_win", "target": 1, "reward": "gems", "amount": 20},
	{"id": "login_7", "name": "Dedicated", "desc": "Log in 7 days in a row", "type": "login_streak", "target": 7, "reward": "gems", "amount": 15},
	{"id": "login_30", "name": "Devoted", "desc": "Log in 30 days in a row", "type": "login_streak", "target": 30, "reward": "gems", "amount": 50},
	{"id": "style_master", "name": "Style Master", "desc": "Score 500 style points in one match", "type": "style_points", "target": 500, "reward": "gems", "amount": 20},
	{"id": "combo_king", "name": "Combo King", "desc": "Land an 8-hit combo", "type": "max_combo", "target": 8, "reward": "coins", "amount": 50},
]

# Season duration in days
const SEASON_DURATION_DAYS := 30

const FIGHTER_SAVE_PATH := "user://fighter_trophies.json"

# Coin costs to buy each weapon (0 = free / always unlocked)
const WEAPON_COSTS := {
	"fists": 0,
	"shadow_blade": 0,
	"kunai_stars": 25,
	"frost_staff": 50,
	"vine_whip": 75,
	"iron_buckler": 100,
	"dragon_gauntlets": 150,
	"spirit_bow": 175,
	"warp_dagger": 200,
	"thunder_claws": 225,
	"poison_fang": 250,
	"fire_greatsword": 275,
	"thors_hammer": 300,
	"blood_scythe": 325,
	"bomb_flail": 350,
	"gravity_orb": 375,
	"plasma_cannon": 400,
	"crystal_spear": 450,
}

const WEAPON_RARITIES := {
	"fists": "common",
	"kunai_stars": "common",
	"frost_staff": "rare",
	"vine_whip": "rare",
	"iron_buckler": "rare",
	"shadow_blade": "epic",
	"dragon_gauntlets": "epic",
	"spirit_bow": "epic",
	"warp_dagger": "epic",
	"thunder_claws": "epic",
	"poison_fang": "epic",
	"fire_greatsword": "epic",
	"thors_hammer": "legendary",
	"blood_scythe": "legendary",
	"bomb_flail": "legendary",
	"gravity_orb": "legendary",
	"plasma_cannon": "legendary",
	"crystal_spear": "legendary",
}

const RARITY_NAMES := {
	"common": "Common",
	"rare": "Rare",
	"epic": "Epic",
	"legendary": "Legendary",
}

const RARITY_COLORS := {
	"common": Color(0.6, 0.6, 0.6),
	"rare": Color(0.3, 0.55, 1.0),
	"epic": Color(0.7, 0.3, 0.9),
	"legendary": Color(1.0, 0.75, 0.15),
}

# Character skins — override scarf, coat, hair, eye iris, accent, emblem colors
const CHAR_SKINS := {
	"default": {
		"name": "Default", "cost": 0,
		"scarf": Color(0.85, 0.15, 0.2), "coat": Color(0.12, 0.12, 0.18),
		"hair": Color(0.12, 0.1, 0.26), "iris": Color(0.2, 0.4, 0.9),
		"accent": Color(0.5, 0.3, 0.8), "emblem": Color(0.5, 0.3, 0.85),
	},
	"crimson": {
		"name": "Crimson", "cost": 15,
		"scarf": Color(1.0, 0.3, 0.1), "coat": Color(0.25, 0.08, 0.08),
		"hair": Color(0.3, 0.08, 0.08), "iris": Color(0.9, 0.2, 0.15),
		"accent": Color(0.9, 0.3, 0.2), "emblem": Color(1.0, 0.4, 0.15),
	},
	"arctic": {
		"name": "Arctic", "cost": 20,
		"scarf": Color(0.5, 0.85, 1.0), "coat": Color(0.15, 0.18, 0.25),
		"hair": Color(0.7, 0.8, 0.9), "iris": Color(0.3, 0.7, 1.0),
		"accent": Color(0.4, 0.75, 1.0), "emblem": Color(0.3, 0.8, 1.0),
	},
	"shadow": {
		"name": "Shadow", "cost": 25,
		"scarf": Color(0.3, 0.1, 0.4), "coat": Color(0.06, 0.04, 0.1),
		"hair": Color(0.08, 0.05, 0.15), "iris": Color(0.6, 0.2, 0.9),
		"accent": Color(0.5, 0.15, 0.7), "emblem": Color(0.6, 0.2, 0.85),
	},
	"golden": {
		"name": "Golden", "cost": 40,
		"scarf": Color(1.0, 0.75, 0.15), "coat": Color(0.2, 0.16, 0.08),
		"hair": Color(0.35, 0.28, 0.1), "iris": Color(0.9, 0.7, 0.15),
		"accent": Color(1.0, 0.8, 0.2), "emblem": Color(1.0, 0.85, 0.3),
	},
	"toxic": {
		"name": "Toxic", "cost": 30,
		"scarf": Color(0.3, 0.9, 0.2), "coat": Color(0.08, 0.15, 0.08),
		"hair": Color(0.1, 0.2, 0.08), "iris": Color(0.3, 0.95, 0.2),
		"accent": Color(0.4, 0.9, 0.3), "emblem": Color(0.35, 1.0, 0.25),
	},
}

# Weapon skins — override weapon glow/accent colors (universal, any weapon)
const WEAPON_SKINS := {
	"default": {
		"name": "Default", "cost": 0,
		"glow": Color(0.4, 0.6, 1.0), "trail": Color(0.6, 0.8, 1.0),
	},
	"inferno": {
		"name": "Inferno", "cost": 15,
		"glow": Color(1.0, 0.4, 0.1), "trail": Color(1.0, 0.6, 0.2),
	},
	"venom": {
		"name": "Venom", "cost": 20,
		"glow": Color(0.3, 0.9, 0.2), "trail": Color(0.5, 1.0, 0.3),
	},
	"frost": {
		"name": "Frost", "cost": 20,
		"glow": Color(0.3, 0.8, 1.0), "trail": Color(0.6, 0.9, 1.0),
	},
	"void": {
		"name": "Void", "cost": 30,
		"glow": Color(0.5, 0.15, 0.8), "trail": Color(0.7, 0.3, 1.0),
	},
	"solar": {
		"name": "Solar", "cost": 40,
		"glow": Color(1.0, 0.85, 0.2), "trail": Color(1.0, 0.95, 0.5),
	},
}

const CHAR_SKIN_ORDER := ["default", "crimson", "arctic", "shadow", "golden", "toxic"]
const WEAPON_SKIN_ORDER := ["default", "inferno", "venom", "frost", "void", "solar"]

const PASS_COST := 100

# Infinite pass — rewards cycle every 3 tiers
const FREE_REWARD_CYCLE := [
	{"type": "coins", "amount": 5},
	{"type": "gems", "amount": 5},
	{"type": "power_ups", "amount": 5},
]
const PAID_REWARD_CYCLE := [
	{"type": "coins", "amount": 10},
	{"type": "gems", "amount": 10},
	{"type": "power_ups", "amount": 10},
]

# Weapon upgrade constants
const WEAPON_MAX_LEVEL := 10
const RAGE_LEVEL := 11
const WEAPON_UPGRADE_COSTS := [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]  # +10 per level
const RAGE_COIN_COST := 500
const WEAPON_DAMAGE_SCALE := 0.065   # ~6.5% per level
const WEAPON_KB_SCALE := 0.04        # ~4% per level
const WEAPON_SUPER_DMG_SCALE := 0.07 # ~7% per level
const WEAPON_SUPER_KB_SCALE := 0.05  # ~5% per level

# Key binding defaults & display names
const DEFAULT_KEY_BINDINGS := {
	"fighter_left": KEY_A,
	"fighter_right": KEY_D,
	"fighter_jump": KEY_SPACE,
	"fighter_down": KEY_S,
	"fighter_light": KEY_J,
	"fighter_heavy": KEY_K,
	"fighter_rage": KEY_E,
}
const KEY_BINDING_NAMES := {
	"fighter_left": "Move Left",
	"fighter_right": "Move Right",
	"fighter_jump": "Jump",
	"fighter_down": "Drop Down",
	"fighter_light": "Light Attack",
	"fighter_heavy": "Heavy Attack",
	"fighter_rage": "Rage",
}
const KEY_BINDING_ORDER := ["fighter_left", "fighter_right", "fighter_jump", "fighter_down", "fighter_light", "fighter_heavy", "fighter_rage"]

# Body skins (full character model replacements)
const BODY_SKINS := {
	"default": {"name": "Fighter", "cost": 0},
	"panda": {"name": "Panda", "cost": 50},
	"darth_bader": {"name": "Dark Lord", "cost": 80},
	"ninja": {"name": "Shadow Ninja", "cost": 60},
	"robot": {"name": "Mech Unit", "cost": 70},
	"cat": {"name": "Street Cat", "cost": 0},
	"shark": {"name": "Shark", "cost": 0},
	"frog": {"name": "Battle Frog", "cost": 0},
	"pikachu": {"name": "Electric Mouse", "cost": 0},
	"goku": {"name": "Super Saiyan", "cost": 0},
	"joker": {"name": "Mad Clown", "cost": 0},
	"hulk": {"name": "Green Giant", "cost": 0},
	"spiderman": {"name": "Web Warrior", "cost": 0},
	"batman": {"name": "Dark Knight", "cost": 0},
	"iron_man": {"name": "Iron Hero", "cost": 0},
	"god": {"name": "God", "cost": 0},
}
const BODY_SKIN_ORDER := ["default", "panda", "darth_bader", "ninja", "robot", "cat", "shark", "frog", "pikachu", "goku", "joker", "hulk", "spiderman", "batman", "iron_man", "god"]

const REWARD_ICONS := {"coins": "C", "gems": "G", "power_ups": "P"}
const REWARD_COLORS := {
	"coins": Color(1.0, 0.85, 0.2),
	"gems": Color(0.2, 0.75, 1.0),
	"power_ups": Color(1.0, 0.6, 0.1),
}

# Trophy Road milestones — earn rewards by reaching total trophy thresholds
const TROPHY_ROAD := [
	# --- Early game (10-300) ---
	{"trophies": 10, "rewards": [{"type": "coins", "amount": 10}]},
	{"trophies": 25, "rewards": [{"type": "coins", "amount": 15}]},
	{"trophies": 50, "rewards": [{"type": "weapon", "id": "kunai_stars"}]},
	{"trophies": 75, "rewards": [{"type": "char_skin", "id": "crimson"}]},
	{"trophies": 100, "rewards": [{"type": "coins", "amount": 25}, {"type": "gems", "amount": 10}]},
	{"trophies": 150, "rewards": [{"type": "weapon", "id": "frost_staff"}]},
	{"trophies": 200, "rewards": [{"type": "weapon_skin", "id": "inferno"}]},
	{"trophies": 250, "rewards": [{"type": "weapon", "id": "iron_buckler"}]},
	{"trophies": 300, "rewards": [{"type": "body_skin", "id": "panda"}]},
	# --- Mid game (400-1500) ---
	{"trophies": 400, "rewards": [{"type": "coins", "amount": 50}, {"type": "gems", "amount": 20}]},
	{"trophies": 500, "rewards": [{"type": "weapon", "id": "spirit_bow"}]},
	{"trophies": 600, "rewards": [{"type": "weapon_skin", "id": "venom"}]},
	{"trophies": 700, "rewards": [{"type": "char_skin", "id": "shadow"}]},
	{"trophies": 800, "rewards": [{"type": "weapon", "id": "thunder_claws"}]},
	{"trophies": 1000, "rewards": [{"type": "body_skin", "id": "ninja"}]},
	{"trophies": 1200, "rewards": [{"type": "weapon", "id": "fire_greatsword"}]},
	{"trophies": 1500, "rewards": [{"type": "weapon_skin", "id": "void"}, {"type": "char_skin", "id": "golden"}]},
	# --- Late game (2000-6000) ---
	{"trophies": 2000, "rewards": [{"type": "weapon", "id": "gravity_orb"}]},
	{"trophies": 2500, "rewards": [{"type": "body_skin", "id": "robot"}]},
	{"trophies": 3000, "rewards": [{"type": "weapon", "id": "crystal_spear"}, {"type": "weapon_skin", "id": "solar"}]},
	{"trophies": 3500, "rewards": [{"type": "char_skin", "id": "toxic"}, {"type": "char_skin", "id": "arctic"}]},
	{"trophies": 4000, "rewards": [{"type": "body_skin", "id": "darth_bader"}]},
	{"trophies": 4500, "rewards": [{"type": "coins", "amount": 200}, {"type": "gems", "amount": 100}]},
	{"trophies": 5000, "rewards": [{"type": "weapon_skin", "id": "frost"}, {"type": "power_ups", "amount": 50}]},
	{"trophies": 6000, "rewards": [{"type": "coins", "amount": 500}, {"type": "gems", "amount": 200}, {"type": "power_ups", "amount": 100}]},
	# --- Endgame (7000-50000) ---
	{"trophies": 7000, "rewards": [{"type": "char_skin", "id": "phantom"}, {"type": "coins", "amount": 100}]},
	{"trophies": 8000, "rewards": [{"type": "weapon_skin", "id": "obsidian"}, {"type": "gems", "amount": 50}]},
	{"trophies": 9000, "rewards": [{"type": "body_skin", "id": "cat"}]},
	{"trophies": 10000, "rewards": [{"type": "weapon_skin", "id": "legendary_gold"}, {"type": "coins", "amount": 300}, {"type": "gems", "amount": 150}]},
	{"trophies": 12000, "rewards": [{"type": "char_skin", "id": "cyber"}, {"type": "power_ups", "amount": 75}]},
	{"trophies": 14000, "rewards": [{"type": "body_skin", "id": "shark"}, {"type": "weapon_skin", "id": "plasma"}]},
	{"trophies": 16000, "rewards": [{"type": "coins", "amount": 600}, {"type": "gems", "amount": 300}]},
	{"trophies": 18000, "rewards": [{"type": "char_skin", "id": "galaxy"}, {"type": "char_skin", "id": "neon"}]},
	{"trophies": 20000, "rewards": [{"type": "body_skin", "id": "frog"}, {"type": "weapon_skin", "id": "diamond"}, {"type": "coins", "amount": 500}]},
	{"trophies": 23000, "rewards": [{"type": "weapon_skin", "id": "chromatic"}, {"type": "gems", "amount": 200}]},
	{"trophies": 24000, "rewards": [{"type": "body_skin", "id": "pikachu"}]},
	{"trophies": 26000, "rewards": [{"type": "body_skin", "id": "goku"}, {"type": "power_ups", "amount": 150}]},
	{"trophies": 28000, "rewards": [{"type": "body_skin", "id": "joker"}]},
	{"trophies": 30000, "rewards": [{"type": "char_skin", "id": "void_walker"}, {"type": "weapon_skin", "id": "supernova"}, {"type": "coins", "amount": 800}]},
	{"trophies": 32000, "rewards": [{"type": "body_skin", "id": "hulk"}]},
	{"trophies": 35000, "rewards": [{"type": "body_skin", "id": "spiderman"}, {"type": "gems", "amount": 500}]},
	{"trophies": 38000, "rewards": [{"type": "body_skin", "id": "batman"}]},
	{"trophies": 40000, "rewards": [{"type": "char_skin", "id": "glitch"}, {"type": "weapon_skin", "id": "prismatic"}, {"type": "power_ups", "amount": 200}]},
	{"trophies": 45000, "rewards": [{"type": "body_skin", "id": "iron_man"}, {"type": "coins", "amount": 1000}, {"type": "gems", "amount": 500}]},
	{"trophies": 50000, "rewards": [{"type": "body_skin", "id": "god"}, {"type": "weapon_skin", "id": "eternal"}, {"type": "char_skin", "id": "transcendent"}, {"type": "coins", "amount": 2000}, {"type": "gems", "amount": 1000}, {"type": "power_ups", "amount": 500}]},
]

const TROPHY_ROAD_REWARD_NAMES := {
	"coins": "Coins", "gems": "Gems", "power_ups": "Power Ups",
	"weapon": "Weapon", "char_skin": "Skin", "weapon_skin": "W.Skin", "body_skin": "Body",
}


# ─── Trophy functions ─────────────────────────────────

func get_weapon_trophies(weapon_id: String) -> int:
	return maxi(int(fighter_weapon_trophies.get(weapon_id, 0)), 0)


func add_weapon_trophies(weapon_id: String, amount: int) -> void:
	var current := get_weapon_trophies(weapon_id)
	fighter_weapon_trophies[weapon_id] = maxi(current + amount, 0)
	check_weapon_unlocks()
	# Submit updated score to online leaderboard
	if Engine.has_singleton("OnlineLeaderboard") or has_node("/root/OnlineLeaderboard"):
		OnlineLeaderboard.submit_score()


func get_total_trophies() -> int:
	var total := 0
	for wid in fighter_weapon_trophies:
		total += maxi(int(fighter_weapon_trophies[wid]), 0)
	return total


func is_weapon_unlocked(weapon_id: String) -> bool:
	return weapon_id in fighter_unlocked_weapons


func get_weapon_cost(weapon_id: String) -> int:
	return int(WEAPON_COSTS.get(weapon_id, 9999))


func check_weapon_unlocks() -> void:
	# Ensure free weapons are always unlocked
	if "fists" not in fighter_unlocked_weapons:
		fighter_unlocked_weapons.append("fists")
	if "shadow_blade" not in fighter_unlocked_weapons:
		fighter_unlocked_weapons.append("shadow_blade")


func buy_fighter_weapon(weapon_id: String) -> bool:
	if is_weapon_unlocked(weapon_id):
		return false
	var cost: int = int(WEAPON_COSTS.get(weapon_id, 9999))
	if cost > 0 and fighter_coins < cost:
		return false
	if cost > 0:
		fighter_coins -= cost
	fighter_unlocked_weapons.append(weapon_id)
	save_fighter_trophies()
	return true


func get_weapon_rarity(weapon_id: String) -> String:
	return str(WEAPON_RARITIES.get(weapon_id, "common"))


func get_rarity_name(weapon_id: String) -> String:
	var rarity := get_weapon_rarity(weapon_id)
	return str(RARITY_NAMES.get(rarity, rarity.capitalize()))


func get_rarity_color(weapon_id: String) -> Color:
	var rarity := get_weapon_rarity(weapon_id)
	var col: Color = RARITY_COLORS.get(rarity, Color(0.6, 0.6, 0.6))
	return col


# ─── Skin functions ──────────────────────────────────

func owns_char_skin(skin_id: String) -> bool:
	return skin_id in fighter_owned_char_skins


func owns_weapon_skin(skin_id: String) -> bool:
	return skin_id in fighter_owned_weapon_skins


func buy_char_skin(skin_id: String) -> bool:
	if owns_char_skin(skin_id):
		return false
	var skin_data: Dictionary = CHAR_SKINS.get(skin_id, {})
	var cost: int = int(skin_data.get("cost", 9999))
	if fighter_gems < cost:
		return false
	fighter_gems -= cost
	fighter_owned_char_skins.append(skin_id)
	save_fighter_trophies()
	return true


func buy_weapon_skin(skin_id: String) -> bool:
	if owns_weapon_skin(skin_id):
		return false
	var skin_data: Dictionary = WEAPON_SKINS.get(skin_id, {})
	var cost: int = int(skin_data.get("cost", 9999))
	if fighter_gems < cost:
		return false
	fighter_gems -= cost
	fighter_owned_weapon_skins.append(skin_id)
	save_fighter_trophies()
	return true


func equip_char_skin(skin_id: String) -> void:
	if owns_char_skin(skin_id):
		fighter_char_skin = skin_id
		save_fighter_trophies()


func equip_weapon_skin(skin_id: String) -> void:
	if owns_weapon_skin(skin_id):
		fighter_weapon_skin = skin_id
		save_fighter_trophies()


func get_char_skin_data() -> Dictionary:
	return CHAR_SKINS.get(fighter_char_skin, CHAR_SKINS["default"])


func get_rage_color() -> Color:
	var skin_data: Dictionary = CHAR_SKINS.get(fighter_char_skin, CHAR_SKINS["default"])
	var base: Color = skin_data.get("scarf", Color(1.0, 0.3, 0.1))
	return base


func get_rage_color_bright() -> Color:
	var base: Color = get_rage_color()
	# Brighter/lighter version for "full meter" state
	return base.lightened(0.35)


func get_weapon_skin_data() -> Dictionary:
	return WEAPON_SKINS.get(fighter_weapon_skin, WEAPON_SKINS["default"])


# ─── Currency functions ───────────────────────────────

func add_fighter_coins(amount: int) -> void:
	fighter_coins = maxi(fighter_coins + amount, 0)


func add_fighter_gems(amount: int) -> void:
	fighter_gems = maxi(fighter_gems + amount, 0)


func add_fighter_power_ups(amount: int) -> void:
	fighter_power_ups = maxi(fighter_power_ups + amount, 0)


# ─── Battle Pass functions ────────────────────────────

func advance_pass() -> void:
	fighter_pass_progress += 1  # infinite — no cap


func get_free_reward(tier: int) -> Dictionary:
	return FREE_REWARD_CYCLE[tier % FREE_REWARD_CYCLE.size()]


func get_paid_reward(tier: int) -> Dictionary:
	return PAID_REWARD_CYCLE[tier % PAID_REWARD_CYCLE.size()]


func buy_fighter_pass() -> bool:
	if fighter_pass_purchased:
		return false
	if fighter_coins < PASS_COST:
		return false
	fighter_coins -= PASS_COST
	fighter_pass_purchased = true
	save_fighter_trophies()
	return true


func claim_free_reward(tier: int) -> bool:
	if tier < 0:
		return false
	if tier >= fighter_pass_progress:
		return false
	if tier in fighter_pass_free_claimed:
		return false
	fighter_pass_free_claimed.append(tier)
	_apply_pass_reward(get_free_reward(tier))
	save_fighter_trophies()
	return true


func claim_paid_reward(tier: int) -> bool:
	if not fighter_pass_purchased:
		return false
	if tier < 0:
		return false
	if tier >= fighter_pass_progress:
		return false
	if tier in fighter_pass_paid_claimed:
		return false
	fighter_pass_paid_claimed.append(tier)
	_apply_pass_reward(get_paid_reward(tier))
	save_fighter_trophies()
	return true


func _apply_pass_reward(reward: Dictionary) -> void:
	var rtype: String = str(reward.get("type", ""))
	var amount: int = int(reward.get("amount", 0))
	match rtype:
		"coins":
			add_fighter_coins(amount)
		"gems":
			add_fighter_gems(amount)
		"power_ups":
			add_fighter_power_ups(amount)


# ─── Weapon Level & RAGE functions ──────────────────

func get_weapon_level(weapon_id: String) -> int:
	return clampi(int(fighter_weapon_levels.get(weapon_id, 1)), 1, RAGE_LEVEL)


func get_upgrade_cost(weapon_id: String) -> int:
	var level := get_weapon_level(weapon_id)
	if level >= WEAPON_MAX_LEVEL:
		return -1
	return WEAPON_UPGRADE_COSTS[level - 1]


func can_upgrade_weapon(weapon_id: String) -> bool:
	var level := get_weapon_level(weapon_id)
	if level >= WEAPON_MAX_LEVEL:
		return false
	var cost: int = WEAPON_UPGRADE_COSTS[level - 1]
	return fighter_power_ups >= cost


func upgrade_weapon(weapon_id: String) -> bool:
	if not can_upgrade_weapon(weapon_id):
		return false
	var cost: int = WEAPON_UPGRADE_COSTS[get_weapon_level(weapon_id) - 1]
	fighter_power_ups -= cost
	fighter_weapon_levels[weapon_id] = get_weapon_level(weapon_id) + 1
	save_fighter_trophies()
	return true


func has_rage(weapon_id: String) -> bool:
	return get_weapon_level(weapon_id) == RAGE_LEVEL


func can_buy_rage(weapon_id: String) -> bool:
	return get_weapon_level(weapon_id) == WEAPON_MAX_LEVEL and fighter_coins >= RAGE_COIN_COST


func buy_rage(weapon_id: String) -> bool:
	if not can_buy_rage(weapon_id):
		return false
	fighter_coins -= RAGE_COIN_COST
	fighter_weapon_levels[weapon_id] = RAGE_LEVEL
	save_fighter_trophies()
	return true


func get_damage_multiplier(weapon_id: String) -> float:
	var level := get_weapon_level(weapon_id)
	return 1.0 + float(level - 1) * WEAPON_DAMAGE_SCALE


func get_knockback_multiplier(weapon_id: String) -> float:
	var level := get_weapon_level(weapon_id)
	return 1.0 + float(level - 1) * WEAPON_KB_SCALE


func get_super_damage_multiplier(weapon_id: String) -> float:
	var level := get_weapon_level(weapon_id)
	return 1.0 + float(level - 1) * WEAPON_SUPER_DMG_SCALE


func get_super_knockback_multiplier(weapon_id: String) -> float:
	var level := get_weapon_level(weapon_id)
	return 1.0 + float(level - 1) * WEAPON_SUPER_KB_SCALE


# ─── Key Binding functions ───────────────────────────

func get_key_binding(action: String) -> int:
	return int(fighter_key_bindings.get(action, DEFAULT_KEY_BINDINGS.get(action, KEY_NONE)))


func set_key_binding(action: String, keycode: int) -> void:
	fighter_key_bindings[action] = keycode
	save_fighter_trophies()


func reset_key_bindings() -> void:
	fighter_key_bindings = DEFAULT_KEY_BINDINGS.duplicate()
	save_fighter_trophies()


func get_key_name(keycode: int) -> String:
	if keycode == KEY_NONE:
		return "None"
	return OS.get_keycode_string(keycode)


# ─── Touch Control functions ─────────────────────────

func set_touch_scale(s: float) -> void:
	touch_button_scale = clampf(s, 0.5, 2.0)
	save_fighter_trophies()


func reset_touch_settings() -> void:
	touch_button_scale = 1.0
	touch_joystick_x = 120.0
	touch_joystick_y = 500.0
	touch_attack_x = 1050.0
	touch_attack_y = 460.0
	save_fighter_trophies()


# ─── Body Skin functions ─────────────────────────────

func owns_body_skin(skin_id: String) -> bool:
	return skin_id in fighter_owned_body_skins


func buy_body_skin(skin_id: String) -> bool:
	if owns_body_skin(skin_id):
		return false
	var skin_data: Dictionary = BODY_SKINS.get(skin_id, {})
	var cost: int = int(skin_data.get("cost", 9999))
	if fighter_gems < cost:
		return false
	fighter_gems -= cost
	fighter_owned_body_skins.append(skin_id)
	save_fighter_trophies()
	return true


func equip_body_skin(skin_id: String) -> void:
	if owns_body_skin(skin_id):
		fighter_body_skin = skin_id
		save_fighter_trophies()


# ─── Trophy Road functions ──────────────────────────────

func get_trophy_road_progress() -> int:
	var total := get_total_trophies()
	var highest := -1
	for i in range(TROPHY_ROAD.size()):
		if total >= int(TROPHY_ROAD[i]["trophies"]):
			highest = i
	return highest


func can_claim_trophy_road(index: int) -> bool:
	if index < 0 or index >= TROPHY_ROAD.size():
		return false
	if index in fighter_trophy_road_claimed:
		return false
	var total := get_total_trophies()
	return total >= int(TROPHY_ROAD[index]["trophies"])


func claim_trophy_road(index: int) -> bool:
	if not can_claim_trophy_road(index):
		return false
	fighter_trophy_road_claimed.append(index)
	var milestone: Dictionary = TROPHY_ROAD[index]
	for reward in milestone["rewards"]:
		_apply_road_reward(reward)
	save_fighter_trophies()
	return true


func _apply_road_reward(reward: Dictionary) -> void:
	var rtype: String = str(reward.get("type", ""))
	match rtype:
		"coins":
			add_fighter_coins(int(reward.get("amount", 0)))
		"gems":
			add_fighter_gems(int(reward.get("amount", 0)))
		"power_ups":
			add_fighter_power_ups(int(reward.get("amount", 0)))
		"weapon":
			var wid: String = str(reward.get("id", ""))
			if wid != "" and not is_weapon_unlocked(wid):
				fighter_unlocked_weapons.append(wid)
			elif wid != "" and is_weapon_unlocked(wid):
				# Already owned — refund half coin cost
				var half_cost: int = int(float(WEAPON_COSTS.get(wid, 0)) / 2.0)
				add_fighter_coins(half_cost)
		"char_skin":
			var sid: String = str(reward.get("id", ""))
			if sid != "" and not owns_char_skin(sid):
				fighter_owned_char_skins.append(sid)
			elif sid != "" and owns_char_skin(sid):
				var skin_data: Dictionary = CHAR_SKINS.get(sid, {})
				add_fighter_gems(int(float(skin_data.get("cost", 0)) / 2.0))
		"weapon_skin":
			var sid: String = str(reward.get("id", ""))
			if sid != "" and not owns_weapon_skin(sid):
				fighter_owned_weapon_skins.append(sid)
			elif sid != "" and owns_weapon_skin(sid):
				var skin_data: Dictionary = WEAPON_SKINS.get(sid, {})
				add_fighter_gems(int(float(skin_data.get("cost", 0)) / 2.0))
		"body_skin":
			var sid: String = str(reward.get("id", ""))
			if sid != "" and not owns_body_skin(sid):
				fighter_owned_body_skins.append(sid)
			elif sid != "" and owns_body_skin(sid):
				var skin_data: Dictionary = BODY_SKINS.get(sid, {})
				add_fighter_gems(int(float(skin_data.get("cost", 0)) / 2.0))


func has_unclaimed_road_rewards() -> bool:
	var total := get_total_trophies()
	for i in range(TROPHY_ROAD.size()):
		if total >= int(TROPHY_ROAD[i]["trophies"]) and i not in fighter_trophy_road_claimed:
			return true
	return false


func get_road_reward_label(reward: Dictionary) -> String:
	var rtype: String = str(reward.get("type", ""))
	match rtype:
		"coins", "gems", "power_ups":
			return str(int(reward.get("amount", 0))) + " " + str(TROPHY_ROAD_REWARD_NAMES.get(rtype, rtype))
		"weapon":
			var wid: String = str(reward.get("id", ""))
			return wid.replace("_", " ").capitalize()
		"char_skin":
			var sid: String = str(reward.get("id", ""))
			var skin_data: Dictionary = CHAR_SKINS.get(sid, {})
			return str(skin_data.get("name", sid.capitalize())) + " Skin"
		"weapon_skin":
			var sid: String = str(reward.get("id", ""))
			var skin_data: Dictionary = WEAPON_SKINS.get(sid, {})
			return str(skin_data.get("name", sid.capitalize())) + " W.Skin"
		"body_skin":
			var sid: String = str(reward.get("id", ""))
			var skin_data: Dictionary = BODY_SKINS.get(sid, {})
			return str(skin_data.get("name", sid.capitalize())) + " Body"
	return rtype


# ─── Ranked Tiers ────────────────────────────────────

func get_current_rank() -> Dictionary:
	var total := get_total_trophies()
	var rank: Dictionary = RANK_TIERS[0]
	for tier in RANK_TIERS:
		if total >= int(tier["min"]):
			rank = tier
	return rank


func get_next_rank() -> Dictionary:
	var total := get_total_trophies()
	for tier in RANK_TIERS:
		if total < int(tier["min"]):
			return tier
	return {}  # Already at max rank


func get_rank_progress() -> float:
	var total := get_total_trophies()
	var current := get_current_rank()
	var next_rank := get_next_rank()
	if next_rank.is_empty():
		return 1.0
	var cur_min: int = int(current["min"])
	var next_min: int = int(next_rank["min"])
	if next_min == cur_min:
		return 1.0
	return clampf(float(total - cur_min) / float(next_min - cur_min), 0.0, 1.0)


# ─── Win Streak ──────────────────────────────────────

func get_streak_multiplier() -> float:
	var idx: int = mini(fighter_win_streak, STREAK_MULTIPLIERS.size() - 1)
	return STREAK_MULTIPLIERS[idx]


func on_match_win() -> void:
	fighter_win_streak += 1
	if fighter_win_streak > fighter_best_win_streak:
		fighter_best_win_streak = fighter_win_streak
	fighter_lose_streak = 0


func on_match_loss() -> void:
	fighter_win_streak = 0
	fighter_lose_streak += 1


# ─── First Win of the Day ───────────────────────────

func check_first_win_of_day() -> bool:
	var today := _get_today_string()
	if first_win_date != today:
		first_win_date = today
		first_win_claimed = true
		return true
	return false


# ─── Login Streak ───────────────────────────────────

func check_login_streak() -> void:
	var today := _get_today_string()
	if last_login_date == today:
		return  # Already logged in today
	var yesterday := _get_yesterday_string()
	if last_login_date == yesterday:
		login_streak += 1
	elif last_login_date == "":
		login_streak = 1
	else:
		login_streak = 1  # Streak broken
	if login_streak > best_login_streak:
		best_login_streak = login_streak
	last_login_date = today
	login_reward_claimed_today = false
	save_fighter_trophies()


func _get_yesterday_string() -> String:
	var unix := Time.get_unix_time_from_system() - 86400
	var dt := Time.get_datetime_dict_from_unix_time(int(unix))
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]


func get_login_reward() -> Dictionary:
	# Find the best matching reward tier for current streak
	var best_reward := {}
	for tier in LOGIN_STREAK_REWARDS:
		if login_streak >= tier[0]:
			best_reward = {"type": str(tier[1]), "amount": int(tier[2]), "desc": str(tier[3])}
	return best_reward


func claim_login_reward() -> Dictionary:
	if login_reward_claimed_today:
		return {}
	var reward := get_login_reward()
	if reward.is_empty():
		return {}
	login_reward_claimed_today = true
	match reward["type"]:
		"coins":
			add_fighter_coins(reward["amount"])
		"gems":
			add_fighter_gems(reward["amount"])
		"power_ups":
			add_fighter_power_ups(reward["amount"])
	save_fighter_trophies()
	return reward


# ─── Seasons ────────────────────────────────────────

func check_season() -> void:
	var today := _get_today_string()
	if season_start_date == "":
		season_start_date = today
		save_fighter_trophies()
		return
	var days_elapsed := _days_between(season_start_date, today)
	if days_elapsed >= SEASON_DURATION_DAYS:
		_end_season()


func _days_between(date_a: String, date_b: String) -> int:
	# Simple day diff using unix timestamps
	var parts_a := date_a.split("-")
	var parts_b := date_b.split("-")
	if parts_a.size() < 3 or parts_b.size() < 3:
		return 0
	var da := Time.get_unix_time_from_datetime_dict({"year": int(parts_a[0]), "month": int(parts_a[1]), "day": int(parts_a[2]), "hour": 0, "minute": 0, "second": 0})
	var db := Time.get_unix_time_from_datetime_dict({"year": int(parts_b[0]), "month": int(parts_b[1]), "day": int(parts_b[2]), "hour": 0, "minute": 0, "second": 0})
	return int(float(db - da) / 86400.0)


func _end_season() -> void:
	# Award season end rewards based on peak trophies
	var peak := season_peak_trophies
	if peak >= 50000:
		add_fighter_gems(100)
	elif peak >= 32000:
		add_fighter_gems(75)
	elif peak >= 18000:
		add_fighter_gems(50)
	elif peak >= 7500:
		add_fighter_gems(30)
	elif peak >= 2000:
		add_fighter_gems(15)
	elif peak >= 500:
		add_fighter_coins(50)
	# Soft reset: keep 75% of trophies
	for wid in fighter_weapon_trophies:
		fighter_weapon_trophies[wid] = int(fighter_weapon_trophies[wid] * 0.75)
	# Start new season
	current_season += 1
	season_start_date = _get_today_string()
	season_peak_trophies = get_total_trophies()
	season_rewards_claimed = false
	save_fighter_trophies()


func update_season_peak() -> void:
	var total := get_total_trophies()
	if total > season_peak_trophies:
		season_peak_trophies = total


# ─── Achievements ───────────────────────────────────

func check_achievements(_weapon_id: String = "") -> void:
	var total_trophies := get_total_trophies()
	var total_wins := fighter_win_streak + fighter_best_win_streak  # Approximate — use real total if tracked
	for ach in ACHIEVEMENTS:
		var aid: String = str(ach["id"])
		if aid in unlocked_achievements:
			continue
		var unlocked := false
		match str(ach["type"]):
			"total_wins":
				# We track best streak as proxy — real total wins would need separate counter
				unlocked = fighter_best_win_streak >= 1 and total_wins >= int(ach["target"])
			"best_streak":
				unlocked = fighter_best_win_streak >= int(ach["target"])
			"rank":
				unlocked = total_trophies >= int(ach["target"])
			"weapons_owned":
				unlocked = fighter_unlocked_weapons.size() >= int(ach["target"])
			"login_streak":
				unlocked = best_login_streak >= int(ach["target"])
		if unlocked:
			_unlock_achievement(aid, ach)


func check_match_achievements(stats: Dictionary) -> void:
	# Called after match with match-specific stats
	for ach in ACHIEVEMENTS:
		var aid: String = str(ach["id"])
		if aid in unlocked_achievements:
			continue
		match str(ach["type"]):
			"flawless_win":
				if stats.get("damage_taken", 1.0) <= 0.0 and stats.get("won", false):
					_unlock_achievement(aid, ach)
			"style_points":
				if stats.get("style_points", 0) >= int(ach["target"]):
					_unlock_achievement(aid, ach)
			"max_combo":
				if stats.get("max_combo", 0) >= int(ach["target"]):
					_unlock_achievement(aid, ach)


func _unlock_achievement(aid: String, ach: Dictionary) -> void:
	unlocked_achievements.append(aid)
	# Grant reward
	match str(ach.get("reward", "")):
		"coins":
			add_fighter_coins(int(ach.get("amount", 0)))
		"gems":
			add_fighter_gems(int(ach.get("amount", 0)))
		"power_ups":
			add_fighter_power_ups(int(ach.get("amount", 0)))
	save_fighter_trophies()


func get_achievement_progress(ach: Dictionary) -> float:
	match str(ach["type"]):
		"best_streak":
			return minf(float(fighter_best_win_streak) / float(ach["target"]), 1.0)
		"rank":
			return minf(float(get_total_trophies()) / float(ach["target"]), 1.0)
		"weapons_owned":
			return minf(float(fighter_unlocked_weapons.size()) / float(ach["target"]), 1.0)
		"login_streak":
			return minf(float(best_login_streak) / float(ach["target"]), 1.0)
	return 0.0


# ─── Daily Challenges ────────────────────────────────

func _get_today_string() -> String:
	var dt := Time.get_datetime_dict_from_system()
	return "%04d-%02d-%02d" % [dt["year"], dt["month"], dt["day"]]


func check_daily_challenges() -> void:
	var today := _get_today_string()
	if daily_challenge_date != today:
		_generate_daily_challenges()
		daily_challenge_date = today
		daily_challenges_claimed = []
		save_fighter_trophies()


func _generate_daily_challenges() -> void:
	daily_challenges = []
	var used_ids: Array[String] = []
	var weapon_names_map: Dictionary = {
		"fists": "Fists", "shadow_blade": "Shadow Blade", "kunai_stars": "Kunai Stars",
		"frost_staff": "Frost Staff", "vine_whip": "Vine Whip", "iron_buckler": "Iron Buckler",
		"dragon_gauntlets": "Dragon Gauntlets", "spirit_bow": "Spirit Bow",
	}
	# Pick 3 unique challenge types
	var templates := CHALLENGE_TEMPLATES.duplicate()
	templates.shuffle()
	for i in range(mini(3, templates.size())):
		var tmpl: Dictionary = templates[i]
		var tid: String = str(tmpl["id"])
		if tid in used_ids:
			continue
		used_ids.append(tid)
		var targets: Array = tmpl["targets"]
		var target: int = targets[randi() % targets.size()]
		var desc: String = str(tmpl["desc"])

		if tid == "win_weapon":
			# Pick a random unlocked weapon
			var weapons := fighter_unlocked_weapons.duplicate()
			weapons.shuffle()
			var wpn: String = weapons[0] if weapons.size() > 0 else "fists"
			desc = desc % str(weapon_names_map.get(wpn, wpn.replace("_", " ").capitalize()))
			daily_challenges.append({
				"id": tid,
				"desc": desc + " (" + str(target) + "x)",
				"target": target,
				"progress": 0,
				"reward_type": str(tmpl["reward_type"]),
				"reward_amount": int(tmpl["reward_amount"]),
				"completed": false,
				"weapon": wpn,
			})
		else:
			desc = desc % target
			daily_challenges.append({
				"id": tid,
				"desc": desc,
				"target": target,
				"progress": 0,
				"reward_type": str(tmpl["reward_type"]),
				"reward_amount": int(tmpl["reward_amount"]),
				"completed": false,
			})


func advance_daily_challenges(event_type: String, amount: int = 1, weapon: String = "", mode: String = "") -> void:
	for ch in daily_challenges:
		if ch["completed"]:
			continue
		var cid: String = str(ch["id"])
		match cid:
			"win_any":
				if event_type == "win":
					ch["progress"] = int(ch["progress"]) + amount
			"win_streak":
				if event_type == "win":
					ch["progress"] = fighter_win_streak
			"win_weapon":
				if event_type == "win" and weapon == str(ch.get("weapon", "")):
					ch["progress"] = int(ch["progress"]) + amount
			"trophies":
				if event_type == "trophies":
					ch["progress"] = int(ch["progress"]) + amount
			"kills":
				if event_type == "kill":
					ch["progress"] = int(ch["progress"]) + amount
			"win_2v2":
				if event_type == "win" and mode == "2v2":
					ch["progress"] = int(ch["progress"]) + amount
		if int(ch["progress"]) >= int(ch["target"]):
			ch["completed"] = true


func claim_daily_challenge(index: int) -> void:
	if index < 0 or index >= daily_challenges.size():
		return
	if index in daily_challenges_claimed:
		return
	var ch: Dictionary = daily_challenges[index]
	if not ch["completed"]:
		return
	daily_challenges_claimed.append(index)
	var rtype: String = str(ch["reward_type"])
	var ramount: int = int(ch["reward_amount"])
	match rtype:
		"coins":
			fighter_coins += ramount
		"gems":
			fighter_gems += ramount
		"power_ups":
			fighter_power_ups += ramount
	save_fighter_trophies()


func get_unclaimed_challenge_count() -> int:
	var count := 0
	for i in range(daily_challenges.size()):
		if daily_challenges[i]["completed"] and i not in daily_challenges_claimed:
			count += 1
	return count


# ─── Save / Load ──────────────────────────────────────

func save_fighter_trophies() -> void:
	var f := FileAccess.open(FIGHTER_SAVE_PATH, FileAccess.WRITE)
	if f:
		f.store_string(JSON.stringify({
			"weapon_trophies": fighter_weapon_trophies,
			"unlocked_weapons": fighter_unlocked_weapons,
			"coins": fighter_coins,
			"gems": fighter_gems,
			"power_ups": fighter_power_ups,
			"lose_streak": fighter_lose_streak,
			"weapon_levels": fighter_weapon_levels,
			"pass_purchased": fighter_pass_purchased,
			"pass_progress": fighter_pass_progress,
			"pass_free_claimed": fighter_pass_free_claimed,
			"pass_paid_claimed": fighter_pass_paid_claimed,
			"char_skin": fighter_char_skin,
			"weapon_skin": fighter_weapon_skin,
			"owned_char_skins": fighter_owned_char_skins,
			"owned_weapon_skins": fighter_owned_weapon_skins,
			"key_bindings": fighter_key_bindings,
			"touch_scale": touch_button_scale,
			"touch_joy_x": touch_joystick_x,
			"touch_joy_y": touch_joystick_y,
			"touch_atk_x": touch_attack_x,
			"touch_atk_y": touch_attack_y,
			"body_skin": fighter_body_skin,
			"owned_body_skins": fighter_owned_body_skins,
			"show_hair": fighter_show_hair,
			"trophy_road_claimed": fighter_trophy_road_claimed,
			"profile_name": profile_name,
			"profile_fav_skin": profile_fav_skin,
			"profile_fav_weapon": profile_fav_weapon,
			"win_streak": fighter_win_streak,
			"best_win_streak": fighter_best_win_streak,
			"daily_challenges": daily_challenges,
			"daily_challenge_date": daily_challenge_date,
			"daily_challenges_claimed": daily_challenges_claimed,
			"first_win_date": first_win_date,
			"first_win_claimed": first_win_claimed,
			"login_streak": login_streak,
			"best_login_streak": best_login_streak,
			"last_login_date": last_login_date,
			"login_reward_claimed_today": login_reward_claimed_today,
			"current_season": current_season,
			"season_start_date": season_start_date,
			"season_peak_trophies": season_peak_trophies,
			"season_rewards_claimed": season_rewards_claimed,
			"unlocked_achievements": unlocked_achievements,
		}))


func load_fighter_trophies() -> void:
	if not FileAccess.file_exists(FIGHTER_SAVE_PATH):
		return
	var f := FileAccess.open(FIGHTER_SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var parsed: Variant = JSON.parse_string(f.get_as_text())
	if typeof(parsed) == TYPE_DICTIONARY:
		# Weapon trophies (with old format migration)
		if parsed.has("trophies") and not parsed.has("weapon_trophies"):
			var old_val := maxi(int(parsed.get("trophies", 0)), 0)
			if old_val > 0:
				fighter_weapon_trophies[fighter_weapon_id] = old_val
		elif parsed.has("weapon_trophies") and typeof(parsed["weapon_trophies"]) == TYPE_DICTIONARY:
			for wid in parsed["weapon_trophies"]:
				fighter_weapon_trophies[str(wid)] = maxi(int(parsed["weapon_trophies"][wid]), 0)
		# Unlocked weapons
		if parsed.has("unlocked_weapons") and typeof(parsed["unlocked_weapons"]) == TYPE_ARRAY:
			fighter_unlocked_weapons = []
			for wid in parsed["unlocked_weapons"]:
				fighter_unlocked_weapons.append(str(wid))
		if "fists" not in fighter_unlocked_weapons:
			fighter_unlocked_weapons.append("fists")
		if "shadow_blade" not in fighter_unlocked_weapons:
			fighter_unlocked_weapons.append("shadow_blade")
		check_weapon_unlocks()
		# Currencies
		fighter_coins = maxi(int(parsed.get("coins", 0)), 0)
		fighter_gems = maxi(int(parsed.get("gems", 0)), 0)
		fighter_power_ups = maxi(int(parsed.get("power_ups", 0)), 0)
		# Lose streak
		fighter_lose_streak = maxi(int(parsed.get("lose_streak", 0)), 0)
		# Weapon levels
		if parsed.has("weapon_levels") and typeof(parsed["weapon_levels"]) == TYPE_DICTIONARY:
			for wid in parsed["weapon_levels"]:
				fighter_weapon_levels[str(wid)] = clampi(int(parsed["weapon_levels"][wid]), 1, RAGE_LEVEL)
		# Battle Pass (infinite — no upper cap)
		fighter_pass_purchased = bool(parsed.get("pass_purchased", false))
		fighter_pass_progress = maxi(int(parsed.get("pass_progress", 0)), 0)
		fighter_pass_free_claimed = _load_int_array(parsed.get("pass_free_claimed", []))
		fighter_pass_paid_claimed = _load_int_array(parsed.get("pass_paid_claimed", []))
		# Skins
		fighter_char_skin = str(parsed.get("char_skin", "default"))
		fighter_weapon_skin = str(parsed.get("weapon_skin", "default"))
		fighter_owned_char_skins = _load_string_array(parsed.get("owned_char_skins", ["default"]))
		fighter_owned_weapon_skins = _load_string_array(parsed.get("owned_weapon_skins", ["default"]))
		if "default" not in fighter_owned_char_skins:
			fighter_owned_char_skins.append("default")
		if "default" not in fighter_owned_weapon_skins:
			fighter_owned_weapon_skins.append("default")
		if not owns_char_skin(fighter_char_skin):
			fighter_char_skin = "default"
		if not owns_weapon_skin(fighter_weapon_skin):
			fighter_weapon_skin = "default"
		# Key bindings
		if parsed.has("key_bindings") and typeof(parsed["key_bindings"]) == TYPE_DICTIONARY:
			for action in parsed["key_bindings"]:
				fighter_key_bindings[str(action)] = int(parsed["key_bindings"][action])
		# Touch control settings
		touch_button_scale = clampf(float(parsed.get("touch_scale", 1.0)), 0.5, 2.0)
		touch_joystick_x = float(parsed.get("touch_joy_x", 120.0))
		touch_joystick_y = float(parsed.get("touch_joy_y", 500.0))
		touch_attack_x = float(parsed.get("touch_atk_x", 1050.0))
		touch_attack_y = float(parsed.get("touch_atk_y", 460.0))
		# Body skins
		fighter_body_skin = str(parsed.get("body_skin", "default"))
		fighter_owned_body_skins = _load_string_array(parsed.get("owned_body_skins", ["default"]))
		if "default" not in fighter_owned_body_skins:
			fighter_owned_body_skins.append("default")
		if not owns_body_skin(fighter_body_skin):
			fighter_body_skin = "default"
		# Hair toggle
		fighter_show_hair = bool(parsed.get("show_hair", false))
		# Trophy Road
		fighter_trophy_road_claimed = _load_int_array(parsed.get("trophy_road_claimed", []))
		# Profile
		profile_name = str(parsed.get("profile_name", "Player"))
		profile_fav_skin = str(parsed.get("profile_fav_skin", "default"))
		profile_fav_weapon = str(parsed.get("profile_fav_weapon", "fists"))
		# Win streak
		fighter_win_streak = maxi(int(parsed.get("win_streak", 0)), 0)
		fighter_best_win_streak = maxi(int(parsed.get("best_win_streak", 0)), 0)
		# Daily challenges
		daily_challenge_date = str(parsed.get("daily_challenge_date", ""))
		daily_challenges_claimed = _load_int_array(parsed.get("daily_challenges_claimed", []))
		var dc_raw: Variant = parsed.get("daily_challenges", [])
		if typeof(dc_raw) == TYPE_ARRAY:
			daily_challenges = []
			for item in dc_raw:
				if typeof(item) == TYPE_DICTIONARY:
					daily_challenges.append(item)
		# First win of the day
		first_win_date = str(parsed.get("first_win_date", ""))
		first_win_claimed = bool(parsed.get("first_win_claimed", false))
		# Login streak
		login_streak = maxi(int(parsed.get("login_streak", 0)), 0)
		best_login_streak = maxi(int(parsed.get("best_login_streak", 0)), 0)
		last_login_date = str(parsed.get("last_login_date", ""))
		login_reward_claimed_today = bool(parsed.get("login_reward_claimed_today", false))
		# Seasons
		current_season = maxi(int(parsed.get("current_season", 1)), 1)
		season_start_date = str(parsed.get("season_start_date", ""))
		season_peak_trophies = maxi(int(parsed.get("season_peak_trophies", 0)), 0)
		season_rewards_claimed = bool(parsed.get("season_rewards_claimed", false))
		# Achievements
		unlocked_achievements = _load_string_array(parsed.get("unlocked_achievements", []))


func _load_int_array(value: Variant) -> Array[int]:
	var result: Array[int] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		result.append(int(entry))
	return result


func _load_string_array(value: Variant) -> Array[String]:
	var result: Array[String] = []
	if typeof(value) != TYPE_ARRAY:
		return result
	for entry in value:
		result.append(str(entry))
	return result

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
const BACKPACK_MAX_WEIGHT := 12.0
const LEVEL_DIFFICULTY_BY_SLOT := {
	1: 0.66,
	2: 0.72,
	3: 0.8,
	4: 0.88,
	5: 0.96,
	6: 1.08,
	7: 1.18,
	8: 1.28,
	9: 1.38,
	10: 1.48,
	11: 1.66,
	12: 1.82,
	13: 1.98,
	14: 2.14,
	15: 2.32,
}
const ITEM_CATEGORY_LABELS := {
	"food": "Food",
	"medical": "Medical",
	"tool": "Tools",
	"loot": "Loot",
	"document": "Docs",
	"mission": "Mission",
	"key_item": "Key Item",
	"weapon": "Weapon",
	"misc": "Misc",
}
const WEAPON_ITEM_IDS := ["slime_blaster", "iron_repeater", "sun_lance", "arc_blaster"]
const WEAPON_PRIORITY := ["arc_blaster", "sun_lance", "iron_repeater", "slime_blaster"]
const ROOM_SCENES := {
	"home_clearing": "res://scenes/World.tscn",
	"forest_path": "res://scenes/ForestPath.tscn",
	"echo_rift": "res://scenes/EchoRift.tscn",
	"ashen_rift": "res://scenes/AshenRift.tscn",
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
	"hub_tavern_int": "res://scenes/interiors/HubTavernInt.tscn",
	"hub_house_int": "res://scenes/interiors/HubHouseInt.tscn",
	"village_house_int": "res://scenes/interiors/VillageHouseInt.tscn",
	"bank_interior": "res://scenes/interiors/BankInterior.tscn",
	"bandit_house_int": "res://scenes/interiors/BanditHouseInt.tscn",
	"market_jeweler_int": "res://scenes/interiors/JewelerInt.tscn",
	"market_store_int": "res://scenes/interiors/MarketStoreInt.tscn",
	"farm_barn_int": "res://scenes/interiors/FarmBarnInt.tscn",
}
const ROOM_TITLES := {
	"home_clearing": "Lantern City",
	"forest_path": "Willow Village",
	"echo_rift": "Echo Rift",
	"ashen_rift": "Ashen Rift",
	"market_crossroads": "Market Square",
	"echo_cave": "Henfield Farm",
	"sunstone_ruins": "Stonebank Bank",
	"ember_fields": "Old Prison",
	"bloom_marsh": "Bandit House",
	"iron_docks": "Canal Docks",
	"verdant_garden": "Clinic Garden",
	"dune_courtyard": "Court Square",
	"ashen_keep": "Old Prison Yard",
	"storm_sanctum": "Storm Sanctum",
	"obsidian_hall": "Obsidian Hall",
	"frost_labyrinth": "Frost Labyrinth",
	"void_bastion": "Void Bastion",
	"sky_keep": "Sky Keep",
	"forge_hall": "Forge Hall",
	"arcane_vault": "Arcane Vault",
	"hub_tavern_int": "City Tavern",
	"hub_house_int": "City House",
	"village_house_int": "Village House",
	"bank_interior": "Stonebank Interior",
	"bandit_house_int": "Bandit House Interior",
	"market_jeweler_int": "Jeweler House",
	"market_store_int": "Market Store",
	"farm_barn_int": "Barn Interior",
}
const ITEM_DEFS := {
	"berry": {
		"display_name": "Berry",
		"description": "A sweet berry that restores 1 HP.",
		"kind": "consumable",
		"category": "food",
		"usable": true,
		"heal_amount": 1,
		"weight": 0.2,
		"stack_limit": 12,
	},
	"apple": {
		"display_name": "Apple",
		"description": "A fresh apple. Restores 1 HP.",
		"kind": "consumable",
		"category": "food",
		"usable": true,
		"heal_amount": 1,
		"weight": 0.3,
		"stack_limit": 6,
	},
	"bread": {
		"display_name": "Bread",
		"description": "A dense loaf that restores 1 HP.",
		"kind": "consumable",
		"category": "food",
		"usable": true,
		"heal_amount": 1,
		"weight": 0.5,
		"stack_limit": 4,
	},
	"bandage": {
		"display_name": "Bandage",
		"description": "A wrapped medical bandage that restores 2 HP.",
		"kind": "consumable",
		"category": "medical",
		"usable": true,
		"heal_amount": 2,
		"weight": 0.2,
		"stack_limit": 6,
	},
	"water_bottle": {
		"display_name": "Water Bottle",
		"description": "Clean water for long routes.",
		"kind": "resource",
		"category": "food",
		"usable": false,
		"weight": 1.0,
		"stack_limit": 3,
	},
	"rope": {
		"display_name": "Rope",
		"description": "Useful for climbs, rescues, and improvised jobs.",
		"kind": "resource",
		"category": "tool",
		"usable": false,
		"weight": 1.2,
		"stack_limit": 2,
	},
	"flashlight": {
		"display_name": "Flashlight",
		"description": "A practical light for dark buildings and tunnels.",
		"kind": "tool",
		"category": "tool",
		"usable": false,
		"weight": 0.5,
		"stack_limit": 1,
	},
	"lockpick_set": {
		"display_name": "Lockpick Set",
		"description": "A small set of picks for quiet entries.",
		"kind": "tool",
		"category": "tool",
		"usable": false,
		"weight": 0.2,
		"stack_limit": 1,
	},
	"notebook": {
		"display_name": "Notebook",
		"description": "A small notebook for routes, hints, and names.",
		"kind": "document",
		"category": "document",
		"usable": false,
		"weight": 0.2,
		"stack_limit": 2,
	},
	"cash_bundle": {
		"display_name": "Cash Bundle",
		"description": "A wrapped stack of notes from a risky job.",
		"kind": "loot",
		"category": "loot",
		"usable": false,
		"weight": 0.4,
		"stack_limit": 10,
	},
	"jewelry_pouch": {
		"display_name": "Jewelry Pouch",
		"description": "A pouch of rings and small valuables.",
		"kind": "loot",
		"category": "loot",
		"usable": false,
		"weight": 0.3,
		"stack_limit": 4,
	},
	"forest_token": {
		"display_name": "Forest Token",
		"description": "A keepsake from the forest ranger.",
		"kind": "key_item",
		"category": "mission",
		"usable": false,
		"weight": 0.1,
		"stack_limit": 1,
	},
	"slime_blaster": {
		"display_name": "Slime Blaster",
		"description": "A basic pistol dropped by slimes.",
		"kind": "weapon",
		"category": "weapon",
		"usable": false,
		"weight": 0.0,
		"stack_limit": 1,
	},
	"iron_repeater": {
		"display_name": "Iron Repeater",
		"description": "A shop gun with faster shots and steadier aim.",
		"kind": "weapon",
		"category": "weapon",
		"usable": false,
		"weight": 0.0,
		"stack_limit": 1,
	},
	"sun_lance": {
		"display_name": "Sun Lance",
		"description": "A twin-shot relic pistol sold at the bazaar.",
		"kind": "weapon",
		"category": "weapon",
		"usable": false,
		"weight": 0.0,
		"stack_limit": 1,
	},
	"arc_blaster": {
		"display_name": "Arc Blaster",
		"description": "A forged upgrade that fires a faster, wider burst of arc rounds.",
		"kind": "weapon",
		"category": "weapon",
		"usable": false,
		"weight": 0.0,
		"stack_limit": 1,
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
	load_fighter_trophies()


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
	_ensure_key_action("map_toggle", KEY_M)
	_ensure_key_action("pause_menu", KEY_ESCAPE)


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
	if not ROOM_SCENES.has(current_room_id):
		current_room_id = DEFAULT_ROOM_ID
		current_spawn_id = DEFAULT_SPAWN_ID
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


func add_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return false

	var check := can_add_item(item_id, amount)
	if not bool(check.get("ok", false)):
		return false

	var current_amount: int = get_item_count(item_id)
	inventory[item_id] = current_amount + amount
	save_game()
	state_changed.emit()
	return true


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


func can_add_item(item_id: String, amount: int = 1) -> Dictionary:
	if amount <= 0:
		return {"ok": false, "reason": "Invalid amount."}

	var item_def := get_item_def(item_id)
	var current_amount := get_item_count(item_id)
	var stack_limit := get_item_stack_limit(item_id)
	if current_amount + amount > stack_limit:
		return {"ok": false, "reason": "No room for more %s." % str(item_def.get("display_name", item_id))}

	if is_weapon_item(item_id):
		return {"ok": true, "reason": ""}

	var projected_weight := get_backpack_load() + get_item_weight(item_id) * float(amount)
	if projected_weight > BACKPACK_MAX_WEIGHT + 0.001:
		return {"ok": false, "reason": "Backpack is full."}

	return {"ok": true, "reason": ""}


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


func get_backpack_capacity() -> float:
	return BACKPACK_MAX_WEIGHT


func get_backpack_load() -> float:
	var total_weight := 0.0
	for item_id in inventory.keys():
		var item_id_string := str(item_id)
		if not is_backpack_item(item_id_string):
			continue
		total_weight += get_item_weight(item_id_string) * float(get_item_count(item_id_string))
	return total_weight


func get_item_weight(item_id: String) -> float:
	return float(get_item_def(item_id).get("weight", 0.2))


func get_item_stack_limit(item_id: String) -> int:
	return int(get_item_def(item_id).get("stack_limit", 99))


func get_item_heal_amount(item_id: String) -> int:
	return int(get_item_def(item_id).get("heal_amount", 0))


func get_item_category(item_id: String) -> String:
	return str(get_item_def(item_id).get("category", "misc"))


func get_item_category_label(item_id: String) -> String:
	return str(ITEM_CATEGORY_LABELS.get(get_item_category(item_id), "Misc"))


func is_weapon_item(item_id: String) -> bool:
	return str(get_item_def(item_id).get("kind", "")) == "weapon"


func is_backpack_item(item_id: String) -> bool:
	return not is_weapon_item(item_id)


func get_add_item_failure_reason(item_id: String, amount: int = 1) -> String:
	return str(can_add_item(item_id, amount).get("reason", ""))


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


func mark_room_discovered(room_id: String) -> void:
	if room_id.is_empty():
		return
	if is_room_discovered(room_id):
		return
	set_flag("discovered_%s" % room_id, true)


func is_room_discovered(room_id: String) -> bool:
	if room_id.is_empty():
		return false
	return get_flag("discovered_%s" % room_id)


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


func is_beginner_level(room_id: String) -> bool:
	var level_number := get_level_number(room_id)
	return level_number > 0 and level_number <= 5


func is_mid_level(room_id: String) -> bool:
	var level_number := get_level_number(room_id)
	return level_number >= 6 and level_number <= 10


func get_beginner_bonus_coins(room_id: String) -> int:
	var level_number := get_level_number(room_id)
	if level_number <= 0 or level_number > 5:
		return 0
	if level_number <= 2:
		return 2
	return 1


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
