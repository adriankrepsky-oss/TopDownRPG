extends CharacterBody2D
class_name BossEnemy

const ENEMY_PROJECTILE_SCENE := preload("res://scenes/EnemyProjectile.tscn")
const COIN_PICKUP_SCENE := preload("res://scenes/CoinPickup.tscn")
const SLIME_SCENE := preload("res://scenes/Slime.tscn")

@export_enum("orbit", "charger", "burst", "summoner", "teleporter", "bombardier", "finale") var behavior_mode := "orbit"
@export var boss_name := "Boss"
@export var max_hp := 10
@export var move_speed := 95.0
@export var detection_radius := 520.0
@export var preferred_distance := 220.0
@export var contact_damage := 1
@export var projectile_speed := 320.0
@export var projectile_count := 3
@export var projectile_spread_degrees := 28.0
@export var shoot_interval := 1.6
@export var saved_enemy_id := ""
@export var defeat_message := "The boss collapses."
@export var hp_bar_width := 72.0
@export var coin_reward := 4
@export var reward_power_id := ""
@export var ring_projectile_count := 8
@export var ring_interval := 2.4
@export var charge_speed := 420.0
@export var charge_duration := 0.34
@export var charge_windup := 0.26
@export var charge_interval := 2.5
@export var teleport_distance := 180.0
@export var teleport_interval := 2.0
@export var summon_interval := 3.8
@export var summon_count := 1
@export var summon_max_active := 2
@export var summon_minion_hp := 2
@export var summon_minion_speed := 90.0
@export var summon_minion_radius := 260.0
@export var bomb_interval := 2.4
@export var bomb_speed := 150.0
@export var bomb_fuse_time := 1.0
@export var bomb_explosion_radius := 88.0
@export var bombs_per_volley := 2

@onready var health_fill: Line2D = $HealthBar/Fill

var hp := 0
var shoot_cooldown := 0.7
var ring_cooldown := 1.4
var charge_cooldown := 1.0
var charge_time := 0.0
var charge_windup_time := 0.0
var charge_direction := Vector2.ZERO
var teleport_cooldown := 1.2
var summon_cooldown := 1.8
var bomb_cooldown := 1.2
var knockback_velocity := Vector2.ZERO
var hit_stun_time := 0.0
var player: CharacterBody2D
var home_position := Vector2.ZERO
var rng := RandomNumberGenerator.new()


func _ready() -> void:
	if not saved_enemy_id.is_empty() and GameState.get_flag(saved_enemy_id):
		queue_free()
		return

	add_to_group("enemy")
	add_to_group("boss")
	rng.randomize()
	home_position = global_position
	_apply_difficulty_scaling()
	hp = max_hp
	shoot_cooldown = shoot_interval * 0.55
	ring_cooldown = maxf(ring_interval * 0.7, 0.7)
	charge_cooldown = maxf(charge_interval * 0.6, 0.7)
	teleport_cooldown = maxf(teleport_interval * 0.7, 0.8)
	summon_cooldown = maxf(summon_interval * 0.7, 1.0)
	bomb_cooldown = maxf(bomb_interval * 0.7, 0.9)
	player = get_tree().get_first_node_in_group("player") as CharacterBody2D
	_update_health_bar()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as CharacterBody2D

	if hit_stun_time > 0.0:
		hit_stun_time = maxf(hit_stun_time - delta, 0.0)
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 1200.0 * delta)
		move_and_slide()
		return

	shoot_cooldown = _tick_timer(shoot_cooldown, delta)
	ring_cooldown = _tick_timer(ring_cooldown, delta)
	charge_cooldown = _tick_timer(charge_cooldown, delta)
	teleport_cooldown = _tick_timer(teleport_cooldown, delta)
	summon_cooldown = _tick_timer(summon_cooldown, delta)
	bomb_cooldown = _tick_timer(bomb_cooldown, delta)

	if player == null:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	var to_player := player.global_position - global_position
	var distance := to_player.length()
	if distance > detection_radius:
		_return_home()
		move_and_slide()
		return

	match behavior_mode:
		"charger":
			_process_charger(delta, to_player, distance)
		"burst":
			_process_burst(to_player, distance)
		"summoner":
			_process_summoner(to_player, distance)
		"teleporter":
			_process_teleporter(to_player, distance)
		"bombardier":
			_process_bombardier(to_player, distance)
		"finale":
			_process_finale(to_player, distance)
		_:
			_process_orbit(to_player, distance)

	move_and_slide()

	if global_position.distance_to(player.global_position) < 42.0:
		player.take_damage(contact_damage, global_position)


func take_damage(amount: int, knockback: Vector2) -> void:
	if amount <= 0:
		return

	hp -= amount
	_update_health_bar()
	hit_stun_time = 0.2
	knockback_velocity = knockback
	modulate = Color(1.0, 0.72, 0.72, 1.0)
	await get_tree().create_timer(0.12).timeout
	if is_instance_valid(self) and charge_windup_time <= 0.0:
		modulate = Color.WHITE

	if hp > 0:
		return

	if not saved_enemy_id.is_empty():
		GameState.set_flag(saved_enemy_id)

	_drop_coin_reward()
	_grant_power_reward()

	var current_scene = get_tree().current_scene
	if GameState.is_final_level(GameState.current_room_id) and current_scene != null and current_scene.has_method("queue_victory"):
		current_scene.queue_victory()
	if current_scene != null and current_scene.has_method("show_status_message"):
		current_scene.show_status_message(defeat_message)
	queue_free()


func _process_orbit(to_player: Vector2, distance: float) -> void:
	var direction := to_player.normalized()
	if distance > preferred_distance:
		velocity = direction * move_speed
	else:
		var orbit := Vector2(-direction.y, direction.x)
		velocity = orbit * move_speed * 0.85

	if shoot_cooldown <= 0.0:
		_fire_spread(direction)
		shoot_cooldown = shoot_interval


func _process_charger(delta: float, to_player: Vector2, distance: float) -> void:
	var direction := to_player.normalized()
	if charge_windup_time > 0.0:
		charge_windup_time = _tick_timer(charge_windup_time, delta)
		velocity = Vector2.ZERO
		modulate = Color(1.0, 0.82, 0.82, 1.0)
		if charge_windup_time <= 0.0:
			charge_time = charge_duration
		return

	if charge_time > 0.0:
		charge_time = _tick_timer(charge_time, delta)
		velocity = charge_direction * charge_speed
		if charge_time <= 0.0:
			modulate = Color.WHITE
			_fire_spread(charge_direction, 1.08)
			shoot_cooldown = maxf(shoot_interval * 0.85, 0.45)
		return

	modulate = Color.WHITE
	if charge_cooldown <= 0.0:
		charge_direction = direction if direction != Vector2.ZERO else Vector2.DOWN
		charge_windup_time = charge_windup
		charge_cooldown = charge_interval
		velocity = Vector2.ZERO
		return

	if distance > preferred_distance * 0.78:
		velocity = direction * move_speed * 0.82
	else:
		velocity = Vector2(-direction.y, direction.x) * move_speed * 0.58

	if shoot_cooldown <= 0.0:
		_fire_spread(direction)
		shoot_cooldown = shoot_interval * 1.08


func _process_burst(to_player: Vector2, distance: float) -> void:
	var direction := to_player.normalized()
	if distance > preferred_distance:
		velocity = direction * move_speed * 0.72
	else:
		velocity = Vector2(-direction.y, direction.x) * move_speed * 0.68

	if shoot_cooldown <= 0.0:
		_fire_spread(direction)
		shoot_cooldown = shoot_interval

	if ring_cooldown <= 0.0:
		_fire_ring(max(ring_projectile_count, projectile_count + 2), 0.94)
		ring_cooldown = ring_interval


func _process_summoner(to_player: Vector2, distance: float) -> void:
	var direction := to_player.normalized()
	var to_home := home_position - global_position
	if to_home.length() > 36.0:
		velocity = to_home.normalized() * move_speed * 0.6
	else:
		velocity = Vector2(-direction.y, direction.x) * move_speed * 0.44

	if shoot_cooldown <= 0.0:
		_fire_spread(direction, 0.96)
		shoot_cooldown = shoot_interval * 1.08

	if summon_cooldown <= 0.0 and _get_active_minion_count() < summon_max_active:
		_summon_minions()
		summon_cooldown = summon_interval

	if distance < preferred_distance * 0.72 and ring_cooldown <= 0.0:
		_fire_ring(max(6, projectile_count + 1), 0.9)
		ring_cooldown = ring_interval * 1.15


func _process_teleporter(_to_player: Vector2, _distance: float) -> void:
	if teleport_cooldown <= 0.0:
		_teleport_around_home(teleport_distance * 0.72, teleport_distance)
		_fire_ring(max(ring_projectile_count, projectile_count + 2), 0.98)
		teleport_cooldown = teleport_interval

	var updated_direction := (player.global_position - global_position).normalized()
	var updated_distance := global_position.distance_to(player.global_position)
	if updated_distance > preferred_distance:
		velocity = updated_direction * move_speed * 0.58
	else:
		velocity = Vector2(-updated_direction.y, updated_direction.x) * move_speed * 0.95

	if shoot_cooldown <= 0.0:
		_fire_spread(updated_direction, 1.04)
		shoot_cooldown = shoot_interval


func _process_bombardier(to_player: Vector2, distance: float) -> void:
	var direction := to_player.normalized()
	if distance < preferred_distance * 0.9:
		velocity = -direction * move_speed * 0.7
	else:
		velocity = Vector2(-direction.y, direction.x) * move_speed * 0.62

	if bomb_cooldown <= 0.0:
		_throw_bomb_volley(direction)
		bomb_cooldown = bomb_interval

	if shoot_cooldown <= 0.0:
		_fire_spread(direction, 0.9)
		shoot_cooldown = shoot_interval * 1.18


func _process_finale(_to_player: Vector2, _distance: float) -> void:
	var low_hp := hp <= maxi(int(round(max_hp * 0.5)), 1)
	if teleport_cooldown <= 0.0:
		_teleport_around_home(teleport_distance * 0.74, teleport_distance * (1.2 if low_hp else 1.0))
		_fire_ring(max(ring_projectile_count + (2 if low_hp else 0), projectile_count + 3), 1.04 if low_hp else 0.96)
		teleport_cooldown = teleport_interval * (0.7 if low_hp else 1.0)

	var direction := (player.global_position - global_position).normalized()
	var distance := global_position.distance_to(player.global_position)
	if distance > preferred_distance * 0.82:
		velocity = direction * move_speed * (0.82 if low_hp else 0.66)
	else:
		velocity = Vector2(-direction.y, direction.x) * move_speed * (1.08 if low_hp else 0.84)

	if shoot_cooldown <= 0.0:
		_fire_spread(direction, 1.16 if low_hp else 1.06)
		if low_hp:
			_fire_ring(max(ring_projectile_count, projectile_count + 2), 0.92)
		if bomb_cooldown <= 0.0:
			_throw_bomb_volley(direction, 1 if low_hp else 0)
			bomb_cooldown = bomb_interval * (0.8 if low_hp else 1.0)
		shoot_cooldown = shoot_interval * (0.72 if low_hp else 0.92)


func _fire_spread(base_direction: Vector2, speed_multiplier: float = 1.0) -> void:
	if get_parent() == null:
		return

	var count: int = maxi(projectile_count, 1)
	var spread_radians: float = deg_to_rad(projectile_spread_degrees)
	for index in range(count):
		var t: float = 0.5 if count == 1 else float(index) / float(count - 1)
		var angle: float = lerpf(-spread_radians, spread_radians, t)
		_spawn_projectile(base_direction.rotated(angle), speed_multiplier)


func _fire_ring(count: int, speed_multiplier: float = 1.0) -> void:
	if get_parent() == null:
		return

	for index in range(maxi(count, 4)):
		var angle := TAU * float(index) / float(maxi(count, 4))
		_spawn_projectile(Vector2.RIGHT.rotated(angle), speed_multiplier)


func _spawn_projectile(direction: Vector2, speed_multiplier: float) -> void:
	var projectile: Area2D = ENEMY_PROJECTILE_SCENE.instantiate() as Area2D
	get_parent().add_child(projectile)
	projectile.global_position = global_position + direction.normalized() * 34.0
	projectile.setup(direction, projectile_speed * speed_multiplier, self)


func _throw_bomb_volley(base_direction: Vector2, extra_bombs: int = 0) -> void:
	if get_parent() == null:
		return

	var total_bombs := maxi(1, bombs_per_volley + extra_bombs)
	for index in range(total_bombs):
		var offset_angle := 0.0
		if total_bombs > 1:
			offset_angle = lerpf(-0.24, 0.24, float(index) / float(total_bombs - 1))
		var projectile: Area2D = ENEMY_PROJECTILE_SCENE.instantiate() as Area2D
		get_parent().add_child(projectile)
		projectile.global_position = global_position + base_direction.normalized() * 28.0
		projectile.setup_bomb(base_direction.rotated(offset_angle), bomb_speed, self, bomb_fuse_time, bomb_explosion_radius, contact_damage)


func _summon_minions() -> void:
	if get_parent() == null:
		return

	var spawn_total: int = int(min(summon_count, summon_max_active - _get_active_minion_count()))
	for index in range(spawn_total):
		var angle: float = TAU * (float(index) / float(maxi(spawn_total, 1))) + rng.randf_range(-0.5, 0.5)
		var offset: Vector2 = Vector2.RIGHT.rotated(angle) * rng.randf_range(76.0, 110.0)
		var minion: Node = SLIME_SCENE.instantiate()
		if minion is Slime:
			var slime := minion as Slime
			slime.max_hp = summon_minion_hp
			slime.move_speed = summon_minion_speed
			slime.detection_radius = summon_minion_radius
			slime.saved_enemy_id = ""
			slime.coin_reward = 0
		get_parent().add_child(minion)
		if minion is Node2D:
			(minion as Node2D).global_position = global_position + offset
		minion.add_to_group("boss_minion")


func _get_active_minion_count() -> int:
	var count := 0
	for node in get_tree().get_nodes_in_group("boss_minion"):
		if is_instance_valid(node):
			count += 1
	return count


func _teleport_around_home(min_distance: float, max_distance: float) -> void:
	var angle := rng.randf_range(0.0, TAU)
	var radius := rng.randf_range(min_distance, max_distance)
	global_position = home_position + Vector2.RIGHT.rotated(angle) * radius
	velocity = Vector2.ZERO


func _return_home() -> void:
	var offset := home_position - global_position
	if offset.length() < 10.0:
		velocity = Vector2.ZERO
		return
	velocity = offset.normalized() * move_speed * 0.44


func _update_health_bar() -> void:
	var ratio := 0.0 if max_hp <= 0 else clampf(float(hp) / float(max_hp), 0.0, 1.0)
	var left := -hp_bar_width * 0.5
	var right := left + hp_bar_width * ratio
	health_fill.points = PackedVector2Array([Vector2(left, 0), Vector2(right, 0)])


func _drop_coin_reward() -> void:
	if coin_reward <= 0 or get_parent() == null:
		return

	var pickup := COIN_PICKUP_SCENE.instantiate()
	get_parent().add_child(pickup)
	pickup.global_position = global_position
	pickup.amount = coin_reward


func _grant_power_reward() -> void:
	if reward_power_id.is_empty():
		return
	if not GameState.unlock_power(reward_power_id):
		return

	var current_scene = get_tree().current_scene
	if current_scene != null and current_scene.has_method("show_power_unlock"):
		current_scene.show_power_unlock(reward_power_id)


func _apply_difficulty_scaling() -> void:
	var difficulty := GameState.get_room_difficulty_multiplier(GameState.current_room_id)
	max_hp = maxi(max_hp, int(round(max_hp * lerpf(1.0, difficulty, 0.72))))
	move_speed *= lerpf(1.0, difficulty, 0.42)
	detection_radius *= lerpf(1.0, difficulty, 0.26)
	preferred_distance += (difficulty - 1.0) * 14.0
	projectile_speed *= lerpf(1.0, difficulty, 0.48)
	shoot_interval = maxf(0.42, shoot_interval / lerpf(1.0, difficulty, 0.34))
	ring_interval = maxf(0.9, ring_interval / lerpf(1.0, difficulty, 0.22))
	charge_interval = maxf(1.1, charge_interval / lerpf(1.0, difficulty, 0.2))
	teleport_interval = maxf(0.95, teleport_interval / lerpf(1.0, difficulty, 0.24))
	summon_interval = maxf(1.5, summon_interval / lerpf(1.0, difficulty, 0.2))
	bomb_interval = maxf(1.1, bomb_interval / lerpf(1.0, difficulty, 0.22))
	bomb_speed *= lerpf(1.0, difficulty, 0.34)
	bomb_explosion_radius *= lerpf(1.0, difficulty, 0.18)
	summon_minion_hp = maxi(1, int(round(summon_minion_hp * lerpf(1.0, difficulty, 0.5))))
	summon_minion_speed *= lerpf(1.0, difficulty, 0.28)
	ring_projectile_count = maxi(ring_projectile_count, projectile_count + int(round((difficulty - 1.0) * 3.0)))


func _tick_timer(value: float, delta: float) -> float:
	return maxf(value - delta, 0.0)
