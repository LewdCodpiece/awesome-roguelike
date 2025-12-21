class_name Contenant extends "res://tuile.gd"

@onready var ui = $CanvasLayer/ui

# la capacité du contenant, i.e. combien d'objets il peut contenir
@export var capacité: int = 10
# le contenu, TODO: en faire un array d'objet quand j'aurais fais les objets
var contenu: Array
# si le contenant est vérouillé
@export var vérouillé: bool = false
# le nom du contenant, i.e. coffre, tonneau, etc.
@export var nom: String = "Contenant"
# si le contenant est piégé
@export var piégé: bool = false

# la loot table du contenant: {objet, poids}
@export var loot_table: Dictionary[Objet, float] = {
	
}
# combien d'objet peuvent se trouver dans le contennant au moment de la génération
@export var objets_générés: Dictionary = {"min": 0, "max": 10}

signal ouverture

func _ready() -> void:
	ui.visible = false
	
	# le contenant est remplie au moment de son instantiation
	var nb_objets = randi_range(objets_générés.min, objets_générés.max)
	var rng = RandomNumberGenerator.new()
	
	#var objets = loot_table.keys()
	#var poids = loot_table.values()
	#for i in range(nb_objets):
	#	self.contenu.append(objets[rng.rand_weighted(poids)])

## publiques
func action():
	if not vérouillé:
		# on ouvre l'ui
		ui.visible = true
		# TODO: tout le reste
		
		VariablesGlobales.journal.ajouter_message("Vous ouvrez " + self.nom + ".")
	else:
		VariablesGlobales.journal.ajouter_message(self.nom + " est vérouillé(e).")

## privés
func retirer_objet(objet):
	if objet in self.contenu:
		self.contenu.erase(objet)

func ajouter_objet(objet):
	if len(self.contenu) < self.capacité:
		self.contenu.append(objet)
	else:
		VariablesGlobales.journal.ajouter_message("L'inventaire du contenant est plein.")

func remplir():
	pass
