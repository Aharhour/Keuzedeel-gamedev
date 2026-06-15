extends Area2D

# Munt die de speler kan oppakken op zijn route naar de finish.
# Bij aanraking telt de munt mee in de score en verdwijnt hij.

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_parent().add_coin()
		queue_free()
