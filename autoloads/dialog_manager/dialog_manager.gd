extends Node

var dialog : Dictionary = {}

@onready var sm = get_tree().root.get_node("SceneManager")

func _ready():
	var fas = FileAccess.get_file_as_string("res://default_dialogs.json")
	var jtext = JSON.parse_string(fas)
	dialog = jtext

func get_dialogs_name():
	return dialog.keys()

func dialog_exists(str : String):
	return str in get_dialogs_name()

func get_dialog(str: String):
	return dialog[str]

func create_dialog(nom: String, data:Array):
	print(sm.json_data["exercises"][1])
	if not dialog_exists(nom):
		for i in data:
			if i["type"] == "qcm":
				i["type"] = "mcq"
				i["text"] = sm.json_data["exercises"][i["id"]]["question"]
				i["questions"] = sm.json_data["exercises"][i["id"]]["options"]
		print(data)
		dialog[nom] = data
	else:
		print("Dialog already exists.")
