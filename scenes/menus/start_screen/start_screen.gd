extends Control

# TODO Créer un autoload avec toutes les varaibles vers les scènes

var in_transition : bool = false
var path = "res://SCENARIO_PRESENTATION.json"

@onready var actionsManager : ActionsManager = get_node("/root/ActionManager")

func _ready():
	get_viewport().files_dropped.connect(on_files_dropped)
	
	# Pour charger le scénario dans le cadre de la soutenance
	#$VBoxContainer/Button.visible = false
	if (path == null):
		$VBoxContainer/Button.visible = false
	else:
		actionsManager.read_json(path)
		$Label.text = "Scénario pour la soutenance"

func on_files_dropped(files):
	path = files[0]
	if path.ends_with(".json"):
		$VBoxContainer/Button.visible = true
		actionsManager.read_json(path)
		$Label.text = str(path)
	else:
		path = null
		$VBoxContainer/Button.visible = false
		$Label.text = "NULL"

func _on_button_button_up():
	SceneManager.load_new_scene("res://scenes/levels/test_world/starting_village/starting_village.tscn")
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and not in_transition and path != null:
		in_transition = true
		SceneManager.load_new_scene("res://scenes/levels/test_world/starting_village/starting_village.tscn")
