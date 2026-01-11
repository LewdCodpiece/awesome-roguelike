extends PanelContainer

@onready var liste_emplacements_node = $ScrollContainer/VBoxContainer

# on stock l'objet en question dans une variable ici
var objet_à_équiper: Objet

func _ready() -> void:
	visible = false
	InventaireJoueur.objet_équipé.connect(équiper_objet)

func équiper_objet(objet: Objet):
	# on affiche le menu
	visible = true
	# on récupère l'objet à équiper
	objet_à_équiper = objet
	# on remplie le menu
	peupler()
	

func peupler():
	var nb_emplacements: int = len(InventaireJoueur.emplacements_équipement.values())
	
	# on vide tout avant de le reremplir
	for node in $ScrollContainer/VBoxContainer.get_children():
		node.queue_free()
	
	for i in InventaireJoueur.emplacements_équipement.keys():
		# chaque ligne d'inventaire
		var fond_ligne = PanelContainer.new()
		# le nom de l'emplacement
		var label_nom_emplacement = Label.new()
		label_nom_emplacement.text = i + " : "
		# le nom de l'objet qui y est équipé
		var nom_objet = Label.new()
		if InventaireJoueur.emplacements_équipement[i] is Objet:
			nom_objet.text = InventaireJoueur.emplacements_équipement[i].nom
		else:
			nom_objet.text = "<vide>"
		# bouton équiper
		var bouton_équipement = Button.new()
		bouton_équipement.text = "équiper"
		# le bouton donne l'emplacement choisi
		bouton_équipement.pressed.connect(_équiper.bind(i))
		
		var h_box = HBoxContainer.new()
		
		h_box.add_child(label_nom_emplacement)
		h_box.add_child(nom_objet)
		h_box.add_child(bouton_équipement)
		fond_ligne.add_child(h_box)
		
		liste_emplacements_node.add_child(fond_ligne)

func _équiper(emplacement: String):
	# on fait les opérations néceissaires à l'équipement
	if InventaireJoueur.emplacements_équipement[emplacement] is Objet:
		# un objet est déjà occupé, on le remplace
		## d'abord, on ajoute à l'inventaire l'objet qui était équipé
		InventaireJoueur.ajouter_objet(InventaireJoueur.emplacements_équipement[emplacement])
		InventaireJoueur.emplacements_équipement[emplacement].équipé[emplacement] = false
		## on remplace l'objet équipé par le nouvel objet
		InventaireJoueur.emplacements_équipement[emplacement] = self.objet_à_équiper
		self.objet_à_équiper.équipé[emplacement] = true
		## on enlève l'objet à équiper de l'inventaire
		### du joueur
		if self.objet_à_équiper.dans_inventaire:
			InventaireJoueur.retirer_objet(self.objet_à_équiper)
		### ou du contenant
		else:
			pass
	else:
		# on équipe l'objet
		InventaireJoueur.emplacements_équipement[emplacement] = self.objet_à_équiper
		self.objet_à_équiper.équipé[emplacement] = true
		# on l'enlève de l'inventaire, 
		## s'il est dans l'inventaire du joueur
		if self.objet_à_équiper.dans_inventaire:
			InventaireJoueur.retirer_objet(self.objet_à_équiper)
		## s'il est dans l'inventaire d'un contenant 
		else:
			pass
	# on ferme cet UI
	self.visible = false
