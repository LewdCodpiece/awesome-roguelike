extends Control

@onready var grille_inv_joueur = $HBoxContainer/panel_inv_joueur/VBoxContainer/grille_inv_joueur
@onready var grille_inv_contenant = $HBoxContainer/panel_inv_contenant/VBoxContainer/grille_inv_contenant

# permet de peupler l'interface quand on l'ouvre
func peupler_interface():
	# on commence par vider l'interface
	for node in grille_inv_contenant.get_children():
		node.queue_free()
	for node in grille_inv_joueur.get_children():
		node.queue_free()
	
	# on peupel l'interface en fonction des variables du joueuer et du contenant
	## l'inventaire du joueur
	for i: Objet in InventaireJoueur.inventaire:
		# TEMP: juste pour afficher les objets pour l'instant
		var tmp_image_obj_i = TextureRect.new()
		tmp_image_obj_i.texture = i.inventaire_texture
		
		grille_inv_joueur.add_child(tmp_image_obj_i)
