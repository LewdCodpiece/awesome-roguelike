extends Control


func _nouvelle_partie():
	# ouvre l'écran de création de personnage
	# TODO
	
	# génère un nouveau donjon
	var donjon = load('res://scènes/carte.tscn').instantiate()
	get_parent().add_child(donjon)
	
	# quitte l'écran d'accueil
	queue_free()


func _on_nouvelle_partie_pressed() -> void:
	_nouvelle_partie()
