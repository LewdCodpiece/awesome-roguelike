extends Control

@onready var liste_inv_joueur = $VBoxContainer/HBoxContainer/panel_inv_joueur/VBoxContainer
@onready var liste_inv_contenant = $VBoxContainer/HBoxContainer/panel_inv_contenant/VBoxContainer
@onready var label_instruction = $VBoxContainer/PanelContainer/Label
@onready var contenant_parent = $"../.."

# la liste de toutes les lignes d'objet, dans le contenant et dans l'inventaire du joueur
var tous_les_objets: Array[LigneInventaire] = []
# l'objet qui est sélectionné et sur lequel faire les opérations
var objet_sélectionné: Objet
# la ligne de l'inventaire qui est sélectionnée, pour vérifier où se trouve le curseur du joueur
var ligne_séléctionné: LigneInventaire

# gérer les différentes actions possibles
func _input(event: InputEvent) -> void:
	# uniquement si l'interface est ouvert
	if self.visible:
		if objet_sélectionné != null and ligne_séléctionné != null:
			# on modifie le label des commandes en fonctiond des actions possibles
			# et en fonction de sa provenance
			if (not ligne_séléctionné in liste_inv_joueur.get_children()) and event.is_action_released("prendre"): 
				prendre(objet_sélectionné)
				# on donne le focus à l'objet qui vient d'être déplacé
				liste_inv_joueur.get_children()[-1].grab_focus()
			elif event.is_action_released("prendre"):
				# on donne le focus à l'objet qui vient d'être déplacé
				déposer(objet_sélectionné)
				liste_inv_contenant.get_children()[-1].grab_focus()
			elif objet_sélectionné.équipable and event.is_action_released("équiper"): 
				équiper(objet_sélectionné)
				# on donne le focus au premier objet du contenant
				liste_inv_contenant.get_children()[1].grab_focus()
			elif objet_sélectionné.utilisable.inventaire and event.is_action_released("utiliser"):
				utiliser(objet_sélectionné)
				# on donne le focus au premier objet du contenant
				liste_inv_contenant.get_children()[1].grab_focus()
		if event.is_action_released("fermer"):
			fermer()


func _process(delta: float) -> void:
	# l'élément de l'inventaire qui à le focus est l'élément qui est sélectioné, on en prend la réf dans une variable
	for node in tous_les_objets:
		if node.has_focus(): 
			objet_sélectionné = node.objet
			ligne_séléctionné = node
	
	# uniquement si un opbjet a été sélectionné
	if objet_sélectionné != null and ligne_séléctionné != null:
		# on modifie le label des commandes en fonctiond des actions possibles
		# et en fonction de sa provenance
		label_instruction.text = "[q] quitter "
		if not ligne_séléctionné in liste_inv_joueur.get_children(): label_instruction.text += "[p] prendre "
		else: label_instruction.text += "[p] déposer "
		if objet_sélectionné.équipable: label_instruction.text += "[e] équiper "
		if objet_sélectionné.utilisable.inventaire: label_instruction.text += "[u] utiliser "
	else:
		label_instruction.text = "[q] quitter "
	

# permet de peupler l'interface quand on l'ouvre
func peupler_interface():
	# on commence par vider l'interface
	for node in liste_inv_contenant.get_children():
		if node is LigneInventaire: node.queue_free()
	for node in liste_inv_joueur.get_children():
		if node is LigneInventaire: node.queue_free()
	
	tous_les_objets = []
	
	# on peupel l'interface en fonction des variables du joueuer et du contenant
	## l'inventaire du joueur
	for i: Objet in InventaireJoueur.inventaire:
		var bg_ligne_inventaire = load("res://ligne_inventaire.tscn").instantiate()
		bg_ligne_inventaire.name = "Ligne bg"
		bg_ligne_inventaire.objet = i
		
		var ligne_inventaire_i = HBoxContainer.new()
		ligne_inventaire_i.name = "Aligner objets lignes"
		ligne_inventaire_i.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		var image_obj_i = TextureRect.new()
		image_obj_i.texture = i.inventaire_texture
		image_obj_i.name = "Image"
		
		var label_titre_obj_i = Label.new()
		label_titre_obj_i.text = i.nom
		label_titre_obj_i.name = "Nom"
		
		bg_ligne_inventaire.add_child(ligne_inventaire_i)
		
		ligne_inventaire_i.add_child(image_obj_i)
		ligne_inventaire_i.add_child(label_titre_obj_i)
		
		liste_inv_joueur.add_child(bg_ligne_inventaire)
		
		# on ajoute la ligne à l'array de toutes les lignes
		tous_les_objets.append(bg_ligne_inventaire)
		
	## l'inventaire du contenant, s'il n'est pas vide
	if len(contenant_parent.contenu) > 0:
		for obj in contenant_parent.contenu:
			var bg_ligne_inventaire = load("res://ligne_inventaire.tscn").instantiate()
			bg_ligne_inventaire.name = "Ligne bg"
			bg_ligne_inventaire.objet = obj
			
			var ligne_inventaire_i = HBoxContainer.new()
			ligne_inventaire_i.name = "Aligner objets lignes"
			ligne_inventaire_i.mouse_filter = Control.MOUSE_FILTER_IGNORE
			
			var image_obj_i = TextureRect.new()
			image_obj_i.texture = obj.inventaire_texture
			image_obj_i.name = "Image"
			
			var label_titre_obj_i = Label.new()
			label_titre_obj_i.text = obj.nom
			label_titre_obj_i.name = "Nom"
			
			bg_ligne_inventaire.add_child(ligne_inventaire_i)
			
			ligne_inventaire_i.add_child(image_obj_i)
			ligne_inventaire_i.add_child(label_titre_obj_i)
			
			liste_inv_contenant.add_child(bg_ligne_inventaire)
			
			# on ajoute la ligne à l'array de toutes les lignes
			tous_les_objets.append(bg_ligne_inventaire)
			
		# on donne le focus au premier objet de l'inventaire du contenant
		liste_inv_contenant.get_children()[1].grab_focus()
	
# les différentes fonctions qui correspondent aux actions de l'inventaire
func déposer(obj: Objet):
	# on ajoute l'objet à l'inventaire du contenant
	contenant_parent.ajouter_objet(obj)
	# on retire l'objet de l'inventaire du joueur
	InventaireJoueur.retirer_objet(obj)
	# on met à jour l'affichage des objets
	peupler_interface()

func prendre(obj: Objet):
	# on ajoute l'objet à l'inventaire du joueur
	InventaireJoueur.ajouter_objet(obj)
	# on retire l'objet du contenant
	contenant_parent.retirer_objet(obj)
	# on met à jour l'affichage des objets
	peupler_interface()

func équiper(obj: Objet):
	return true

func utiliser(obj: Objet):
	pass

func fermer():
	visible = false
	VariablesGlobales.ui_ouvert = false
