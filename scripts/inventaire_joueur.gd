extends Node

# inventaire du personnage et emplacement d'équipement
var inventaire: Array = [
	load("res://scènes/torche.tscn").instantiate(),
	load("res://scènes/torche.tscn").instantiate()
]

var objet_main_gauche: Objet
var objet_main_droite: Objet
