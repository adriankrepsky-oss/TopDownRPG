extends CharacterBody2D
class_name ArmedRobber

const ENEMY_PROJECTILE_SCENE := preload("res://scenes/EnemyProjectile.tscn")
const COIN_PICKUP_SCENE := preload("res://scenes/CoinPickup.tscn")

@export var max_hp := 4
@export var move_speed := 92.0
@export var detection_radius := 320.0
@export var preferred_distance := 170.0
@export var projectile_speed := 320.0
@export var shoot_cooldown := 1.0
@export var saved_enemy_id := ""
@export var coin_reward := 3
@export var hp_bar_width := 38.0

@onready var health_fill: Line2D = $HealthBar/Fill
@onready var muzzle: Marker2D = $Visuals/GunPivot/Muzzle
@onready var gun_pivot: Node2D = $Visuals/GunPivot

var hp := max_hp
var shoot_timer := 0.0
var knockback_velocity := Vector2.ZERO
var hit_stun_time := 0.0
var player: Node2D


func _ready() -> void:
	if not saved_enemy_id.is_empty() and GameState.get_flag(saved_enemy_id):
		queue_free()
		return

	add_to_group("enemy")
	_apply_difficulty_scaling()
	hp = max_hp
	player = get_tree().get_first_node_in_group("player") as Node2D
	_update_health_bar()


func _physics_process(delta: float) -> void:
	if player == null or not is_instance_valid(player):
		player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return

	shoot_timer = maxf(shoot_timer - delta, 0.0)
	var to_player := player.global_position - global_position
	if to_player.length() <= detection_radius:
		gun_pivot.look_at(player.global_position)

	if hit_stun_time > 0.0:
		hit_stun_time = maxf(hit_stun_time - delta, 0.0)
		velocity = knockback_velocity
		knockback_velocity = knockback_velocity.move_toward(Vector2.ZERO, 920.0 * delta)
	else:
		var distance := to_player.length()
		if distance > detection_radius:
			velocity = Vector2.ZERO
		elif distance > preferred_distance + 28.0:
			velocity = to_player.normalized() * move_speed
		elif distance < preferred_distance - 28.0 and distance > 0.001:
			velocity = -to_player.normalized() * move_speed * 0.7
		else:
			velocity = Vector2.ZERO

		if distance <= detection_radius and shoot_timer <= 0.0 and distance > 0.001:
			_fire_at_player(to_player.normalized())
			shoot_timer = shoot_cooldown

	move_and_slide()

	if to_player.length() < 28.0 and player.has_method("take_damage"):
		player.take_damage(1, global_position)


func take_damage(amount: int, knockback: Vector2) -> void:
	if amount <= 0:
		return

	hp -= amount
	_update_health_bar()
	hit_stun_time = 0.18
	knockback_velocity = knockback
	modulate = Color(1.0, 0.64, 0.64, 1.0)
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		modulate = Color.WHITE

	if hp > 0:
		return

	if not saved_enemy_id.is_empty():
		GameState.set_flag(saved_enemy_id)
	_drop_coin_reward()
	queue_free()


func _fire_at_player(direction: Vector2) -> void:
	var projectile := ENEMY_PROJECTILE_SCENE.instantiate()
	get_parent().add_child(projectile)
	projectile.global_position = muzzle.global_position
	projectile.call("setup", direction, projectile_speed, self)


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


func _apply_difficulty_scaling() -> void:
	var difficulty := GameState.get_room_difficulty_multiplier(GameState.current_room_id)
	max_hp = maxi(1, int(round(max_hp * lerpf(0.9, difficulty, 0.35))))
	move_speed *= lerpf(0.9, difficulty, 0.25)
	projectile_speed *= lerpf(1.0, difficulty, 0.2)
	shoot_cooldown *= lerpf(1.06, 0.86, clampf(difficulty / 2.0, 0.0, 1.0))
