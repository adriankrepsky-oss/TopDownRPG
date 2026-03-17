extends CharacterBody2D


func _safe_create_tween() -> Tween:
	if not is_inside_tree():
		return null
	return create_tween()


# --- Movement constants ---
const GRAVITY := 1200.0
const MOVE_SPEED := 320.0
const JUMP_VELOCITY := -480.0
const MAX_FALL_SPEED := 900.0
const MAX_JUMPS := 2
const ACCELERATION := 1800.0
const AIR_ACCELERATION := 1200.0
const FRICTION := 2400.0
const AIR_FRICTION := 200.0
const COYOTE_TIME := 0.1

# --- Weapon definitions ---
const WEAPONS := {
	"fists": {
		"charge_capable": false,
		"primary_damage": 8.0,
		"primary_knockback": 280.0,
		"primary_cooldown": 0.25,
		"primary_duration": 0.12,
		"secondary_damage": 14.0,
		"secondary_knockback": 420.0,
		"secondary_cooldown": 0.6,
		"secondary_duration": 0.2,
		"secondary_type": "normal",
		"speed_multiplier": 1.0,
		"charge_speed_mult": 1.0,
	},
	"thors_hammer": {
		"charge_capable": true,
		"max_charge_time": 1.8,
		"min_damage": 12.0,
		"max_damage": 35.0,
		"min_knockback": 350.0,
		"max_knockback": 900.0,
		"primary_cooldown": 0.55,
		"primary_duration": 0.35,
		"secondary_damage": 18.0,
		"secondary_knockback": 500.0,
		"secondary_cooldown": 0.8,
		"secondary_duration": 0.25,
		"secondary_type": "normal",
		"speed_multiplier": 0.85,
		"charge_speed_mult": 0.4,
	},
	"shadow_blade": {
		"charge_capable": false,
		"primary_damage": 10.0,
		"primary_knockback": 250.0,
		"primary_cooldown": 0.18,
		"primary_duration": 0.1,
		"secondary_damage": 12.0,
		"secondary_knockback": 200.0,
		"secondary_cooldown": 1.2,
		"secondary_duration": 0.15,
		"secondary_type": "dash",
		"dash_distance": 120.0,
		"dash_invuln_time": 0.15,
		"speed_multiplier": 1.15,
		"charge_speed_mult": 1.0,
	},
	"frost_staff": {
		"charge_capable": false,
		"primary_damage": 8.0,
		"primary_knockback": 200.0,
		"primary_cooldown": 0.4,
		"primary_duration": 0.1,
		"secondary_damage": 10.0,
		"secondary_knockback": 350.0,
		"secondary_cooldown": 1.0,
		"secondary_duration": 0.2,
		"secondary_type": "aoe",
		"aoe_radius": 80.0,
		"projectile_speed": 600.0,
		"projectile_range": 400.0,
		"slow_duration": 0.5,
		"slow_amount": 0.5,
		"speed_multiplier": 1.0,
		"charge_speed_mult": 1.0,
	},
	"dragon_gauntlets": {
		"charge_capable": false,
		"primary_damage": 5.0,
		"primary_knockback": 180.0,
		"primary_cooldown": 0.12,
		"primary_duration": 0.08,
		"secondary_damage": 16.0,
		"secondary_knockback": 500.0,
		"secondary_cooldown": 0.8,
		"secondary_duration": 0.18,
		"secondary_type": "uppercut",
		"uppercut_self_boost": -250.0,
		"speed_multiplier": 1.05,
		"charge_speed_mult": 1.0,
	},
	"warp_dagger": {
		"charge_capable": false,
		"primary_damage": 7.0,
		"primary_knockback": 220.0,
		"primary_cooldown": 0.15,
		"primary_duration": 0.1,
		"secondary_damage": 14.0,
		"secondary_knockback": 380.0,
		"secondary_cooldown": 1.4,
		"secondary_duration": 0.15,
		"secondary_type": "blink",
		"blink_distance": 100.0,
		"speed_multiplier": 1.15,
		"charge_speed_mult": 1.0,
	},
	"bomb_flail": {
		"charge_capable": false,
		"primary_damage": 11.0,
		"primary_knockback": 350.0,
		"primary_cooldown": 0.45,
		"primary_duration": 0.25,
		"secondary_damage": 18.0,
		"secondary_knockback": 450.0,
		"secondary_cooldown": 1.6,
		"secondary_duration": 0.3,
		"secondary_type": "bomb",
		"bomb_radius": 60.0,
		"bomb_speed": 500.0,
		"bomb_range": 300.0,
		"speed_multiplier": 0.88,
		"charge_speed_mult": 1.0,
	},
	"plasma_cannon": {
		"charge_capable": false,
		"primary_damage": 6.0,
		"primary_knockback": 180.0,
		"primary_cooldown": 0.3,
		"primary_duration": 0.1,
		"secondary_damage": 4.0,
		"secondary_knockback": 100.0,
		"secondary_cooldown": 4.0,
		"secondary_duration": 1.5,
		"secondary_type": "laser",
		"laser_tick_rate": 0.33,
		"laser_range": 350.0,
		"projectile_speed": 700.0,
		"projectile_range": 350.0,
		"speed_multiplier": 0.95,
		"charge_speed_mult": 1.0,
	},
	"kunai_stars": {
		"charge_capable": false,
		"primary_damage": 7.0, "primary_knockback": 200.0,
		"primary_cooldown": 0.16, "primary_duration": 0.1,
		"secondary_damage": 6.0, "secondary_knockback": 260.0,
		"secondary_cooldown": 0.8, "secondary_duration": 0.1,
		"secondary_type": "multi_shot",
		"projectile_speed": 750.0, "projectile_range": 400.0,
		"fan_angle": 20.0,
		"speed_multiplier": 1.25, "charge_speed_mult": 1.0,
	},
	"vine_whip": {
		"charge_capable": false,
		"primary_damage": 11.0, "primary_knockback": 300.0,
		"primary_cooldown": 0.25, "primary_duration": 0.15,
		"secondary_damage": 9.0, "secondary_knockback": 200.0,
		"secondary_cooldown": 1.2, "secondary_duration": 0.2,
		"secondary_type": "pull",
		"pull_range": 250.0, "pull_force": 550.0,
		"speed_multiplier": 1.05, "charge_speed_mult": 1.0,
	},
	"iron_buckler": {
		"charge_capable": false,
		"primary_damage": 13.0, "primary_knockback": 380.0,
		"primary_cooldown": 0.3, "primary_duration": 0.15,
		"secondary_damage": 28.0, "secondary_knockback": 550.0,
		"secondary_cooldown": 1.5, "secondary_duration": 1.0,
		"secondary_type": "block",
		"speed_multiplier": 0.95, "charge_speed_mult": 1.0,
	},
	"spirit_bow": {
		"charge_capable": false,
		"primary_damage": 10.0, "primary_knockback": 260.0,
		"primary_cooldown": 0.28, "primary_duration": 0.1,
		"secondary_damage": 8.0, "secondary_knockback": 380.0,
		"secondary_cooldown": 1.6, "secondary_duration": 0.1,
		"secondary_type": "rain",
		"projectile_speed": 750.0, "projectile_range": 420.0,
		"rain_count": 4,
		"speed_multiplier": 1.1, "charge_speed_mult": 1.0,
	},
	"thunder_claws": {
		"charge_capable": false,
		"primary_damage": 8.0, "primary_knockback": 250.0,
		"primary_cooldown": 0.1, "primary_duration": 0.08,
		"secondary_damage": 18.0, "secondary_knockback": 420.0,
		"secondary_cooldown": 0.9, "secondary_duration": 0.12,
		"secondary_type": "dash",
		"dash_distance": 140.0, "dash_invuln_time": 0.15,
		"speed_multiplier": 1.15, "charge_speed_mult": 1.0,
	},
	"poison_fang": {
		"charge_capable": false,
		"primary_damage": 8.0, "primary_knockback": 240.0,
		"primary_cooldown": 0.15, "primary_duration": 0.1,
		"secondary_damage": 12.0, "secondary_knockback": 300.0,
		"secondary_cooldown": 1.0, "secondary_duration": 0.15,
		"secondary_type": "poison",
		"poison_dps": 3.5, "poison_duration": 4.0,
		"speed_multiplier": 1.15, "charge_speed_mult": 1.0,
	},
	"fire_greatsword": {
		"charge_capable": false,
		"primary_damage": 16.0, "primary_knockback": 400.0,
		"primary_cooldown": 0.35, "primary_duration": 0.2,
		"secondary_damage": 22.0, "secondary_knockback": 500.0,
		"secondary_cooldown": 1.1, "secondary_duration": 0.2,
		"secondary_type": "aoe",
		"aoe_radius": 85.0,
		"speed_multiplier": 0.95, "charge_speed_mult": 1.0,
	},
	"blood_scythe": {
		"charge_capable": false,
		"primary_damage": 14.0, "primary_knockback": 350.0,
		"primary_cooldown": 0.25, "primary_duration": 0.18,
		"secondary_damage": 22.0, "secondary_knockback": 420.0,
		"secondary_cooldown": 1.2, "secondary_duration": 0.18,
		"secondary_type": "lifesteal",
		"lifesteal_percent": 0.65,
		"speed_multiplier": 1.0, "charge_speed_mult": 1.0,
	},
	"gravity_orb": {
		"charge_capable": false,
		"primary_damage": 10.0, "primary_knockback": 280.0,
		"primary_cooldown": 0.28, "primary_duration": 0.1,
		"secondary_damage": 5.0, "secondary_knockback": 150.0,
		"secondary_cooldown": 2.5, "secondary_duration": 2.5,
		"secondary_type": "vortex",
		"vortex_pull_force": 450.0, "vortex_radius": 130.0,
		"projectile_speed": 650.0, "projectile_range": 380.0,
		"speed_multiplier": 0.95, "charge_speed_mult": 1.0,
	},
	"crystal_spear": {
		"charge_capable": false,
		"primary_damage": 13.0, "primary_knockback": 330.0,
		"primary_cooldown": 0.22, "primary_duration": 0.12,
		"secondary_damage": 30.0, "secondary_knockback": 620.0,
		"secondary_cooldown": 1.3, "secondary_duration": 0.2,
		"secondary_type": "impale",
		"impale_range": 180.0,
		"speed_multiplier": 1.05, "charge_speed_mult": 1.0,
	},
	"minato_kunai": {
		"charge_capable": false,
		"primary_damage": 9.0, "primary_knockback": 200.0,
		"primary_cooldown": 0.3, "primary_duration": 0.1,
		"secondary_damage": 18.0, "secondary_knockback": 400.0,
		"secondary_cooldown": 1.0, "secondary_duration": 0.15,
		"secondary_type": "blink",
		"blink_distance": 150.0,
		"projectile_speed": 700.0, "projectile_range": 450.0,
		"slow_duration": 0.0, "slow_amount": 1.0,
		"speed_multiplier": 1.2, "charge_speed_mult": 1.0,
	},
}

# --- Shared combat constants ---
const HITSTUN_TIME := 0.15
const INVULN_TIME := 0.5

# Super attack constants (opponent on head, RIGHT CLICK only)
const SUPER_HEAD_DY := -25.0  # opponent must be this far above
const SUPER_HEAD_DX := 20.0   # and this close horizontally

# Per-weapon super stats
const SUPER_STATS := {
	"fists": {"damage": 35.0, "knockback": 1200.0, "cooldown": 0.8},
	"thors_hammer": {"damage": 60.0, "knockback": 1800.0, "cooldown": 1.4, "windup": 0.55},
	"shadow_blade": {"damage": 40.0, "knockback": 1400.0, "cooldown": 1.0, "dash_dist": 200.0},
	"frost_staff": {"damage": 30.0, "knockback": 1100.0, "cooldown": 1.0, "freeze_time": 0.6},
	"dragon_gauntlets": {"damage": 45.0, "knockback": 1300.0, "cooldown": 0.9},
	"warp_dagger": {"damage": 45.0, "knockback": 1300.0, "cooldown": 1.0},
	"bomb_flail": {"damage": 55.0, "knockback": 1800.0, "cooldown": 1.2, "blast_radius": 120.0},
	"plasma_cannon": {"damage": 50.0, "knockback": 1500.0, "cooldown": 1.3},
	"kunai_stars": {"damage": 42.0, "knockback": 1300.0, "cooldown": 0.7},
	"vine_whip": {"damage": 48.0, "knockback": 1400.0, "cooldown": 0.8},
	"iron_buckler": {"damage": 55.0, "knockback": 1800.0, "cooldown": 0.9},
	"spirit_bow": {"damage": 58.0, "knockback": 1700.0, "cooldown": 0.9},
	"thunder_claws": {"damage": 62.0, "knockback": 1700.0, "cooldown": 0.8},
	"poison_fang": {"damage": 55.0, "knockback": 1500.0, "cooldown": 0.9},
	"fire_greatsword": {"damage": 70.0, "knockback": 2000.0, "cooldown": 1.0},
	"blood_scythe": {"damage": 65.0, "knockback": 1700.0, "cooldown": 1.0, "heal_percent": 0.4},
	"gravity_orb": {"damage": 68.0, "knockback": 2000.0, "cooldown": 1.0},
	"crystal_spear": {"damage": 75.0, "knockback": 2200.0, "cooldown": 1.0},
	"minato_kunai": {"damage": 55.0, "knockback": 1600.0, "cooldown": 0.9, "rasengan_radius": 70.0},
}

# --- Platform positions (for AI navigation) ---
const PLATFORMS := [
	{"pos": Vector2(0, 200), "half_w": 300.0},
	{"pos": Vector2(-180, 60), "half_w": 100.0},
	{"pos": Vector2(180, 60), "half_w": 100.0},
	{"pos": Vector2(0, -80), "half_w": 75.0},
]
const STAGE_CENTER := Vector2(0, 160)

# --- AI constants (base values, scaled by trophies) ---
const AI_ATTACK_RANGE := 45.0
const AI_CLOSE_RANGE := 80.0
const AI_BASE_REACTION_TIME := 0.12
const AI_BASE_RETREAT_TIME := 0.3

@export var is_ai: bool = false
@export var practice_mode: bool = false
var weapon_id: String = "thors_hammer"
var trophy_count: int = 0  # Set by Arena for AI difficulty scaling
var team_id: int = 0  # 0 = player's team, 1 = enemy team. Set by Arena.
var allies: Array = []   # other fighters on same team (set by Arena)
var enemies: Array = []  # fighters on opposing team (set by Arena)
var color_override: Dictionary = {}  # Team color override for AI in 2v2
var show_hair: bool = false  # Whether to display hair polygons
var frozen: bool = false
var laser_active: bool = false
var laser_timer: float = 0.0
var laser_tick_timer: float = 0.0
var _laser_beam_node: Polygon2D = null

# Block state (Iron Buckler)
var block_active: bool = false
var block_timer: float = 0.0

# Poison state (applied TO this fighter by opponent)
var poison_timer: float = 0.0
var poison_tick_timer: float = 0.0
var poison_dps: float = 0.0

# Vortex state (Gravity Orb)
var vortex_active: bool = false
var vortex_timer: float = 0.0
var vortex_position: Vector2 = Vector2.ZERO

# Lifesteal flag (Blood Scythe)
var lifesteal_active: bool = false

# --- State ---
var jump_count: int = 0
var facing_right: bool = true
var was_on_floor: bool = false
var coyote_timer: float = 0.0

# Combat state
var damage_percent: float = 0.0
var light_cooldown: float = 0.0
var heavy_cooldown: float = 0.0
var hitstun_timer: float = 0.0
var invuln_timer: float = 0.0
var attack_timer: float = 0.0
var is_attacking: bool = false
var current_attack: String = ""
var opponent: CharacterBody2D = null
var _current_attack_damage: float = 0.0
var _current_attack_knockback: float = 0.0

# Charge state (Thor's Hammer)
var is_charging: bool = false
var charge_time: float = 0.0
var charge_ratio: float = 0.0

# Dash state (Shadow Blade)
var is_dashing: bool = false
var dash_timer: float = 0.0
var dash_direction: float = 0.0
var dash_start_pos: float = 0.0

# Slow effect (from Frost Staff hits)
var slow_timer: float = 0.0
var slow_multiplier: float = 1.0

# Platform drop-through (hold S to fall through floating platforms)
var drop_through_timer: float = 0.0
const DROP_THROUGH_TIME := 0.25

# Super windup state (Thor's Hammer)
var is_super_winding: bool = false
var super_windup_timer: float = 0.0

# Weapon level multipliers (set in _ready from GameState)
var damage_mult: float = 1.0
var kb_mult: float = 1.0
var super_damage_mult: float = 1.0
var super_kb_mult: float = 1.0

# RAGE mode
const RAGE_DURATION := 8.0
const RAGE_SPEED_BONUS := 0.3
const RAGE_DAMAGE_BONUS := 0.2
const RAGE_MAX_JUMPS := 3
const RAGE_METER_MAX := 100.0
const RAGE_FILL_DEAL := 0.6
const RAGE_FILL_TAKE := 0.4
const RAGE_FILL_KO := 25.0

var rage_available: bool = false
var rage_meter: float = 0.0
var rage_active: bool = false
var rage_timer: float = 0.0
var rage_color: Color = Color(1.0, 0.3, 0.1)
var _rage_glow_node: Polygon2D = null
var _weapon_aura_node: Polygon2D = null
var _weapon_aura_color: Color = Color(0.4, 0.6, 1.0)

# Animation state
var _anim_time: float = 0.0
var _was_on_floor_last: bool = false
var _attack_tween: Tween = null
var _dash_ghost_timer: float = 0.0

# AI state
enum AIState { CHASE, ATTACK, RETREAT, RECOVER, EDGE_GUARD, CHARGE_ATTACK }
var ai_state: int = AIState.CHASE
var ai_input_dir: float = 0.0
var ai_wants_jump: bool = false
var ai_wants_light: bool = false
var ai_wants_heavy: bool = false
var ai_wants_light_held: bool = false
var ai_wants_light_released: bool = false
var ai_charge_target_time: float = 0.0
var ai_charge_timer: float = 0.0
var ai_reaction_timer: float = 0.0
var ai_retreat_timer: float = 0.0
var ai_jump_cooldown: float = 0.0
var ai_action_timer: float = 0.0

@onready var visuals: Node2D = $Visuals
@onready var attack_area: Area2D = $AttackArea
@onready var attack_shape: CollisionShape2D = $AttackArea/CollisionShape2D
@onready var attack_visual: Node2D = $Visuals/AttackVisual


func _ready() -> void:
	attack_shape.set_deferred("disabled", true)
	attack_visual.visible = false
	attack_area.body_entered.connect(_on_attack_hit)
	_update_weapon_visuals()
	# Hide hair by default — body skins re-show the nodes they reshape
	show_hair = false
	_apply_hair_visibility()
	_apply_skins()
	# Enable collision with floating platforms (layer 2)
	set_collision_mask_value(2, true)
	# Weapon level scaling (player only, AI stays at 1.0)
	if not is_ai:
		damage_mult = GameState.get_damage_multiplier(weapon_id)
		kb_mult = GameState.get_knockback_multiplier(weapon_id)
		super_damage_mult = GameState.get_super_damage_multiplier(weapon_id)
		super_kb_mult = GameState.get_super_knockback_multiplier(weapon_id)
		rage_available = GameState.has_rage(weapon_id)
		rage_color = GameState.get_rage_color()
		_create_weapon_aura()


func _physics_process(delta: float) -> void:
	if not is_inside_tree():
		return
	# Frozen: only apply gravity and floor collision, no actions
	if frozen:
		_apply_gravity(delta)
		velocity.x = 0.0
		move_and_slide()
		_animate(delta)
		return

	# Update timers
	light_cooldown = maxf(light_cooldown - delta, 0.0)
	heavy_cooldown = maxf(heavy_cooldown - delta, 0.0)
	# Rage = infinite supers (no heavy cooldown)
	if rage_active:
		heavy_cooldown = 0.0
	hitstun_timer = maxf(hitstun_timer - delta, 0.0)
	invuln_timer = maxf(invuln_timer - delta, 0.0)
	ai_jump_cooldown = maxf(ai_jump_cooldown - delta, 0.0)

	# Slow effect timer
	if slow_timer > 0.0:
		slow_timer -= delta
		if slow_timer <= 0.0:
			slow_multiplier = 1.0

	# Invuln flash
	if invuln_timer > 0.0:
		visuals.modulate.a = 0.5 + 0.5 * sin(invuln_timer * 20.0)
	else:
		visuals.modulate.a = 1.0

	# RAGE timer tick
	if rage_active:
		rage_timer -= delta
		if rage_timer <= 0.0:
			_deactivate_rage()
		else:
			_update_rage_glow()

	# Laser beam update
	if laser_active:
		_update_laser_beam(delta)

	# Block timer update
	_update_block(delta)

	# Poison DOT update
	_update_poison_dot(delta)

	# Vortex update
	if vortex_active:
		_update_vortex(delta)

	# Handle Thor's Hammer super windup
	if is_super_winding:
		super_windup_timer -= delta
		# Slow movement during windup
		velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta * 2.0)
		if super_windup_timer <= 0.0:
			_execute_thor_super_slam()
			is_super_winding = false

	# Handle active attack timing
	if is_attacking and not is_dashing:
		attack_timer -= delta
		if attack_timer <= 0.0:
			_end_attack()

	# Handle active dash (Shadow Blade)
	if is_dashing:
		dash_timer -= delta
		invuln_timer = maxf(invuln_timer, delta)
		velocity = Vector2(dash_direction * 800.0, 0.0)
		move_and_slide()
		# Spawn dash afterimages
		_dash_ghost_timer -= delta
		if _dash_ghost_timer <= 0.0:
			_spawn_dash_ghost()
			_dash_ghost_timer = 0.04
		var traveled := absf(global_position.x - dash_start_pos)
		if dash_timer <= 0.0 or traveled >= 120.0:
			is_dashing = false
			_end_attack()
		_animate(delta)
		return

	# If in hitstun, can't act (also cancel charge)
	if hitstun_timer > 0.0:
		if is_charging:
			is_charging = false
			_update_charge_glow()
		_apply_gravity(delta)
		move_and_slide()
		_check_landing()
		_animate(delta)
		return

	# Get input (player or AI)
	if is_ai:
		_run_ai_brain(delta)

	var input_dir := _get_input_dir()
	var wants_jump := _get_jump_input()

	# RAGE activation (press E when meter full)
	if rage_available and not rage_active and rage_meter >= RAGE_METER_MAX:
		if not is_ai and Input.is_action_just_pressed("fighter_rage"):
			_activate_rage()

	# Apply physics
	_apply_gravity(delta)

	# Platform drop-through: hold S/Down to fall through floating platforms (NOT main stage)
	if drop_through_timer > 0.0:
		drop_through_timer -= delta
		if drop_through_timer <= 0.0:
			set_collision_mask_value(2, true)
	elif _get_down_held() and _is_on_floating_platform():
		set_collision_mask_value(2, false)
		drop_through_timer = DROP_THROUGH_TIME
		position.y += 6.0
		velocity.y = 80.0

	# Jump (triple jump during RAGE)
	var max_jumps := RAGE_MAX_JUMPS if rage_active else MAX_JUMPS
	if wants_jump and jump_count < max_jumps:
		_spawn_dust(global_position + Vector2(0, 4))
		velocity.y = JUMP_VELOCITY
		jump_count += 1

	# Horizontal movement (slowed during charge, boosted by weapon passive, reduced by slow debuff)
	var speed_mult := 1.0
	if is_charging:
		speed_mult = WEAPONS[weapon_id].get("charge_speed_mult", 1.0)
	speed_mult *= WEAPONS[weapon_id].get("speed_multiplier", 1.0)
	speed_mult *= slow_multiplier
	if rage_active:
		speed_mult *= (1.0 + RAGE_SPEED_BONUS)

	if input_dir != 0.0:
		var accel := ACCELERATION if is_on_floor() else AIR_ACCELERATION
		velocity.x = move_toward(velocity.x, input_dir * MOVE_SPEED * speed_mult, accel * delta)
	else:
		var fric := FRICTION if is_on_floor() else AIR_FRICTION
		velocity.x = move_toward(velocity.x, 0.0, fric * delta)

	# Facing
	if input_dir > 0.0 and not facing_right:
		facing_right = true
		visuals.scale.x = 1.0
	elif input_dir < 0.0 and facing_right:
		facing_right = false
		visuals.scale.x = -1.0

	# Attacks
	if not is_attacking:
		# Super attack: right-click when opponent is on our head
		if _is_opponent_on_head() and _get_heavy_input() and heavy_cooldown <= 0.0:
			_execute_super_attack()
		else:
			var wpn: Dictionary = WEAPONS[weapon_id]
			if wpn.get("charge_capable", false):
				_handle_charge_weapon(delta, wpn)
			else:
				_handle_simple_weapon(wpn)

	# Update charge glow visual
	_update_charge_glow()

	move_and_slide()
	_check_landing()
	_animate(delta)


# --- Input helpers ---

func _get_input_dir() -> float:
	if is_ai:
		return ai_input_dir
	return Input.get_axis("fighter_left", "fighter_right")


func _get_jump_input() -> bool:
	if is_ai:
		var val := ai_wants_jump
		ai_wants_jump = false
		return val
	return Input.is_action_just_pressed("fighter_jump")


func _get_light_input() -> bool:
	if is_ai:
		var val := ai_wants_light
		ai_wants_light = false
		return val
	return Input.is_action_just_pressed("fighter_light")


func _get_light_held() -> bool:
	if is_ai:
		return ai_wants_light_held
	return Input.is_action_pressed("fighter_light")


func _get_light_just_released() -> bool:
	if is_ai:
		var val := ai_wants_light_released
		ai_wants_light_released = false
		return val
	return Input.is_action_just_released("fighter_light")


func _get_heavy_input() -> bool:
	if is_ai:
		var val := ai_wants_heavy
		ai_wants_heavy = false
		return val
	return Input.is_action_just_pressed("fighter_heavy")


func _get_down_held() -> bool:
	if is_ai:
		return false  # AI doesn't drop through platforms
	return Input.is_action_pressed("fighter_down")


func _is_on_floating_platform() -> bool:
	if not is_on_floor():
		return false
	# Check if any floor collision is with a layer-2 body (floating platform)
	for i in range(get_slide_collision_count()):
		var collision := get_slide_collision(i)
		var collider := collision.get_collider()
		if collider is StaticBody2D and collider.get_collision_layer_value(2):
			return true
	return false


# --- Weapon attack handlers ---

func _handle_simple_weapon(wpn: Dictionary) -> void:
	var wants_light := _get_light_input()
	var wants_heavy := _get_heavy_input()

	if wants_light and light_cooldown <= 0.0:
		if weapon_id in ["frost_staff", "plasma_cannon", "kunai_stars", "spirit_bow", "gravity_orb", "minato_kunai"]:
			_fire_projectile(wpn)
			light_cooldown = wpn["primary_cooldown"]
		else:
			_start_attack_with_values("light", wpn["primary_damage"], wpn["primary_knockback"], wpn["primary_duration"], wpn["primary_cooldown"])
	elif wants_heavy and heavy_cooldown <= 0.0:
		var sec_type: String = wpn.get("secondary_type", "normal")
		match sec_type:
			"dash":
				_execute_dash(wpn)
			"aoe":
				_execute_frost_nova(wpn)
			"uppercut":
				_execute_uppercut(wpn)
			"blink":
				_execute_blink(wpn)
			"bomb":
				_execute_bomb_toss(wpn)
			"laser":
				_execute_laser(wpn)
			"multi_shot":
				_execute_multi_shot(wpn)
			"pull":
				_execute_pull(wpn)
			"block":
				_execute_block(wpn)
			"rain":
				_execute_rain(wpn)
			"poison":
				_execute_poison(wpn)
			"lifesteal":
				_execute_lifesteal(wpn)
			"vortex":
				_execute_vortex(wpn)
			"impale":
				_execute_impale(wpn)
			_:
				_start_attack_with_values("heavy", wpn["secondary_damage"], wpn["secondary_knockback"], wpn["secondary_duration"], wpn["secondary_cooldown"])


func _handle_charge_weapon(delta: float, wpn: Dictionary) -> void:
	if is_charging:
		charge_time = minf(charge_time + delta, wpn["max_charge_time"])
		charge_ratio = charge_time / wpn["max_charge_time"]
		if _get_light_just_released() or not _get_light_held():
			_execute_charge_attack(wpn)
	else:
		var wants_light := _get_light_input()
		var wants_heavy := _get_heavy_input()
		if wants_light and light_cooldown <= 0.0:
			is_charging = true
			charge_time = 0.0
			charge_ratio = 0.0
		elif wants_heavy and heavy_cooldown <= 0.0:
			_start_attack_with_values("secondary", wpn["secondary_damage"], wpn["secondary_knockback"], wpn["secondary_duration"], wpn["secondary_cooldown"])


func _execute_charge_attack(wpn: Dictionary) -> void:
	is_charging = false
	var t := charge_ratio
	var dmg := lerpf(wpn["min_damage"], wpn["max_damage"], t)
	var kb := lerpf(wpn["min_knockback"], wpn["max_knockback"], t)
	_start_attack_with_values("charged", dmg, kb, wpn["primary_duration"], wpn["primary_cooldown"])


# --- Special abilities ---

func _is_opponent_on_head() -> bool:
	if not is_instance_valid(opponent):
		return false
	var dy := opponent.global_position.y - global_position.y
	var dx_abs := absf(opponent.global_position.x - global_position.x)
	return dy < SUPER_HEAD_DY and dx_abs < SUPER_HEAD_DX


func _execute_super_attack() -> void:
	if get_parent() == null or get_tree() == null:
		return
	_doing_super = true
	var stats: Dictionary = SUPER_STATS.get(weapon_id, {"damage": 35.0, "knockback": 1200.0, "cooldown": 0.8})
	heavy_cooldown = stats["cooldown"]
	light_cooldown = stats["cooldown"]

	match weapon_id:
		"thors_hammer":
			_super_thors_hammer(stats)
		"shadow_blade":
			_super_shadow_blade(stats)
		"frost_staff":
			_super_frost_staff(stats)
		"dragon_gauntlets":
			_super_dragon_gauntlets(stats)
		"warp_dagger":
			_super_warp_dagger(stats)
		"bomb_flail":
			_super_bomb_flail(stats)
		"plasma_cannon":
			_super_plasma_cannon(stats)
		"kunai_stars":
			_super_kunai_stars(stats)
		"vine_whip":
			_super_vine_whip(stats)
		"iron_buckler":
			_super_iron_buckler(stats)
		"spirit_bow":
			_super_spirit_bow(stats)
		"thunder_claws":
			_super_thunder_claws(stats)
		"poison_fang":
			_super_poison_fang(stats)
		"fire_greatsword":
			_super_fire_greatsword(stats)
		"blood_scythe":
			_super_blood_scythe(stats)
		"gravity_orb":
			_super_gravity_orb(stats)
		"crystal_spear":
			_super_crystal_spear(stats)
		"minato_kunai":
			_super_minato_kunai(stats)
		_:
			_super_fists(stats)
	_doing_super = false


# --- FISTS SUPER: Sky Uppercut ---
func _super_fists(stats: Dictionary) -> void:
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var hit_pos := (global_position + opponent.global_position) * 0.5
		_spawn_super_burst(hit_pos)
		_spawn_hit_spark(hit_pos)
		var rage_mult := 1.5 if rage_active else 1.0
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, Vector2(0, -1), stats["knockback"] * super_kb_mult * rage_mult)
	# Small self-hop for impact feel
	velocity.y = -200.0
	_anim_attack_swing()


# --- THOR'S HAMMER SUPER: Mjolnir Slam (slow windup → massive slam + ground shockwave) ---
func _super_thors_hammer(stats: Dictionary) -> void:
	is_super_winding = true
	super_windup_timer = stats.get("windup", 0.55)
	_anim_thor_windup()


func _execute_thor_super_slam() -> void:
	var stats: Dictionary = SUPER_STATS.get("thors_hammer", {"damage": 60.0, "knockback": 1800.0})
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var face_dir := 1.0 if facing_right else -1.0
		var hit_pos := (global_position + opponent.global_position) * 0.5
		_spawn_super_burst(hit_pos)
		_spawn_super_burst(hit_pos + Vector2(0, -15))
		_spawn_hit_spark(hit_pos)
		_spawn_thor_ground_shockwave()
		var kb_dir := Vector2(face_dir * 0.6, -1.0).normalized()
		var rage_mult := 1.5 if rage_active else 1.0
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	_anim_thor_slam()


# --- SHADOW BLADE SUPER: Phantom Slash (teleport behind + cross-slash) ---
func _super_shadow_blade(stats: Dictionary) -> void:
	if not is_instance_valid(opponent):
		return
	var face_dir := 1.0 if facing_right else -1.0

	# Spawn afterimage trail at start
	for i in range(5):
		_spawn_dash_ghost()

	# Teleport behind opponent
	var behind_x := opponent.global_position.x + (-face_dir * 40.0)
	global_position = Vector2(behind_x, opponent.global_position.y)

	# Flip to face opponent
	facing_right = global_position.x < opponent.global_position.x
	visuals.scale.x = 1.0 if facing_right else -1.0

	# Spawn more ghosts at arrival
	for i in range(3):
		_spawn_dash_ghost()

	# Cross-slash VFX
	_spawn_shadow_cross_slash(opponent.global_position)
	_spawn_hit_spark(opponent.global_position)

	if opponent.has_method("take_hit"):
		var slash_dir := (opponent.global_position - global_position).normalized()
		if slash_dir.length_squared() < 0.01:
			slash_dir = Vector2(face_dir, -0.5).normalized()
		slash_dir.y = minf(slash_dir.y, -0.3)
		slash_dir = slash_dir.normalized()
		var rage_mult := 1.5 if rage_active else 1.0
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, slash_dir, stats["knockback"] * super_kb_mult * rage_mult)

	_anim_attack_swing()


# --- FROST STAFF SUPER: Blizzard Burst (freeze + ice explosion) ---
func _super_frost_staff(stats: Dictionary) -> void:
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var hit_pos := (global_position + opponent.global_position) * 0.5
		# Freeze effect first
		if opponent.has_method("apply_slow"):
			opponent.apply_slow(stats.get("freeze_time", 0.6), 0.1)
		# Ice explosion VFX
		_spawn_super_burst(hit_pos)
		_spawn_frost_explosion(hit_pos)
		_spawn_nova_ring(100.0)
		# Launch them
		var face_dir := 1.0 if facing_right else -1.0
		var kb_dir := Vector2(face_dir * 0.4, -1.0).normalized()
		var rage_mult := 1.5 if rage_active else 1.0
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)

	_anim_attack_swing()


# --- DRAGON GAUNTLETS SUPER: Dragon Frenzy (rapid hits + fire uppercut) ---
func _super_dragon_gauntlets(stats: Dictionary) -> void:
	if not is_instance_valid(opponent) or not opponent.has_method("take_hit"):
		_anim_attack_swing()
		return

	var face_dir := 1.0 if facing_right else -1.0

	# 3 rapid hits in quick succession then a big uppercut
	var hit_pos := (global_position + opponent.global_position) * 0.5

	# Rapid small hits (visual frenzy) — more hits during RAGE
	var rage_mult := 1.5 if rage_active else 1.0
	var rapid_count := 5 if rage_active else 3
	for i in range(rapid_count):
		_spawn_hit_spark(hit_pos + Vector2(randf_range(-10, 10), randf_range(-10, 10)))
		opponent.take_hit(5.0 * super_damage_mult * rage_mult, Vector2(face_dir * 0.5, -0.2).normalized(), 80.0 * super_kb_mult)

	# Big fire uppercut finale
	_spawn_super_burst(hit_pos)
	_spawn_dragon_fire_burst(hit_pos)
	var kb_dir := Vector2(face_dir * 0.3, -1.0).normalized()
	opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)

	# Self hop from the uppercut
	velocity.y = -300.0
	_anim_attack_swing()


# --- WARP DAGGER SUPER: Dimension Swap ---
func _super_warp_dagger(stats: Dictionary) -> void:
	if not is_instance_valid(opponent) or not opponent.has_method("take_hit"):
		_anim_attack_swing()
		return
	var rage_mult := 1.5 if rage_active else 1.0
	# Store positions
	var my_pos := global_position
	var opp_pos := opponent.global_position
	# Swap positions
	global_position = opp_pos
	opponent.global_position = my_pos
	# Spawn warp VFX at both positions
	_spawn_warp_circle(my_pos)
	_spawn_warp_circle(opp_pos)
	_spawn_super_burst((my_pos + opp_pos) * 0.5)
	# Deal damage
	var face_dir := 1.0 if facing_right else -1.0
	var kb_dir := Vector2(face_dir, -0.3).normalized()
	opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	_anim_attack_swing()


func _spawn_warp_circle(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(16):
		var angle := float(i) / 16.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 6.0)
	ring.polygon = pts
	ring.color = Color(0.9, 0.2, 0.7, 0.8)
	ring.global_position = pos
	parent.add_child(ring)
	var tw := _safe_create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2.ONE * 8.0, 0.35).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, 0.4)
	tw.chain().tween_callback(ring.queue_free)


# --- BOMB FLAIL SUPER: Mega Bomb ---
func _super_bomb_flail(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	var blast_radius: float = stats.get("blast_radius", 120.0)
	# Spawn massive explosion VFX
	_spawn_explosion_ring(global_position, blast_radius)
	_spawn_super_burst(global_position)
	# Damage opponent if in range
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var dist := global_position.distance_to(opponent.global_position)
		if dist <= blast_radius:
			var push_dir := (opponent.global_position - global_position).normalized()
			if push_dir.length_squared() < 0.01:
				push_dir = Vector2(1.0 if facing_right else -1.0, -0.5).normalized()
			opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, push_dir, stats["knockback"] * super_kb_mult * rage_mult)
	_anim_attack_swing()


func _spawn_explosion_ring(pos: Vector2, col_or_radius = null, radius_arg: float = 0.0) -> void:
	# Supports both old calls: (pos, radius) and new calls: (pos, color, radius)
	var ring_color := Color(1.0, 0.5, 0.1, 0.7)
	var radius: float = 60.0
	if col_or_radius is Color:
		ring_color = col_or_radius
		radius = radius_arg
	elif col_or_radius is float:
		radius = col_or_radius
	var parent := get_parent()
	if parent == null:
		return
	# Outer explosion ring
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(20):
		var angle := float(i) / 20.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 8.0)
	ring.polygon = pts
	ring.color = ring_color
	ring.global_position = pos
	parent.add_child(ring)
	var target_scale := radius / 8.0
	var tw := _safe_create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2.ONE * target_scale, 0.3).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, 0.5)
	tw.chain().tween_callback(ring.queue_free)
	# Inner fire burst
	for i in range(8):
		var flame := Polygon2D.new()
		flame.polygon = PackedVector2Array([Vector2(-4, 3), Vector2(0, -6), Vector2(4, 3)])
		flame.color = Color(1.0, randf_range(0.3, 0.7), 0.0, 0.9)
		flame.global_position = pos
		parent.add_child(flame)
		var fangle := randf() * TAU
		var target := pos + Vector2(cos(fangle), sin(fangle)) * randf_range(20.0, radius * 0.8)
		var ftw := _safe_create_tween()
		ftw.set_parallel(true)
		ftw.tween_property(flame, "global_position", target, 0.25).set_ease(Tween.EASE_OUT)
		ftw.tween_property(flame, "modulate:a", 0.0, 0.3)
		ftw.chain().tween_callback(flame.queue_free)


# --- PLASMA CANNON SUPER: Omega Beam ---
func _super_plasma_cannon(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	var face_dir := 1.0 if facing_right else -1.0
	# Spawn thick laser beam visual
	_spawn_omega_beam(face_dir)
	# Damage opponent if in line
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var dx := opponent.global_position.x - global_position.x
		var dy_abs := absf(opponent.global_position.y - global_position.y)
		var in_direction := (dx > 0.0 and face_dir > 0.0) or (dx < 0.0 and face_dir < 0.0)
		if in_direction and absf(dx) <= 400.0 and dy_abs <= 40.0:
			var kb_dir := Vector2(face_dir, -0.2).normalized()
			opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	_anim_attack_swing()


func _spawn_omega_beam(face_dir: float) -> void:
	var parent := get_parent()
	if parent == null:
		return
	var beam := Polygon2D.new()
	beam.polygon = PackedVector2Array([
		Vector2(0, -8), Vector2(400, -6), Vector2(400, 6), Vector2(0, 8)
	])
	beam.color = Color(0.2, 0.9, 1.0, 0.8)
	beam.global_position = global_position + Vector2(face_dir * 20.0, 0.0)
	beam.scale.x = face_dir
	parent.add_child(beam)
	var tw := _safe_create_tween()
	tw.tween_property(beam, "modulate:a", 0.0, 0.4)
	tw.chain().tween_callback(beam.queue_free)
	# Core beam (brighter, thinner)
	var core := Polygon2D.new()
	core.polygon = PackedVector2Array([
		Vector2(0, -3), Vector2(400, -2), Vector2(400, 2), Vector2(0, 3)
	])
	core.color = Color(0.8, 1.0, 1.0, 0.9)
	core.global_position = beam.global_position
	core.scale.x = face_dir
	parent.add_child(core)
	var tw2 := _safe_create_tween()
	tw2.tween_property(core, "modulate:a", 0.0, 0.35)
	tw2.chain().tween_callback(core.queue_free)


# --- KUNAI STARS SUPER: Kunai Storm ---
func _super_kunai_stars(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var kb_dir := (opponent.global_position - global_position).normalized()
		if kb_dir.length() < 0.1:
			kb_dir = Vector2(1.0 if facing_right else -1.0, -0.3).normalized()
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	# Rain VFX - spawn falling stars
	for i in range(8):
		var vfx := Polygon2D.new()
		vfx.color = Color(0.8, 0.8, 0.85, 0.7)
		vfx.polygon = PackedVector2Array([Vector2(0, -4), Vector2(2, 0), Vector2(0, 4), Vector2(-2, 0)])
		vfx.global_position = global_position + Vector2(randf_range(-80.0, 80.0), -100.0 - randf() * 60.0)
		get_parent().add_child(vfx)
		var tw := _safe_create_tween()
		tw.tween_property(vfx, "global_position:y", global_position.y + 20.0, 0.3 + randf() * 0.2)
		tw.parallel().tween_property(vfx, "modulate:a", 0.0, 0.4)
		tw.tween_callback(vfx.queue_free)
	_anim_attack_swing()


# --- VINE WHIP SUPER: Thorn Prison ---
func _super_vine_whip(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var kb_dir := Vector2(0, -1).normalized()
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	# Vine eruption VFX
	for i in range(5):
		var vine := Polygon2D.new()
		vine.color = Color(0.3, 0.8, 0.2, 0.6)
		vine.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -30), Vector2(2, 0)])
		vine.global_position = global_position + Vector2((i - 2) * 20.0, 10.0)
		get_parent().add_child(vine)
		var tw := _safe_create_tween()
		tw.tween_property(vine, "scale", Vector2(1.0, 2.0), 0.3).from(Vector2(1.0, 0.0))
		tw.tween_property(vine, "modulate:a", 0.0, 0.3)
		tw.tween_callback(vine.queue_free)
	_anim_attack_swing()


# --- IRON BUCKLER SUPER: Fortress Slam ---
func _super_iron_buckler(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var kb_dir := (opponent.global_position - global_position).normalized()
		if kb_dir.length() < 0.1:
			kb_dir = Vector2(1.0 if facing_right else -1.0, -0.3).normalized()
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	_spawn_explosion_ring(global_position, Color(0.5, 0.55, 0.7, 0.6), 80.0)
	_anim_attack_swing()


# --- SPIRIT BOW SUPER: Divine Arrow ---
func _super_spirit_bow(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	var face_dir := 1.0 if facing_right else -1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var dx := opponent.global_position.x - global_position.x
		var dy_abs := absf(opponent.global_position.y - global_position.y)
		var in_direction := (dx > 0.0 and face_dir > 0.0) or (dx < 0.0 and face_dir < 0.0)
		if in_direction and absf(dx) <= 400.0 and dy_abs <= 50.0:
			var kb_dir := Vector2(face_dir, -0.3).normalized()
			opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	# Golden arrow beam VFX
	var arrow := Polygon2D.new()
	arrow.polygon = PackedVector2Array([Vector2(0, -4), Vector2(350, -2), Vector2(350, 2), Vector2(0, 4)])
	arrow.color = Color(1.0, 0.9, 0.5, 0.8)
	arrow.global_position = global_position + Vector2(face_dir * 15.0, -4.0)
	arrow.scale.x = face_dir
	get_parent().add_child(arrow)
	var tw := _safe_create_tween()
	tw.tween_property(arrow, "modulate:a", 0.0, 0.4)
	tw.tween_callback(arrow.queue_free)
	_anim_attack_swing()


# --- THUNDER CLAWS SUPER: Lightning Storm ---
func _super_thunder_claws(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var kb_dir := Vector2(0, -1).normalized()
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	# Lightning bolt VFX
	for i in range(3):
		var bolt := Polygon2D.new()
		bolt.color = Color(1.0, 1.0, 0.3, 0.8)
		bolt.polygon = PackedVector2Array([Vector2(-2, -60), Vector2(2, -60), Vector2(4, 0), Vector2(-4, 0)])
		bolt.global_position = global_position + Vector2((i - 1) * 25.0, -20.0)
		get_parent().add_child(bolt)
		var tw := _safe_create_tween()
		tw.tween_interval(0.1 * i)
		tw.tween_property(bolt, "modulate:a", 0.0, 0.2)
		tw.tween_callback(bolt.queue_free)
	_anim_attack_swing()


# --- POISON FANG SUPER: Venom Burst ---
func _super_poison_fang(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var kb_dir := (opponent.global_position - global_position).normalized()
		if kb_dir.length() < 0.1:
			kb_dir = Vector2(1.0 if facing_right else -1.0, -0.3).normalized()
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
		if opponent.has_method("apply_poison"):
			opponent.apply_poison(4.0, 3.0)
	_spawn_explosion_ring(global_position, Color(0.4, 0.9, 0.15, 0.5), 70.0)
	_anim_attack_swing()


# --- FIRE GREATSWORD SUPER: Inferno Slash ---
func _super_fire_greatsword(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	var face_dir := 1.0 if facing_right else -1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var kb_dir := Vector2(face_dir, -0.4).normalized()
		var dist := absf(opponent.global_position.x - global_position.x)
		if dist <= 180.0:
			opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	# Fire wave VFX
	var wave := Polygon2D.new()
	wave.polygon = PackedVector2Array([Vector2(0, -12), Vector2(180, -6), Vector2(180, 6), Vector2(0, 12)])
	wave.color = Color(1.0, 0.4, 0.1, 0.7)
	wave.global_position = global_position + Vector2(face_dir * 10.0, 0.0)
	wave.scale.x = face_dir
	get_parent().add_child(wave)
	var tw := _safe_create_tween()
	tw.tween_property(wave, "modulate:a", 0.0, 0.4)
	tw.tween_callback(wave.queue_free)
	_anim_attack_swing()


# --- BLOOD SCYTHE SUPER: Soul Harvest ---
func _super_blood_scythe(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var kb_dir := (opponent.global_position - global_position).normalized()
		if kb_dir.length() < 0.1:
			kb_dir = Vector2(1.0 if facing_right else -1.0, -0.3).normalized()
		var dmg: float = stats["damage"] * super_damage_mult * rage_mult
		opponent.take_hit(dmg, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
		# Heal self
		var heal_pct: float = stats.get("heal_percent", 0.3)
		damage_percent = maxf(0.0, damage_percent - dmg * heal_pct)
	_spawn_explosion_ring(global_position, Color(0.7, 0.1, 0.15, 0.5), 70.0)
	_anim_attack_swing()


# --- GRAVITY ORB SUPER: Black Hole ---
func _super_gravity_orb(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		# Pull opponent to self then damage
		var pull_dir := (global_position - opponent.global_position).normalized()
		opponent.velocity = pull_dir * 600.0
		var kb_dir := Vector2(0, -1).normalized()
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	_spawn_explosion_ring(global_position, Color(0.4, 0.1, 0.6, 0.6), 100.0)
	_anim_attack_swing()


# --- CRYSTAL SPEAR SUPER: Crystal Shatter ---
func _super_crystal_spear(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var kb_dir := (opponent.global_position - global_position).normalized()
		if kb_dir.length() < 0.1:
			kb_dir = Vector2(1.0 if facing_right else -1.0, -0.3).normalized()
		opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	# Crystal shard explosion VFX
	for i in range(6):
		var shard := Polygon2D.new()
		shard.color = Color(0.5, 0.7, 1.0, 0.7)
		shard.polygon = PackedVector2Array([Vector2(0, -6), Vector2(3, 0), Vector2(0, 6), Vector2(-3, 0)])
		shard.global_position = global_position
		get_parent().add_child(shard)
		var angle: float = i * (TAU / 6.0)
		var target_pos := global_position + Vector2(cos(angle) * 80.0, sin(angle) * 80.0)
		var tw := _safe_create_tween()
		tw.tween_property(shard, "global_position", target_pos, 0.3)
		tw.parallel().tween_property(shard, "modulate:a", 0.0, 0.35)
		tw.tween_callback(shard.queue_free)
	_anim_attack_swing()


# --- MINATO KUNAI SUPER: Rasengan (teleport behind opponent + massive spiral burst) ---
func _super_minato_kunai(stats: Dictionary) -> void:
	var rage_mult := 1.5 if rage_active else 1.0
	if not is_instance_valid(opponent) or not opponent.has_method("take_hit"):
		_anim_attack_swing()
		return
	var parent := get_parent()
	if parent == null:
		return
	# Teleport behind opponent (yellow flash)
	var opp_face: float = -1.0 if opponent.facing_right else 1.0
	var old_pos := global_position
	global_position = opponent.global_position + Vector2(opp_face * 30.0, 0.0)
	facing_right = opp_face < 0.0
	# Yellow flash VFX at old and new position
	_spawn_minato_flash(old_pos)
	_spawn_minato_flash(global_position)
	# Rasengan spiral VFX
	var rasengan_radius: float = stats.get("rasengan_radius", 70.0)
	_spawn_rasengan_vfx(opponent.global_position, rasengan_radius)
	# Deal massive damage
	var face_dir := 1.0 if facing_right else -1.0
	var kb_dir := Vector2(face_dir, -0.4).normalized()
	opponent.take_hit(stats["damage"] * super_damage_mult * rage_mult, kb_dir, stats["knockback"] * super_kb_mult * rage_mult)
	_spawn_super_burst(opponent.global_position)
	_anim_attack_swing()


func _spawn_minato_flash(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Yellow flash circle
	var flash := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(12):
		var angle := float(i) / 12.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 15.0)
	flash.polygon = pts
	flash.color = Color(1.0, 0.9, 0.2, 0.8)
	flash.global_position = pos
	parent.add_child(flash)
	var tw := _safe_create_tween()
	tw.tween_property(flash, "scale", Vector2(3.0, 3.0), 0.2)
	tw.parallel().tween_property(flash, "modulate:a", 0.0, 0.25)
	tw.tween_callback(flash.queue_free)


func _spawn_rasengan_vfx(pos: Vector2, radius: float) -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Spinning blue energy sphere
	for ring_i in range(3):
		var ring := Polygon2D.new()
		var ring_pts := PackedVector2Array()
		var r := radius * (0.4 + ring_i * 0.3)
		for i in range(16):
			var angle := float(i) / 16.0 * TAU + ring_i * 0.5
			ring_pts.append(Vector2(cos(angle), sin(angle)) * r)
		ring.polygon = ring_pts
		ring.color = Color(0.3, 0.6, 1.0, 0.5 - ring_i * 0.12)
		ring.global_position = pos
		parent.add_child(ring)
		var tw := _safe_create_tween()
		tw.tween_property(ring, "rotation", TAU * (2 - ring_i), 0.4)
		tw.parallel().tween_property(ring, "scale", Vector2(1.5, 1.5), 0.4)
		tw.parallel().tween_property(ring, "modulate:a", 0.0, 0.45)
		tw.tween_callback(ring.queue_free)


func _execute_dash(wpn: Dictionary) -> void:
	var face_dir := 1.0 if facing_right else -1.0
	is_dashing = true
	dash_timer = wpn.get("dash_invuln_time", 0.15)
	dash_direction = face_dir
	dash_start_pos = global_position.x
	invuln_timer = dash_timer
	_dash_ghost_timer = 0.0

	is_attacking = true
	current_attack = "dash"
	var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
	_current_attack_damage = wpn["secondary_damage"] * damage_mult * rage_dmg
	_current_attack_knockback = wpn["secondary_knockback"] * kb_mult
	attack_timer = dash_timer
	heavy_cooldown = wpn["secondary_cooldown"]

	attack_shape.set_deferred("disabled", false)
	attack_area.position = Vector2(face_dir * 10.0, 0.0)
	attack_shape.shape.size = Vector2(50, 30)
	attack_visual.visible = true
	attack_visual.position = attack_area.position
	attack_visual.scale.x = face_dir


func _fire_projectile(wpn: Dictionary) -> void:
	var parent := get_parent()
	if parent == null:
		return
	var face_dir := 1.0 if facing_right else -1.0
	var icicle_scene := preload("res://scenes/fighter/Icicle.tscn")
	var icicle := icicle_scene.instantiate()
	icicle.direction = face_dir
	var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
	icicle.damage = wpn["primary_damage"] * damage_mult * rage_dmg
	icicle.knockback = wpn["primary_knockback"] * kb_mult
	icicle.max_range = wpn.get("projectile_range", 400.0)
	icicle.speed = wpn.get("projectile_speed", 600.0)
	icicle.slow_duration = wpn.get("slow_duration", 0.5)
	icicle.slow_amount = wpn.get("slow_amount", 0.5)
	icicle.owner_fighter = self
	icicle.global_position = global_position + Vector2(face_dir * 20.0, -4.0)
	parent.add_child(icicle)


func _execute_frost_nova(wpn: Dictionary) -> void:
	heavy_cooldown = wpn["secondary_cooldown"]
	_spawn_nova_ring(wpn.get("aoe_radius", 80.0))

	var aoe_radius: float = wpn.get("aoe_radius", 80.0)
	var my_pos := global_position

	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var dist := my_pos.distance_to(opponent.global_position)
		if dist <= aoe_radius:
			var push_dir := (opponent.global_position - my_pos).normalized()
			if push_dir.length_squared() < 0.01:
				push_dir = Vector2(1.0 if facing_right else -1.0, -0.3).normalized()
			var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
			opponent.take_hit(wpn["secondary_damage"] * damage_mult * rage_dmg, push_dir, wpn["secondary_knockback"] * kb_mult)
			if opponent.has_method("apply_slow"):
				opponent.apply_slow(wpn.get("slow_duration", 0.5), wpn.get("slow_amount", 0.5))

	# Visual feedback
	is_attacking = true
	current_attack = "nova"
	attack_timer = wpn["secondary_duration"]
	_current_attack_damage = 0.0
	_current_attack_knockback = 0.0
	attack_shape.set_deferred("disabled", true)
	attack_visual.visible = true
	attack_visual.position = Vector2.ZERO


func _execute_uppercut(wpn: Dictionary) -> void:
	var face_dir := 1.0 if facing_right else -1.0

	is_attacking = true
	current_attack = "uppercut"
	_current_attack_damage = wpn["secondary_damage"]
	_current_attack_knockback = wpn["secondary_knockback"]
	attack_timer = wpn["secondary_duration"]
	heavy_cooldown = wpn["secondary_cooldown"]

	attack_shape.set_deferred("disabled", false)
	attack_area.position = Vector2(face_dir * 10.0, -20.0)
	attack_shape.shape.size = Vector2(28, 36)
	attack_visual.visible = true
	attack_visual.position = attack_area.position
	attack_visual.scale.x = face_dir

	# Small hop for the attacker
	velocity.y = wpn.get("uppercut_self_boost", -250.0)


# --- Warp Dagger Blink ---
func _execute_blink(wpn: Dictionary) -> void:
	var face_dir := 1.0 if facing_right else -1.0
	var blink_dist: float = wpn.get("blink_distance", 100.0)
	heavy_cooldown = wpn["secondary_cooldown"]

	# Spawn afterimage at old position
	_spawn_dash_ghost()

	# Teleport forward
	global_position.x += face_dir * blink_dist
	invuln_timer = 0.1

	# Attack at destination
	is_attacking = true
	current_attack = "blink"
	var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
	_current_attack_damage = wpn["secondary_damage"] * damage_mult * rage_dmg
	_current_attack_knockback = wpn["secondary_knockback"] * kb_mult
	attack_timer = wpn["secondary_duration"]

	attack_shape.set_deferred("disabled", false)
	attack_area.position = Vector2(face_dir * 10.0, 0.0)
	attack_shape.shape.size = Vector2(30, 30)
	attack_visual.visible = true
	attack_visual.position = attack_area.position
	attack_visual.scale.x = face_dir

	# Flash VFX at arrival
	_spawn_warp_circle(global_position)


# --- Bomb Flail Bomb Toss ---
func _execute_bomb_toss(wpn: Dictionary) -> void:
	heavy_cooldown = wpn["secondary_cooldown"]
	var face_dir := 1.0 if facing_right else -1.0
	var bomb_speed: float = wpn.get("bomb_speed", 500.0)
	var bomb_range: float = wpn.get("bomb_range", 300.0)
	var bomb_radius: float = wpn.get("bomb_radius", 60.0)
	var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
	var dmg: float = wpn["secondary_damage"] * damage_mult * rage_dmg
	var kb: float = wpn["secondary_knockback"] * kb_mult

	# Spawn bomb projectile (visual only, handle damage on arrival)
	var parent := get_parent()
	if parent == null:
		return
	var bomb := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(10):
		var angle := float(i) / 10.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 5.0)
	bomb.polygon = pts
	bomb.color = Color(0.3, 0.3, 0.3, 1.0)
	bomb.global_position = global_position + Vector2(face_dir * 15.0, -5.0)
	parent.add_child(bomb)

	var target_pos := bomb.global_position + Vector2(face_dir * bomb_range, 0.0)
	var travel_time := bomb_range / bomb_speed

	var tw := _safe_create_tween()
	tw.tween_property(bomb, "global_position", target_pos, travel_time).set_ease(Tween.EASE_OUT)
	# Capture variables for lambda
	var opp := opponent
	var my_dmg := dmg
	var my_kb := kb
	var my_radius := bomb_radius
	var my_dir := face_dir
	tw.chain().tween_callback(func() -> void:
		# Explode
		_spawn_explosion_ring(bomb.global_position, my_radius)
		# Check if opponent is in blast radius
		if opp and is_instance_valid(opp) and opp.has_method("take_hit"):
			var dist := bomb.global_position.distance_to(opp.global_position)
			if dist <= my_radius:
				var push := (opp.global_position - bomb.global_position).normalized()
				if push.length_squared() < 0.01:
					push = Vector2(my_dir, -0.3).normalized()
				opp.take_hit(my_dmg, push, my_kb)
		bomb.queue_free()
	)
	_anim_attack_swing()


# --- Plasma Cannon Laser Beam ---
func _execute_laser(wpn: Dictionary) -> void:
	if laser_active:
		return
	heavy_cooldown = wpn["secondary_cooldown"]
	laser_active = true
	laser_timer = wpn["secondary_duration"]
	laser_tick_timer = 0.0
	# Create laser beam visual
	_create_laser_beam_visual()
	_anim_attack_swing()


func _create_laser_beam_visual() -> void:
	if _laser_beam_node:
		_laser_beam_node.queue_free()
	_laser_beam_node = Polygon2D.new()
	_laser_beam_node.polygon = PackedVector2Array([
		Vector2(0, -3), Vector2(350, -2), Vector2(350, 2), Vector2(0, 3)
	])
	_laser_beam_node.color = Color(0.2, 0.9, 1.0, 0.6)
	var face_dir := 1.0 if facing_right else -1.0
	_laser_beam_node.position = Vector2(face_dir * 20.0, 0.0)
	_laser_beam_node.scale.x = face_dir
	visuals.add_child(_laser_beam_node)


func _update_laser_beam(delta: float) -> void:
	if not laser_active:
		if _laser_beam_node:
			_laser_beam_node.queue_free()
			_laser_beam_node = null
		return

	laser_timer -= delta
	if laser_timer <= 0.0:
		laser_active = false
		if _laser_beam_node:
			_laser_beam_node.queue_free()
			_laser_beam_node = null
		return

	var face_dir: float = 1.0 if facing_right else -1.0

	# Pulse the beam visual
	if _laser_beam_node:
		var pulse_alpha: float = 0.4 + 0.3 * sin(laser_timer * 12.0)
		_laser_beam_node.color = Color(0.2, 0.9, 1.0, pulse_alpha)
		_laser_beam_node.position = Vector2(face_dir * 20.0, 0.0)
		_laser_beam_node.scale.x = face_dir

	# Lock movement during laser
	velocity.x = 0.0

	# Tick damage
	laser_tick_timer -= delta
	if laser_tick_timer <= 0.0:
		laser_tick_timer = WEAPONS["plasma_cannon"].get("laser_tick_rate", 0.33)
		# Check if opponent is in beam line
		if is_instance_valid(opponent) and opponent.has_method("take_hit"):
			var dx := opponent.global_position.x - global_position.x
			var dy_abs := absf(opponent.global_position.y - global_position.y)
			var in_direction := (dx > 0.0 and face_dir > 0.0) or (dx < 0.0 and face_dir < 0.0)
			var laser_range: float = WEAPONS["plasma_cannon"].get("laser_range", 350.0)
			if in_direction and absf(dx) <= laser_range and dy_abs <= 30.0:
				var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
				var dmg: float = WEAPONS["plasma_cannon"]["secondary_damage"] * damage_mult * rage_dmg
				var kb: float = WEAPONS["plasma_cannon"]["secondary_knockback"] * kb_mult
				var kb_dir := Vector2(face_dir, -0.2).normalized()
				opponent.take_hit(dmg, kb_dir, kb)


# --- New Secondary Abilities ---

func _execute_multi_shot(wpn: Dictionary) -> void:
	heavy_cooldown = wpn["secondary_cooldown"]
	var parent := get_parent()
	if parent == null:
		return
	var face_dir: float = 1.0 if facing_right else -1.0
	var icicle_scene := preload("res://scenes/fighter/Icicle.tscn")
	var y_offsets: Array = [-12.0, 0.0, 12.0]
	for i in range(3):
		var proj := icicle_scene.instantiate()
		proj.direction = face_dir
		proj.damage = wpn["secondary_damage"] * damage_mult
		proj.knockback = wpn["secondary_knockback"] * kb_mult
		proj.max_range = wpn.get("projectile_range", 350.0)
		proj.speed = wpn.get("projectile_speed", 650.0)
		proj.slow_duration = 0.0
		proj.slow_amount = 1.0
		proj.owner_fighter = self
		parent.add_child(proj)
		proj.global_position = global_position + Vector2(face_dir * 20.0, -4.0 + y_offsets[i])


func _execute_pull(wpn: Dictionary) -> void:
	heavy_cooldown = wpn["secondary_cooldown"]
	if not is_instance_valid(opponent):
		return
	var face_dir := 1.0 if facing_right else -1.0
	var dx := opponent.global_position.x - global_position.x
	var dist := absf(dx)
	var pull_range: float = wpn.get("pull_range", 200.0)
	var in_direction := (dx > 0.0 and face_dir > 0.0) or (dx < 0.0 and face_dir < 0.0)
	if in_direction and dist <= pull_range:
		var pull_dir := (global_position - opponent.global_position).normalized()
		var pull_force: float = wpn.get("pull_force", 400.0)
		opponent.velocity = pull_dir * pull_force
		if opponent.has_method("take_hit"):
			var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
			opponent.take_hit(wpn["secondary_damage"] * damage_mult * rage_dmg, pull_dir, wpn["secondary_knockback"] * kb_mult)


func _execute_block(wpn: Dictionary) -> void:
	block_active = true
	block_timer = wpn["secondary_duration"]
	heavy_cooldown = wpn["secondary_cooldown"]
	invuln_timer = wpn["secondary_duration"]
	velocity.x = 0.0


func _execute_rain(wpn: Dictionary) -> void:
	heavy_cooldown = wpn["secondary_cooldown"]
	var parent := get_parent()
	if parent == null or get_tree() == null:
		return
	var rain_count: int = int(wpn.get("rain_count", 3))
	var target_x: float = global_position.x
	if is_instance_valid(opponent):
		target_x = opponent.global_position.x
	# Direct area damage at target zone
	if is_instance_valid(opponent) and opponent.has_method("take_hit"):
		var dist_to_target := absf(opponent.global_position.x - target_x)
		if dist_to_target <= 60.0:
			var face_dir: float = 1.0 if facing_right else -1.0
			var kb_dir := Vector2(face_dir, -0.5).normalized()
			var rage_dmg: float = (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
			var total_dmg: float = wpn["secondary_damage"] * damage_mult * rage_dmg * float(rain_count)
			opponent.take_hit(total_dmg, kb_dir, wpn["secondary_knockback"] * kb_mult)
	# Falling arrow VFX
	for i in range(rain_count):
		var offset_x: float = (i - rain_count / 2.0) * 40.0
		var arrow := Polygon2D.new()
		arrow.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -20), Vector2(2, 0)])
		arrow.color = Color(1.0, 0.9, 0.5, 0.9)
		arrow.global_position = Vector2(target_x + offset_x, global_position.y - 120.0)
		parent.add_child(arrow)
		var tw := _safe_create_tween()
		tw.tween_property(arrow, "global_position:y", global_position.y + 10.0, 0.3)
		tw.parallel().tween_property(arrow, "modulate:a", 0.0, 0.35)
		tw.tween_callback(arrow.queue_free)


func _execute_poison(wpn: Dictionary) -> void:
	_start_attack_with_values("heavy", wpn["secondary_damage"], wpn["secondary_knockback"], wpn["secondary_duration"], wpn["secondary_cooldown"])
	# Poison is applied on hit via _on_attack_hit check
	if is_instance_valid(opponent) and opponent.has_method("apply_poison"):
		# Delayed apply - will be applied through the attack hit instead
		pass


func _execute_lifesteal(wpn: Dictionary) -> void:
	lifesteal_active = true
	_start_attack_with_values("heavy", wpn["secondary_damage"], wpn["secondary_knockback"], wpn["secondary_duration"], wpn["secondary_cooldown"])


func _execute_vortex(wpn: Dictionary) -> void:
	heavy_cooldown = wpn["secondary_cooldown"]
	var parent := get_parent()
	if parent == null or get_tree() == null:
		return
	vortex_active = true
	vortex_timer = wpn["secondary_duration"]
	if is_instance_valid(opponent):
		vortex_position = opponent.global_position
	else:
		var face_dir := 1.0 if facing_right else -1.0
		vortex_position = global_position + Vector2(face_dir * 120.0, 0.0)
	# Spawn vortex visual
	var vfx := Polygon2D.new()
	vfx.color = Color(0.4, 0.1, 0.6, 0.4)
	vfx.polygon = PackedVector2Array([
		Vector2(-20, -20), Vector2(20, -20), Vector2(25, 0),
		Vector2(20, 20), Vector2(-20, 20), Vector2(-25, 0)
	])
	vfx.global_position = vortex_position
	parent.add_child(vfx)
	var tw := _safe_create_tween()
	tw.tween_property(vfx, "scale", Vector2(3.0, 3.0), wpn["secondary_duration"]).from(Vector2(0.5, 0.5))
	tw.parallel().tween_property(vfx, "modulate:a", 0.0, wpn["secondary_duration"]).from(0.6)
	tw.tween_callback(vfx.queue_free)


var _impale_tween: Tween = null
var _impale_orig_pos: Vector2 = Vector2.ZERO
var _impale_orig_size: Vector2 = Vector2(36.0, 28.0)

func _execute_impale(wpn: Dictionary) -> void:
	heavy_cooldown = wpn["secondary_cooldown"]
	if get_tree() == null:
		return
	# Kill any previous impale tween and reset shape first
	if _impale_tween and _impale_tween.is_valid():
		_impale_tween.kill()
	if attack_shape:
		var shape: RectangleShape2D = attack_shape.shape as RectangleShape2D
		if shape:
			attack_shape.position = _impale_orig_pos
			shape.size = _impale_orig_size
	# Temporarily extend attack range
	var impale_range: float = wpn.get("impale_range", 150.0)
	var face_dir := 1.0 if facing_right else -1.0
	_start_attack_with_values("heavy", wpn["secondary_damage"], wpn["secondary_knockback"], wpn["secondary_duration"], wpn["secondary_cooldown"])
	# Extend the attack shape forward for this attack
	if attack_shape:
		_impale_orig_pos = attack_shape.position
		attack_shape.position = Vector2(face_dir * impale_range * 0.5, _impale_orig_pos.y)
		var shape: RectangleShape2D = attack_shape.shape as RectangleShape2D
		if shape:
			_impale_orig_size = shape.size
			shape.size = Vector2(impale_range, _impale_orig_size.y)
			# Reset after attack duration
			_impale_tween = _safe_create_tween()
			if _impale_tween:
				_impale_tween.tween_interval(wpn["secondary_duration"] + 0.05)
				_impale_tween.tween_callback(func():
					if is_instance_valid(self) and attack_shape:
						attack_shape.position = _impale_orig_pos
						shape.size = _impale_orig_size
				)


func _update_block(delta: float) -> void:
	if not block_active:
		return
	block_timer -= delta
	if block_timer <= 0.0:
		block_active = false


func _update_poison_dot(delta: float) -> void:
	if poison_timer <= 0.0:
		return
	poison_timer -= delta
	poison_tick_timer -= delta
	if poison_tick_timer <= 0.0:
		poison_tick_timer = 0.5
		damage_percent += poison_dps
	if poison_timer <= 0.0:
		poison_dps = 0.0


func _update_vortex(delta: float) -> void:
	if not vortex_active:
		return
	vortex_timer -= delta
	if vortex_timer <= 0.0:
		vortex_active = false
		return
	# Pull opponent toward vortex center
	if is_instance_valid(opponent):
		var wpn: Dictionary = WEAPONS.get("gravity_orb", {})
		var vortex_radius: float = wpn.get("vortex_radius", 100.0)
		var pull_force: float = wpn.get("vortex_pull_force", 300.0)
		var dist := opponent.global_position.distance_to(vortex_position)
		if dist < vortex_radius * 2.0 and dist > 5.0:
			var pull_dir := (vortex_position - opponent.global_position).normalized()
			opponent.velocity += pull_dir * pull_force * delta
			# Tick damage
			var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
			var tick_dmg: float = WEAPONS.get("gravity_orb", {}).get("secondary_damage", 3.0) * damage_mult * rage_dmg * delta
			opponent.damage_percent += tick_dmg


func apply_poison(duration: float, dps_amount: float) -> void:
	poison_timer = duration
	poison_dps = dps_amount
	poison_tick_timer = 0.5


# --- Combat ---

func _start_attack_with_values(attack_type: String, dmg: float, kb: float, duration: float, cooldown: float) -> void:
	is_attacking = true
	current_attack = attack_type
	var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
	_current_attack_damage = dmg * damage_mult * rage_dmg
	_current_attack_knockback = kb * kb_mult
	attack_timer = duration
	light_cooldown = cooldown
	heavy_cooldown = cooldown

	attack_shape.set_deferred("disabled", false)
	attack_visual.visible = true
	_anim_attack_swing()

	var face_dir := 1.0 if facing_right else -1.0
	if attack_type == "charged":
		var base_size := Vector2(36, 28)
		var size_mult := lerpf(1.0, 1.4, charge_ratio)
		if weapon_id == "thors_hammer":
			base_size = Vector2(44, 34)  # Bigger hitbox for hammer
			size_mult = lerpf(1.0, 1.6, charge_ratio)
		attack_area.position = Vector2(face_dir * 22.0, -4.0 if is_on_floor() else 0.0)
		attack_shape.shape.size = Vector2(base_size.x * size_mult, base_size.y * size_mult)
		attack_visual.position = attack_area.position
		attack_visual.scale.x = face_dir
	elif attack_type == "heavy" and not is_on_floor():
		attack_area.position = Vector2(0.0, 20.0)
		attack_shape.shape.size = Vector2(34, 30)
		attack_visual.position = Vector2(0.0, 20.0)
	else:
		attack_area.position = Vector2(face_dir * 20.0, -4.0 if is_on_floor() else 0.0)
		attack_shape.shape.size = Vector2(30, 24)
		attack_visual.position = attack_area.position
		attack_visual.scale.x = face_dir


func _end_attack() -> void:
	is_attacking = false
	current_attack = ""
	attack_shape.set_deferred("disabled", true)
	attack_visual.visible = false


func _on_attack_hit(body: Node2D) -> void:
	if not is_instance_valid(body):
		return
	if body == self or not is_attacking:
		return
	if not body is CharacterBody2D or not body.has_method("take_hit"):
		return
	# Skip teammates in 2v2
	if "team_id" in body and body.team_id == team_id:
		return
	if body == opponent or (not is_instance_valid(opponent) and body != self):
		var kb_dir := Vector2.ZERO
		if current_attack == "heavy" and not is_on_floor():
			kb_dir = Vector2(0, 1).normalized()
		elif current_attack == "uppercut":
			var face_dir := 1.0 if facing_right else -1.0
			kb_dir = Vector2(face_dir * 0.2, -1.0).normalized()
		else:
			var face_dir := 1.0 if facing_right else -1.0
			kb_dir = Vector2(face_dir, -0.4).normalized()

		# Frost staff: apply slow on any melee hit
		if weapon_id == "frost_staff" and body.has_method("apply_slow"):
			var wpn: Dictionary = WEAPONS[weapon_id]
			body.apply_slow(wpn.get("slow_duration", 0.5), wpn.get("slow_amount", 0.5))

		# Poison Fang: apply poison DOT on heavy attack
		if weapon_id == "poison_fang" and current_attack == "heavy" and body.has_method("apply_poison"):
			var wpn: Dictionary = WEAPONS[weapon_id]
			body.apply_poison(wpn.get("poison_duration", 3.0), wpn.get("poison_dps", 2.0))

		# Blood Scythe: lifesteal on heavy attack
		if lifesteal_active and weapon_id == "blood_scythe":
			var heal_amount: float = _current_attack_damage * WEAPONS["blood_scythe"].get("lifesteal_percent", 0.5)
			damage_percent = maxf(0.0, damage_percent - heal_amount)
			lifesteal_active = false

		var hit_pos := (global_position + body.global_position) * 0.5
		_spawn_hit_spark(hit_pos)
		body.take_hit(_current_attack_damage, kb_dir, _current_attack_knockback)
		# Fill rage meter from dealing damage
		if rage_available and not rage_active:
			_fill_rage_meter(_current_attack_damage * RAGE_FILL_DEAL)


var _counter_attacking: bool = false
var _doing_super: bool = false

func take_hit(dmg: float, knockback_dir: Vector2, base_force: float) -> void:
	if invuln_timer > 0.0:
		return
	# Block counter (Iron Buckler) — guard against infinite recursion
	if block_active and not _counter_attacking:
		block_active = false
		block_timer = 0.0
		# Counter-attack the attacker
		if is_instance_valid(opponent) and opponent.has_method("take_hit"):
			_counter_attacking = true
			var counter_dir := (opponent.global_position - global_position).normalized()
			var wpn: Dictionary = WEAPONS.get("iron_buckler", {})
			var rage_dmg := (1.0 + RAGE_DAMAGE_BONUS) if rage_active else 1.0
			opponent.take_hit(wpn["secondary_damage"] * damage_mult * rage_dmg, counter_dir, wpn["secondary_knockback"] * kb_mult)
			_counter_attacking = false
		return
	damage_percent += dmg
	var kb_multiplier := 1.0 + damage_percent / 80.0
	velocity = knockback_dir * base_force * kb_multiplier
	hitstun_timer = HITSTUN_TIME
	jump_count = 0  # Reset jumps so you can double jump to recover
	is_charging = false
	is_dashing = false
	is_super_winding = false
	laser_active = false
	_end_attack()
	# Fill rage meter from taking damage
	if rage_available and not rage_active:
		_fill_rage_meter(dmg * RAGE_FILL_TAKE)
	# Notify Arena for screen shake / combo tracking
	_notify_arena_hit(dmg, false)


func apply_slow(duration: float, amount: float) -> void:
	slow_timer = duration
	slow_multiplier = amount


func _notify_arena_hit(dmg: float, _is_super: bool) -> void:
	var arena := get_parent()
	if arena == null:
		return
	# "this" fighter just got hit — figure out who the attacker was
	if not is_ai and arena.has_method("on_player_got_hit"):
		arena.on_player_got_hit(dmg)
	elif is_ai and arena.has_method("on_player_hit_landed"):
		# AI got hit = player landed a hit — check if attacker was doing a super
		var attacker_super := false
		if is_instance_valid(opponent) and "_doing_super" in opponent:
			attacker_super = opponent._doing_super
		arena.on_player_hit_landed(dmg, attacker_super)


# --- Weapon visuals ---

func _update_weapon_visuals() -> void:
	var show_hammer := weapon_id == "thors_hammer"
	var show_blade := weapon_id == "shadow_blade"
	var show_staff := weapon_id == "frost_staff"
	var show_gauntlets := weapon_id == "dragon_gauntlets"

	for node_name in ["HammerHandle", "HammerHead", "HammerHeadAccent"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_hammer
	if has_node("Visuals/HammerGlow"):
		get_node("Visuals/HammerGlow").visible = false

	for node_name in ["ShadowBlade", "ShadowBladeEdge"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_blade

	for node_name in ["FrostStaff", "FrostStaffCrystal", "FrostStaffGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_staff

	for node_name in ["DragonGauntletLeft", "DragonGauntletRight", "DragonGauntletFlame"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_gauntlets

	var show_warp := weapon_id == "warp_dagger"
	for node_name in ["WarpDagger", "WarpDaggerGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_warp

	var show_bomb := weapon_id == "bomb_flail"
	for node_name in ["BombFlailChain", "BombFlailHead", "BombFlailSpike", "BombFlailFuse"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_bomb

	var show_plasma := weapon_id == "plasma_cannon"
	for node_name in ["PlasmaCannon", "PlasmaCannonBarrel", "PlasmaCannonGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_plasma

	var show_kunai := weapon_id == "kunai_stars"
	for node_name in ["KunaiStar", "KunaiStarGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_kunai

	var show_vine := weapon_id == "vine_whip"
	for node_name in ["VineWhip", "VineWhipLeaf"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_vine

	var show_buckler := weapon_id == "iron_buckler"
	for node_name in ["IronBuckler", "IronBucklerBorder"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_buckler

	var show_bow := weapon_id == "spirit_bow"
	for node_name in ["SpiritBow", "SpiritBowString", "SpiritBowGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_bow

	var show_thunder := weapon_id == "thunder_claws"
	for node_name in ["ThunderClawLeft", "ThunderClawRight", "ThunderClawSpark"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_thunder

	var show_poison := weapon_id == "poison_fang"
	for node_name in ["PoisonFangLeft", "PoisonFangRight", "PoisonFangDrip"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_poison

	var show_fire := weapon_id == "fire_greatsword"
	for node_name in ["FireGreatsword", "FireGreatswordEdge", "FireGreatswordGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_fire

	var show_scythe := weapon_id == "blood_scythe"
	for node_name in ["BloodScythe", "BloodScytheHandle", "BloodScytheGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_scythe

	var show_gravity := weapon_id == "gravity_orb"
	for node_name in ["GravityOrb", "GravityOrbRing", "GravityOrbGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_gravity

	var show_spear := weapon_id == "crystal_spear"
	for node_name in ["CrystalSpear", "CrystalSpearTip", "CrystalSpearGlow"]:
		if has_node("Visuals/" + node_name):
			get_node("Visuals/" + node_name).visible = show_spear


func _create_weapon_aura() -> void:
	var level: int = GameState.get_weapon_level(weapon_id)
	# Get weapon skin glow color
	var wskin: Dictionary = GameState.get_weapon_skin_data()
	_weapon_aura_color = wskin.get("glow", Color(0.4, 0.6, 1.0))
	# Create aura polygon (circle) — always visible
	_weapon_aura_node = Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(16):
		var angle := float(i) / 16.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)))
	_weapon_aura_node.polygon = pts
	# Size grows with level: level 1 = small base, level 10 = large
	var aura_radius: float = 5.0 + (level - 1) * 2.5
	_weapon_aura_node.scale = Vector2.ONE * aura_radius
	var aura_alpha: float = 0.08 + (level - 1) * 0.025
	_weapon_aura_node.color = Color(_weapon_aura_color.r, _weapon_aura_color.g, _weapon_aura_color.b, aura_alpha)
	_weapon_aura_node.position = Vector2(7.0, -2.0)
	_weapon_aura_node.z_index = -1
	visuals.add_child(_weapon_aura_node)


func _update_weapon_aura(_delta: float) -> void:
	if _weapon_aura_node == null:
		return
	var level: int = GameState.get_weapon_level(weapon_id)
	var base_radius: float = 5.0 + (level - 1) * 2.5
	# During RAGE: bigger, brighter, faster pulse
	if rage_active:
		var rage_pulse: float = 1.0 + 0.25 * sin(_anim_time * 6.0)
		_weapon_aura_node.scale = Vector2.ONE * base_radius * 1.6 * rage_pulse
		var rage_alpha: float = 0.25 + 0.12 * sin(_anim_time * 8.0)
		_weapon_aura_node.color = Color(_weapon_aura_color.r, _weapon_aura_color.g, _weapon_aura_color.b, rage_alpha)
	else:
		var pulse: float = 1.0 + 0.12 * sin(_anim_time * 2.5)
		_weapon_aura_node.scale = Vector2.ONE * base_radius * pulse
		var base_alpha: float = 0.08 + (level - 1) * 0.025
		var alpha_pulse: float = base_alpha + 0.04 * sin(_anim_time * 3.0)
		_weapon_aura_node.color = Color(_weapon_aura_color.r, _weapon_aura_color.g, _weapon_aura_color.b, alpha_pulse)


func _apply_skins() -> void:
	var cskin: Dictionary
	if is_ai:
		if color_override.is_empty():
			return  # AI with no override keeps scene defaults
		cskin = color_override
	else:
		cskin = GameState.get_char_skin_data()

	# Character skin — recolor scarf, coat, hair, eyes, accents, emblem
	var scarf_col: Color = cskin.get("scarf", Color(0.85, 0.15, 0.2))
	var coat_col: Color = cskin.get("coat", Color(0.12, 0.12, 0.18))
	var hair_col: Color = cskin.get("hair", Color(0.12, 0.1, 0.26))
	var iris_col: Color = cskin.get("iris", Color(0.2, 0.4, 0.9))
	var accent_col: Color = cskin.get("accent", Color(0.5, 0.3, 0.8))
	var emblem_col: Color = cskin.get("emblem", Color(0.5, 0.3, 0.85))

	# Scarf
	_set_poly_color("ScarfTrail", Color(scarf_col.r, scarf_col.g, scarf_col.b, 0.7))
	_set_poly_color("ScarfTrailTip", Color(scarf_col.r + 0.05, scarf_col.g + 0.05, scarf_col.b + 0.05, 0.5))
	_set_poly_color("ScarfFront", scarf_col)
	_set_poly_color("ScarfKnot", scarf_col.darkened(0.12))

	# Coat / jacket
	_set_poly_color("CoatBack", coat_col)
	_set_poly_color("CoatTailLeft", coat_col.darkened(0.1))
	_set_poly_color("CoatTailRight", coat_col.darkened(0.1))
	_set_poly_color("TorsoBase", Color(coat_col.r + 0.02, coat_col.g + 0.02, coat_col.b + 0.02, 1.0))
	_set_poly_color("JacketLapelLeft", coat_col.lightened(0.15))
	_set_poly_color("JacketLapelRight", coat_col.lightened(0.15))

	# Hair
	_set_poly_color("HairBack", hair_col.darkened(0.1))
	_set_poly_color("HairSpikeTopLeft", hair_col)
	_set_poly_color("HairSpikeTop", hair_col.lightened(0.05))
	_set_poly_color("HairSpikeTopRight", hair_col)
	_set_poly_color("HairSpikeSideLeft", hair_col)
	_set_poly_color("HairSpikeSideRight", hair_col)
	_set_poly_color("HairFringe", hair_col.lightened(0.02))
	_set_poly_color("HairHighlight1", Color(hair_col.r + 0.15, hair_col.g + 0.12, hair_col.b + 0.28, 0.4))
	_set_poly_color("HairHighlight2", Color(hair_col.r + 0.2, hair_col.g + 0.14, hair_col.b + 0.3, 0.3))

	# Eyes
	_set_poly_color("IrisLeft", iris_col)
	_set_poly_color("IrisRight", iris_col)
	_set_poly_color("BrowLeft", hair_col.darkened(0.15))
	_set_poly_color("BrowRight", hair_col.darkened(0.15))

	# Accents (shoulder pads, boot accents)
	_set_poly_color("ShoulderLeftAccent", Color(accent_col.r, accent_col.g, accent_col.b, 0.5))
	_set_poly_color("ShoulderRightAccent", Color(accent_col.r, accent_col.g, accent_col.b, 0.5))
	_set_poly_color("BootLeftAccent", Color(accent_col.r, accent_col.g, accent_col.b, 0.5))
	_set_poly_color("BootRightAccent", Color(accent_col.r, accent_col.g, accent_col.b, 0.5))

	# Emblem
	_set_poly_color("Emblem", Color(emblem_col.r, emblem_col.g, emblem_col.b, 0.6))
	_set_poly_color("EmblemInner", Color(emblem_col.r + 0.15, emblem_col.g + 0.15, emblem_col.b + 0.15, 0.4))

	# Weapon skin + body skin — player only
	if not is_ai:
		var wskin: Dictionary = GameState.get_weapon_skin_data()
		var glow_col: Color = wskin.get("glow", Color(0.4, 0.6, 1.0))
		var trail_col: Color = wskin.get("trail", Color(0.6, 0.8, 1.0))
		_set_poly_color("AttackVisual/SlashArc", Color(glow_col.r, glow_col.g, glow_col.b, 0.7))
		_set_poly_color("AttackVisual/SlashTrail", Color(trail_col.r, trail_col.g, trail_col.b, 0.4))
		_set_poly_color("HammerHeadAccent", Color(glow_col.r, glow_col.g, glow_col.b, 0.6))
		_set_poly_color("ShadowBladeEdge", Color(glow_col.r, glow_col.g, glow_col.b, 0.5))
		_set_poly_color("FrostStaffGlow", Color(glow_col.r, glow_col.g, glow_col.b, 0.25))

		# Body skin override (full character model replacement)
		if GameState.fighter_body_skin != "default":
			_apply_body_skin(GameState.fighter_body_skin)


const HAIR_NODES := [
	"HairBack", "HairSpikeTopLeft", "HairSpikeTop", "HairSpikeTopRight",
	"HairSpikeSideLeft", "HairSpikeSideRight", "HairFringe",
	"HairHighlight1", "HairHighlight2",
]


func _apply_hair_visibility() -> void:
	for i in range(HAIR_NODES.size()):
		var full_path: String = "Visuals/" + HAIR_NODES[i]
		if has_node(full_path):
			get_node(full_path).visible = show_hair


func _show_hair_node(node_name: String) -> void:
	var full_path: String = "Visuals/" + node_name
	if has_node(full_path):
		get_node(full_path).visible = true


func _set_poly_color(node_path: String, col: Color) -> void:
	var full_path := "Visuals/" + node_path
	if has_node(full_path):
		var poly: Polygon2D = get_node(full_path) as Polygon2D
		if poly:
			poly.color = col


func _apply_body_skin(skin_id: String) -> void:
	match skin_id:
		"panda":
			_apply_panda_skin()
		"darth_bader":
			_apply_darth_bader_skin()
		"ninja":
			_apply_ninja_skin()
		"robot":
			_apply_robot_skin()
		"cat":
			_apply_cat_skin()
		"shark":
			_apply_shark_skin()
		"frog":
			_apply_frog_skin()
		"pikachu":
			_apply_pikachu_skin()
		"goku":
			_apply_goku_skin()
		"joker":
			_apply_joker_skin()
		"hulk":
			_apply_hulk_skin()
		"spiderman":
			_apply_spiderman_skin()
		"batman":
			_apply_batman_skin()
		"iron_man":
			_apply_iron_man_skin()
		"god":
			_apply_god_skin()
		"manito":
			_apply_manito_skin()


func _set_poly_points(node_path: String, points: PackedVector2Array) -> void:
	var full_path := "Visuals/" + node_path
	if has_node(full_path):
		var poly: Polygon2D = get_node(full_path) as Polygon2D
		if poly:
			poly.polygon = points


func _apply_panda_skin() -> void:
	# === PANDA: Round fluffy body, black/white fur, round ears, cute button eyes ===

	# Body — white round torso
	_set_poly_color("CoatBack", Color(0.95, 0.95, 0.97))
	_set_poly_color("CoatTailLeft", Color(0.12, 0.12, 0.14))
	_set_poly_color("CoatTailRight", Color(0.12, 0.12, 0.14))
	_set_poly_color("TorsoBase", Color(0.92, 0.92, 0.95))
	_set_poly_color("JacketLapelLeft", Color(0.88, 0.88, 0.92))
	_set_poly_color("JacketLapelRight", Color(0.88, 0.88, 0.92))
	# Rounder torso shape
	_set_poly_points("TorsoBase", PackedVector2Array([
		Vector2(-11, -14), Vector2(-12, -8), Vector2(-13, 0), Vector2(-12, 8),
		Vector2(-10, 14), Vector2(-5, 16), Vector2(0, 17), Vector2(5, 16),
		Vector2(10, 14), Vector2(12, 8), Vector2(13, 0), Vector2(12, -8),
		Vector2(11, -14), Vector2(5, -16), Vector2(0, -17), Vector2(-5, -16)]))
	# Head — round white face with black eye patches
	_set_poly_color("HeadBase", Color(0.96, 0.96, 0.98))
	_set_poly_color("Neck", Color(0.93, 0.93, 0.96))
	_set_poly_points("HeadBase", PackedVector2Array([
		Vector2(-10, -10), Vector2(-12, -5), Vector2(-12, 2), Vector2(-10, 8),
		Vector2(-6, 11), Vector2(0, 12), Vector2(6, 11), Vector2(10, 8),
		Vector2(12, 2), Vector2(12, -5), Vector2(10, -10), Vector2(6, -12),
		Vector2(0, -13), Vector2(-6, -12)]))
	# Black eye patches (dark circles around eyes — panda signature)
	_set_poly_color("IrisLeft", Color(0.05, 0.05, 0.08))
	_set_poly_color("IrisRight", Color(0.05, 0.05, 0.08))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-3, -4), Vector2(-5, -2), Vector2(-5, 2), Vector2(-3, 4),
		Vector2(0, 5), Vector2(3, 4), Vector2(5, 2), Vector2(5, -2),
		Vector2(3, -4), Vector2(0, -5)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-3, -4), Vector2(-5, -2), Vector2(-5, 2), Vector2(-3, 4),
		Vector2(0, 5), Vector2(3, 4), Vector2(5, 2), Vector2(5, -2),
		Vector2(3, -4), Vector2(0, -5)]))
	# Cute white pupils inside black patches
	_set_poly_color("PupilLeft", Color(1.0, 1.0, 1.0))
	_set_poly_color("PupilRight", Color(1.0, 1.0, 1.0))
	# Tiny black nose
	_set_poly_color("Mouth", Color(0.1, 0.1, 0.12))
	# Hair becomes panda ears (black round ears on top)
	_set_poly_color("HairBack", Color(0.08, 0.08, 0.1))
	_set_poly_color("HairSpikeTopLeft", Color(0.05, 0.05, 0.08))
	_set_poly_color("HairSpikeTop", Color(0.96, 0.96, 0.98, 0.0))  # hide middle spike
	_set_poly_color("HairSpikeTopRight", Color(0.05, 0.05, 0.08))
	_set_poly_color("HairSpikeSideLeft", Color(0.05, 0.05, 0.08))
	_set_poly_color("HairSpikeSideRight", Color(0.05, 0.05, 0.08))
	_set_poly_color("HairFringe", Color(0.96, 0.96, 0.98, 0.0))  # hide fringe
	_set_poly_color("HairHighlight1", Color(0.2, 0.2, 0.22, 0.3))
	_set_poly_color("HairHighlight2", Color(0.2, 0.2, 0.22, 0.2))
	# Round ear shapes
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(0, 0), Vector2(-4, -6), Vector2(-6, -12), Vector2(-5, -16),
		Vector2(-2, -18), Vector2(2, -18), Vector2(5, -16), Vector2(6, -12),
		Vector2(4, -6)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(0, 0), Vector2(-4, -6), Vector2(-6, -12), Vector2(-5, -16),
		Vector2(-2, -18), Vector2(2, -18), Vector2(5, -16), Vector2(6, -12),
		Vector2(4, -6)]))
	# Black arms & legs (panda limbs)
	_set_poly_color("ShoulderLeftAccent", Color(0.08, 0.08, 0.1, 0.9))
	_set_poly_color("ShoulderRightAccent", Color(0.08, 0.08, 0.1, 0.9))
	_set_poly_color("BootLeftAccent", Color(0.08, 0.08, 0.1, 0.9))
	_set_poly_color("BootRightAccent", Color(0.08, 0.08, 0.1, 0.9))
	# Scarf becomes bamboo leaf green
	_set_poly_color("ScarfTrail", Color(0.2, 0.6, 0.15, 0.7))
	_set_poly_color("ScarfTrailTip", Color(0.25, 0.65, 0.2, 0.5))
	_set_poly_color("ScarfFront", Color(0.2, 0.6, 0.15))
	_set_poly_color("ScarfKnot", Color(0.15, 0.5, 0.1))
	# Brow becomes invisible (pandas don't have brows)
	_set_poly_color("BrowLeft", Color(0.05, 0.05, 0.08, 0.0))
	_set_poly_color("BrowRight", Color(0.05, 0.05, 0.08, 0.0))
	# White belly emblem with bamboo pattern
	_set_poly_color("Emblem", Color(0.88, 0.88, 0.92, 0.8))
	_set_poly_color("EmblemInner", Color(0.3, 0.65, 0.2, 0.5))
	# Rounder emblem
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-7, -7), Vector2(-8, 0), Vector2(-7, 7), Vector2(0, 9),
		Vector2(7, 7), Vector2(8, 0), Vector2(7, -7), Vector2(0, -9)]))


func _apply_darth_bader_skin() -> void:
	# === DARTH BADER: Dark lord helmet, cape, red glow accents, sinister visor ===

	# Body — jet black robes
	_set_poly_color("CoatBack", Color(0.04, 0.04, 0.06))
	_set_poly_color("CoatTailLeft", Color(0.06, 0.04, 0.08))
	_set_poly_color("CoatTailRight", Color(0.06, 0.04, 0.08))
	_set_poly_color("TorsoBase", Color(0.08, 0.08, 0.1))
	_set_poly_color("JacketLapelLeft", Color(0.12, 0.1, 0.14))
	_set_poly_color("JacketLapelRight", Color(0.12, 0.1, 0.14))
	# Chest panel with buttons/lights
	_set_poly_color("Emblem", Color(0.15, 0.15, 0.18, 0.9))
	_set_poly_color("EmblemInner", Color(0.9, 0.15, 0.1, 0.7))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-6, -5), Vector2(-6, 5), Vector2(6, 5), Vector2(6, -5)]))
	_set_poly_points("EmblemInner", PackedVector2Array([
		Vector2(-2, -2), Vector2(-2, 2), Vector2(2, 2), Vector2(2, -2)]))
	# Head — black helmet with angular visor
	_set_poly_color("HeadBase", Color(0.06, 0.06, 0.08))
	_set_poly_color("Neck", Color(0.04, 0.04, 0.06))
	# Angular helmet shape
	_set_poly_points("HeadBase", PackedVector2Array([
		Vector2(-11, -8), Vector2(-13, -2), Vector2(-13, 4), Vector2(-11, 9),
		Vector2(-7, 12), Vector2(0, 13), Vector2(7, 12), Vector2(11, 9),
		Vector2(13, 4), Vector2(13, -2), Vector2(11, -8), Vector2(8, -13),
		Vector2(3, -15), Vector2(0, -16), Vector2(-3, -15), Vector2(-8, -13)]))
	# Visor — red glowing triangular eyes
	_set_poly_color("IrisLeft", Color(0.95, 0.1, 0.05))
	_set_poly_color("IrisRight", Color(0.95, 0.1, 0.05))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-5, 0), Vector2(-2, -3), Vector2(2, -2), Vector2(4, 0),
		Vector2(2, 1), Vector2(-2, 1)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-4, 0), Vector2(-2, -2), Vector2(2, -3), Vector2(5, 0),
		Vector2(2, 1), Vector2(-2, 1)]))
	# No pupils visible (solid red visor)
	_set_poly_color("PupilLeft", Color(1.0, 0.3, 0.1, 0.6))
	_set_poly_color("PupilRight", Color(1.0, 0.3, 0.1, 0.6))
	_set_poly_color("EyeWhiteLeft", Color(0.06, 0.06, 0.08))
	_set_poly_color("EyeWhiteRight", Color(0.06, 0.06, 0.08))
	# No mouth visible — solid helmet
	_set_poly_color("Mouth", Color(0.06, 0.06, 0.08, 0.0))
	# Brow becomes visor ridge
	_set_poly_color("BrowLeft", Color(0.12, 0.12, 0.15))
	_set_poly_color("BrowRight", Color(0.12, 0.12, 0.15))
	# Hair becomes helmet dome (smooth dark shape)
	_set_poly_color("HairBack", Color(0.04, 0.04, 0.06))
	_set_poly_color("HairSpikeTopLeft", Color(0.08, 0.06, 0.1))
	_set_poly_color("HairSpikeTop", Color(0.06, 0.06, 0.08))
	_set_poly_color("HairSpikeTopRight", Color(0.08, 0.06, 0.1))
	_set_poly_color("HairSpikeSideLeft", Color(0.06, 0.06, 0.08))
	_set_poly_color("HairSpikeSideRight", Color(0.06, 0.06, 0.08))
	_set_poly_color("HairFringe", Color(0.08, 0.08, 0.1))
	_set_poly_color("HairHighlight1", Color(0.15, 0.12, 0.2, 0.15))
	_set_poly_color("HairHighlight2", Color(0.2, 0.15, 0.25, 0.1))
	# Smooth dome shape for helmet top
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-8, 2), Vector2(-10, -2), Vector2(-9, -8), Vector2(-6, -12),
		Vector2(-2, -14), Vector2(2, -14), Vector2(6, -12), Vector2(9, -8),
		Vector2(10, -2), Vector2(8, 2)]))
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(0, 2), Vector2(-3, -2), Vector2(-4, -6), Vector2(-2, -9),
		Vector2(1, -8), Vector2(3, -4), Vector2(3, 0)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(0, 2), Vector2(3, -2), Vector2(4, -6), Vector2(2, -9),
		Vector2(-1, -8), Vector2(-3, -4), Vector2(-3, 0)]))
	# Cape/scarf — deep dark red
	_set_poly_color("ScarfTrail", Color(0.35, 0.05, 0.05, 0.85))
	_set_poly_color("ScarfTrailTip", Color(0.4, 0.08, 0.08, 0.6))
	_set_poly_color("ScarfFront", Color(0.3, 0.04, 0.04))
	_set_poly_color("ScarfKnot", Color(0.25, 0.03, 0.03))
	# Dark shoulders with red accent edges
	_set_poly_color("ShoulderLeftAccent", Color(0.7, 0.1, 0.08, 0.7))
	_set_poly_color("ShoulderRightAccent", Color(0.7, 0.1, 0.08, 0.7))
	# Dark boots with red trim
	_set_poly_color("BootLeftAccent", Color(0.6, 0.08, 0.06, 0.6))
	_set_poly_color("BootRightAccent", Color(0.6, 0.08, 0.06, 0.6))


func _apply_ninja_skin() -> void:
	# === SHADOW NINJA: Wrapped cloth, face mask, dark outfit, shuriken emblem ===

	# Body — dark indigo/navy stealth gear
	_set_poly_color("CoatBack", Color(0.08, 0.08, 0.18))
	_set_poly_color("CoatTailLeft", Color(0.06, 0.06, 0.14))
	_set_poly_color("CoatTailRight", Color(0.06, 0.06, 0.14))
	_set_poly_color("TorsoBase", Color(0.1, 0.1, 0.2))
	_set_poly_color("JacketLapelLeft", Color(0.12, 0.12, 0.25))
	_set_poly_color("JacketLapelRight", Color(0.12, 0.12, 0.25))
	# Head — cloth-wrapped face, only eyes visible
	_set_poly_color("HeadBase", Color(0.1, 0.1, 0.18))
	_set_poly_color("Neck", Color(0.08, 0.08, 0.16))
	# Sharp eyes — glowing cyan
	_set_poly_color("IrisLeft", Color(0.1, 0.85, 0.9))
	_set_poly_color("IrisRight", Color(0.1, 0.85, 0.9))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-5, 0), Vector2(-3, -2), Vector2(0, -3), Vector2(4, -1),
		Vector2(4, 1), Vector2(0, 2), Vector2(-3, 1)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-4, -1), Vector2(0, -3), Vector2(3, -2), Vector2(5, 0),
		Vector2(3, 1), Vector2(0, 2), Vector2(-4, 1)]))
	_set_poly_color("PupilLeft", Color(0.02, 0.02, 0.04))
	_set_poly_color("PupilRight", Color(0.02, 0.02, 0.04))
	_set_poly_color("EyeWhiteLeft", Color(0.08, 0.08, 0.15))
	_set_poly_color("EyeWhiteRight", Color(0.08, 0.08, 0.15))
	# Mouth hidden by mask
	_set_poly_color("Mouth", Color(0.1, 0.1, 0.18, 0.0))
	# Thin brows
	_set_poly_color("BrowLeft", Color(0.08, 0.08, 0.16))
	_set_poly_color("BrowRight", Color(0.08, 0.08, 0.16))
	# Hair becomes cloth wrap (flat, dark)
	_set_poly_color("HairBack", Color(0.06, 0.06, 0.14))
	_set_poly_color("HairSpikeTopLeft", Color(0.08, 0.08, 0.16))
	_set_poly_color("HairSpikeTop", Color(0.08, 0.08, 0.16))
	_set_poly_color("HairSpikeTopRight", Color(0.08, 0.08, 0.16))
	_set_poly_color("HairSpikeSideLeft", Color(0.06, 0.06, 0.14))
	_set_poly_color("HairSpikeSideRight", Color(0.06, 0.06, 0.14))
	_set_poly_color("HairFringe", Color(0.08, 0.08, 0.17))
	_set_poly_color("HairHighlight1", Color(0.15, 0.15, 0.35, 0.2))
	_set_poly_color("HairHighlight2", Color(0.12, 0.12, 0.3, 0.15))
	# Shorter wrap headband shape
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-7, 0), Vector2(-8, -3), Vector2(-6, -7), Vector2(-2, -9),
		Vector2(2, -9), Vector2(6, -7), Vector2(8, -3), Vector2(7, 0)]))
	# Tail cloth (flowing behind)
	_set_poly_color("ScarfTrail", Color(0.1, 0.1, 0.22, 0.7))
	_set_poly_color("ScarfTrailTip", Color(0.12, 0.12, 0.25, 0.5))
	_set_poly_color("ScarfFront", Color(0.1, 0.1, 0.2))
	_set_poly_color("ScarfKnot", Color(0.08, 0.08, 0.18))
	# Shuriken emblem (4-pointed star shape)
	_set_poly_color("Emblem", Color(0.5, 0.5, 0.6, 0.6))
	_set_poly_color("EmblemInner", Color(0.15, 0.8, 0.85, 0.5))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(0, -8), Vector2(2, -2), Vector2(8, 0), Vector2(2, 2),
		Vector2(0, 8), Vector2(-2, 2), Vector2(-8, 0), Vector2(-2, -2)]))
	# Dark accents
	_set_poly_color("ShoulderLeftAccent", Color(0.12, 0.12, 0.25, 0.6))
	_set_poly_color("ShoulderRightAccent", Color(0.12, 0.12, 0.25, 0.6))
	_set_poly_color("BootLeftAccent", Color(0.1, 0.1, 0.22, 0.6))
	_set_poly_color("BootRightAccent", Color(0.1, 0.1, 0.22, 0.6))


func _apply_robot_skin() -> void:
	# === MECH UNIT: Metallic body, visor screen, antenna, glowing circuits ===

	# Body — gunmetal grey with blue circuit lines
	_set_poly_color("CoatBack", Color(0.25, 0.27, 0.3))
	_set_poly_color("CoatTailLeft", Color(0.2, 0.22, 0.25))
	_set_poly_color("CoatTailRight", Color(0.2, 0.22, 0.25))
	_set_poly_color("TorsoBase", Color(0.3, 0.32, 0.35))
	_set_poly_color("JacketLapelLeft", Color(0.35, 0.37, 0.4))
	_set_poly_color("JacketLapelRight", Color(0.35, 0.37, 0.4))
	# Angular torso plating
	_set_poly_points("TorsoBase", PackedVector2Array([
		Vector2(-10, -14), Vector2(-12, -7), Vector2(-12, 7), Vector2(-10, 14),
		Vector2(-4, 16), Vector2(4, 16), Vector2(10, 14), Vector2(12, 7),
		Vector2(12, -7), Vector2(10, -14), Vector2(4, -16), Vector2(-4, -16)]))
	# Head — metal box with screen visor
	_set_poly_color("HeadBase", Color(0.28, 0.3, 0.34))
	_set_poly_color("Neck", Color(0.22, 0.24, 0.28))
	# Angular helmet
	_set_poly_points("HeadBase", PackedVector2Array([
		Vector2(-10, -9), Vector2(-12, -3), Vector2(-12, 5), Vector2(-10, 10),
		Vector2(-5, 12), Vector2(5, 12), Vector2(10, 10), Vector2(12, 5),
		Vector2(12, -3), Vector2(10, -9), Vector2(5, -12), Vector2(-5, -12)]))
	# Screen visor eyes — bright cyan
	_set_poly_color("IrisLeft", Color(0.1, 0.9, 1.0))
	_set_poly_color("IrisRight", Color(0.1, 0.9, 1.0))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-4, -2), Vector2(-4, 2), Vector2(0, 3), Vector2(4, 2),
		Vector2(4, -2), Vector2(0, -3)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-4, -2), Vector2(-4, 2), Vector2(0, 3), Vector2(4, 2),
		Vector2(4, -2), Vector2(0, -3)]))
	_set_poly_color("PupilLeft", Color(0.0, 0.6, 0.8))
	_set_poly_color("PupilRight", Color(0.0, 0.6, 0.8))
	_set_poly_color("EyeWhiteLeft", Color(0.15, 0.17, 0.2))
	_set_poly_color("EyeWhiteRight", Color(0.15, 0.17, 0.2))
	# No mouth — speaker grill
	_set_poly_color("Mouth", Color(0.18, 0.2, 0.23))
	# Antenna instead of hair
	_set_poly_color("HairBack", Color(0.22, 0.24, 0.28))
	_set_poly_color("HairSpikeTopLeft", Color(0.3, 0.32, 0.35))
	_set_poly_color("HairSpikeTop", Color(0.4, 0.42, 0.45))
	_set_poly_color("HairSpikeTopRight", Color(0.3, 0.32, 0.35))
	_set_poly_color("HairSpikeSideLeft", Color(0.25, 0.27, 0.3))
	_set_poly_color("HairSpikeSideRight", Color(0.25, 0.27, 0.3))
	_set_poly_color("HairFringe", Color(0.28, 0.3, 0.34))
	_set_poly_color("HairHighlight1", Color(0.1, 0.85, 1.0, 0.2))
	_set_poly_color("HairHighlight2", Color(0.1, 0.85, 1.0, 0.15))
	# Antenna shape (tall spike in center)
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-2, 2), Vector2(-3, -4), Vector2(-2, -12), Vector2(0, -18),
		Vector2(2, -12), Vector2(3, -4), Vector2(2, 2)]))
	# Flat panel sides
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(0, 0), Vector2(-5, -2), Vector2(-6, -6), Vector2(-3, -8),
		Vector2(0, -6), Vector2(2, -2)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(0, 0), Vector2(5, -2), Vector2(6, -6), Vector2(3, -8),
		Vector2(0, -6), Vector2(-2, -2)]))
	_set_poly_color("BrowLeft", Color(0.22, 0.24, 0.28))
	_set_poly_color("BrowRight", Color(0.22, 0.24, 0.28))
	# Scarf becomes cable/wire (blue circuit)
	_set_poly_color("ScarfTrail", Color(0.1, 0.5, 0.7, 0.6))
	_set_poly_color("ScarfTrailTip", Color(0.1, 0.6, 0.8, 0.4))
	_set_poly_color("ScarfFront", Color(0.1, 0.5, 0.65))
	_set_poly_color("ScarfKnot", Color(0.08, 0.4, 0.55))
	# Circuit emblem — glowing blue square
	_set_poly_color("Emblem", Color(0.1, 0.7, 0.9, 0.7))
	_set_poly_color("EmblemInner", Color(0.1, 0.9, 1.0, 0.5))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-5, -5), Vector2(-5, 5), Vector2(5, 5), Vector2(5, -5)]))
	# Metal shoulder/boot accents
	_set_poly_color("ShoulderLeftAccent", Color(0.35, 0.37, 0.4, 0.7))
	_set_poly_color("ShoulderRightAccent", Color(0.35, 0.37, 0.4, 0.7))
	_set_poly_color("BootLeftAccent", Color(0.3, 0.32, 0.35, 0.7))
	_set_poly_color("BootRightAccent", Color(0.3, 0.32, 0.35, 0.7))


func _update_charge_glow() -> void:
	if not has_node("Visuals/HammerGlow"):
		return
	var glow: Polygon2D = get_node("Visuals/HammerGlow")
	if is_charging:
		glow.visible = true
		var alpha := lerpf(0.1, 0.8, charge_ratio)
		glow.color = Color(0.4, 0.6, 1.0, alpha)
		glow.scale = Vector2.ONE * lerpf(0.8, 1.5, charge_ratio)
	else:
		glow.visible = false


func _apply_cat_skin() -> void:
	# === CAT: Orange tabby, pointy ears, whisker marks, cute nose ===

	_set_poly_color("CoatBack", Color(0.9, 0.55, 0.15))
	_set_poly_color("CoatTailLeft", Color(0.85, 0.5, 0.12))
	_set_poly_color("CoatTailRight", Color(0.85, 0.5, 0.12))
	_set_poly_color("TorsoBase", Color(0.95, 0.65, 0.2))
	_set_poly_color("JacketLapelLeft", Color(1.0, 0.75, 0.35))
	_set_poly_color("JacketLapelRight", Color(1.0, 0.75, 0.35))
	_set_poly_color("HeadBase", Color(0.95, 0.65, 0.2))
	_set_poly_color("Neck", Color(0.9, 0.6, 0.18))
	_set_poly_points("HeadBase", PackedVector2Array([
		Vector2(-10, -8), Vector2(-12, -3), Vector2(-12, 4), Vector2(-9, 9),
		Vector2(-5, 11), Vector2(0, 12), Vector2(5, 11), Vector2(9, 9),
		Vector2(12, 4), Vector2(12, -3), Vector2(10, -8), Vector2(5, -11),
		Vector2(0, -12), Vector2(-5, -11)]))
	# Big round green cat eyes
	_set_poly_color("EyeWhiteLeft", Color(0.9, 0.95, 0.8))
	_set_poly_color("EyeWhiteRight", Color(0.9, 0.95, 0.8))
	_set_poly_color("IrisLeft", Color(0.3, 0.85, 0.2))
	_set_poly_color("IrisRight", Color(0.3, 0.85, 0.2))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-4, -4), Vector2(-5, 0), Vector2(-4, 4), Vector2(0, 5),
		Vector2(4, 4), Vector2(5, 0), Vector2(4, -4), Vector2(0, -5)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-4, -4), Vector2(-5, 0), Vector2(-4, 4), Vector2(0, 5),
		Vector2(4, 4), Vector2(5, 0), Vector2(4, -4), Vector2(0, -5)]))
	# Vertical slit pupils
	_set_poly_color("PupilLeft", Color(0.02, 0.02, 0.02))
	_set_poly_color("PupilRight", Color(0.02, 0.02, 0.02))
	_set_poly_points("PupilLeft", PackedVector2Array([
		Vector2(-0.8, -3), Vector2(0.8, -3), Vector2(1.2, 0), Vector2(0.8, 3),
		Vector2(-0.8, 3), Vector2(-1.2, 0)]))
	_set_poly_points("PupilRight", PackedVector2Array([
		Vector2(-0.8, -3), Vector2(0.8, -3), Vector2(1.2, 0), Vector2(0.8, 3),
		Vector2(-0.8, 3), Vector2(-1.2, 0)]))
	# Tiny pink triangle nose
	_set_poly_color("Mouth", Color(0.95, 0.5, 0.55))
	_set_poly_points("Mouth", PackedVector2Array([
		Vector2(-2, -1), Vector2(2, -1), Vector2(0, 2)]))
	# Pointy triangle ears from hair
	_set_poly_color("HairBack", Color(0.85, 0.5, 0.12))
	_set_poly_color("HairSpikeTopLeft", Color(0.95, 0.6, 0.18))
	_set_poly_color("HairSpikeTopRight", Color(0.95, 0.6, 0.18))
	_set_poly_color("HairSpikeTop", Color(0.95, 0.65, 0.2, 0.0))
	_set_poly_color("HairSpikeSideLeft", Color(0.85, 0.5, 0.12, 0.0))
	_set_poly_color("HairSpikeSideRight", Color(0.85, 0.5, 0.12, 0.0))
	_set_poly_color("HairFringe", Color(0.9, 0.55, 0.15, 0.0))
	_set_poly_color("HairHighlight1", Color(1.0, 0.85, 0.5, 0.3))
	_set_poly_color("HairHighlight2", Color(1.0, 0.8, 0.4, 0.2))
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(0, 0), Vector2(-3, -5), Vector2(-5, -14), Vector2(-4, -18),
		Vector2(-1, -15), Vector2(1, -8), Vector2(2, 0)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(-2, 0), Vector2(-1, -8), Vector2(1, -15), Vector2(4, -18),
		Vector2(5, -14), Vector2(3, -5), Vector2(0, 0)]))
	_set_poly_color("BrowLeft", Color(0.8, 0.45, 0.1, 0.0))
	_set_poly_color("BrowRight", Color(0.8, 0.45, 0.1, 0.0))
	# White belly
	_set_poly_color("Emblem", Color(1.0, 0.95, 0.85, 0.9))
	_set_poly_color("EmblemInner", Color(1.0, 0.9, 0.8, 0.6))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-7, -7), Vector2(-8, 0), Vector2(-7, 7), Vector2(0, 9),
		Vector2(7, 7), Vector2(8, 0), Vector2(7, -7), Vector2(0, -9)]))
	# Orange tabby stripes on scarf
	_set_poly_color("ScarfTrail", Color(0.7, 0.35, 0.05, 0.7))
	_set_poly_color("ScarfTrailTip", Color(0.8, 0.4, 0.08, 0.5))
	_set_poly_color("ScarfFront", Color(0.7, 0.35, 0.05))
	_set_poly_color("ScarfKnot", Color(0.6, 0.3, 0.04))
	_set_poly_color("ShoulderLeftAccent", Color(0.85, 0.5, 0.12, 0.7))
	_set_poly_color("ShoulderRightAccent", Color(0.85, 0.5, 0.12, 0.7))
	_set_poly_color("BootLeftAccent", Color(1.0, 0.95, 0.85, 0.6))
	_set_poly_color("BootRightAccent", Color(1.0, 0.95, 0.85, 0.6))


func _apply_shark_skin() -> void:
	# === SHARK: Blue-gray skin, dorsal fin, sharp teeth, dark eyes ===

	_set_poly_color("CoatBack", Color(0.3, 0.38, 0.45))
	_set_poly_color("CoatTailLeft", Color(0.25, 0.32, 0.4))
	_set_poly_color("CoatTailRight", Color(0.25, 0.32, 0.4))
	_set_poly_color("TorsoBase", Color(0.35, 0.42, 0.5))
	_set_poly_color("JacketLapelLeft", Color(0.4, 0.48, 0.55))
	_set_poly_color("JacketLapelRight", Color(0.4, 0.48, 0.55))
	_set_poly_color("HeadBase", Color(0.4, 0.48, 0.55))
	_set_poly_color("Neck", Color(0.35, 0.42, 0.5))
	_set_poly_points("HeadBase", PackedVector2Array([
		Vector2(-10, -6), Vector2(-12, 0), Vector2(-11, 6), Vector2(-8, 10),
		Vector2(-3, 13), Vector2(3, 13), Vector2(8, 10), Vector2(11, 6),
		Vector2(12, 0), Vector2(10, -6), Vector2(6, -10), Vector2(0, -11),
		Vector2(-6, -10)]))
	# Small dark beady shark eyes
	_set_poly_color("EyeWhiteLeft", Color(0.15, 0.15, 0.18))
	_set_poly_color("EyeWhiteRight", Color(0.15, 0.15, 0.18))
	_set_poly_color("IrisLeft", Color(0.05, 0.05, 0.08))
	_set_poly_color("IrisRight", Color(0.05, 0.05, 0.08))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-2, -2), Vector2(-3, 0), Vector2(-2, 2), Vector2(0, 3),
		Vector2(2, 2), Vector2(3, 0), Vector2(2, -2), Vector2(0, -3)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-2, -2), Vector2(-3, 0), Vector2(-2, 2), Vector2(0, 3),
		Vector2(2, 2), Vector2(3, 0), Vector2(2, -2), Vector2(0, -3)]))
	_set_poly_color("PupilLeft", Color(0.02, 0.02, 0.02))
	_set_poly_color("PupilRight", Color(0.02, 0.02, 0.02))
	# Jagged shark teeth mouth
	_set_poly_color("Mouth", Color(0.9, 0.9, 0.92))
	_set_poly_points("Mouth", PackedVector2Array([
		Vector2(-6, -1), Vector2(-4, 2), Vector2(-2, -1), Vector2(0, 2),
		Vector2(2, -1), Vector2(4, 2), Vector2(6, -1), Vector2(4, 3),
		Vector2(-4, 3)]))
	# Dorsal fin on top (center hair spike)
	_set_poly_color("HairBack", Color(0.3, 0.38, 0.45))
	_set_poly_color("HairSpikeTop", Color(0.35, 0.43, 0.52))
	_set_poly_color("HairSpikeTopLeft", Color(0.3, 0.38, 0.45, 0.0))
	_set_poly_color("HairSpikeTopRight", Color(0.3, 0.38, 0.45, 0.0))
	_set_poly_color("HairSpikeSideLeft", Color(0.3, 0.38, 0.45, 0.0))
	_set_poly_color("HairSpikeSideRight", Color(0.3, 0.38, 0.45, 0.0))
	_set_poly_color("HairFringe", Color(0.35, 0.42, 0.5, 0.0))
	_set_poly_color("HairHighlight1", Color(0.5, 0.6, 0.7, 0.2))
	_set_poly_color("HairHighlight2", Color(0.5, 0.6, 0.7, 0.15))
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-4, 0), Vector2(-2, -6), Vector2(0, -22), Vector2(2, -6), Vector2(4, 0)]))
	_set_poly_color("BrowLeft", Color(0.3, 0.38, 0.45, 0.0))
	_set_poly_color("BrowRight", Color(0.3, 0.38, 0.45, 0.0))
	# White belly emblem
	_set_poly_color("Emblem", Color(0.85, 0.88, 0.9, 0.9))
	_set_poly_color("EmblemInner", Color(0.9, 0.92, 0.95, 0.6))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-7, -6), Vector2(-8, 0), Vector2(-6, 8), Vector2(0, 10),
		Vector2(6, 8), Vector2(8, 0), Vector2(7, -6), Vector2(0, -8)]))
	_set_poly_color("ScarfTrail", Color(0.25, 0.32, 0.4, 0.5))
	_set_poly_color("ScarfTrailTip", Color(0.3, 0.38, 0.48, 0.3))
	_set_poly_color("ScarfFront", Color(0.25, 0.32, 0.4))
	_set_poly_color("ScarfKnot", Color(0.2, 0.28, 0.35))
	_set_poly_color("ShoulderLeftAccent", Color(0.35, 0.42, 0.5, 0.6))
	_set_poly_color("ShoulderRightAccent", Color(0.35, 0.42, 0.5, 0.6))
	_set_poly_color("BootLeftAccent", Color(0.3, 0.38, 0.45, 0.5))
	_set_poly_color("BootRightAccent", Color(0.3, 0.38, 0.45, 0.5))


func _apply_frog_skin() -> void:
	# === FROG: Bright green skin, huge round eyes, wide mouth, webbed look ===

	_set_poly_color("CoatBack", Color(0.15, 0.5, 0.1))
	_set_poly_color("CoatTailLeft", Color(0.12, 0.45, 0.08))
	_set_poly_color("CoatTailRight", Color(0.12, 0.45, 0.08))
	_set_poly_color("TorsoBase", Color(0.2, 0.6, 0.15))
	_set_poly_color("JacketLapelLeft", Color(0.25, 0.65, 0.2))
	_set_poly_color("JacketLapelRight", Color(0.25, 0.65, 0.2))
	_set_poly_color("HeadBase", Color(0.25, 0.65, 0.18))
	_set_poly_color("Neck", Color(0.2, 0.55, 0.14))
	# Wider rounder head
	_set_poly_points("HeadBase", PackedVector2Array([
		Vector2(-12, -6), Vector2(-14, 0), Vector2(-13, 6), Vector2(-9, 10),
		Vector2(-4, 12), Vector2(4, 12), Vector2(9, 10), Vector2(13, 6),
		Vector2(14, 0), Vector2(12, -6), Vector2(6, -10), Vector2(0, -11),
		Vector2(-6, -10)]))
	# Huge bulging eyes
	_set_poly_color("EyeWhiteLeft", Color(0.95, 1.0, 0.9))
	_set_poly_color("EyeWhiteRight", Color(0.95, 1.0, 0.9))
	_set_poly_color("IrisLeft", Color(0.8, 0.5, 0.0))
	_set_poly_color("IrisRight", Color(0.8, 0.5, 0.0))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-5, -5), Vector2(-6, 0), Vector2(-5, 5), Vector2(0, 6),
		Vector2(5, 5), Vector2(6, 0), Vector2(5, -5), Vector2(0, -6)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-5, -5), Vector2(-6, 0), Vector2(-5, 5), Vector2(0, 6),
		Vector2(5, 5), Vector2(6, 0), Vector2(5, -5), Vector2(0, -6)]))
	_set_poly_color("PupilLeft", Color(0.02, 0.02, 0.02))
	_set_poly_color("PupilRight", Color(0.02, 0.02, 0.02))
	# Wide grin
	_set_poly_color("Mouth", Color(0.15, 0.35, 0.1))
	_set_poly_points("Mouth", PackedVector2Array([
		Vector2(-7, 0), Vector2(-5, 2), Vector2(-2, 3), Vector2(0, 3),
		Vector2(2, 3), Vector2(5, 2), Vector2(7, 0), Vector2(4, 1),
		Vector2(0, 1), Vector2(-4, 1)]))
	# No hair — flat smooth frog head
	_set_poly_color("HairBack", Color(0.2, 0.55, 0.14))
	_set_poly_color("HairSpikeTopLeft", Color(0.2, 0.6, 0.15, 0.0))
	_set_poly_color("HairSpikeTop", Color(0.2, 0.6, 0.15, 0.0))
	_set_poly_color("HairSpikeTopRight", Color(0.2, 0.6, 0.15, 0.0))
	_set_poly_color("HairSpikeSideLeft", Color(0.2, 0.6, 0.15, 0.0))
	_set_poly_color("HairSpikeSideRight", Color(0.2, 0.6, 0.15, 0.0))
	_set_poly_color("HairFringe", Color(0.2, 0.6, 0.15, 0.0))
	_set_poly_color("HairHighlight1", Color(0.4, 0.8, 0.3, 0.2))
	_set_poly_color("HairHighlight2", Color(0.3, 0.7, 0.2, 0.15))
	_set_poly_color("BrowLeft", Color(0.2, 0.55, 0.14, 0.0))
	_set_poly_color("BrowRight", Color(0.2, 0.55, 0.14, 0.0))
	# Yellow belly
	_set_poly_color("Emblem", Color(0.9, 0.9, 0.4, 0.9))
	_set_poly_color("EmblemInner", Color(0.95, 0.95, 0.5, 0.6))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-7, -6), Vector2(-8, 0), Vector2(-6, 8), Vector2(0, 10),
		Vector2(6, 8), Vector2(8, 0), Vector2(7, -6), Vector2(0, -8)]))
	_set_poly_color("ScarfTrail", Color(0.15, 0.4, 0.08, 0.4))
	_set_poly_color("ScarfTrailTip", Color(0.2, 0.45, 0.1, 0.3))
	_set_poly_color("ScarfFront", Color(0.15, 0.4, 0.08))
	_set_poly_color("ScarfKnot", Color(0.12, 0.35, 0.06))
	_set_poly_color("ShoulderLeftAccent", Color(0.2, 0.55, 0.12, 0.6))
	_set_poly_color("ShoulderRightAccent", Color(0.2, 0.55, 0.12, 0.6))
	_set_poly_color("BootLeftAccent", Color(0.2, 0.5, 0.1, 0.5))
	_set_poly_color("BootRightAccent", Color(0.2, 0.5, 0.1, 0.5))


func _apply_pikachu_skin() -> void:
	# === PIKACHU: Bright yellow body, red cheek circles, pointy ears, brown back stripes ===

	_set_poly_color("CoatBack", Color(0.6, 0.45, 0.1))
	_set_poly_color("CoatTailLeft", Color(0.55, 0.4, 0.08))
	_set_poly_color("CoatTailRight", Color(0.55, 0.4, 0.08))
	_set_poly_color("TorsoBase", Color(1.0, 0.85, 0.1))
	_set_poly_color("JacketLapelLeft", Color(1.0, 0.88, 0.15))
	_set_poly_color("JacketLapelRight", Color(1.0, 0.88, 0.15))
	_set_poly_color("HeadBase", Color(1.0, 0.85, 0.1))
	_set_poly_color("Neck", Color(0.95, 0.8, 0.08))
	# Round chubby head
	_set_poly_points("HeadBase", PackedVector2Array([
		Vector2(-11, -8), Vector2(-13, -2), Vector2(-13, 4), Vector2(-10, 9),
		Vector2(-5, 12), Vector2(0, 13), Vector2(5, 12), Vector2(10, 9),
		Vector2(13, 4), Vector2(13, -2), Vector2(11, -8), Vector2(6, -12),
		Vector2(0, -13), Vector2(-6, -12)]))
	# Big round dark eyes
	_set_poly_color("EyeWhiteLeft", Color(0.95, 0.95, 0.95))
	_set_poly_color("EyeWhiteRight", Color(0.95, 0.95, 0.95))
	_set_poly_color("IrisLeft", Color(0.1, 0.08, 0.05))
	_set_poly_color("IrisRight", Color(0.1, 0.08, 0.05))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-3, -4), Vector2(-5, 0), Vector2(-3, 4), Vector2(0, 5),
		Vector2(3, 4), Vector2(5, 0), Vector2(3, -4), Vector2(0, -5)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-3, -4), Vector2(-5, 0), Vector2(-3, 4), Vector2(0, 5),
		Vector2(3, 4), Vector2(5, 0), Vector2(3, -4), Vector2(0, -5)]))
	# Tiny white reflection in eye
	_set_poly_color("PupilLeft", Color(1.0, 1.0, 1.0))
	_set_poly_color("PupilRight", Color(1.0, 1.0, 1.0))
	_set_poly_points("PupilLeft", PackedVector2Array([
		Vector2(-1, -2), Vector2(1, -2), Vector2(1, 0), Vector2(-1, 0)]))
	_set_poly_points("PupilRight", PackedVector2Array([
		Vector2(-1, -2), Vector2(1, -2), Vector2(1, 0), Vector2(-1, 0)]))
	# Small mouth
	_set_poly_color("Mouth", Color(0.7, 0.55, 0.05))
	_set_poly_points("Mouth", PackedVector2Array([
		Vector2(-2, 0), Vector2(0, 2), Vector2(2, 0)]))
	# Pointy ears with black tips
	_set_poly_color("HairBack", Color(0.95, 0.8, 0.08))
	_set_poly_color("HairSpikeTopLeft", Color(1.0, 0.85, 0.1))
	_set_poly_color("HairSpikeTopRight", Color(1.0, 0.85, 0.1))
	_set_poly_color("HairSpikeTop", Color(1.0, 0.85, 0.1, 0.0))
	_set_poly_color("HairSpikeSideLeft", Color(0.15, 0.12, 0.05))
	_set_poly_color("HairSpikeSideRight", Color(0.15, 0.12, 0.05))
	_set_poly_color("HairFringe", Color(1.0, 0.85, 0.1, 0.0))
	_set_poly_color("HairHighlight1", Color(1.0, 1.0, 0.6, 0.3))
	_set_poly_color("HairHighlight2", Color(1.0, 1.0, 0.5, 0.2))
	# Tall pointy ears
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(0, 0), Vector2(-4, -8), Vector2(-6, -18), Vector2(-5, -22),
		Vector2(-3, -16), Vector2(-1, -6), Vector2(1, 0)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(-1, 0), Vector2(1, -6), Vector2(3, -16), Vector2(5, -22),
		Vector2(6, -18), Vector2(4, -8), Vector2(0, 0)]))
	# Black ear tips
	_set_poly_points("HairSpikeSideLeft", PackedVector2Array([
		Vector2(-4, -16), Vector2(-5, -22), Vector2(-3, -18)]))
	_set_poly_points("HairSpikeSideRight", PackedVector2Array([
		Vector2(3, -18), Vector2(5, -22), Vector2(4, -16)]))
	_set_poly_color("BrowLeft", Color(0.9, 0.75, 0.05, 0.0))
	_set_poly_color("BrowRight", Color(0.9, 0.75, 0.05, 0.0))
	# Red cheek circles as emblem
	_set_poly_color("Emblem", Color(1.0, 0.25, 0.15, 0.85))
	_set_poly_color("EmblemInner", Color(1.0, 0.35, 0.2, 0.6))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-4, -4), Vector2(-5, 0), Vector2(-4, 4), Vector2(0, 5),
		Vector2(4, 4), Vector2(5, 0), Vector2(4, -4), Vector2(0, -5)]))
	# Brown back stripes as scarf
	_set_poly_color("ScarfTrail", Color(0.55, 0.35, 0.05, 0.7))
	_set_poly_color("ScarfTrailTip", Color(0.6, 0.4, 0.08, 0.5))
	_set_poly_color("ScarfFront", Color(0.55, 0.35, 0.05))
	_set_poly_color("ScarfKnot", Color(0.5, 0.3, 0.04))
	_set_poly_color("ShoulderLeftAccent", Color(1.0, 0.85, 0.1, 0.5))
	_set_poly_color("ShoulderRightAccent", Color(1.0, 0.85, 0.1, 0.5))
	_set_poly_color("BootLeftAccent", Color(0.9, 0.75, 0.05, 0.4))
	_set_poly_color("BootRightAccent", Color(0.9, 0.75, 0.05, 0.4))


func _apply_goku_skin() -> void:
	# === GOKU / SUPER SAIYAN: Orange gi, blue belt, tall spiky golden hair ===

	_set_poly_color("CoatBack", Color(0.95, 0.5, 0.05))
	_set_poly_color("CoatTailLeft", Color(0.9, 0.45, 0.04))
	_set_poly_color("CoatTailRight", Color(0.9, 0.45, 0.04))
	_set_poly_color("TorsoBase", Color(1.0, 0.55, 0.08))
	_set_poly_color("JacketLapelLeft", Color(1.0, 0.6, 0.1))
	_set_poly_color("JacketLapelRight", Color(1.0, 0.6, 0.1))
	# Skin-colored head
	_set_poly_color("HeadBase", Color(0.95, 0.8, 0.6))
	_set_poly_color("Neck", Color(0.9, 0.75, 0.55))
	# Intense dark eyes
	_set_poly_color("EyeWhiteLeft", Color(1.0, 1.0, 1.0))
	_set_poly_color("EyeWhiteRight", Color(1.0, 1.0, 1.0))
	_set_poly_color("IrisLeft", Color(0.15, 0.6, 0.5))
	_set_poly_color("IrisRight", Color(0.15, 0.6, 0.5))
	_set_poly_color("PupilLeft", Color(0.02, 0.02, 0.02))
	_set_poly_color("PupilRight", Color(0.02, 0.02, 0.02))
	_set_poly_color("Mouth", Color(0.8, 0.6, 0.45))
	# Tall spiky Super Saiyan golden hair
	_set_poly_color("HairBack", Color(1.0, 0.85, 0.15))
	_set_poly_color("HairSpikeTopLeft", Color(1.0, 0.9, 0.2))
	_set_poly_color("HairSpikeTop", Color(1.0, 0.92, 0.25))
	_set_poly_color("HairSpikeTopRight", Color(1.0, 0.9, 0.2))
	_set_poly_color("HairSpikeSideLeft", Color(1.0, 0.82, 0.12))
	_set_poly_color("HairSpikeSideRight", Color(1.0, 0.82, 0.12))
	_set_poly_color("HairFringe", Color(1.0, 0.88, 0.18))
	_set_poly_color("HairHighlight1", Color(1.0, 1.0, 0.5, 0.5))
	_set_poly_color("HairHighlight2", Color(1.0, 1.0, 0.6, 0.4))
	# Massive spiky hair pointing up
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-2, -2), Vector2(-1, -16), Vector2(0, -32), Vector2(1, -16), Vector2(2, -2)]))
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(-1, 0), Vector2(-4, -6), Vector2(-7, -14), Vector2(-10, -26),
		Vector2(-8, -12), Vector2(-5, -4), Vector2(-2, 0)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(2, 0), Vector2(5, -4), Vector2(8, -12), Vector2(10, -26),
		Vector2(7, -14), Vector2(4, -6), Vector2(1, 0)]))
	_set_poly_points("HairSpikeSideLeft", PackedVector2Array([
		Vector2(-8, 2), Vector2(-12, -4), Vector2(-16, -14), Vector2(-12, -6), Vector2(-8, -2)]))
	_set_poly_points("HairSpikeSideRight", PackedVector2Array([
		Vector2(8, -2), Vector2(12, -6), Vector2(16, -14), Vector2(12, -4), Vector2(8, 2)]))
	_set_poly_color("BrowLeft", Color(0.7, 0.5, 0.2))
	_set_poly_color("BrowRight", Color(0.7, 0.5, 0.2))
	# Blue belt/sash as scarf
	_set_poly_color("ScarfTrail", Color(0.1, 0.2, 0.7, 0.8))
	_set_poly_color("ScarfTrailTip", Color(0.15, 0.25, 0.8, 0.6))
	_set_poly_color("ScarfFront", Color(0.1, 0.2, 0.7))
	_set_poly_color("ScarfKnot", Color(0.08, 0.15, 0.6))
	# Kanji symbol emblem
	_set_poly_color("Emblem", Color(0.1, 0.2, 0.7, 0.9))
	_set_poly_color("EmblemInner", Color(1.0, 0.55, 0.08, 0.7))
	_set_poly_color("ShoulderLeftAccent", Color(0.95, 0.5, 0.05, 0.6))
	_set_poly_color("ShoulderRightAccent", Color(0.95, 0.5, 0.05, 0.6))
	# Blue boots like Goku
	_set_poly_color("BootLeftAccent", Color(0.1, 0.2, 0.65, 0.7))
	_set_poly_color("BootRightAccent", Color(0.1, 0.2, 0.65, 0.7))


func _apply_joker_skin() -> void:
	# === JOKER: Chalk-white face, green slicked hair, red smile, purple suit ===

	_set_poly_color("CoatBack", Color(0.25, 0.08, 0.35))
	_set_poly_color("CoatTailLeft", Color(0.2, 0.06, 0.3))
	_set_poly_color("CoatTailRight", Color(0.2, 0.06, 0.3))
	_set_poly_color("TorsoBase", Color(0.3, 0.1, 0.4))
	_set_poly_color("JacketLapelLeft", Color(0.35, 0.12, 0.45))
	_set_poly_color("JacketLapelRight", Color(0.35, 0.12, 0.45))
	# Chalk-white face
	_set_poly_color("HeadBase", Color(0.95, 0.95, 0.95))
	_set_poly_color("Neck", Color(0.9, 0.9, 0.9))
	# Sinister dark-ringed eyes
	_set_poly_color("EyeWhiteLeft", Color(0.85, 0.85, 0.85))
	_set_poly_color("EyeWhiteRight", Color(0.85, 0.85, 0.85))
	_set_poly_color("IrisLeft", Color(0.2, 0.6, 0.1))
	_set_poly_color("IrisRight", Color(0.2, 0.6, 0.1))
	_set_poly_color("PupilLeft", Color(0.02, 0.02, 0.02))
	_set_poly_color("PupilRight", Color(0.02, 0.02, 0.02))
	# Wide red grin
	_set_poly_color("Mouth", Color(0.9, 0.1, 0.05))
	_set_poly_points("Mouth", PackedVector2Array([
		Vector2(-7, -1), Vector2(-5, 2), Vector2(-3, 3), Vector2(0, 4),
		Vector2(3, 3), Vector2(5, 2), Vector2(7, -1), Vector2(4, 2),
		Vector2(0, 2), Vector2(-4, 2)]))
	# Bright green slicked-back hair
	_set_poly_color("HairBack", Color(0.1, 0.5, 0.08))
	_set_poly_color("HairSpikeTopLeft", Color(0.15, 0.6, 0.1))
	_set_poly_color("HairSpikeTop", Color(0.18, 0.65, 0.12))
	_set_poly_color("HairSpikeTopRight", Color(0.15, 0.6, 0.1))
	_set_poly_color("HairSpikeSideLeft", Color(0.12, 0.5, 0.08))
	_set_poly_color("HairSpikeSideRight", Color(0.12, 0.5, 0.08))
	_set_poly_color("HairFringe", Color(0.15, 0.55, 0.1))
	_set_poly_color("HairHighlight1", Color(0.3, 0.8, 0.2, 0.3))
	_set_poly_color("HairHighlight2", Color(0.25, 0.7, 0.15, 0.2))
	# Slicked wavy hair shapes
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-6, 0), Vector2(-4, -6), Vector2(-1, -12), Vector2(2, -14),
		Vector2(5, -10), Vector2(6, -4), Vector2(6, 0)]))
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(-2, 0), Vector2(-5, -4), Vector2(-8, -10), Vector2(-7, -6), Vector2(-4, 0)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(4, 0), Vector2(6, -4), Vector2(8, -10), Vector2(7, -6), Vector2(4, -2)]))
	# Dark brow ridges
	_set_poly_color("BrowLeft", Color(0.3, 0.3, 0.3))
	_set_poly_color("BrowRight", Color(0.3, 0.3, 0.3))
	# Green flower lapel as emblem
	_set_poly_color("Emblem", Color(0.15, 0.65, 0.1, 0.9))
	_set_poly_color("EmblemInner", Color(1.0, 1.0, 0.2, 0.7))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-3, -3), Vector2(-4, 0), Vector2(-3, 3), Vector2(0, 4),
		Vector2(3, 3), Vector2(4, 0), Vector2(3, -3), Vector2(0, -4)]))
	# Purple suit scarf
	_set_poly_color("ScarfTrail", Color(0.35, 0.1, 0.5, 0.8))
	_set_poly_color("ScarfTrailTip", Color(0.4, 0.15, 0.55, 0.6))
	_set_poly_color("ScarfFront", Color(0.35, 0.1, 0.5))
	_set_poly_color("ScarfKnot", Color(0.3, 0.08, 0.4))
	_set_poly_color("ShoulderLeftAccent", Color(0.3, 0.1, 0.4, 0.7))
	_set_poly_color("ShoulderRightAccent", Color(0.3, 0.1, 0.4, 0.7))
	_set_poly_color("BootLeftAccent", Color(0.25, 0.08, 0.35, 0.6))
	_set_poly_color("BootRightAccent", Color(0.25, 0.08, 0.35, 0.6))


func _apply_hulk_skin() -> void:
	# === HULK: Massive green skin, purple torn pants, angry brow, huge fists ===

	_set_poly_color("CoatBack", Color(0.2, 0.08, 0.3))
	_set_poly_color("CoatTailLeft", Color(0.18, 0.06, 0.28))
	_set_poly_color("CoatTailRight", Color(0.18, 0.06, 0.28))
	# Green muscular body
	_set_poly_color("TorsoBase", Color(0.2, 0.55, 0.15))
	_set_poly_color("JacketLapelLeft", Color(0.22, 0.6, 0.18))
	_set_poly_color("JacketLapelRight", Color(0.22, 0.6, 0.18))
	# Wider bulkier torso
	_set_poly_points("TorsoBase", PackedVector2Array([
		Vector2(-13, -14), Vector2(-15, -6), Vector2(-15, 8), Vector2(-12, 16),
		Vector2(-5, 18), Vector2(5, 18), Vector2(12, 16), Vector2(15, 8),
		Vector2(15, -6), Vector2(13, -14), Vector2(5, -17), Vector2(-5, -17)]))
	# Green face with angry expression
	_set_poly_color("HeadBase", Color(0.2, 0.55, 0.15))
	_set_poly_color("Neck", Color(0.18, 0.5, 0.12))
	_set_poly_color("EyeWhiteLeft", Color(0.9, 0.95, 0.85))
	_set_poly_color("EyeWhiteRight", Color(0.9, 0.95, 0.85))
	_set_poly_color("IrisLeft", Color(0.15, 0.5, 0.1))
	_set_poly_color("IrisRight", Color(0.15, 0.5, 0.1))
	_set_poly_color("PupilLeft", Color(0.02, 0.02, 0.02))
	_set_poly_color("PupilRight", Color(0.02, 0.02, 0.02))
	# Angry grimace mouth
	_set_poly_color("Mouth", Color(0.12, 0.35, 0.08))
	_set_poly_points("Mouth", PackedVector2Array([
		Vector2(-5, 0), Vector2(-3, 2), Vector2(0, 1), Vector2(3, 2),
		Vector2(5, 0), Vector2(3, 3), Vector2(0, 2), Vector2(-3, 3)]))
	# Short messy dark hair
	_set_poly_color("HairBack", Color(0.12, 0.12, 0.1))
	_set_poly_color("HairSpikeTopLeft", Color(0.15, 0.15, 0.12))
	_set_poly_color("HairSpikeTop", Color(0.18, 0.18, 0.14))
	_set_poly_color("HairSpikeTopRight", Color(0.15, 0.15, 0.12))
	_set_poly_color("HairSpikeSideLeft", Color(0.12, 0.12, 0.1))
	_set_poly_color("HairSpikeSideRight", Color(0.12, 0.12, 0.1))
	_set_poly_color("HairFringe", Color(0.14, 0.14, 0.11))
	_set_poly_color("HairHighlight1", Color(0.25, 0.25, 0.2, 0.2))
	_set_poly_color("HairHighlight2", Color(0.22, 0.22, 0.18, 0.15))
	# Short messy spikes
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-3, 0), Vector2(-1, -6), Vector2(0, -10), Vector2(1, -6), Vector2(3, 0)]))
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(-2, 0), Vector2(-4, -4), Vector2(-5, -8), Vector2(-3, -3), Vector2(-1, 0)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(1, 0), Vector2(3, -3), Vector2(5, -8), Vector2(4, -4), Vector2(2, 0)]))
	# Heavy angry brow
	_set_poly_color("BrowLeft", Color(0.15, 0.4, 0.1))
	_set_poly_color("BrowRight", Color(0.15, 0.4, 0.1))
	# Purple torn pants scarf
	_set_poly_color("ScarfTrail", Color(0.35, 0.1, 0.5, 0.6))
	_set_poly_color("ScarfTrailTip", Color(0.4, 0.15, 0.55, 0.4))
	_set_poly_color("ScarfFront", Color(0.35, 0.1, 0.5))
	_set_poly_color("ScarfKnot", Color(0.3, 0.08, 0.4))
	_set_poly_color("Emblem", Color(0.2, 0.55, 0.15, 0.5))
	_set_poly_color("EmblemInner", Color(0.25, 0.6, 0.2, 0.3))
	# Green shoulders/arms
	_set_poly_color("ShoulderLeftAccent", Color(0.18, 0.5, 0.12, 0.8))
	_set_poly_color("ShoulderRightAccent", Color(0.18, 0.5, 0.12, 0.8))
	# Purple boots (torn pants)
	_set_poly_color("BootLeftAccent", Color(0.3, 0.08, 0.4, 0.7))
	_set_poly_color("BootRightAccent", Color(0.3, 0.08, 0.4, 0.7))


func _apply_spiderman_skin() -> void:
	# === SPIDER-MAN: Red/blue suit, large white eyes, web pattern ===

	# Blue lower body
	_set_poly_color("CoatBack", Color(0.05, 0.1, 0.4))
	_set_poly_color("CoatTailLeft", Color(0.04, 0.08, 0.35))
	_set_poly_color("CoatTailRight", Color(0.04, 0.08, 0.35))
	# Red upper body
	_set_poly_color("TorsoBase", Color(0.8, 0.05, 0.05))
	_set_poly_color("JacketLapelLeft", Color(0.85, 0.08, 0.08))
	_set_poly_color("JacketLapelRight", Color(0.85, 0.08, 0.08))
	# Red mask head
	_set_poly_color("HeadBase", Color(0.85, 0.05, 0.05))
	_set_poly_color("Neck", Color(0.8, 0.04, 0.04))
	# Huge white angular eyes (signature Spidey look)
	_set_poly_color("EyeWhiteLeft", Color(1.0, 1.0, 1.0))
	_set_poly_color("EyeWhiteRight", Color(1.0, 1.0, 1.0))
	_set_poly_color("IrisLeft", Color(0.95, 0.95, 0.95))
	_set_poly_color("IrisRight", Color(0.95, 0.95, 0.95))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-5, -4), Vector2(-6, 0), Vector2(-4, 5), Vector2(0, 6),
		Vector2(4, 4), Vector2(5, 0), Vector2(3, -4), Vector2(0, -5)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-3, -4), Vector2(-5, 0), Vector2(-4, 4), Vector2(0, 6),
		Vector2(4, 5), Vector2(6, 0), Vector2(5, -4), Vector2(0, -5)]))
	# Black outline around eyes
	_set_poly_color("PupilLeft", Color(0.85, 0.05, 0.05))
	_set_poly_color("PupilRight", Color(0.85, 0.05, 0.05))
	_set_poly_points("PupilLeft", PackedVector2Array([
		Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]))
	_set_poly_points("PupilRight", PackedVector2Array([
		Vector2(0, 0), Vector2(0, 0), Vector2(0, 0)]))
	# No mouth visible — full mask
	_set_poly_color("Mouth", Color(0.85, 0.05, 0.05, 0.0))
	# No hair — smooth mask
	_set_poly_color("HairBack", Color(0.8, 0.04, 0.04))
	_set_poly_color("HairSpikeTopLeft", Color(0.8, 0.05, 0.05, 0.0))
	_set_poly_color("HairSpikeTop", Color(0.8, 0.05, 0.05, 0.0))
	_set_poly_color("HairSpikeTopRight", Color(0.8, 0.05, 0.05, 0.0))
	_set_poly_color("HairSpikeSideLeft", Color(0.8, 0.05, 0.05, 0.0))
	_set_poly_color("HairSpikeSideRight", Color(0.8, 0.05, 0.05, 0.0))
	_set_poly_color("HairFringe", Color(0.8, 0.05, 0.05, 0.0))
	_set_poly_color("HairHighlight1", Color(1.0, 0.3, 0.3, 0.15))
	_set_poly_color("HairHighlight2", Color(1.0, 0.2, 0.2, 0.1))
	_set_poly_color("BrowLeft", Color(0.8, 0.05, 0.05, 0.0))
	_set_poly_color("BrowRight", Color(0.8, 0.05, 0.05, 0.0))
	# Web pattern emblem (spider on chest)
	_set_poly_color("Emblem", Color(0.02, 0.02, 0.02, 0.9))
	_set_poly_color("EmblemInner", Color(0.85, 0.05, 0.05, 0.5))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-1, -6), Vector2(-4, -3), Vector2(-6, 0), Vector2(-4, 3),
		Vector2(-1, 6), Vector2(1, 6), Vector2(4, 3), Vector2(6, 0),
		Vector2(4, -3), Vector2(1, -6)]))
	# Red/blue scarf
	_set_poly_color("ScarfTrail", Color(0.8, 0.05, 0.05, 0.7))
	_set_poly_color("ScarfTrailTip", Color(0.85, 0.1, 0.1, 0.5))
	_set_poly_color("ScarfFront", Color(0.8, 0.05, 0.05))
	_set_poly_color("ScarfKnot", Color(0.7, 0.04, 0.04))
	# Red shoulders, blue boots
	_set_poly_color("ShoulderLeftAccent", Color(0.8, 0.05, 0.05, 0.7))
	_set_poly_color("ShoulderRightAccent", Color(0.8, 0.05, 0.05, 0.7))
	_set_poly_color("BootLeftAccent", Color(0.05, 0.1, 0.4, 0.7))
	_set_poly_color("BootRightAccent", Color(0.05, 0.1, 0.4, 0.7))


func _apply_batman_skin() -> void:
	# === BATMAN: Dark gray/black suit, pointed cowl ears, white slit eyes, cape ===

	_set_poly_color("CoatBack", Color(0.08, 0.08, 0.1))
	_set_poly_color("CoatTailLeft", Color(0.06, 0.06, 0.08))
	_set_poly_color("CoatTailRight", Color(0.06, 0.06, 0.08))
	_set_poly_color("TorsoBase", Color(0.15, 0.15, 0.18))
	_set_poly_color("JacketLapelLeft", Color(0.18, 0.18, 0.22))
	_set_poly_color("JacketLapelRight", Color(0.18, 0.18, 0.22))
	# Dark cowl head
	_set_poly_color("HeadBase", Color(0.08, 0.08, 0.1))
	_set_poly_color("Neck", Color(0.06, 0.06, 0.08))
	# White slit eyes (no pupils visible)
	_set_poly_color("EyeWhiteLeft", Color(0.08, 0.08, 0.1))
	_set_poly_color("EyeWhiteRight", Color(0.08, 0.08, 0.1))
	_set_poly_color("IrisLeft", Color(0.95, 0.95, 1.0))
	_set_poly_color("IrisRight", Color(0.95, 0.95, 1.0))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-5, 0), Vector2(-3, -2), Vector2(0, -3), Vector2(4, -1),
		Vector2(4, 1), Vector2(0, 2), Vector2(-3, 1)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-4, -1), Vector2(0, -3), Vector2(3, -2), Vector2(5, 0),
		Vector2(3, 1), Vector2(0, 2), Vector2(-4, 1)]))
	_set_poly_color("PupilLeft", Color(0.95, 0.95, 1.0, 0.5))
	_set_poly_color("PupilRight", Color(0.95, 0.95, 1.0, 0.5))
	# No mouth — cowl covers lower face
	_set_poly_color("Mouth", Color(0.08, 0.08, 0.1, 0.0))
	# Pointed bat ears from hair
	_set_poly_color("HairBack", Color(0.06, 0.06, 0.08))
	_set_poly_color("HairSpikeTopLeft", Color(0.08, 0.08, 0.1))
	_set_poly_color("HairSpikeTopRight", Color(0.08, 0.08, 0.1))
	_set_poly_color("HairSpikeTop", Color(0.08, 0.08, 0.1, 0.0))
	_set_poly_color("HairSpikeSideLeft", Color(0.06, 0.06, 0.08, 0.0))
	_set_poly_color("HairSpikeSideRight", Color(0.06, 0.06, 0.08, 0.0))
	_set_poly_color("HairFringe", Color(0.08, 0.08, 0.1, 0.0))
	_set_poly_color("HairHighlight1", Color(0.2, 0.2, 0.25, 0.15))
	_set_poly_color("HairHighlight2", Color(0.18, 0.18, 0.22, 0.1))
	# Sharp pointed bat ears
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(0, 0), Vector2(-3, -6), Vector2(-5, -16), Vector2(-4, -22),
		Vector2(-2, -14), Vector2(0, -4), Vector2(1, 0)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(-1, 0), Vector2(0, -4), Vector2(2, -14), Vector2(4, -22),
		Vector2(5, -16), Vector2(3, -6), Vector2(0, 0)]))
	_set_poly_color("BrowLeft", Color(0.08, 0.08, 0.1, 0.0))
	_set_poly_color("BrowRight", Color(0.08, 0.08, 0.1, 0.0))
	# Bat symbol on chest
	_set_poly_color("Emblem", Color(1.0, 0.85, 0.1, 0.9))
	_set_poly_color("EmblemInner", Color(0.02, 0.02, 0.02, 0.9))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-8, -3), Vector2(-6, -5), Vector2(-2, -4), Vector2(0, -6),
		Vector2(2, -4), Vector2(6, -5), Vector2(8, -3), Vector2(6, 2),
		Vector2(3, 5), Vector2(0, 3), Vector2(-3, 5), Vector2(-6, 2)]))
	# Dark cape scarf
	_set_poly_color("ScarfTrail", Color(0.06, 0.06, 0.1, 0.85))
	_set_poly_color("ScarfTrailTip", Color(0.08, 0.08, 0.12, 0.6))
	_set_poly_color("ScarfFront", Color(0.06, 0.06, 0.1))
	_set_poly_color("ScarfKnot", Color(0.05, 0.05, 0.08))
	_set_poly_color("ShoulderLeftAccent", Color(0.12, 0.12, 0.15, 0.7))
	_set_poly_color("ShoulderRightAccent", Color(0.12, 0.12, 0.15, 0.7))
	_set_poly_color("BootLeftAccent", Color(0.08, 0.08, 0.1, 0.6))
	_set_poly_color("BootRightAccent", Color(0.08, 0.08, 0.1, 0.6))


func _apply_iron_man_skin() -> void:
	# === IRON MAN: Red/gold armor, glowing blue arc reactor eyes, helmet ===

	_set_poly_color("CoatBack", Color(0.6, 0.15, 0.05))
	_set_poly_color("CoatTailLeft", Color(0.55, 0.12, 0.04))
	_set_poly_color("CoatTailRight", Color(0.55, 0.12, 0.04))
	_set_poly_color("TorsoBase", Color(0.7, 0.18, 0.06))
	_set_poly_color("JacketLapelLeft", Color(0.85, 0.65, 0.1))
	_set_poly_color("JacketLapelRight", Color(0.85, 0.65, 0.1))
	# Gold/red helmet head
	_set_poly_color("HeadBase", Color(0.85, 0.65, 0.1))
	_set_poly_color("Neck", Color(0.7, 0.18, 0.06))
	# Angular helmet shape
	_set_poly_points("HeadBase", PackedVector2Array([
		Vector2(-11, -8), Vector2(-13, -2), Vector2(-13, 4), Vector2(-11, 9),
		Vector2(-7, 12), Vector2(0, 13), Vector2(7, 12), Vector2(11, 9),
		Vector2(13, 4), Vector2(13, -2), Vector2(11, -8), Vector2(8, -13),
		Vector2(3, -15), Vector2(0, -16), Vector2(-3, -15), Vector2(-8, -13)]))
	# Glowing blue slit eyes
	_set_poly_color("EyeWhiteLeft", Color(0.7, 0.5, 0.08))
	_set_poly_color("EyeWhiteRight", Color(0.7, 0.5, 0.08))
	_set_poly_color("IrisLeft", Color(0.3, 0.8, 1.0))
	_set_poly_color("IrisRight", Color(0.3, 0.8, 1.0))
	_set_poly_points("IrisLeft", PackedVector2Array([
		Vector2(-5, 0), Vector2(-3, -2), Vector2(0, -2), Vector2(4, 0),
		Vector2(0, 1), Vector2(-3, 1)]))
	_set_poly_points("IrisRight", PackedVector2Array([
		Vector2(-4, 0), Vector2(0, -2), Vector2(3, -2), Vector2(5, 0),
		Vector2(3, 1), Vector2(0, 1)]))
	_set_poly_color("PupilLeft", Color(0.5, 0.9, 1.0, 0.6))
	_set_poly_color("PupilRight", Color(0.5, 0.9, 1.0, 0.6))
	# No mouth — faceplate
	_set_poly_color("Mouth", Color(0.7, 0.5, 0.08, 0.0))
	# Smooth helmet top (no hair)
	_set_poly_color("HairBack", Color(0.7, 0.18, 0.06))
	_set_poly_color("HairSpikeTopLeft", Color(0.85, 0.65, 0.1))
	_set_poly_color("HairSpikeTop", Color(0.85, 0.65, 0.1))
	_set_poly_color("HairSpikeTopRight", Color(0.85, 0.65, 0.1))
	_set_poly_color("HairSpikeSideLeft", Color(0.7, 0.5, 0.08, 0.0))
	_set_poly_color("HairSpikeSideRight", Color(0.7, 0.5, 0.08, 0.0))
	_set_poly_color("HairFringe", Color(0.85, 0.65, 0.1))
	_set_poly_color("HairHighlight1", Color(1.0, 0.85, 0.3, 0.25))
	_set_poly_color("HairHighlight2", Color(1.0, 0.8, 0.25, 0.2))
	# Smooth dome
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-8, 2), Vector2(-10, -2), Vector2(-9, -8), Vector2(-6, -12),
		Vector2(-2, -14), Vector2(2, -14), Vector2(6, -12), Vector2(9, -8),
		Vector2(10, -2), Vector2(8, 2)]))
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(0, 2), Vector2(-3, -2), Vector2(-4, -6), Vector2(-2, -9),
		Vector2(1, -8), Vector2(3, -4), Vector2(3, 0)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(0, 2), Vector2(3, -2), Vector2(4, -6), Vector2(2, -9),
		Vector2(-1, -8), Vector2(-3, -4), Vector2(-3, 0)]))
	_set_poly_color("BrowLeft", Color(0.7, 0.5, 0.08))
	_set_poly_color("BrowRight", Color(0.7, 0.5, 0.08))
	# Arc reactor chest emblem (glowing blue circle)
	_set_poly_color("Emblem", Color(0.3, 0.85, 1.0, 0.95))
	_set_poly_color("EmblemInner", Color(0.6, 0.95, 1.0, 0.8))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(-5, -5), Vector2(-6, 0), Vector2(-5, 5), Vector2(0, 6),
		Vector2(5, 5), Vector2(6, 0), Vector2(5, -5), Vector2(0, -6)]))
	# Red/gold accents
	_set_poly_color("ScarfTrail", Color(0.7, 0.18, 0.06, 0.6))
	_set_poly_color("ScarfTrailTip", Color(0.8, 0.25, 0.08, 0.4))
	_set_poly_color("ScarfFront", Color(0.7, 0.18, 0.06))
	_set_poly_color("ScarfKnot", Color(0.6, 0.15, 0.05))
	_set_poly_color("ShoulderLeftAccent", Color(0.85, 0.65, 0.1, 0.7))
	_set_poly_color("ShoulderRightAccent", Color(0.85, 0.65, 0.1, 0.7))
	_set_poly_color("BootLeftAccent", Color(0.7, 0.18, 0.06, 0.6))
	_set_poly_color("BootRightAccent", Color(0.7, 0.18, 0.06, 0.6))


func _apply_god_skin() -> void:
	# === GOD: Radiant white/gold divine being, glowing aura, crown of light ===

	_set_poly_color("CoatBack", Color(1.0, 0.95, 0.7))
	_set_poly_color("CoatTailLeft", Color(0.95, 0.9, 0.65))
	_set_poly_color("CoatTailRight", Color(0.95, 0.9, 0.65))
	_set_poly_color("TorsoBase", Color(1.0, 0.98, 0.8))
	_set_poly_color("JacketLapelLeft", Color(1.0, 1.0, 0.85))
	_set_poly_color("JacketLapelRight", Color(1.0, 1.0, 0.85))
	# Pure radiant white-gold face
	_set_poly_color("HeadBase", Color(1.0, 0.98, 0.85))
	_set_poly_color("Neck", Color(0.95, 0.92, 0.75))
	# Pure glowing white eyes
	_set_poly_color("EyeWhiteLeft", Color(1.0, 1.0, 1.0))
	_set_poly_color("EyeWhiteRight", Color(1.0, 1.0, 1.0))
	_set_poly_color("IrisLeft", Color(1.0, 0.95, 0.5))
	_set_poly_color("IrisRight", Color(1.0, 0.95, 0.5))
	_set_poly_color("PupilLeft", Color(1.0, 1.0, 0.8))
	_set_poly_color("PupilRight", Color(1.0, 1.0, 0.8))
	_set_poly_color("Mouth", Color(0.95, 0.88, 0.65))
	# Massive divine crown of light — tall golden spikes
	_set_poly_color("HairBack", Color(1.0, 0.92, 0.4, 0.5))
	_set_poly_color("HairSpikeTopLeft", Color(1.0, 0.92, 0.3))
	_set_poly_color("HairSpikeTop", Color(1.0, 0.95, 0.4))
	_set_poly_color("HairSpikeTopRight", Color(1.0, 0.92, 0.3))
	_set_poly_color("HairSpikeSideLeft", Color(1.0, 0.88, 0.25))
	_set_poly_color("HairSpikeSideRight", Color(1.0, 0.88, 0.25))
	_set_poly_color("HairFringe", Color(1.0, 0.9, 0.35))
	_set_poly_color("HairHighlight1", Color(1.0, 1.0, 0.85, 0.8))
	_set_poly_color("HairHighlight2", Color(1.0, 1.0, 0.9, 0.7))
	# Tall divine crown spikes
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-2, -4), Vector2(-1, -16), Vector2(0, -34), Vector2(1, -16), Vector2(2, -4)]))
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(-1, -2), Vector2(-5, -10), Vector2(-9, -24), Vector2(-6, -8), Vector2(-2, -2)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(2, -2), Vector2(6, -8), Vector2(9, -24), Vector2(5, -10), Vector2(1, -2)]))
	_set_poly_points("HairSpikeSideLeft", PackedVector2Array([
		Vector2(-8, 2), Vector2(-12, -4), Vector2(-14, -12), Vector2(-10, -2), Vector2(-8, 0)]))
	_set_poly_points("HairSpikeSideRight", PackedVector2Array([
		Vector2(8, 0), Vector2(10, -2), Vector2(14, -12), Vector2(12, -4), Vector2(8, 2)]))
	_set_poly_color("BrowLeft", Color(0.9, 0.85, 0.5))
	_set_poly_color("BrowRight", Color(0.9, 0.85, 0.5))
	# Divine golden scarf
	_set_poly_color("ScarfTrail", Color(1.0, 0.92, 0.4, 0.8))
	_set_poly_color("ScarfTrailTip", Color(1.0, 0.95, 0.55, 0.6))
	_set_poly_color("ScarfFront", Color(1.0, 0.92, 0.4))
	_set_poly_color("ScarfKnot", Color(0.9, 0.82, 0.3))
	# Glowing divine emblem
	_set_poly_color("Emblem", Color(1.0, 1.0, 0.6, 0.95))
	_set_poly_color("EmblemInner", Color(1.0, 1.0, 0.85, 0.8))
	_set_poly_points("Emblem", PackedVector2Array([
		Vector2(0, -7), Vector2(-4, -4), Vector2(-7, 0), Vector2(-4, 4),
		Vector2(0, 7), Vector2(4, 4), Vector2(7, 0), Vector2(4, -4)]))
	_set_poly_color("ShoulderLeftAccent", Color(1.0, 0.95, 0.5, 0.8))
	_set_poly_color("ShoulderRightAccent", Color(1.0, 0.95, 0.5, 0.8))
	_set_poly_color("BootLeftAccent", Color(1.0, 0.9, 0.4, 0.7))
	_set_poly_color("BootRightAccent", Color(1.0, 0.9, 0.4, 0.7))


func _apply_manito_skin() -> void:
	# === MANITO: Yellow Flash — Hokage coat, blonde spiky hair, headband, whisker marks ===

	# Yellow Hokage coat
	_set_poly_color("CoatBack", Color(0.95, 0.82, 0.15))
	_set_poly_color("CoatTailLeft", Color(0.9, 0.78, 0.12))
	_set_poly_color("CoatTailRight", Color(0.9, 0.78, 0.12))
	_set_poly_color("TorsoBase", Color(0.1, 0.12, 0.22))
	_set_poly_color("JacketLapelLeft", Color(0.95, 0.85, 0.18))
	_set_poly_color("JacketLapelRight", Color(0.95, 0.85, 0.18))
	# Skin tone face
	_set_poly_color("HeadBase", Color(0.92, 0.8, 0.68))
	_set_poly_color("Neck", Color(0.88, 0.76, 0.64))
	# Blue eyes
	_set_poly_color("EyeWhiteLeft", Color(0.95, 0.95, 1.0))
	_set_poly_color("EyeWhiteRight", Color(0.95, 0.95, 1.0))
	_set_poly_color("IrisLeft", Color(0.2, 0.5, 0.95))
	_set_poly_color("IrisRight", Color(0.2, 0.5, 0.95))
	_set_poly_color("PupilLeft", Color(0.05, 0.1, 0.3))
	_set_poly_color("PupilRight", Color(0.05, 0.1, 0.3))
	_set_poly_color("Mouth", Color(0.82, 0.68, 0.55))
	# Blonde spiky hair
	_set_poly_color("HairBack", Color(0.95, 0.85, 0.15))
	_set_poly_color("HairSpikeTopLeft", Color(0.95, 0.82, 0.12))
	_set_poly_color("HairSpikeTop", Color(1.0, 0.9, 0.2))
	_set_poly_color("HairSpikeTopRight", Color(0.95, 0.82, 0.12))
	_set_poly_color("HairSpikeSideLeft", Color(0.9, 0.78, 0.1))
	_set_poly_color("HairSpikeSideRight", Color(0.9, 0.78, 0.1))
	_set_poly_color("HairFringe", Color(0.95, 0.85, 0.18))
	_set_poly_color("HairHighlight1", Color(1.0, 0.95, 0.5, 0.6))
	_set_poly_color("HairHighlight2", Color(1.0, 0.92, 0.45, 0.5))
	# Tall spiky Minato-style hair
	_set_poly_points("HairSpikeTop", PackedVector2Array([
		Vector2(-2, -4), Vector2(-1, -12), Vector2(0, -26), Vector2(1, -12), Vector2(2, -4)]))
	_set_poly_points("HairSpikeTopLeft", PackedVector2Array([
		Vector2(-1, -2), Vector2(-4, -8), Vector2(-8, -20), Vector2(-5, -6), Vector2(-2, -2)]))
	_set_poly_points("HairSpikeTopRight", PackedVector2Array([
		Vector2(2, -2), Vector2(5, -6), Vector2(8, -20), Vector2(4, -8), Vector2(1, -2)]))
	_set_poly_points("HairSpikeSideLeft", PackedVector2Array([
		Vector2(-8, 2), Vector2(-11, -3), Vector2(-13, -10), Vector2(-9, -1), Vector2(-8, 0)]))
	_set_poly_points("HairSpikeSideRight", PackedVector2Array([
		Vector2(8, 0), Vector2(9, -1), Vector2(13, -10), Vector2(11, -3), Vector2(8, 2)]))
	_set_poly_color("BrowLeft", Color(0.85, 0.75, 0.15))
	_set_poly_color("BrowRight", Color(0.85, 0.75, 0.15))
	# Dark blue headband scarf
	_set_poly_color("ScarfTrail", Color(0.12, 0.12, 0.3))
	_set_poly_color("ScarfTrailTip", Color(0.15, 0.15, 0.35))
	_set_poly_color("ScarfFront", Color(0.15, 0.15, 0.32))
	_set_poly_color("ScarfKnot", Color(0.5, 0.55, 0.65))  # Metal plate
	# Emblem — Leaf village symbol
	_set_poly_color("Emblem", Color(0.9, 0.3, 0.1, 0.9))
	_set_poly_color("EmblemInner", Color(1.0, 0.5, 0.2, 0.7))
	# Dark pants and sandals
	_set_poly_color("ShoulderLeftAccent", Color(0.95, 0.85, 0.2, 0.6))
	_set_poly_color("ShoulderRightAccent", Color(0.95, 0.85, 0.2, 0.6))
	_set_poly_color("BootLeftAccent", Color(0.12, 0.12, 0.2))
	_set_poly_color("BootRightAccent", Color(0.12, 0.12, 0.2))


# --- Physics helpers ---

func _apply_gravity(delta: float) -> void:
	if not is_on_floor():
		velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL_SPEED)


func _check_landing() -> void:
	if is_on_floor():
		if not _was_on_floor_last:
			_anim_land_squash()
			_spawn_dust(global_position + Vector2(0, 4))
		_was_on_floor_last = true
		jump_count = 0
		was_on_floor = true
		coyote_timer = COYOTE_TIME
	else:
		_was_on_floor_last = false
		if was_on_floor and jump_count == 0:
			coyote_timer -= get_physics_process_delta_time()
			if coyote_timer <= 0.0:
				jump_count = 0  # Keep at 0 so you still get full double jump while falling
				was_on_floor = false


func respawn(spawn_position: Vector2) -> void:
	global_position = spawn_position
	velocity = Vector2.ZERO
	jump_count = 0
	damage_percent = 0.0
	hitstun_timer = 0.0
	invuln_timer = INVULN_TIME
	is_charging = false
	is_dashing = false
	is_super_winding = false
	dash_timer = 0.0
	slow_timer = 0.0
	slow_multiplier = 1.0
	drop_through_timer = 0.0
	set_collision_mask_value(2, true)
	_end_attack()
	# Stop laser beam
	laser_active = false
	laser_timer = 0.0
	if _laser_beam_node:
		_laser_beam_node.queue_free()
		_laser_beam_node = null
	# Reset new weapon states
	block_active = false
	block_timer = 0.0
	poison_timer = 0.0
	poison_dps = 0.0
	vortex_active = false
	vortex_timer = 0.0
	lifesteal_active = false
	# Deactivate rage on respawn but keep meter progress
	if rage_active:
		_deactivate_rage()


func on_ko_scored() -> void:
	if rage_available and not rage_active:
		_fill_rage_meter(RAGE_FILL_KO)


# ============================================================
# RAGE MODE
# ============================================================

func _fill_rage_meter(amount: float) -> void:
	rage_meter = minf(rage_meter + amount, RAGE_METER_MAX)


func _activate_rage() -> void:
	rage_active = true
	rage_timer = RAGE_DURATION
	rage_meter = 0.0
	_spawn_rage_burst()
	_create_rage_glow()


func _deactivate_rage() -> void:
	rage_active = false
	rage_timer = 0.0
	if _rage_glow_node:
		_rage_glow_node.queue_free()
		_rage_glow_node = null


func _create_rage_glow() -> void:
	if _rage_glow_node:
		_rage_glow_node.queue_free()
	_rage_glow_node = Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(16):
		var angle := float(i) / 16.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 22.0)
	_rage_glow_node.polygon = pts
	_rage_glow_node.color = Color(rage_color.r, rage_color.g, rage_color.b, 0.2)
	_rage_glow_node.z_index = -1
	visuals.add_child(_rage_glow_node)


func _update_rage_glow() -> void:
	if _rage_glow_node:
		var pulse_speed := lerpf(3.0, 12.0, 1.0 - (rage_timer / RAGE_DURATION))
		var alpha := 0.15 + 0.15 * sin(rage_timer * pulse_speed)
		_rage_glow_node.color = Color(rage_color.r, rage_color.g, rage_color.b, alpha)
		var scale_pulse := 1.0 + 0.1 * sin(rage_timer * pulse_speed * 0.7)
		_rage_glow_node.scale = Vector2.ONE * scale_pulse


func _spawn_rage_burst() -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Big expanding ring using skin rage color
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(20):
		var angle := float(i) / 20.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 8.0)
	ring.polygon = pts
	ring.color = Color(rage_color.r, rage_color.g, rage_color.b, 0.8)
	ring.global_position = global_position
	parent.add_child(ring)
	var tw := _safe_create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2.ONE * 10.0, 0.4).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, 0.5)
	tw.chain().tween_callback(ring.queue_free)
	# Particles using skin rage color with slight variation
	for i in range(12):
		var flame := Polygon2D.new()
		flame.polygon = PackedVector2Array([Vector2(-3, 2), Vector2(0, -4), Vector2(3, 2)])
		var vary := randf_range(-0.15, 0.15)
		flame.color = Color(clampf(rage_color.r + vary, 0.0, 1.0), clampf(rage_color.g + vary, 0.0, 1.0), clampf(rage_color.b * 0.5, 0.0, 1.0), 0.9)
		flame.global_position = global_position
		parent.add_child(flame)
		var fangle := randf() * TAU
		var target := global_position + Vector2(cos(fangle), sin(fangle)) * randf_range(30.0, 60.0)
		var ftw := _safe_create_tween()
		ftw.set_parallel(true)
		ftw.tween_property(flame, "global_position", target, 0.3).set_ease(Tween.EASE_OUT)
		ftw.tween_property(flame, "modulate:a", 0.0, 0.35)
		ftw.chain().tween_callback(flame.queue_free)


# ============================================================
# ANIMATIONS
# ============================================================

func _animate(delta: float) -> void:
	_anim_time += delta
	_update_weapon_aura(delta)
	var face_sign := 1.0 if facing_right else -1.0

	if is_dashing:
		# Horizontal stretch during dash
		visuals.scale = Vector2(face_sign * 1.3, 0.75)
		visuals.position = Vector2.ZERO
		visuals.rotation = 0.0
		return

	if hitstun_timer > 0.0:
		# Shake during hitstun
		visuals.position = Vector2(randf_range(-2.0, 2.0), randf_range(-1.0, 1.0))
		visuals.rotation = 0.0
		visuals.scale = Vector2(face_sign, 1.0)
		return

	if is_super_winding:
		# Thor windup: intense vibrate on top of tween animation
		var r := 1.5
		visuals.position += Vector2(randf_range(-r, r), randf_range(-r * 0.5, r * 0.5))
		return

	if is_charging:
		# Vibrate during charge, intensity scales with charge_ratio
		var r := charge_ratio * 2.0
		visuals.position = Vector2(randf_range(-r, r), randf_range(-r * 0.5, r * 0.5))
		visuals.rotation = 0.0
		visuals.scale = Vector2(face_sign, 1.0)
		return

	if is_on_floor():
		var moving := absf(velocity.x) > 30.0
		if moving:
			# Running: squish X to look sideways, bounce, lean forward
			var bounce := absf(sin(_anim_time * 12.0)) * -2.5
			var lean := face_sign * 0.2
			visuals.position = Vector2(face_sign * 2.0, bounce)
			visuals.rotation = lean
			visuals.scale = Vector2(face_sign * 0.7, 1.05)
		else:
			# Idle: gentle bob
			visuals.position = Vector2(0.0, sin(_anim_time * 3.0) * 1.5)
			visuals.rotation = 0.0
			visuals.scale = Vector2(face_sign, 1.0)
	else:
		if velocity.y < 0.0:
			# Jumping up: vertical stretch
			visuals.position = Vector2.ZERO
			visuals.rotation = 0.0
			visuals.scale = Vector2(face_sign * 0.9, 1.12)
		else:
			# Falling: slight stretch
			visuals.position = Vector2.ZERO
			visuals.rotation = 0.0
			visuals.scale = Vector2(face_sign * 0.95, 1.05)


func _anim_land_squash() -> void:
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()
	var face_sign := 1.0 if facing_right else -1.0
	visuals.scale = Vector2(face_sign * 1.15, 0.85)
	_attack_tween = create_tween()
	_attack_tween.tween_property(visuals, "scale", Vector2(face_sign, 1.0), 0.15).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


func _anim_attack_swing() -> void:
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()
	var face_sign := 1.0 if facing_right else -1.0
	if weapon_id == "thors_hammer":
		# Heavier, slower swing for the hammer
		visuals.rotation = face_sign * 0.45
		visuals.position = Vector2(face_sign * 4.0, 2.0)
		visuals.scale = Vector2(face_sign * 1.1, 0.92)
		_attack_tween = create_tween()
		_attack_tween.set_parallel(true)
		_attack_tween.tween_property(visuals, "rotation", 0.0, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		_attack_tween.tween_property(visuals, "position", Vector2.ZERO, 0.25).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
		_attack_tween.tween_property(visuals, "scale", Vector2(face_sign, 1.0), 0.2).set_ease(Tween.EASE_OUT)
	else:
		var swing_dir := face_sign * 0.25
		visuals.rotation = swing_dir
		_attack_tween = create_tween()
		_attack_tween.tween_property(visuals, "rotation", 0.0, 0.1).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)


func _anim_thor_windup() -> void:
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()
	var face_sign := 1.0 if facing_right else -1.0
	var windup_time: float = SUPER_STATS["thors_hammer"].get("windup", 0.55)
	# Slowly raise up and lean back (winding up the hammer)
	_attack_tween = create_tween()
	_attack_tween.set_parallel(true)
	_attack_tween.tween_property(visuals, "rotation", -face_sign * 0.5, windup_time * 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_attack_tween.tween_property(visuals, "position", Vector2(-face_sign * 4.0, -6.0), windup_time * 0.8).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_QUAD)
	_attack_tween.tween_property(visuals, "scale", Vector2(face_sign * 1.1, 1.15), windup_time * 0.8).set_ease(Tween.EASE_IN)


func _anim_thor_slam() -> void:
	if _attack_tween and _attack_tween.is_valid():
		_attack_tween.kill()
	var face_sign := 1.0 if facing_right else -1.0
	# Slam down hard — fast swing forward
	visuals.rotation = face_sign * 0.6
	visuals.position = Vector2(face_sign * 6.0, 4.0)
	visuals.scale = Vector2(face_sign * 1.2, 0.85)
	_attack_tween = create_tween()
	_attack_tween.set_parallel(true)
	_attack_tween.tween_property(visuals, "rotation", 0.0, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_attack_tween.tween_property(visuals, "position", Vector2.ZERO, 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)
	_attack_tween.tween_property(visuals, "scale", Vector2(face_sign, 1.0), 0.2).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_ELASTIC)


# ============================================================
# VISUAL EFFECTS
# ============================================================

func _spawn_hit_spark(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	for i in range(5):
		var spark := Polygon2D.new()
		spark.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -2), Vector2(2, 0), Vector2(0, 2)])
		spark.color = Color(1.0, 1.0, 0.7, 0.9) if i % 2 == 0 else Color(1.0, 0.9, 0.4, 0.9)
		spark.global_position = pos
		parent.add_child(spark)
		var angle := randf() * TAU
		var dist := randf_range(15.0, 40.0)
		var target_pos := pos + Vector2(cos(angle), sin(angle)) * dist
		var tw := _safe_create_tween()
		tw.set_parallel(true)
		tw.tween_property(spark, "global_position", target_pos, 0.2).set_ease(Tween.EASE_OUT)
		tw.tween_property(spark, "modulate:a", 0.0, 0.2)
		tw.chain().tween_callback(spark.queue_free)


func _spawn_dust(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	for i in range(4):
		var dust := Polygon2D.new()
		dust.polygon = PackedVector2Array([Vector2(-2, -1), Vector2(0, -2), Vector2(2, -1), Vector2(2, 1), Vector2(0, 2), Vector2(-2, 1)])
		dust.color = Color(0.6, 0.55, 0.5, 0.5)
		dust.global_position = pos
		parent.add_child(dust)
		var dir_x := randf_range(-30.0, 30.0)
		var target_pos := pos + Vector2(dir_x, randf_range(-8.0, -2.0))
		var tw := _safe_create_tween()
		tw.set_parallel(true)
		tw.tween_property(dust, "global_position", target_pos, 0.15).set_ease(Tween.EASE_OUT)
		tw.tween_property(dust, "modulate:a", 0.0, 0.15)
		tw.chain().tween_callback(dust.queue_free)


func _spawn_dash_ghost() -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Create a simple silhouette polygon at current position
	var ghost := Polygon2D.new()
	ghost.polygon = PackedVector2Array([
		Vector2(-6, -16), Vector2(6, -16), Vector2(8, -8), Vector2(8, 8),
		Vector2(4, 16), Vector2(-4, 16), Vector2(-8, 8), Vector2(-8, -8)
	])
	ghost.color = Color(0.5, 0.2, 0.8, 0.4)
	ghost.global_position = global_position
	var face_sign := 1.0 if facing_right else -1.0
	ghost.scale = Vector2(face_sign, 1.0)
	parent.add_child(ghost)
	var tw := _safe_create_tween()
	tw.tween_property(ghost, "modulate:a", 0.0, 0.15)
	tw.tween_callback(ghost.queue_free)


func _spawn_super_burst(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Big expanding shockwave ring
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	var segments := 20
	for i in range(segments):
		var angle := float(i) / float(segments) * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 6.0)
	ring.polygon = pts
	ring.color = Color(1.0, 0.8, 0.2, 0.7)
	ring.global_position = pos
	parent.add_child(ring)
	var tw := _safe_create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2.ONE * 12.0, 0.3).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, 0.35)
	tw.chain().tween_callback(ring.queue_free)
	# Extra big sparks shooting outward
	for i in range(8):
		var spark := Polygon2D.new()
		spark.polygon = PackedVector2Array([Vector2(-3, 0), Vector2(0, -3), Vector2(3, 0), Vector2(0, 3)])
		spark.color = Color(1.0, 1.0, 0.3, 1.0) if i % 2 == 0 else Color(1.0, 0.6, 0.1, 1.0)
		spark.global_position = pos
		parent.add_child(spark)
		var angle := float(i) / 8.0 * TAU
		var target := pos + Vector2(cos(angle), sin(angle)) * randf_range(40.0, 70.0)
		var stw := _safe_create_tween()
		stw.set_parallel(true)
		stw.tween_property(spark, "global_position", target, 0.25).set_ease(Tween.EASE_OUT)
		stw.tween_property(spark, "modulate:a", 0.0, 0.3)
		stw.chain().tween_callback(spark.queue_free)


func _spawn_nova_ring(radius: float) -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Create expanding ring
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	var segments := 24
	for i in range(segments):
		var angle := float(i) / float(segments) * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 8.0)
	ring.polygon = pts
	ring.color = Color(0.5, 0.8, 1.0, 0.5)
	ring.global_position = global_position
	parent.add_child(ring)
	var target_scale := radius / 8.0
	var tw := _safe_create_tween()
	tw.set_parallel(true)
	tw.tween_property(ring, "scale", Vector2.ONE * target_scale, 0.2).set_ease(Tween.EASE_OUT)
	tw.tween_property(ring, "modulate:a", 0.0, 0.25)
	tw.chain().tween_callback(ring.queue_free)


func _spawn_thor_ground_shockwave() -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Two ground-level shockwave lines expanding outward
	for side in [-1.0, 1.0]:
		var wave := Polygon2D.new()
		wave.polygon = PackedVector2Array([
			Vector2(0, -4), Vector2(10, -6), Vector2(20, -3), Vector2(30, -5),
			Vector2(30, 2), Vector2(20, 4), Vector2(10, 1), Vector2(0, 3)
		])
		wave.color = Color(1.0, 0.9, 0.3, 0.8)
		wave.global_position = global_position + Vector2(0, 4)
		wave.scale.x = side
		parent.add_child(wave)
		var tw := _safe_create_tween()
		tw.set_parallel(true)
		tw.tween_property(wave, "global_position", wave.global_position + Vector2(side * 120.0, 0), 0.3).set_ease(Tween.EASE_OUT)
		tw.tween_property(wave, "scale", Vector2(side * 3.0, 2.0), 0.3).set_ease(Tween.EASE_OUT)
		tw.tween_property(wave, "modulate:a", 0.0, 0.35)
		tw.chain().tween_callback(wave.queue_free)
	# Ground crack particles
	for i in range(6):
		var rock := Polygon2D.new()
		rock.polygon = PackedVector2Array([Vector2(-3, -2), Vector2(0, -3), Vector2(3, -1), Vector2(2, 2), Vector2(-2, 3)])
		rock.color = Color(0.6, 0.5, 0.3, 0.8)
		rock.global_position = global_position + Vector2(randf_range(-40, 40), 2)
		parent.add_child(rock)
		var target := rock.global_position + Vector2(randf_range(-20, 20), randf_range(-30, -10))
		var tw := _safe_create_tween()
		tw.set_parallel(true)
		tw.tween_property(rock, "global_position", target, 0.25).set_ease(Tween.EASE_OUT)
		tw.tween_property(rock, "modulate:a", 0.0, 0.3)
		tw.chain().tween_callback(rock.queue_free)


func _spawn_shadow_cross_slash(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Two crossing slash lines forming an X
	for angle_offset in [-0.4, 0.4]:
		var slash := Polygon2D.new()
		slash.polygon = PackedVector2Array([
			Vector2(-30, -2), Vector2(-20, -3), Vector2(30, 2), Vector2(20, 3)
		])
		slash.color = Color(0.6, 0.2, 1.0, 0.9)
		slash.global_position = pos
		slash.rotation = angle_offset
		parent.add_child(slash)
		var tw := _safe_create_tween()
		tw.set_parallel(true)
		tw.tween_property(slash, "scale", Vector2(2.5, 1.5), 0.15).set_ease(Tween.EASE_OUT)
		tw.tween_property(slash, "modulate:a", 0.0, 0.25)
		tw.chain().tween_callback(slash.queue_free)
	# Purple shadow particles
	for i in range(8):
		var shard := Polygon2D.new()
		shard.polygon = PackedVector2Array([Vector2(-2, 0), Vector2(0, -3), Vector2(2, 0), Vector2(0, 3)])
		shard.color = Color(0.5, 0.1, 0.9, 0.8) if i % 2 == 0 else Color(0.8, 0.3, 1.0, 0.8)
		shard.global_position = pos
		parent.add_child(shard)
		var angle := randf() * TAU
		var target := pos + Vector2(cos(angle), sin(angle)) * randf_range(25, 55)
		var tw := _safe_create_tween()
		tw.set_parallel(true)
		tw.tween_property(shard, "global_position", target, 0.2).set_ease(Tween.EASE_OUT)
		tw.tween_property(shard, "modulate:a", 0.0, 0.25)
		tw.chain().tween_callback(shard.queue_free)


func _spawn_frost_explosion(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Ice crystal shards flying outward
	for i in range(10):
		var crystal := Polygon2D.new()
		crystal.polygon = PackedVector2Array([Vector2(0, -5), Vector2(2, -1), Vector2(2, 1), Vector2(0, 5), Vector2(-2, 1), Vector2(-2, -1)])
		crystal.color = Color(0.6, 0.85, 1.0, 0.9) if i % 2 == 0 else Color(0.8, 0.95, 1.0, 0.8)
		crystal.global_position = pos
		crystal.rotation = randf() * TAU
		parent.add_child(crystal)
		var angle := float(i) / 10.0 * TAU + randf_range(-0.2, 0.2)
		var dist := randf_range(35, 70)
		var target := pos + Vector2(cos(angle), sin(angle)) * dist
		var tw := _safe_create_tween()
		tw.set_parallel(true)
		tw.tween_property(crystal, "global_position", target, 0.25).set_ease(Tween.EASE_OUT)
		tw.tween_property(crystal, "rotation", crystal.rotation + randf_range(-2, 2), 0.25)
		tw.tween_property(crystal, "modulate:a", 0.0, 0.3)
		tw.chain().tween_callback(crystal.queue_free)
	# Expanding frost ring
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(16):
		var angle := float(i) / 16.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 5.0)
	ring.polygon = pts
	ring.color = Color(0.5, 0.8, 1.0, 0.6)
	ring.global_position = pos
	parent.add_child(ring)
	var ring_tw := _safe_create_tween()
	ring_tw.set_parallel(true)
	ring_tw.tween_property(ring, "scale", Vector2.ONE * 15.0, 0.25).set_ease(Tween.EASE_OUT)
	ring_tw.tween_property(ring, "modulate:a", 0.0, 0.3)
	ring_tw.chain().tween_callback(ring.queue_free)


func _spawn_dragon_fire_burst(pos: Vector2) -> void:
	var parent := get_parent()
	if parent == null:
		return
	# Fire particles going upward (dragon fire)
	for i in range(12):
		var flame := Polygon2D.new()
		flame.polygon = PackedVector2Array([Vector2(-3, 2), Vector2(0, -4), Vector2(3, 2)])
		var r := randf()
		if r < 0.33:
			flame.color = Color(1.0, 0.3, 0.1, 0.9)  # Red-orange
		elif r < 0.66:
			flame.color = Color(1.0, 0.6, 0.0, 0.9)  # Orange
		else:
			flame.color = Color(1.0, 1.0, 0.2, 0.9)  # Yellow
		flame.global_position = pos + Vector2(randf_range(-15, 15), randf_range(-5, 5))
		parent.add_child(flame)
		var target := flame.global_position + Vector2(randf_range(-25, 25), randf_range(-50, -20))
		var tw := _safe_create_tween()
		tw.set_parallel(true)
		tw.tween_property(flame, "global_position", target, 0.3).set_ease(Tween.EASE_OUT)
		tw.tween_property(flame, "scale", Vector2(0.3, 0.3), 0.3)
		tw.tween_property(flame, "modulate:a", 0.0, 0.35)
		tw.chain().tween_callback(flame.queue_free)
	# Expanding fire ring
	var ring := Polygon2D.new()
	var pts := PackedVector2Array()
	for i in range(16):
		var angle := float(i) / 16.0 * TAU
		pts.append(Vector2(cos(angle), sin(angle)) * 5.0)
	ring.polygon = pts
	ring.color = Color(1.0, 0.5, 0.1, 0.6)
	ring.global_position = pos
	parent.add_child(ring)
	var ring_tw := _safe_create_tween()
	ring_tw.set_parallel(true)
	ring_tw.tween_property(ring, "scale", Vector2.ONE * 10.0, 0.2).set_ease(Tween.EASE_OUT)
	ring_tw.tween_property(ring, "modulate:a", 0.0, 0.25)
	ring_tw.chain().tween_callback(ring.queue_free)


# ============================================================
# AI BRAIN
# ============================================================

# Trophy-based difficulty scaling:
# 0 trophies = easy AI, scales aggressively as trophies rise
# Uses exponential/quadratic curves so difficulty ramps up hard at high trophies
# 0-15 trophies = beginner, 15-30 = intermediate, 30-50 = hard, 50+ = max
func _ai_reaction_time() -> float:
	# Lower = faster reactions. 0.18s at 0 trophies → 0.02s at 50+
	var t := clampf(float(trophy_count) / 50.0, 0.0, 1.0)
	var diff := t * t  # quadratic: slow improvement early, fast improvement late
	return lerpf(0.18, 0.02, diff)

func _ai_retreat_time() -> float:
	# Lower = less retreating. 0.4s at 0 trophies → 0.05s at 50+
	var t := clampf(float(trophy_count) / 50.0, 0.0, 1.0)
	var diff := t * t
	return lerpf(0.4, 0.05, diff)

func _ai_aggression() -> float:
	# Higher = more heavy attacks and combos. 0.05 at 0 → 1.0 at 40+
	var t := clampf(float(trophy_count) / 40.0, 0.0, 1.0)
	return t * t  # quadratic: stays tame early, ramps fast

func _ai_jump_skill() -> float:
	# Higher = better at chasing with jumps. 0.1 at 0 → 1.0 at 35+
	var t := clampf(float(trophy_count) / 35.0, 0.0, 1.0)
	return t * t

func _ai_dodge_skill() -> float:
	# Higher = better at dodging/spacing. 0.0 at 0 → 0.8 at 50+
	var t := clampf(float(trophy_count) / 50.0, 0.0, 1.0)
	return t * t * 0.8

func _ai_combo_skill() -> float:
	# Higher = chains attacks better. 0.0 at 0 → 1.0 at 45+
	var t := clampf(float(trophy_count) / 45.0, 0.0, 1.0)
	return t * t


func _pick_nearest_enemy() -> void:
	if enemies.is_empty():
		return
	var best: CharacterBody2D = null
	var best_dist := 99999.0
	for e in enemies:
		if is_instance_valid(e):
			var d := global_position.distance_to(e.global_position)
			if d < best_dist:
				best_dist = d
				best = e
	if best != null:
		opponent = best


func _run_ai_brain(delta: float) -> void:
	# In 2v2, periodically re-evaluate target
	if not enemies.is_empty():
		if not is_instance_valid(opponent) or ("team_id" in opponent and opponent.team_id == team_id):
			_pick_nearest_enemy()
		elif randf() < 0.02:
			_pick_nearest_enemy()
	if not is_instance_valid(opponent):
		return

	# Practice mode: only recover when falling off stage, otherwise stand still
	if practice_mode:
		_run_ai_practice(delta)
		return

	ai_reaction_timer -= delta
	ai_action_timer -= delta
	ai_retreat_timer -= delta

	if ai_state == AIState.CHARGE_ATTACK:
		_ai_charge_hold(delta)
		return

	if ai_reaction_timer > 0.0:
		return

	var my_pos := global_position
	var target_pos := opponent.global_position
	var dist := my_pos.distance_to(target_pos)
	var dx := target_pos.x - my_pos.x
	var dy := target_pos.y - my_pos.y

	var off_stage := _is_off_stage(my_pos)
	var target_off_stage := _is_off_stage(target_pos)

	# Attack range varies by weapon
	var attack_range := AI_ATTACK_RANGE
	if weapon_id == "frost_staff":
		attack_range = 180.0

	# Decide state
	if off_stage and not is_on_floor():
		ai_state = AIState.RECOVER
	elif ai_retreat_timer > 0.0:
		ai_state = AIState.RETREAT
	elif target_off_stage and opponent.damage_percent > 40.0:
		ai_state = AIState.EDGE_GUARD
	elif dist < attack_range * 0.6 and opponent.is_attacking and randf() < _ai_dodge_skill():
		# Dodge: retreat when opponent is swinging nearby (high trophy AI reads attacks)
		ai_retreat_timer = _ai_retreat_time() * 0.8
		ai_state = AIState.RETREAT
	elif dist < attack_range and ai_action_timer <= 0.0:
		ai_state = AIState.ATTACK
	else:
		ai_state = AIState.CHASE

	match ai_state:
		AIState.CHASE:
			_ai_chase(dx, dy, dist)
		AIState.ATTACK:
			_ai_attack(dx)
		AIState.RETREAT:
			_ai_retreat(dx)
		AIState.RECOVER:
			_ai_recover(my_pos)
		AIState.EDGE_GUARD:
			_ai_edge_guard(dx, target_pos)


func _run_ai_practice(_delta: float) -> void:
	ai_input_dir = 0.0
	ai_wants_jump = false
	ai_wants_light = false
	ai_wants_heavy = false

	var my_pos := global_position

	# Only recover when truly falling off-stage (below all platforms)
	if my_pos.y > 250.0 and not is_on_floor():
		_ai_recover(my_pos)
	else:
		# Stand completely still — on platform or just airborne from a hit
		ai_input_dir = 0.0


func _ai_chase(dx: float, dy: float, dist: float) -> void:
	if absf(dx) > 16.0:
		ai_input_dir = signf(dx)
	else:
		ai_input_dir = 0.0

	# Jump to chase — scales with trophy skill
	var jump_threshold := lerpf(-50.0, -30.0, _ai_jump_skill())
	if dy < jump_threshold and ai_jump_cooldown <= 0.0:
		if is_on_floor() or (jump_count < MAX_JUMPS and not is_on_floor()):
			ai_wants_jump = true
			var jump_cd := lerpf(0.25, 0.15, _ai_jump_skill())
			ai_jump_cooldown = jump_cd + randf() * 0.1

	if dist > AI_CLOSE_RANGE and absf(dy) < 30.0:
		ai_input_dir = signf(dx)

	if dy > 60.0 and absf(dx) < 50.0 and ai_jump_cooldown <= 0.0:
		ai_input_dir = signf(dx)


func _ai_attack(dx: float) -> void:
	ai_input_dir = signf(dx) * 0.3

	var wpn: Dictionary = WEAPONS[weapon_id]
	if wpn.get("charge_capable", false):
		_ai_charge_attack(dx, wpn)
	else:
		var sec_type: String = wpn.get("secondary_type", "normal")
		match sec_type:
			"dash":
				_ai_shadow_blade_attack()
			"aoe":
				_ai_frost_staff_attack()
			"uppercut":
				_ai_dragon_gauntlets_attack()
			"blink", "multi_shot", "pull", "rain", "poison", "lifesteal", "vortex", "impale", "block":
				_ai_fists_attack()
			_:
				_ai_fists_attack()


func _ai_fists_attack() -> void:
	var heavy_threshold := lerpf(80.0, 30.0, _ai_aggression())
	if opponent.damage_percent > heavy_threshold and heavy_cooldown <= 0.0:
		ai_wants_heavy = true
		ai_action_timer = lerpf(0.35, 0.15, _ai_combo_skill()) + randf() * 0.15
		ai_retreat_timer = _ai_retreat_time()
		ai_reaction_timer = _ai_reaction_time()
	elif light_cooldown <= 0.0:
		ai_wants_light = true
		# Combo skill: chain light attacks faster at high trophies
		ai_action_timer = lerpf(0.18, 0.06, _ai_combo_skill()) + randf() * 0.08
		if opponent.damage_percent > 50.0 and randf() < 0.4 + _ai_combo_skill() * 0.3:
			ai_retreat_timer = 0.0  # Keep pressure on damaged opponents
		else:
			ai_retreat_timer = _ai_retreat_time() * 0.5
		ai_reaction_timer = _ai_reaction_time()


func _ai_shadow_blade_attack() -> void:
	if light_cooldown <= 0.0:
		ai_wants_light = true
		ai_action_timer = lerpf(0.12, 0.04, _ai_combo_skill()) + randf() * 0.06
		ai_reaction_timer = _ai_reaction_time() * 0.7
		# Chance to follow up with dash scales with trophies
		var dash_chance := lerpf(0.2, 0.65, _ai_aggression())
		if opponent.damage_percent > 40.0 and heavy_cooldown <= 0.0 and randf() < dash_chance:
			ai_wants_heavy = true
			ai_retreat_timer = _ai_retreat_time() * 0.2
		else:
			ai_retreat_timer = _ai_retreat_time() * 0.3


func _ai_frost_staff_attack() -> void:
	var dist := global_position.distance_to(opponent.global_position)
	if dist < 60.0 and heavy_cooldown <= 0.0 and randf() < 0.6:
		# Close range: frost nova
		ai_wants_heavy = true
		ai_action_timer = 0.4 + randf() * 0.2
		ai_retreat_timer = _ai_retreat_time()
		ai_reaction_timer = _ai_reaction_time()
	elif light_cooldown <= 0.0:
		# Fire icicle
		ai_wants_light = true
		ai_action_timer = 0.3 + randf() * 0.15
		ai_retreat_timer = _ai_retreat_time() * 0.2
		ai_reaction_timer = _ai_reaction_time()


func _ai_dragon_gauntlets_attack() -> void:
	var uppercut_threshold := lerpf(70.0, 25.0, _ai_aggression())
	if opponent.damage_percent > uppercut_threshold and heavy_cooldown <= 0.0 and randf() < 0.5 + _ai_aggression() * 0.35:
		# Try uppercut finisher
		ai_wants_heavy = true
		ai_action_timer = lerpf(0.35, 0.15, _ai_combo_skill()) + randf() * 0.15
		ai_retreat_timer = _ai_retreat_time()
		ai_reaction_timer = _ai_reaction_time()
	elif light_cooldown <= 0.0:
		ai_wants_light = true
		# Dragon gauntlets: rapid punches chain faster with combo skill
		ai_action_timer = lerpf(0.1, 0.03, _ai_combo_skill()) + randf() * 0.04
		ai_reaction_timer = _ai_reaction_time() * 0.5
		ai_retreat_timer = _ai_retreat_time() * 0.2


func _ai_charge_attack(_dx: float, wpn: Dictionary) -> void:
	var opp_dmg: float = opponent.damage_percent

	if randf() < 0.3 and heavy_cooldown <= 0.0:
		ai_wants_heavy = true
		ai_action_timer = 0.2
		ai_retreat_timer = _ai_retreat_time() * 0.4
		ai_reaction_timer = _ai_reaction_time()
		return

	if light_cooldown <= 0.0 and not is_charging:
		if opp_dmg < 40.0:
			ai_charge_target_time = randf_range(0.1, 0.4)
		elif opp_dmg < 80.0:
			ai_charge_target_time = randf_range(0.5, 0.9)
		else:
			ai_charge_target_time = randf_range(1.0, wpn["max_charge_time"])

		if randf() < 0.15:
			ai_charge_target_time *= randf_range(0.2, 0.5)

		ai_wants_light = true
		ai_wants_light_held = true
		ai_charge_timer = 0.0
		ai_state = AIState.CHARGE_ATTACK


func _ai_charge_hold(delta: float) -> void:
	ai_charge_timer += delta
	ai_wants_light_held = true

	if is_instance_valid(opponent):
		var dx := opponent.global_position.x - global_position.x
		ai_input_dir = signf(dx) * 0.2

	if ai_charge_timer >= ai_charge_target_time:
		ai_wants_light_held = false
		ai_wants_light_released = true
		ai_retreat_timer = _ai_retreat_time()
		ai_action_timer = 0.3 + randf() * 0.2
		ai_reaction_timer = _ai_reaction_time()
		ai_state = AIState.RETREAT


func _ai_retreat(dx: float) -> void:
	ai_input_dir = -signf(dx)
	if absf(dx) < 30.0 and ai_jump_cooldown <= 0.0 and is_on_floor():
		ai_wants_jump = true
		ai_jump_cooldown = 0.3


func _ai_recover(my_pos: Vector2) -> void:
	var nearest_plat := PLATFORMS[0]
	var nearest_dist := 99999.0
	for plat in PLATFORMS:
		var d: float = my_pos.distance_to(plat["pos"])
		if d < nearest_dist:
			nearest_dist = d
			nearest_plat = plat

	var target_x: float = nearest_plat["pos"].x
	ai_input_dir = signf(target_x - my_pos.x) if absf(target_x - my_pos.x) > 10.0 else 0.0

	if jump_count < MAX_JUMPS and ai_jump_cooldown <= 0.0:
		ai_wants_jump = true
		ai_jump_cooldown = 0.2


func _ai_edge_guard(dx: float, target_pos: Vector2) -> void:
	var edge_x := clampf(target_pos.x, -280.0, 280.0)
	var to_edge := edge_x - global_position.x

	if absf(to_edge) > 20.0:
		ai_input_dir = signf(to_edge)
	else:
		ai_input_dir = 0.0
		# At high trophies, edge-guard more aggressively with both light and heavy
		var guard_range := lerpf(AI_ATTACK_RANGE * 1.3, AI_ATTACK_RANGE * 2.0, _ai_aggression())
		if absf(dx) < guard_range:
			if heavy_cooldown <= 0.0 and (opponent.damage_percent > 60.0 or randf() < _ai_aggression() * 0.5):
				ai_wants_heavy = true
				ai_action_timer = lerpf(0.4, 0.2, _ai_combo_skill())
				ai_reaction_timer = _ai_reaction_time()
			elif light_cooldown <= 0.0:
				ai_wants_light = true
				ai_action_timer = lerpf(0.3, 0.1, _ai_combo_skill())
				ai_reaction_timer = _ai_reaction_time()


func _is_off_stage(pos: Vector2) -> bool:
	for plat in PLATFORMS:
		var px: float = plat["pos"].x
		var hw: float = plat["half_w"]
		var py: float = plat["pos"].y
		if pos.x > px - hw and pos.x < px + hw and pos.y < py and pos.y > py - 200.0:
			return false
	return true
