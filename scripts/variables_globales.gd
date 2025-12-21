extends Node

# la position globale du personnage joueur
var position_globale_joueur: Vector2

# le journal qui détailles les actions du jour et des personnages du donjon chaque tour
# la variable est attribué quand le journal est instancié dans le jeu, lors de la création du donjon
var journal: Journal

# la variable qui enregistre si un UI est ouvert à l'écran
# quand un UI est ouvert, le jeu est en pause :
# les tours n'avancent pas
# le joueur ne peut pas accomplir d'action
# les autres personnages ne peuvent pas accomplir d'action
var ui_ouvert: bool = false
