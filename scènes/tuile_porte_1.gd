extends "res://tuile.gd"

@onready var sprite = $StaticBody2D/Sprite2D
@onready var hitbox = $StaticBody2D/CollisionShape2D
@onready var light_occluder = $StaticBody2D/LightOccluder2D
@onready var static_body = $StaticBody2D

@export var vérouillé: bool = false
@export var ouvert: bool = false

signal porte_ouverte
signal porte_fermée


func action():
	if not self.ouvert:
		ouvrir_porte()
	else:
		fermer_porte()

func fermer_porte():
	self.ouvert = false
	self.porte_fermée.emit()
	
	# visuel
	sprite.visible = true
	light_occluder.visible = true
	# collision
	## n'est plus un obstacle
	static_body.set_collision_layer_value(1, true)
	static_body.set_collision_mask_value(1, true)
	## peut toujours être détecter par le raycast pour être fermée
	static_body.set_collision_layer_value(2, false)
	static_body.set_collision_mask_value(2, false)

func ouvrir_porte():
	if not self.vérouillé:
		self.ouvert = true
		self.porte_ouverte.emit()
		
		# visuel
		sprite.visible = false
		light_occluder.visible = false
		# collision
		## n'est plus un obstacle
		static_body.set_collision_layer_value(1, false)
		static_body.set_collision_mask_value(1, false)
		## peut toujours être détecter par le raycast pour être fermée
		static_body.set_collision_layer_value(2, true)
		static_body.set_collision_mask_value(2, true)
		
		## Alternativement : self.queue_free()
		## mais à réservé pour quand la porte est détruite
