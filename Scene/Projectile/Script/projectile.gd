extends Node2D

class_name Projectile


@onready var direction : Vector2 = Vector2.RIGHT.rotated(rotation)

@export var speed : float = 300.0

func _physics_process(delta : float) -> void:
	var velocity : Vector2 = direction * speed * delta
	global_position += velocity

func _on_area_entered(area : Area2D) -> void:
	if area is Asteroid:
		area.destroy()
		destroy()

func destroy() -> void:
	queue_free()
