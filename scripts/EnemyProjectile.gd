extends Area2D
class_name EnemyProjectile

@export var speed := 280.0
@export var damage := 1
@export var lifetime := 3.0
@export var explosive := false
@export var explosion_radius := 0.0
@export var fuse_time := 0.0

var direction := Vector2.RIGHT
var projectile_owner: Node2D
var life_remaining := 0.0
var has_exploded := false

@onready var glow: Polygon2D = $Glow
@onready var core: Polygon2D = $Core


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	life_remaining = lifetime
	rotation = direction.angle()
	_apply_visual_state()


func setup(travel_direction: Vector2, projectile_speed: float, owner_node: Node2D = null) -> void:
	direction = travel_direction.normalized()
	speed = projectile_speed
	projectile_owner = owner_node
	rotation = direction.angle()


func setup_bomb(travel_direction: Vector2, projectile_speed: float, owner_node: Node2D = null, fuse := 1.0, radius := 72.0, projectile_damage := 1) -> void:
	setup(travel_direction, projectile_speed, owner_node)
	explosive = true
	fuse_time = fuse
	explosion_radius = radius
	damage = projectile_damage
	lifetime = maxf(lifetime, fuse + 0.2)
	_apply_visual_state()


func _physics_process(delta: float) -> void:
	if explosive:
		fuse_time = maxf(fuse_time - delta, 0.0)
		if fuse_time <= 0.0 and not has_exploded:
			_explode()
			return

	global_position += direction * speed * delta
	life_remaining -= delta
	if life_remaining <= 0.0:
		if explosive and not has_exploded:
			_explode()
			return
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body == projectile_owner:
		return

	if body.is_in_group("player") and body.has_method("take_damage"):
		if explosive:
			_explode()
		else:
			body.take_damage(damage, global_position)
			queue_free()
		return

	if body is StaticBody2D or body is CharacterBody2D:
		if explosive:
			_explode()
		else:
			queue_free()


func _explode() -> void:
	if has_exploded:
		return

	has_exploded = true
	speed = 0.0
	var player := get_tree().get_first_node_in_group("player")
	if player is Node2D and player.has_method("take_damage"):
		var player_node := player as Node2D
		if player_node.global_position.distance_to(global_position) <= explosion_radius:
			player.call("take_damage", damage, global_position)

	rotation = 0.0
	glow.color = Color(1.0, 0.42, 0.18, 0.3)
	core.color = Color(1.0, 0.84, 0.42, 0.95)
	var scale_factor := maxf(explosion_radius / 16.0, 2.8)
	glow.scale = Vector2.ONE * scale_factor
	core.scale = Vector2.ONE * (scale_factor * 0.58)
	$CollisionShape2D.set_deferred("disabled", true)
	await get_tree().create_timer(0.12).timeout
	queue_free()


func _apply_visual_state() -> void:
	if not is_node_ready():
		return
	if explosive:
		glow.color = Color(1.0, 0.18, 0.12, 0.48)
		core.color = Color(0.14, 0.14, 0.16, 1.0)
		glow.scale = Vector2.ONE * 1.2
		core.scale = Vector2.ONE * 1.15
	else:
		glow.color = Color(0.98, 0.42, 0.22, 0.4)
		core.color = Color(1.0, 0.72, 0.26, 1.0)
		glow.scale = Vector2.ONE
		core.scale = Vector2.ONE
