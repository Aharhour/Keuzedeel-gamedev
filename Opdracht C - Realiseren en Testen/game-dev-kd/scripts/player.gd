extends CharacterBody2D

const SPEED = 300.0
const RAND = 30.0  # straal van de speler, zodat hij niet half buiten beeld komt

func _physics_process(_delta: float) -> void:
	var direction := Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if direction:
		velocity = direction * SPEED
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Bevinding 2 (test Akshay): houd de speler binnen de schermranden.
	var screen := get_viewport_rect().size
	global_position.x = clamp(global_position.x, RAND, screen.x - RAND)
	global_position.y = clamp(global_position.y, RAND, screen.y - RAND)
