extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().add_coin()
		queue_free()
