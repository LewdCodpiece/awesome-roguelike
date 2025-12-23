extends "res://scripts/objet.gd"

@onready var lumière = $PointLight2D

func _process(delta: float) -> void:
	if self.équipé.main_gauche or self.équipé.main_droite:
		self.lumière.enabled = true
	else:
		self.lumière.enabled = false
