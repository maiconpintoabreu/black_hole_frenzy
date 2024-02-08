extends Area2D

func _on_destroy_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.refill_fuel(20)
		queue_free()
