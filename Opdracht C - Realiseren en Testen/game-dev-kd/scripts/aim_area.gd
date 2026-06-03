extends Area2D

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$"../CanvasLayer/YouWinUI".show()
		get_tree().paused = true
