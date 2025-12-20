extends Node2D

######## Légende #########
# V = case vide =/= sol
# S = sol, endroit ou un objet/personnage peut se trouver
# M = mur
# C = couloir
##########################

enum DIRECTIONS {N, S, E, O}
var str_to_dir = {"N": DIRECTIONS.N, "S": DIRECTIONS.S, "E": DIRECTIONS.E, "O": DIRECTIONS.O}
var dir_to_str = {DIRECTIONS.N: "N", DIRECTIONS.S: "S", DIRECTIONS.E: "E", DIRECTIONS.O: "O"}

@onready var dongeon_node = $carte
@onready var personnages_node = $personnages
@onready var mobilier_node = $mobilier

@onready var écran_chargement = $"écran_de_chargement"
@onready var bar_progression = $"écran_de_chargement/bar_de_progression"

var infos_salles: Array[Dictionary] = []
var nb_salles: int = 0

var mobilier_array: Array[Array]

func _ready() -> void:
	# seed(50)
	
	dongeon_node.visible = false
	_générer_étage()
	dongeon_node.visible = true
	écran_chargement.visible = false
	

func _process(delta: float) -> void:
	pass


func _générer_étage():
	var étage_array: Array[Array] = []
	mobilier_array = []
	
	# première étape, on remplie de cases vides
	# il faut donc définir la taille de l'étage
	var taille_max_étage: int = 100
	for i in range(0, taille_max_étage):
		étage_array.append([])
		mobilier_array.append([])
		for j in range(0, taille_max_étage):
			étage_array[i].append("V")
			mobilier_array[i].append("X")
		
	print("hauteur: " + str(len(étage_array)) + ", largeur: " + str(len(étage_array[0])))
	
	# sélection et génération du nombre de salle
	var nb_salles_max: int = 20
	var nb_salles_min: int = 15
	var nb_salles: int = randi_range(nb_salles_min, nb_salles_max)
	self.nb_salles = nb_salles
	
	print("Génération de " + str(nb_salles) + " salles")
	étage_array = générer_étage(étage_array, nb_salles)
		
	
	# on passe à la transformation de l'array en objet du jeu
	for i in range(len(étage_array)):
		for j in range(len(étage_array[i])):
			# TEMP
			if étage_array[j][i] == "V":
				dongeon_node.set_cell(Vector2i(j, i), 0, Vector2i(0, 0), 3)
			elif étage_array[j][i][0] == "S" or étage_array[j][i][0] == "C":
				dongeon_node.set_cell(Vector2i(j, i), 0, Vector2i(0, 0), 2)
			elif étage_array[j][i] == "E":
				dongeon_node.set_cell(Vector2i(j, i), 0, Vector2i(0, 0), 5)


func salle_est_possible(position_x: int, position_y: int, taille_l: int, taille_h: int, étage: Array[Array], marge: int = 1) -> bool:
	# test si ça ne dépasse pas de la map
	if not (position_x - marge > 0 and position_x + taille_l + marge < len(étage[0])
		and position_y - marge > 0 and position_y + taille_h + marge < len(étage)):
		return false
	
	# test si overlap sur une autre salle
	for i in range(position_y - marge, position_y + taille_h + marge):
		for j in range(position_x - marge, position_x + taille_l + marge):
			if étage[i][j] != "V":
				return false
	
	# les deux conditions du dessus sont vrais, la salle est valide
	return true

func générer_salles(taille: Array, position: Array, étage: Array[Array], id: int = 0) -> Array[Array]:
	var nb_tentatives = 20
	
	# on fait un certains nombre de tentative de génération
	while nb_tentatives > 0:
		# on test si la salle est possible
		## on génère des valeurs temporaires, qui, si la salle est possible deviendront les valeurs définitives
		var temp_pos_x = position.pick_random()
		var temp_pos_y = position.pick_random()
		
		var temp_l = taille.pick_random()
		var temp_h = taille.pick_random()
		
		# on test si la salle ne dépasse pas de la carte et qu'elle n'empiète pas sur une autre salle
		# on veut une distance de au moins une case vite entre deux salles
		if salle_est_possible(temp_pos_x, temp_pos_y, temp_l, temp_h, étage):
			print("salle générée au bout de " + str(20-nb_tentatives) + " essaies")
			self.infos_salles.append({"id": id, "x": temp_pos_x, "y": temp_pos_y, "l": temp_l, "h": temp_h})
			étage = générer_salle(étage, {"id": id, "x": temp_pos_x, "y": temp_pos_y, "l": temp_l, "h": temp_h})
			return étage
		else:
			nb_tentatives -= 1
	
	print("échec de génération de la salle")
	# renvoie une salle impossible avec tout à -1
	
	return étage

func supprimer_salle(étage: Array[Array], infos_salles, erreur: bool = false) -> Array[Array]:
	if not infos_salles is Array: infos_salles = [infos_salles]
	
	for salle in infos_salles:
		for i in range(salle.y, salle.y + salle.h):
			for j in range(salle.x, salle.x + salle.l):
				if not erreur: étage[i][j] = "V"
				else: étage[i][j] = "E"
	
	return étage

func générer_salle(étage: Array[Array], infos_salles: Dictionary[String, int]) -> Array[Array]:
	if infos_salles.x != -1:
		for i in range(infos_salles.y, infos_salles.y + infos_salles.h):
			for j in range(infos_salles.x, infos_salles.x + infos_salles.l):
				étage[i][j] = "S" + str(infos_salles.id)
	
	return étage

func vecteur_direction(orientation: DIRECTIONS):
	var direction = Vector2i.ZERO
	
	match orientation: 
		DIRECTIONS.N:
			direction.y = -1
		DIRECTIONS.S:
			direction.y = +1
		DIRECTIONS.E:
			direction.x = +1
		DIRECTIONS.O:
			direction.x = -1
			
	return direction

func get_vecteur_orthogonal_random(vec: Vector2i) -> Vector2i:
	var new_vec: Vector2i
	
	if vec.x != 0: new_vec.x = 0
	else: new_vec.x = [-1, 1].pick_random()
	
	if vec.y != 0: new_vec.y = 0
	else: new_vec.y = [-1, 1].pick_random()
	
	return new_vec

func générer_couloir(étage: Array[Array], par_poids: bool=false) -> Array[Array]:
	# cette fonction de générer et d'afficher chacun des couloirs assignés aux salles dans connecter_salles
	# on prend les salles une par une, puis les couloirs de cette salle un par un,
	# pour chaque couloir, on l'étend dans la direction souhaitée jusqu'à ce qu'il tombe sur une salle
	# s'il atteind les bords de l'étage avant d'atteindre une autre salle, on recommence en lui faisant faire une virrage
	# si au bout d'un nombre donné d'essaie, le couloir ne peut être généré, on en fait un cul-de-sac de taille aléatoire
	
	for salle in self.infos_salles: # chaque salle
		# on ajoute le suivit des connections aux salles
		salle["connections"] = []
		for couloir in salle["couloirs"]: # chaque couloir de chaque salle
			var tentative_max: int = 1000 # le nombre de tentative de génération
			
			var longueur_max: int = 0 # une variable qui permet de dire quand on doit faire une virage
			
			var direction: Vector2i = vecteur_direction(couloir)
			var origine: Vector2i = Vector2i(0, 0)
			match couloir: 
				# on détermine la direction du couloir
				# et on détermine aussi le point d'origine du couloir
				# il s'agit d'une case aléatoire du mur de la direction du couloir
				DIRECTIONS.N:
					origine.y = salle.y - 1
					origine.x = range(salle.x, salle.x + salle.l).pick_random()
				DIRECTIONS.S:
					origine.y = salle.y + salle.h
					origine.x = range(salle.x, salle.x + salle.l).pick_random()
				DIRECTIONS.E:
					origine.x = salle.x + salle.l
					origine.y = range(salle.y, salle.y + salle.h).pick_random()
				DIRECTIONS.O:
					origine.x = salle.x - 1
					origine.y = range(salle.y, salle.y + salle.h).pick_random()
			
			# on génère le couloir en lui même
			var trajet_temp: Array[Vector2i] = []
			# le nombre de virage que doit prendre le couloir, au max
			var nb_virages: int = tentative_max - 10
			while tentative_max > 0:
				# on construit jusqu'à trouver une salle
				var offset_x: int = 0 # détermine la taille du couloir
				var offset_y: int = 0
				
				var chemin_trouvé: bool = false
				var mauvais_chemin: bool = false
				
				# permet de générer la possibiblité des virages
				# que le couloir peut prendre
				var direction_possible = DIRECTIONS.values()
				direction_possible.erase(couloir)
				match couloir:
					DIRECTIONS.N:
						direction_possible.erase(DIRECTIONS.S)
					DIRECTIONS.S:
						direction_possible.erase(DIRECTIONS.N)
					DIRECTIONS.E:
						direction_possible.erase(DIRECTIONS.O)
					DIRECTIONS.O:
						direction_possible.erase(DIRECTIONS.E)
				
				while not chemin_trouvé and not mauvais_chemin:
					# on ajoute cette case au chemin temporaire
					trajet_temp.append(Vector2i(origine.x + offset_x, origine.y + offset_y))
					
					offset_x += direction.x
					offset_y += direction.y
					
					# on détermine si on fait un virage, si c'est possible et sa direction
					# on ne peut pas faire de virage si le couloir n'a pas de taille
					# deux techniques pour déterminer la direction du virage
					# la premier get_vecteur_orthogonal_randomn est aléatoire
					# l'autre utilise la divition en secteur de poids, la direction est toujours vers la section au poids dans le top trois
					if len(trajet_temp) > 0:
						if randf() >= .5:
							if len(trajet_temp) % [5, 7].pick_random() == 0:
								if par_poids:
									# TODO: résoudre le problème suivant
									# dans un secteur S, une salle a un couloir vers le nord
									# le secteur avec le plus gros poids S' se trouve au sud de cette salle
									# si on applique naïvement la direction en fonction du poids, le couloir
									# fera aussitot demi tour et se retrouvera au poit de départ
									pass
								else:
									direction = get_vecteur_orthogonal_random(direction)
					
					# on check si le chemin sort de l'étage
					if (origine.x + offset_x <= 1 
						or origine.x + offset_x >= (len(étage[0]) - 1)
						or origine.y + offset_y <= 1
						or origine.y + offset_y >= (len(étage)) - 1):
						mauvais_chemin = true
						break
					
					# si on retombe sur la salle d'origine
					if étage[origine.y + offset_y][origine.x + offset_x] == str(salle.id):
						mauvais_chemin = true
						break
					
					# on check si le chemin à atteind une autre salle
					var salles_valables = str_range(0, self.nb_salles)
					salles_valables.erase(str(salle.id))
					if étage[origine.y + offset_y][origine.x + offset_x].lstrip("S") in salles_valables or étage[origine.y + offset_y][origine.x + offset_x][0] == "C":
						chemin_trouvé = true
						break
					
				
				if chemin_trouvé: 
					print("Chemin valide trouvé pour couloir " + dir_to_str[couloir] + " de la salle " + str(salle.id) + " après " + str(1000-tentative_max) + ".\n   Couloir connecté à " + étage[origine.y + offset_y][origine.x + offset_x])
					salle["connections"].append(étage[origine.y + offset_y][origine.x + offset_x].lstrip("S").lstrip("C"))
					break
				if mauvais_chemin and tentative_max <= 1: 
					tentative_max -= 1
					print("échec de génération d'un chemin valide pour le couloir " + dir_to_str[couloir] + " de la salle " + str(salle.id))
					trajet_temp = []
				else: 
					longueur_max = len(trajet_temp)
					trajet_temp = []
					tentative_max -= 1
				
			
			# on le dessine à partir du trajet selectionné
			for t in trajet_temp:
				for i in range(0, len(étage)):
					for j in range(0, len(étage[0])):
						if i == t.y and j == t.x:
							étage[i][j] = "C" + str(salle.id)
	
	return étage

#util pour checker les alentours d'une tuile pour la tuile à teser
func retour_alentours(étage, tuile_origine: Vector2i, rayon: int = 1) -> Array:
	var liste_alentours: Array = []
	
	for i in range(tuile_origine.y - rayon, tuile_origine.y + rayon):
		for j in range(tuile_origine.x - rayon, tuile_origine.x + rayon):
			if i in range(0, len(étage)) and j in range(0, len(étage[i])):
				liste_alentours.append(étage[i][j])
	
	return liste_alentours

# une version de la fonction au dessus qui renvoie plus de détails
# elle renvoie précisément toutes les tuiles et chacune de leurs positions dans un dict
func retour_alentours_détaillé(étage, tuile_origine: Vector2i, rayon: int = 1) -> Array[Dictionary]:
	var liste_alentours: Array[Dictionary] = []
	
	for i in range(tuile_origine.y - rayon, tuile_origine.y + rayon):
		for j in range(tuile_origine.x - rayon, tuile_origine.x + rayon):
			if i in range(0, len(étage)) and j in range(0, len(étage[i])):
				liste_alentours.append({"tuile": étage[i][j], "x": i, "y": j})
	
	return liste_alentours

func salle_contigue(alentours_array: String, salle: int):
	for i in alentours_array:
		if "S" in i and not str(salle) in i:
			return true
	return false

func nétoyer_étage(étage: Array[Array]) -> Array[Array]:
	# on essaie de trouver les salles qui sont complétement isolées
	# un salle est complétement isolée si aucune de ses murs ne touche à une case couloir
	
	for salle in infos_salles:
		var isolée = true
		
		for i in range(salle.y, salle.y + salle.h):
			for j in range(salle.x, salle.x + salle.l):
				var alentours: Array = retour_alentours(étage, Vector2i(j, i))
				if alentours.any(func(a): return a[0] == "C") or alentours.any(salle_contigue.bind(salle.id)):
					isolée = false
					break
			if isolée: break
					
		# si on trouve qu'elle est isolée, on la remplace par du vide
		if isolée:
			print("La salle " + str(salle.id) + " est complétement isolée")
			supprimer_salle(étage, salle)
		
			# on retire de la liste des infos_salles
			infos_salles.erase(salle)
		
	
	# le nétoyage consiste à trouver s'il y a des salles isolées et de les supprimer si c'est le cas.
	# on calcul l'air de tous les "îlots" de salles
	# si on trouve deux valeurs, on supprime toutes les cases de ce plus petit îlot
	
	"""
	var liste_ilot: Array[Array] = [[]]
	
	var compteur_ilot: int = 0
	
	for i in range(len(étage)):
		for j in range(len(étage[0])):
			if len(liste_ilot[0]) == 0 and étage[i][j] != "V":
				liste_ilot[0].append([i, j])
			else:
				if étage[i][j] != "V":
					for k in liste_ilot:
						if [i-1, j] in k:
							k.append([i, j])
						else:
							liste_ilot.append([[i, j]])
	
	print(len(liste_ilot))
	"""
	
	# autre moyen de nétoyer les étages en détectant différents îlots
	# on inclut pour chaque salle dans info_salles, à quelle autre salle elle est connecté
	# on génère donc les ilots de cette manière
	
	var ilots: Array[Dictionary] = []
	
	for salle in infos_salles:
		for connec in salle.connections:
			if not id_par_salle(connec) in ilots:
				ilots.append(id_par_salle(connec))
	
	# on a une list de salle qui sont peut être isolées
	var salles_isolées = soustraction_array(infos_salles, ilots)
	
	# on fait un premier test pour savoir si les salles de cet array sont bine isolés
	for salle in salles_isolées:
		for connec in salle:
			if id_par_salle(connec) in ilots:
				salles_isolées.erase(salle)
	
	# deuxième test si elle est bien isolée
	for salle in salles_isolées:
		# on test à chaque fois si elle est bien isolé
		var isolée = true
		
		for i in range(salle.y, salle.y + salle.h):
			for j in range(salle.x, salle.x + salle.l):
				var alentours = retour_alentours(étage, Vector2i(j, i))
				if alentours.any(func(a): return (a[0] == "S" and not str(salle.id) in a) or a[0] == "C"):
					isolée = false
					break
			if not isolée: break
		
		# si la salle est bel et bien isolée, on la supprime
		if isolée:
			supprimer_salle(étage, salle)
	
	return étage

func connecter_salles(étage: Array[Array], infos_salles: Array[Dictionary]=self.infos_salles) -> Array[Array]:
	# ajoute des informations quand à la positions et la direction des couloirs pour toutes les salles
	# appelle ensuit la fonction générer_couloir pour les mettre dans l'étage
	for salle in infos_salles:
		salle["couloirs"] = []
		# on choisi un nombre aléatoire de couloir pour chaque salle
		# puis on assigne les diréctions de ces couloirs aléatoirement
		var nb_couloir = randi_range(2, 3) # max trois couloir pour le moment
		# Si on pouvait changer la distribution aléatoire de la fonction random
		# on ferait en sorte que ce soit une distribution exponentielle
		# avec 4 couloirs étant beacuoup pls rare que 1-3 couloirs
		# mais puisqu'on est sur une distribution normale, on prend que 1-3 couloirs
		
		# la liste des directions possibles des couloirs
		var liste_directions = [DIRECTIONS.N, DIRECTIONS.S, DIRECTIONS.E, DIRECTIONS.O]
		for d in range(nb_couloir):
			# tirage sans remise
			var temp_dir = randi_range(0, len(liste_directions)-1)
			salle["couloirs"].append(liste_directions[temp_dir])
			liste_directions.remove_at(temp_dir)
	
	# maintenant que chaque salle s'est vue affectée un nombre de couloirs et une direction pour ces couloirs
	# on peut demander à la fonction générer couloir de les faire.
	étage = générer_couloir(étage)
	
	return étage

func générer_étage(étage: Array[Array], nb_salles: int) -> Array[Array]:
	var tailles_salles = range(5, 8)
	var position_salles = range(1, len(étage) - 1)
		
	for salle in range(nb_salles):
		étage = générer_salles(tailles_salles, position_salles, étage, salle)
	
	étage = connecter_salles(étage)
	# tant que la détection d'îlots ne sera pas au point
	# on garde cette ligne commentée
	#étage = nétoyer_étage(étage)
	étage = peupler_donjon(étage)
			
	return étage

# util
func str_range(min: int, max: int, step: int = 1) -> Array:
	var a = []
	
	for i in range(min, max, step):
		a.append(str(i))
	
	return a


# retourne la salle à partir de son identifiant
func id_par_salle(id: String) -> Dictionary:
	for i in infos_salles:
		if str(i["id"]) == id:
			return i
	return {}
	
func soustraction_array(a: Array, b: Array) -> Array:
	var c: Array = []
	
	c = a
	
	for i in b:
		if i in c:
			c.erase(i)
	
	return c
	
###### Expérience pour décider la direction dse couloirs ######
func connecter_salles_poids(étage: Array[Array], grain: int) -> Dictionary[Array, float]:
	# le grain définie le niveau de division de la map pour calculer les poids
	var taille_division = int(len(étage) / grain)
	# nombre total de salle dans la map
	var nb_salles: int = 0
	# les poids réparties dans un dictionnaire
	var poids_dict: Dictionary[Array, float] = {}
	
	for i in range(0, len(étage)):
		for j in range(0, len(étage[i])):
			if "S" in étage[i][j]:
				nb_salles += 1
	
	for division_x in range(grain):
		for division_y in range(grain):
			poids_dict[[division_x, division_y]] = 0
			for i in range(division_y, division_y * taille_division):
				for j in range(division_x, division_x * taille_division):
					if "S" in étage[i][j]:
						poids_dict[[division_x, division_y]] += 1
	
	# on normalise les poids
	for poids in poids_dict.keys():
		poids_dict[poids] = float(poids_dict[poids] / nb_salles)
	
	return poids_dict

########### PEUPLER LE DONJON ###########
func peupler_donjon(étage: Array[Array]) -> Array[Array]:
	# on détermine la position du joueur dans le donjon
	var position_joueur: Vector2i = Vector2i(randi_range(0, len(étage[0]) - 1), randi_range(0, len(étage) - 1))
	
	while not "S" in étage[position_joueur.y][position_joueur.x]:
		position_joueur = Vector2i(randi_range(0, len(étage[0]) - 1), randi_range(0, len(étage) - 1))
		
	personnages_node.set_cell(Vector2i(position_joueur.y, position_joueur.x), 0, Vector2i(0, 0), 1)
	
	## tout ce qui se passe ci-après doit faire attention de ne pas se superposé avec d'autres
	## objets du mobilier; à cet effet, on utilise un array qui va stocker toutes les infos du mobiliers
	# on trouve les emplacements qui correspondent à des portse et on les ajoute à une liste
	print("Génération des portes...")
	étage = ajouter_portes(étage, trouver_porte(étage))
	print("Portes générées et placées.")
	
	# on place l'escalier qui mène à l'étage suivant
	étage = ajouter_escalier(étage)
	
	## on peuple le mobilier de chaque salles
	print("On meuble les salles...")
	étage = meubler_salles(étage)
	print("Les salles sont toutes meublées.")
	
	return étage

# trouver les portes
# une porte suit le schéma suivant dans la tilemap
# SMMMM    SMMMM
# SMMMM    SMMMM
# SCCCC -> SPCCC
# SMMMM    SMMMM
# MMMMM    MMMMM
# la fonction renvoit une liste de dictionnaire: {"x": <posx>, "y": <posy>, "orientation": <direction>}
func trouver_porte(étage: Array[Array]) -> Array[Dictionary]:
	var liste_portes: Array[Dictionary] = []
	
	for i in range(len(étage[0])):
		for j in range(len(étage)):	
			if "S" in étage[j][i]:
				if "C" in étage[j+1][i] and étage[j+1][i+1] == "V" and étage[j+1][i-1] == "V": 
					liste_portes.append({"x": j+1, "y": i, "orientation": DIRECTIONS.E})
				elif "C" in étage[j-1][i] and étage[j-1][i+1] == "V" and étage[j-1][i-1] == "V": 
					liste_portes.append({"x": j-1, "y": i, "orientation": DIRECTIONS.O}) 
				elif "C" in étage[j][i+1] and étage[j+1][i+1] == "V" and étage[j-1][i+1] == "V": 
					liste_portes.append({"x": j, "y": i+1, "orientation": DIRECTIONS.S}) 
				elif "C" in étage[j][i-1] and étage[j+1][i-1] == "V" and étage[j-1][i-1] == "V": 
					liste_portes.append({"x": j, "y": i-1, "orientation": DIRECTIONS.N}) 
	
	return liste_portes

# la fonction qui, à partir des positions des portes, les ajoutent dans l'array étage
func ajouter_portes(étage: Array[Array], liste_info_portes) -> Array[Array]:
	for i in liste_info_portes:
		match i.orientation:
			DIRECTIONS.O:
				mobilier_node.set_cell(Vector2i(i.x, i.y), 0, Vector2i(0, 0), 1)
			DIRECTIONS.E:
				mobilier_node.set_cell(Vector2i(i.x, i.y), 0, Vector2i(0, 0), 1)
			DIRECTIONS.N:
				mobilier_node.set_cell(Vector2i(i.x, i.y), 0, Vector2i(0, 0), 2)
			DIRECTIONS.S:
				mobilier_node.set_cell(Vector2i(i.x, i.y), 0, Vector2i(0, 0), 2)
	
	return étage

# placer escalier
func ajouter_escalier(étage: Array[Array]) -> Array[Array]:
	var endroit_trouvé: bool = false
	
	print("Génération de l'escalier de sortie")
	
	var position_escalier: Vector2i
	
	while not endroit_trouvé:
		position_escalier = Vector2i(randi_range(0, len(étage[0]) - 1), randi_range(0, len(étage) - 1))
		
		if (étage[position_escalier.y][position_escalier.x][0] == "S" 
			and mobilier_array[position_escalier.y][position_escalier.x] == "X"):
				print("Escalier de sortie créé avec succès")
				endroit_trouvé = true
	
	mobilier_array[position_escalier.y][position_escalier.x] = "Es"
	mobilier_node.set_cell(Vector2i(position_escalier.y, position_escalier.x), 0, Vector2i(0, 0), 3)
		
	return étage

# fonction qui permet de trouver un endroit valide aléatoirement
# à finir plus tard, quand j'en aurais besoin dans un cas réel
func trouver_emplacement_valide_mobilier(étage, tuiles_autorisées: Array[String]=[]) -> Vector2i:
	var pos: Vector2i = Vector2i(randi_range(0, len(étage[0] - 1)), randi_range(0, len(étage) - 1))
	
	while not "S" in étage[pos.y][pos.x] and mobilier_array[pos.y][pos.x] != "X":
		pos = Vector2i(randi_range(0, len(étage[0] - 1)), randi_range(0, len(étage) - 1))
	
	return pos

# la fonction qui prend chaque salle, décide quel mobilier y placer, où le placer et le place en conséquence
func meubler_salles(étage) -> Array[Array]:	
	# on prend toutes les salles une par une
	for salle in infos_salles:
		# est-ce que la salle a un chandelier: 90% des salles
		if randf() >= .1:
			var position_chandelier: Vector2i = Vector2i(randi_range(salle.x, salle.x + salle.l -1), randi_range(salle.y, salle.y + salle.h - 1))
			var emplacement_trouvé: bool = false
			
			while not emplacement_trouvé:
				if (mobilier_array[position_chandelier.y][position_chandelier.x] == "X"
					and étage[position_chandelier.y][position_chandelier.x] == "S"+str(salle.id)):
						emplacement_trouvé = true
				
				position_chandelier = Vector2i(randi_range(salle.x, salle.x + salle.l - 1), randi_range(salle.y, salle.y + salle.h - 1))
			
			print("Chandelier généré dans la salle " + str(salle.id) + "!")
			mobilier_array[position_chandelier.y][position_chandelier.x] = "Ch"
			mobilier_node.set_cell(Vector2i(position_chandelier.y, position_chandelier.x), 0, Vector2i(0, 0), 4)
			
	return étage
