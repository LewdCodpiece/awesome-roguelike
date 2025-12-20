class_name Journal extends Control

@onready var entrées_journal_node = $"PanelContainer/entrées_journals"

func _ready() -> void:
	VariablesGlobales.journal = self

func ajouter_message(texte: String):
	var message_lab: Label = Label.new()
	
	message_lab.text = "["+ str(ToursDeJeu.tour_de_jeu_actuel) +"] " + texte
	# change la taille de la police dans le journal sans avoir à créer un nouveau thème
	# ou une ressource label settings
	message_lab.add_theme_font_size_override("font_size", 18)
	
	entrées_journal_node.add_child(message_lab)
