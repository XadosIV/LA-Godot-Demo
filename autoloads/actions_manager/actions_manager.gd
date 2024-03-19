class_name ActionsManager extends Node

@onready var sm = get_tree().root.get_node("SceneManager")

var json_data = {}

var npcs = []
var exercises = []

var actions_fifo = []
var lastIdExecuted = -1

func _ready():
	var file = FileAccess.get_file_as_string("res://default_dialogs.json")
	var jtext = JSON.parse_string(file)
	# charger ces actions

func read_json(path):
	var file = FileAccess.get_file_as_string(path)
	var jtext = JSON.parse_string(file)
	
	json_data = jtext
	
	for pnj in jtext.pnjs:
		npcs.append(pnj)
	
	for exercice in jtext.exercises:
		exercises.append(exercice)

func getNpcById(id):
	for npc in npcs:
		if npc.id == id:
			return npc
	return false #L'id ne correspond à aucun pnj

func getExerciceById(id):
	for exo in exercises:
		if exo.id == id:
			return exo
	return false #L'id ne correspond à aucun exo

func interact(id):
	loadPage(id)
	executeNextAction()

func loadPage(id):
	var npc = getNpcById(id)
	if npc:
		actions_fifo = []
		for action in npc.pages[npc.currentPage]:
			actions_fifo.append(action)
		lastIdExecuted = id
	else:
		print("NPC Introuvable lors du chargement de la page.")

func executeNextAction():
	if actions_fifo.size() != 0:
		readAction(lastIdExecuted, actions_fifo.remove(0)) #défile l'action mise en paramètre et la renvoie donc

func getName(id, action):
	var name = "Diantre ! Je n'ai point de nom, how is that possible ?"
	if "name" in action:
		name = action.name
	else:
		var npc = getNpcById(id)
		if npc:
			name = npc.name
	return name

func readAction(id, action):
	match action.type:
		"dire":
			dire(getName(id, action), action.text)
		"exercice":
			exercice(getName(id, action), action.target, action.echec, action.succes)
		"aller":
			aller(action.target, action.page)
		"executer":
			executer(id, action.page)
		"donner":
			donner(action.id)
		_:
			print("Mot inconnu.")

func dire(name, text):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	
	dialog_box.dialog_init([{"name":name, "text":text, "type":"paragraph"}])

func exercice(name, id_exercice, echec, succes):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	
	var exercice = getExerciceById(id_exercice)
	if exercice:
		dialog_box.dialog_init([{"name":name, "text":exercice.question, "type":"mcq", "questions":exercice.options}])
	else:
		print("marche po")

func aller(id, page):
	var npc = getNpcById(id)
	if npc != -1:
		if npc.pages.length < page:
			npc.currentPage = page
		else:
			return -2 # Page introuvable
	return -1 # Pnj introuvable

func executer(id, page):
	# break l'action courante et lit la page donnée
	if aller(id, page) < 0:
		print("Erreur sur exécuter")
	else:
		loadPage(id)

func donner(id):
	pass
