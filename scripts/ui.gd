extends Control

func _ready() -> void:
	InventaireJoueur.objet_équipé.connect(afficher_ui_équipement)


func _process(delta: float) -> void:
	pass


## l'ui qui permet de choisir ou et commment s'équiper d'un objet
func afficher_ui_équipement(obj: Objet):
	pass
