extends Node

## le dictionnaire de correspondance entre les noms d'objets (str) et les objets réels
var str_obj: Dictionary[String, Objet] = {
	"torche": load("res://scènes/torche.tscn").instantiate()
}
