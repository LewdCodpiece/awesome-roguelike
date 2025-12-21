class_name Objet extends Node2D
## classe virtuelle

@export_group("Générale")
# le nom de l'objet
@export var nom: String = "Obj"
# la valeur de l'objet (quand vendu à un marchant)
@export var valeure_marchande: int = 100
@export_group("Utilisation")
# les informations concernant si et où l'objet peut être équipé
@export var équipable: Dictionary[String, bool] = {"main_gauche": false, "main_droite": false} # sans doute d'autres emplacements à ajouter dans le futur comme ceinture de potions, etc.
# détermine si l'objet est utilisable, et d'où il est utilisable
@export var utilisable: Dictionary[String, bool] = {"mains": false, "inventaire": false}
# si l'objet est consommable, il est supprimé de l'inventaire quand il est utilisé
@export var consommable: bool = false
@export_group("Graphique")
# l'image de l'objet quand il est au sol dans le donjon
@export var tuile_texture: Texture2D = preload("res://ressources/obj_tuile_placeholder.png")
# l'image de l'objet quand il est équipé
## pas encore déterminé la taille de la texture, à voir plus tard pour faire un placeholder
@export var inventaire_texture: Texture2D

# information logiques 
## est-ce que l'objet est équipé, et où
var équipé: Dictionary[String, bool] = {"main_gauche": false, "main_droite": false}
## si l'objet est dans l'inventaire
var dans_inventaire: bool = false

signal objet_utilisé

# la variable
func action():
	pass
