class_name Contenant extends "res://tuile.gd"

@onready var ui = $CanvasLayer/ui_contenant

# la capacité du contenant, i.e. combien d'objets il peut contenir
@export var capacité: int = 10
# le contenu
var contenu: Array[Objet]
# si le contenant est vérouillé
@export var vérouillé: bool = false
# le nom du contenant, i.e. coffre, tonneau, etc.
@export var nom: String = "Contenant"
# si le contenant est piégé
@export var piégé: bool = false

# la loot table du contenant: {objet, poids}
@export var loot_table: Dictionary[String, float] = {
	
}
# combien d'objet peuvent se trouver dans le contennant au moment de la génération
@export var obj_min: int = 0
@export var obj_max: int = 10

signal ouverture

func _ready() -> void:
	ui.visible = false
	
	# le contenant est remplie au moment de son instantiation
	var nb_objets = randi_range(obj_min, obj_max)
	var rng = RandomNumberGenerator.new()
	
	var objets = loot_table.keys()
	var poids = loot_table.values()
	for i in range(nb_objets):
		self.contenu.append(ObjetsGlobals.str_obj[objets[rng.rand_weighted(poids)]])

## publiques
func action():
	if not vérouillé:
		# on ouvre l'ui
		ui.visible = true
		# l'ui est ouvert, tout le jeu est en pause
		VariablesGlobales.ui_ouvert = true
		ui.peupler_interface()
		
		# on émet le signal que le coffre a été ouvert
		ouverture.emit()
		
		VariablesGlobales.journal.ajouter_message("Vous ouvrez " + self.nom + ".")
	else:
		VariablesGlobales.journal.ajouter_message(self.nom + " est vérouillé(e).")

## privés
func retirer_objet(objet: Objet):
	if objet in self.contenu:
		self.contenu.erase(objet)

func ajouter_objet(objet: Objet):
	if len(self.contenu) < self.capacité:
		self.contenu.append(objet)
	else:
		VariablesGlobales.journal.ajouter_message("L'inventaire du contenant est plein.")

func activer_piège():
	pass

func _on_ouverture() -> void:
	# si le contenant n'est pas piégé, rien ne se passe
	# sinon, le piège s'active
	if self.piégé:
		activer_piège()
		VariablesGlobales.journal.ajouter_message("Le " + self.nom + " était piégé!")
