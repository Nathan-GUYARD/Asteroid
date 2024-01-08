extends CharacterBody2D

class_name Player


@onready var sprite_2d : Sprite2D = %Sprite2D
@onready var death_timer : Timer = %DeathTimer
@onready var fire_delay = %FireDelay

enum TEXTURE{
	NORMAL,
	TOUCH
}

var texture : TEXTURE = TEXTURE.NORMAL:
	set(value):
		if value != texture:
			texture = value
			texture_changed.emit()

@export var player_texture_array : Array[PlayerTexture]

@export var max_speed : float = 150.0
var speed : float = 0.0

@export var projectile_scene : PackedScene

@export_range(0,1) var acceleration : float = 0.05
@export_range(0,1) var rotation_acceleration : float = 0.11

@export var life : int = 3
var isInvincible : bool = false

var canFire : bool = true

var direction : Vector2 = Vector2.ZERO
var last_direction : Vector2 = direction

var screen_size : Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), 
	ProjectSettings.get_setting("display/window/size/viewport_height"))
var ecart : float = 10.0

signal projectile_fired(projectile)
signal destroyed
signal texture_changed

func _physics_process(_delta : float) -> void:
	move()
	rotate_to_mouse()
	
	travel_screen()

func move() -> void:
	if direction:
		speed = lerp(speed,max_speed,acceleration)
	else:
		speed = lerp(speed,0.0,acceleration)
	
	velocity = last_direction*speed
	move_and_slide()

func travel_screen() -> void:
	if global_position.x > screen_size.x + ecart*2:
		global_position.x = -ecart
	elif global_position.x < -ecart*2:
		global_position.x = screen_size.x + ecart
	
	if global_position.y > screen_size.y + ecart*2:
		global_position.y = -ecart
	elif global_position.y < -ecart*2:
		global_position.y = screen_size.y + ecart

func rotate_to_mouse() -> void:
	var mouse_pos : Vector2 = get_global_mouse_position()
	var angle : float = global_position.angle_to_point(mouse_pos)
	rotation = lerp_angle(rotation,angle,rotation_acceleration)

func _input(event : InputEvent) -> void:
	direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if direction:
		last_direction = direction
	
	if event.is_action_pressed("fire"):
		if canFire:
			fire()

func fire() -> void:
	var projectile : Projectile = projectile_scene.instantiate()
	projectile.transform = global_transform
	
	canFire = false
	fire_delay.start()
	
	projectile_fired.emit(projectile)
	
func kill() -> void:
	life -=1
	
	if life <= 0:
		destroy()
	
	else:
		isInvincible = true
		texture = TEXTURE.TOUCH
		death_timer.start()

func destroy() -> void:
	destroyed.emit()
	queue_free()

func update_texture() -> void:
	assert(texture in range(player_texture_array.size()),"the texture argument {texture_value} is not valid argument".format({"texture_value":texture}))
	
	sprite_2d.texture = player_texture_array[texture].texture

func _on_death_timer_timeout() -> void:
	isInvincible = false
	texture = TEXTURE.NORMAL

func _on_fire_delay_timeout():
	canFire = true
