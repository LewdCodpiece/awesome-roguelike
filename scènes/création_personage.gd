extends Control

# nodes
## stats
@onready var puissance_bar = $fond/colonnes/stats/lignes/puissance/TextureProgressBar
@onready var verve_bar = $fond/colonnes/stats/lignes/verve/TextureProgressBar
@onready var entendement_bar = $fond/colonnes/stats/lignes/entendement/TextureProgressBar
@onready var finesse_bar = $fond/colonnes/stats/lignes/finesse/TextureProgressBar
@onready var fortitude_bar = $fond/colonnes/stats/lignes/fortitude/TextureProgressBar

# stats
var puissance: int = 0
var verve: int = 0
var entendement: int = 0
var finesse: int = 0
var fortitude: int = 0

func _ready() -> void:
	roll_stats()

func roll_stats():
	puissance = 0
	verve = 0
	entendement = 0
	finesse = 0
	fortitude = 0
	
	var points_à_attribuer: int = randi() % 30 + 20
	
	for i in range(points_à_attribuer):
		var tmp = randi() % 5 + 1
		
		match tmp:
			1: puissance += 1
			2: verve += 1
			3: entendement += 1
			4: finesse += 1
			5: fortitude += 1
	
	# màj des sliders
	puissance_bar.value = puissance
	verve_bar.value = verve
	entendement_bar.value = entendement
	finesse_bar.value = finesse
	fortitude_bar.value = fortitude


func _on_reroll_pressed() -> void:
	roll_stats()
