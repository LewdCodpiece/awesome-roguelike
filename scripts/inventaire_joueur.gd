extends Node

# inventaire du personnage et emplacement d'équipement
var inventaire: Array[Objet] = [
	
]

# emplacement d'équipement
# les deux emplacements par défaut sont les deux mains du personnage
# cependant, si le joueur obtient une ceinture de potion, par exemple, il est possible d'ajouter des
# emplacements d'inventaire facilement, en ajouter une key au dictionnaire
# null si l'emplacement est vide
# on ne type pas le dictionnaire pour permettre d'ajouter des arrays d'objets pour certains types d'équipement
var emplacements_équipement: Dictionary = {
	"main_gauche": null,
	"main_droite": null
}

# permet de vérifier si un objet se trouve dans l'inventaire du personnage
func vérifier(obj: Objet) -> bool:
	if obj in inventaire: return true
	else: return false

## toutes les fonctions qui suivent peuvent prendre soit un array d'objet, soit un objet
## pour facilier la gestion de plusieurs objets à la fois
# ajouter un objet à l'inventaire du joueur
func ajouter_objet(obj):
	if obj is Array:
		var liste_objet_noms: String = ""
		for o in obj:
			inventaire.append(o)
			liste_objet_noms += o.nom + ", "
		VariablesGlobales.journal.ajouter_message("Vous mettez " + liste_objet_noms + " dans votre inventaire.")
	else:	
		VariablesGlobales.journal.ajouter_message("Vous mettez " + obj.nom + " dans votre inventaire.")
		inventaire.append(obj)

# pour retirer un ou des objets de l'inventaires
func retirer_objet(obj):
	if obj is Array:
		var liste_objets_noms: String = ""
		for o in obj:
			if vérifier(o):
				inventaire.erase(o)
				liste_objets_noms += o.nom + ", "
		VariablesGlobales.journal.ajouter_message("Vous retirez " + liste_objets_noms + " de votre inventaire.")
	else:
		if vérifier(obj):
			inventaire.erase(obj)
			VariablesGlobales.journal.ajouter_message("Vous retirez " + obj.nom + " de votre inventaire.")
