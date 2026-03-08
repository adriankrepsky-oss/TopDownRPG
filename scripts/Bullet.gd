extends Area2D
class_name Bullet

@export var speed := 620.0
@export var damage := 1
@export var knockback := 320.0
@export var lifetime := 1.0

var direction := Vector2.RIGHT
var life_remaining := 0.0


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	life_remaining = lifetime
	rotation = direction.angle()


func setup(travel_direction: Vector2, projectile_speed: float = speed) -> void:
	direction = travel_direction.normalized()
	speed = projectile_speed
	rotation = direction.angle()


func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta
	life_remaining -= delta
	if life_remaining <= 0.0:
		queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		return

	if body.is_in_group("enemy") and body.has_method("take_damage"):
		body.take_damage(damage, direction * knockback)
		queue_free()
		return

	if body is StaticBody2D or body is CharacterBody2D:
		queue_free()
