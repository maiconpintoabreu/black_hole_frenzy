extends PathFollow2D

@export var black_hole: Area2D
@export var level: Level
var speed: float = 20.0
var time_to_spawn: float = 2.0
@onready var timer: Timer = $Timer
const ROCK = preload("res://Scenes/rock.tscn")
@export var level_node:Node2D

func _ready() -> void:
	random_values()
	timer.start(time_to_spawn)

func _process(_delta: float) -> void:
	progress = progress + speed

func spawn() -> void:
	var rock = ROCK.instantiate()
	rock.black_hole = black_hole
	rock.level = level
	rock.position = global_position
	level_node.add_child(rock)
	random_values()
	timer.start(time_to_spawn)
	
func random_values() -> void:
	time_to_spawn = randf_range(1,3)
	speed = randf_range(20,80)


func _on_timer_timeout() -> void:
	spawn()
