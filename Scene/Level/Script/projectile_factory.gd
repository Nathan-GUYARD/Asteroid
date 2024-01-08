extends Node2D

class_name ProjectileFactory


func spawn_projectile(projectile : Projectile) -> void:
	add_child(projectile)
