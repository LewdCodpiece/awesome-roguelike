extends Control

@onready var liste_inv_joueur = $VBoxContainer/HBoxContainer/panel_inv_joueur/VBoxContainer
@onready var liste_inv_contenant = $VBoxContainer/HBoxContainer/panel_inv_contenant/VBoxContainer

# permet de peupler l'interface quand on l'ouvre
func peupler_interface():
	# on commence par vider l'interface
	for node in liste_inv_contenant.get_children():
		if node is LigneInventaire: node.queue_free()
	for node in liste_inv_joueur.get_children():
		if node is LigneInventaire: node.queue_free()
	
	# on peupel l'interface en fonction des variables du joueuer et du contenant
	## l'inventaire du joueur
	for i: Objet in InventaireJoueur.inventaire:
		# TEMP: juste pour afficher les objets pour l'instant
		var bg_ligne_inventaire = load("res://ligne_inventaire.tscn").instantiate()
		bg_ligne_inventaire.name = "Ligne bg"
		
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
