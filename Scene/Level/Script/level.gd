extends Node2D

class_name Level


@onready var border_rect : ReferenceRect = %Border
@onready var asteroids_container : Node2D = %AsteroidsContainer
@onready var spawn_timer : Timer = %SpawnTimer
@onready var player : Player = %Player

enum MODE{
	NORMAL,
	HARD
}

@export var game_mode : MODE = MODE.NORMAL:
	set(value):
		game_mode = value
		mode_changed.emit()

@export var level_mode_array : Array[GameMode]

@export var asteroid_scene : PackedScene
@export var spawn_circle_radius : float = 350.0

@export var asteroid_direction_variance : float = 40.0
var screen_size : Vector2 = Vector2(ProjectSettings.get_setting("display/window/size/viewport_width"), 
	ProjectSettings.get_setting("display/window/size/viewport_height"))

var acceleration_timer : float
var timer_max : float
var score : int = 0

var time = Time.get_unix_time_from_system()

signal mode_changed

func spawn_asteroid(point : Vector2 ,direction : Vector2 ,size : Asteroid.SIZE) -> void:
	var asteroid : Asteroid = asteroid_scene.instantiate()
	asteroids_container.add_child.call_deferred(asteroid)
	
	asteroid.direction = direction
	asteroid.position = point
	asteroid.size = size
	
	asteroid.destroyed.connect(_on_asteroid_destroyed.bind(asteroid))

func spawn_asteroid_on_border() -> void:
	var screen_center : Vector2 = screen_size / 2.0
	var top_left : Vector2 = border_rect.global_position
	var botton_right : Vector2 = border_rect.global_position + border_rect.size
	
	var angle : float = deg_to_rad(randf_range(0.0,360.0))
	var direction : Vector2 = Vector2.RIGHT.rotated(angle)
	
	var point : Vector2 = screen_center + direction * spawn_circle_radius
	point = point.clamp(top_left,botton_right)
	
	var direction_to_center : Vector2 = point.direction_to(screen_center)
	var direction_rotation : float = randfn(0.0,asteroid_direction_variance)
	var asteroid_direction : Vector2 = direction_to_center.rotated(deg_to_rad(direction_rotation))
	
	var asteroid_size : int = randi_range(Asteroid.SIZE.MEDIUM,Asteroid.SIZE.size()-1)
	
	spawn_asteroid(point,asteroid_direction,asteroid_size)

func _on_spawn_timer_timeout() -> void:
	if spawn_timer.wait_time > timer_max:
		
		spawn_timer.wait_time *= acceleration_timer
	
	spawn_asteroid_on_border()

func _on_asteroid_destroyed(asteroid : Asteroid) -> void:
	if asteroid.size == Asteroid.SIZE.BIG:
		score += 1
	elif asteroid.size == Asteroid.SIZE.MEDIUM:
		score += 2
	else:
		score += 3
	
	if asteroid.size > 0:
		var nb_new_asteroid : int = randi_range(2,3)
		
		for i in range(nb_new_asteroid):
			var asteroid_rotation : float = 90.0 + randfn(0.0,asteroid_direction_variance)
			asteroid_rotation = deg_to_rad([-1.0,1.0].pick_random()*asteroid_rotation)
			var direction : Vector2 = asteroid.direction.rotated(asteroid_rotation)
			
			spawn_asteroid(asteroid.global_position,direction,asteroid.size-1)

func _on_area_exited(area : Area2D) -> void:
	area.queue_free()

func update_mode():
	assert(game_mode in range(level_mode_array.size()),"the mode argument {mode_value} is not valid argument".format({"mode_value":game_mode}))
	
	var mode_select : GameMode = level_mode_array[game_mode]
	
	acceleration_timer = mode_select.timer_acceleration
	timer_max = mode_select.max_timer
