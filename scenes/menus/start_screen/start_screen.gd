extends Control

# TODO create an autoload with all the path to the scenes

var in_transition : bool = false


func _on_button_button_up():
	SceneManager.load_new_scene("res://scenes/levels/test_world/starting_village.tscn","fade_to_black")
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact") and not in_transition:
		in_transition = true
		SceneManager.load_new_scene("res://scenes/levels/test_world/starting_village.tscn","fade_to_black")
