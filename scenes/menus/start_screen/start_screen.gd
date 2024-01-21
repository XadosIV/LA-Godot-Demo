extends Control

# TODO create an autoload with all the path to the scenes

func _on_button_button_up():
	SceneManager.load_new_scene("res://scenes/levels/test_world/test_map_1.tscn","fade_to_black")
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
		SceneManager.load_new_scene("res://scenes/levels/test_world/test_map_1.tscn","fade_to_black")
