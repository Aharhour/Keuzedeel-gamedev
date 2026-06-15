extends Area2D

# Bevinding 5 (test Akshay): per auto instelbaar, zodat de auto's verschillend
# snel rijden en het verkeer minder voorspelbaar wordt.
@export var SPEED: float = 500.0

@export var move_down: bool

@onready var initial_position = position

func _process(delta: float) -> void:
	if move_down:
		position += Vector2.DOWN * SPEED * delta
	if !move_down:
		position += Vector2.UP * SPEED * delta

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	position = initial_position

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$"../CanvasLayer/GameOverUI".show()
		get_tree().paused = true
