extends StaticBody2D

@onready var sprite = $Sprite2D
@onready var raycast_action = $Sprite2D/raycast_actions

# variables statistiques personnage
var pv: int = 0
var mana: int = 0
var sanité: int = 0

var verve: int = 0
var entendement: int = 0
var puissance: int = 0
var finesse: int = 0
var fortitude: int = 0

# inventaire du personnage et emplacement d'équipement
# il va falloir faire la classe objet et typer ces variables
var inventaire: Array = []
var objet_main_gauche
var objet_main_droite

# variables logiques

func _process(delta: float) -> void:
	# envoie la position du joueur à l'ui
	VariablesGlobales.position_globale_joueur = self.global_position

func _input(event: InputEvent) -> void:
	
	var direction: Vector2 = Vector2(0, 0)
	
	# aucune action n'est possible tant qu'un ui est ouvert
	if not VariablesGlobales.ui_ouvert:
		# actions qui font passer un tour
		## Intéractions avec les objets du monde
		## on fait appel au raycast et on appelle la fonction action() de l'interractible
		
		### Le raycast action scan les layers de collisions 1 et 2.
		### La présence objet dans le premier layer de collision fait d'un objet un obstacle
		### et la présence d'un objet dans le deuxième en fait une tuile non-obstacle interractive
		### cette division permet d'interragir avec des objets qui ne sont pas/plus des obstacles
		### e.g. une porte ouverte que l'on veut refermer, etc.
		if raycast_action.is_colliding():
			
			var colider = raycast_action.get_collider().get_parent()
			# si le colider est une tuile interractive
			if colider is Tuile and colider:
				if event.is_action_released("interragir"):
					colider.action()
					ToursDeJeu.prochain_tour()
				
		## déplacements
		if event.is_action_released("bas"):
			# déplacement
			direction.y = 1
			# rotation
			sprite.rotation_degrees = 180
		elif event.is_action_released("droite"):
			# déplacement
			direction.x = 1
			# rotation
			sprite.rotation_degrees = 90
		elif event.is_action_released("gauche"):
			# déplacement
			direction.x = -1
			# rotation
			sprite.rotation_degrees = -90
		elif event.is_action_released("haut"):
			# déplacement
			direction.y = -1
			# rotation
			sprite.rotation_degrees = 0
			
		if not test_move(transform, direction*8) and direction != Vector2.ZERO:
			move_and_collide(direction * 8)
			ToursDeJeu.prochain_tour()
		
		# actions qui ne font pas passer un tour
