extends Area2D
@onready var destroy_timer: Timer = $DestroyTimer
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var is_ending:bool = false

func _on_destroy_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.refill_fuel(20)
		queue_free()

func _physics_process(_delta: float) -> void:
	if is_ending: return
	if destroy_timer.time_left < 1:
		is_ending = true
		animated_sprite_2d.speed_scale = 2
