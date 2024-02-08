extends Node2D
const FUEL = preload("res://Scenes/fuel.tscn")

func _on_fuel_spawner_timer_timeout() -> void:
	var fuel = FUEL.instantiate()
	var side_random:float = randf_range(0,50)
	var hight_random:float = randf_range(0,50)
	if randi_range(0,1) == 0:
		fuel.position = Vector2(222-side_random,148-hight_random)
	else:
		fuel.position = Vector2(260+side_random,180+hight_random)
	add_child(fuel)
