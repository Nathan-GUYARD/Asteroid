@tool
extends Area2D

class_name Asteroid


@onready var sprite : Sprite2D = %Sprite2D
@onready var collision_shape : CollisionShape2D = %CollisionShape2D

enum SIZE {
	SMALL,
	MEDIUM,
	BIG
}

@export var size : SIZE = SIZE.BIG:
	set(value):
		if value != size:
			size = value
			size_changed.emit()

@export var asteroid_size_array : Array[AsteroidSize]

@export var speed_max : float = 250.0
@export var speed_min : float = 50.0
var speed : float = randf_range(speed_min,speed_max)

@export var torque_max : float = 60.0
@export var torque_min : float = 5.0
var torque : float = randf_range(torque_min,torque_max) * [-1.0,1.0].pick_random()

var direction : Vector2 = Vector2.RIGHT

signal size_changed
signal destroyed

func _ready() -> void:
	if Engine.is_editor_hint():
		set_physics_process(false)
	
	size_changed.connect(update_size)
	update_size()

func _physics_process(delta : float) -> void:
	var velocity : Vector2 = direction * speed * delta
	global_position += velocity
	
	rotation_degrees += torque * delta

func _on_body_entered(body : CharacterBody2D) -> void:
	if body is Player:
		if not body.isInvincible:
			body.kill()

func update_size() -> void:
	assert(size in range(asteroid_size_array.size()),"the size argument {size_value} is not valid argument".format({"size_value":size}))
	
	var asteroid_size : AsteroidSize  = asteroid_size_array[size]
	
	sprite.texture = asteroid_size.texture
	collision_shape.shape = asteroid_size.shape_collision

func destroy() -> void:
	destroyed.emit()
	queue_free()

