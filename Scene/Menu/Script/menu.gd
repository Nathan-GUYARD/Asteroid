extends Node2D

class_name Menu


@onready var level_container : Node2D = %LevelContainer
@onready var score_text : Label = %Score
@onready var time_text : Label = %Time
@onready var menu : CanvasLayer = %Menu


@export var level_scene : PackedScene

var level : Level

func _ready() -> void:
	load_level(Level.MODE.NORMAL)
	level.player.destroy()

func end_game() -> void:
	var time : int = Time.get_unix_time_from_system() - level.time
	score_text.set_score(level.score)
	time_text.set_time(time)
	menu.show()

func _on_normal_mode_pressed() -> void:
	start(Level.MODE.NORMAL)

func _on_hard_mode_pressed() -> void:
	start(Level.MODE.HARD)

func start(mode : Level.MODE) -> void:
	level.queue_free()
	load_level(mode)
	
	menu.hide()

func load_level(mode : Level.MODE) -> void:
	level = level_scene.instantiate()
	level_container.add_child(level)
	level.player.destroyed.connect(end_game)
	level.game_mode = mode

