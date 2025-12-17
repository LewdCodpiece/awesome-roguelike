extends PanelContainer

func _ready() -> void:
	visible = false

func _process(delta: float) -> void:
	$Label.text = "tour #" + str(ToursDeJeu.tour_de_jeu_actuel)

func _input(event: InputEvent) -> void:
	if event.is_action_released("débug"):
		visible = not visible
