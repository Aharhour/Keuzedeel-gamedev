extends Node2D

var coins := 0

@onready var coin_label: Label = $CanvasLayer/Label

func add_coin() -> void:
	coins += 1
	coin_label.text = "Munten: %d" % coins
