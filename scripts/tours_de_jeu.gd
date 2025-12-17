extends Node

# le tour de jeu actuel
var tour_de_jeu_actuel: int = 0

# le signal émit lors de du début d'un tour
signal nouveau_tour

# fonction appelé dès qu'une action qui finit un tour est faite
func prochain_tour():
	# on augmente le numéro du tour
	tour_de_jeu_actuel += 1
	
	# on signal le nouveau tour
	nouveau_tour.emit()
