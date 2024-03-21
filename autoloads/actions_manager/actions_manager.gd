class_name ActionsManager extends Node

@onready var sm = get_tree().root.get_node("SceneManager")

var json_data = {}

var npcs = []
var exercises = []
var items = []

var actions_fifo = []
var lastIdExecuted = -1
var lastExerciceExecuted = {}


func _ready():
	var file = FileAccess.get_file_as_string("res://default_dialogs.json")
	var jtext = JSON.parse_string(file)
	# charger ces actions
	for pnj in jtext.pnjs:
		npcs.append(pnj)
	
	for exercice in jtext.exercises:
		exercises.append(exercice)

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
		if i.id == id:
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
	print(action)
	match action.type:
		"dire":
			dire(getName(id, action), action.text)
			return false
		"exercice":
			exercice(getName(id, action), action.target, action.echec, action.succes)
			return false
		"aller":
			aller(action.target, action.page)
			return true
		"executer":
			executer(id, action.page)
			return true
		"donner":
			donner(action.target)
			return true
		_:
			printerr("Mot inconnu.")

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

func exo_result(res:Array):
	# A appeler à la fin d'un exo pour exécuter la bonne prochaine action définie dans le graphe.
	if res.size() >= 0.5: #succes
		actions_fifo.insert(0, lastExerciceExecuted.succes)
	else: #echec
		actions_fifo.insert(0, lastExerciceExecuted.echec)
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
		sm.player.inventory_add(item, true)
