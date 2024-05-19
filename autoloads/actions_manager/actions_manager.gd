class_name ActionsManager extends Node

@onready var sm = get_tree().root.get_node("SceneManager")
@onready var gm = get_tree().root.get_node("GameManager")

# Contient tout les éléments chargés des données
var npcs = [] 
var exercises = []
var items = []

# Variables de sauvegarde du verbe en cours d'exécution si celui-ci
# nécessite une UI de choix.
var lastNpcExecuted = -1 # Id du pnj interagi
var lastExerciceExecuted = {} # Exercice en cours
var lastChoicesAction = [] # Choix en cours

# File des verbes d'actions à exécuter
var actions_fifo = []

func _ready():
	read_json("res://default_dialogs.json")

# Charge les données à partir du chemin du fichier d'export.
func read_json(path):
	var file = FileAccess.get_file_as_string(path)
	var jtext = JSON.parse_string(file)
	
	var json_data = jtext
	
	for pnj in jtext.pnjs:
		npcs.append(pnj)
	
	for exercice in jtext.exercises:
		exercises.append(exercice)
	
	if "items" in jtext:
		for item in jtext.items:
			items.append(item)

# Fonction générique, renvoie le premier élément d'une liste d'objet
# ayant la propriété obj.id == id (donnée en paramètre)
func getIdFromList(id, list):
	for i in list:
		if int(i.id) == int(id):
			return i
	return false

# Appels de la fonction générique ci-dessus pour chaque ressource chargé.
func getNpcById(id):
	return getIdFromList(id, npcs)

func getExerciceById(id):
	return getIdFromList(id, exercises)

func getItemById(id):
	return getIdFromList(id, items)

# Appelé lors de l'interaction avec un pnj.
# Charge la page du pnj en question (via son id)
# Et exécute les actions correspondantes.
func interact(id):
	loadPage(id)
	executeNextAction()

# Charge la page d'un pnj
func loadPage(npcId):
	var npc = getNpcById(npcId)
	if npc:
		actions_fifo = []
		for action in npc.pages[npc.currentPage]:
			actions_fifo.append(action)
		lastNpcExecuted = npcId # Stocke l'id du pnj en cours de lecture
	else:
		print("NPC Introuvable lors du chargement de la page.")

# Fonction récursive exécutant les actions
# dans l'ordre de la file
func executeNextAction():
	if actions_fifo.size() != 0:
		#pop_front => défile l'action mise en paramètre et la renvoie donc
		var next = readAction(lastNpcExecuted, actions_fifo.pop_front())
		# next est un booléen mis à true si la prochaine action peut s'éxecuter
		# false dans le cas où on requiert un choix de l'utilisateur (exercice, choice, ...)
		if next:
			executeNextAction()

# Fonction tentant d'obtenir un nom affichable pour le dialogue
# Regarde dans action.name et npc.name, renvoie une valeur par défaut
# si aucun des deux n'est défini.
func getName(id, action):
	var name = "UNDEFINED NAME"
	if "name" in action:
		name = action.name
	else:
		var npc = getNpcById(id)
		if npc:
			name = npc.name
	return name

# Exécute la prochaine action en appelant
# la fonction correspondante avec les paramètres nécessaires.
func readAction(id, action):
	print(action)
	print(id)
	# Note : return false => N'exécute pas la prochaine action
	# c'est la valeur 'next' de la fonction 'executeNextAction'
	
	match action.type:
		"dire":
			if action.text == "DISPARAITRE":
				var logicMap = sm.player.get_parent().get_node("LogicMap")
				print(logicMap.suppr_actor(id))
				return true
			else:
				dire(getName(id, action), action.text)
				return false
		"aller":
			aller(action.target, action.page-1)
			return true
		"executer":
			executer(action.target, action.page-1)
			return true
		"donner":
			if action.target == "object":
				donner(action.id)
			elif action.target == "exercice":
				exercice(getName(id, action), action.id, action.echec, action.succes)
			return false
		"choisir":
			choisir(getName(id, action), action.text, action.target)
			return false
		"tester":
			tester(action.target, action.id, action.succes, action.echec)
			return true
		"rien": # Mot-clé ne produisant rien, généré par l'éditeur via un champ "ne rien faire"...
			return true
		_:
			printerr("Mot inconnu : " + action.type)

# Initialise une boite de dialogue avec le nom et le texte donné.
func dire(name, text):
	# La boite de dialogue étant attaché au joueur, elle change durant les scènes
	# et ne peut pas être mise en cache.
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	var dia = ParagraphDialog.new()
	dia.init(name, text)
	dialog_box.init_paragraph(dia)

# Change la page courante du pnj avec l'id donné en paramètre.
func aller(id, page):
	var npc = getNpcById(id)
	if npc:
		if page < npc.pages.size():
			npc.currentPage = page
			return 0
		else:
			return -2 # Page introuvable
	else:
		return -1 # Pnj introuvable

# Change la page courante du pnj, charge cette page et l'exécute. (next = true)
func executer(id, page):
	if aller(id, page) < 0:
		print("Erreur sur exécuter")
	else:
		loadPage(id)

# Donne l'item 'id' au joueur.
func donner(id):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	var dia = ParagraphDialog.new()
	
	var item = getItemById(id)
	if item:
		dia.init("Information", "Vous obtenez : " + item.name)
		dialog_box.init_paragraph(dia)
		sm.player.inventory_add(item.id)

# Donne un exercice au joueur.
func exercice(name, id_exercice, echec, succes):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	
	var exercice = getExerciceById(id_exercice)
	if exercice:
		lastExerciceExecuted = {"exercice":exercice, "echec":echec, "succes":succes}
		var exoObject = McqDialog.new()
		exoObject.init(name, exercice.question, exercice.options)
		dialog_box.init_mcq(exoObject)
	else:
		printerr("Exercice inconnu, id : " + str(id_exercice))

# Donne un choix entre plusieurs options.
func choisir(name, question, target):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	var choiceObject = McqDialog.new()
	
	lastChoicesAction = target
	
	var choices = []
	for i in target:
		choices.append(i["text"])
	
	choiceObject.init(name, question, choices)
	dialog_box.init_choice(choiceObject)

# Teste si un id est dans une liste (= Si un exercice est fait / Si un objet est dans l'inventaire)
# Exécute le mot défini dans 'succes' ou 'echec' selon le résultat.
func tester(type, id, succes, echec):
	var list = []
	if type == "exercice":
		list = gm.exercisesCompleted
	elif type == "object":
		list = gm.inventory
	else:
		return -1 # type inconnu
	
	if list.has(int(id)):
		actions_fifo.insert(0, succes)
	else:
		actions_fifo.insert(0, echec)

# Attribut un score entre 0 et 1 pour les réponses du qcm.
func get_result_value_mcq(query, options, response):
	var point_negatif = 1/float(options.size())
	var point = 1/float(response.size())
	var total = 0
	for i in range(options.size()):
		if (query.has(i)):
			if response.has(float(i)):
				total += point
			else:
				total -= point_negatif
	return total

# Appelé à la fin d'un exo, permet de tester le résultat et d'exécuter le mot correspondant.
func exo_result(res:Array):
	var r = get_result_value_mcq(res, lastExerciceExecuted.exercice.options, lastExerciceExecuted.exercice.response)
	if r >= 0.5: #succes
		actions_fifo.insert(0, lastExerciceExecuted.succes)
		var exo_id = lastExerciceExecuted.exercice.id
		if not gm.exercisesCompleted.has(int(exo_id)):
			gm.exercisesCompleted.append(int(exo_id))
	else: #echec
		actions_fifo.insert(0, lastExerciceExecuted.echec)
	executeNextAction()

# Appelé à la fin d'un choix, permet d'exécuter le mot correspondant au choix donné.
func choice_result(res:Array):
	actions_fifo.insert(0, lastChoicesAction[res[0]]["action"])
	executeNextAction()
