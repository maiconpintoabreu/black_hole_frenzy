extends RigidBody2D

var black_hole: Area2D
var level: Level
var rock_by_black_hole: Vector2
var rock_distance_black_hole: float
var gravity_direction:Vector2 = Vector2.ZERO
var random_rotate_to: float = 1
func _ready() -> void:
	random_rotate_to = randf_range(-0.01,0.01)

func _physics_process(_delta: float) -> void:
	rotate(random_rotate_to)
	rock_by_black_hole = global_position.direction_to(black_hole.global_position)
	rock_distance_black_hole = global_position.distance_to(black_hole.global_position)
	gravity_direction = rock_by_black_hole.normalized()
	apply_force(gravity_direction*(level.gravity_pull*level.level),gravity_direction)

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body is Player:
		level.game_over()
	queue_free()


func _on_hit_box_area_entered(_area: Area2D) -> void:
	queue_free()
