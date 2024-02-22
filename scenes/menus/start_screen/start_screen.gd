extends Control

# TODO Créer un autoload avec totues les varaibles vers les scènes

var in_transition : bool = false

func _ready():
	get_viewport().files_dropped.connect(on_files_dropped)

func on_files_dropped(files):
	var path = files[0]
	if path.ends_with(".json"):
		var jstring = FileAccess.get_file_as_string(path)
		SceneManager.json_data = JSON.parse_string(jstring)


#MDR
func _on_button_button_up():
	SceneManager.load_new_scene("res://scenes/levels/test_world/starting_village.tscn", "wipe_to_right")
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and not in_transition:
		in_transition = true
		SceneManager.load_new_scene("res://scenes/levels/test_world/starting_village.tscn","wipe_to_right")
