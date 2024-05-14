class_name ActionsManager extends Node

@onready var sm = get_tree().root.get_node("SceneManager")
@onready var gm = get_tree().root.get_node("GameManager")

var json_data = {}

var npcs = []
var exercises = []
var items = []

var actions_fifo = []
var lastIdExecuted = -1
var lastExerciceExecuted = {}
var lastChoicesAction = []


func _ready():
	var file = FileAccess.get_file_as_string("res://default_dialogs.json")
	var jtext = JSON.parse_string(file)
	# charger ces actions
	for pnj in jtext.pnjs:
		npcs.append(pnj)
	
	for exercice in jtext.exercises:
		exercises.append(exercice)
	
	for item in jtext.items:
		items.append(item)

func read_json(path):
	var file = FileAccess.get_file_as_string(path)
	var jtext = JSON.parse_string(file)
	
	json_data = jtext
	
	for pnj in jtext.pnjs:
		npcs.append(pnj)
	
	for exercice in jtext.exercises:
		exercises.append(exercice)
	
	if "items" in jtext:
		for item in jtext.items:
			items.append(item)

func getIdFromList(id, list):
	for i in list:
		if int(i.id) == int(id):
			return i
	return false

func getNpcById(id):
	return getIdFromList(id, npcs)

func getExerciceById(id):
	return getIdFromList(id, exercises)

func getItemById(id):
	return getIdFromList(id, items)

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
		var next = readAction(lastIdExecuted, actions_fifo.pop_front()) #défile l'action mise en paramètre et la renvoie donc
		if next:
			executeNextAction()

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
	#print(action)
	match action.type:
		"dire":
			dire(getName(id, action), action.text)
			return false
		"aller":
			aller(action.target, action.page)
			return true
		"executer":
			executer(id, action.page)
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
		"rien":
			return true
		_:
			printerr("Mot inconnu : " + action.type)

func tester(type, id, succes, echec):
	var list = []
	if type == "exercice":
		list = gm.exercicesCompleted
	elif type == "object":
		list = gm.inventory
	else:
		return -1 # type inconnu
	
	if list.has(int(id)):
		actions_fifo.insert(0, succes)
	else:
		actions_fifo.insert(0, echec)

func dire(name, text):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	var dia = ParagraphDialog.new()
	dia.init(name, text)
	dialog_box.init_paragraph(dia)

func exercice(name, id_exercice, echec, succes):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	
	var exercice = getExerciceById(id_exercice)
	if exercice:
		lastExerciceExecuted = {"exercice":exercice, "echec":echec, "succes":succes}
		var exoObject = McqDialog.new()
		exoObject.init(name, exercice.question, exercice.options)
		dialog_box.init_mcq(exoObject)
	else:
		printerr("marche po")

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

func exo_result(res:Array):
	# A appeler à la fin d'un exo pour exécuter la bonne prochaine action définie dans le graphe.
	var r = get_result_value_mcq(res, lastExerciceExecuted.exercice.options, lastExerciceExecuted.exercice.response)
	if r >= 0.5: #succes
		actions_fifo.insert(0, lastExerciceExecuted.succes)
		var exo_id = lastExerciceExecuted.exercice.id
		if not gm.exercisesCompleted.has(int(exo_id)):
			gm.exercisesCompleted.append(int(exo_id))
	else: #echec
		actions_fifo.insert(0, lastExerciceExecuted.echec)
	executeNextAction()

func choice_result(res:Array):
	# A appeler à la fin d'un exo pour exécuter la bonne prochaine action définie dans le graphe.
	actions_fifo.insert(0, lastChoicesAction[res[0]]["action"])
	executeNextAction()

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

func executer(id, page):
	# break l'action courante et lit la page donnée
	if aller(id, page) < 0:
		print("Erreur sur exécuter")
	else:
		loadPage(id)

func donner(id):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	var dia = ParagraphDialog.new()
	
	var item = getItemById(id)
	if item:
		dia.init("Information", "Vous obtenez : " + item.name)
		dialog_box.init_paragraph(dia)
		sm.player.inventory_add(item.id)

func choisir(name, question, target):
	var dialog_box : DialogBox = get_node("/root/SceneManager").player.dialog_box
	var choiceObject = McqDialog.new()
	
	lastChoicesAction = target
	
	var choices = []
	for i in target:
		choices.append(i["text"])
	
	choiceObject.init(name, question, choices)
	dialog_box.init_choice(choiceObject)
