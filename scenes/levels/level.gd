class_name Level extends Node

@onready var sm: SceneManager = get_parent().get_node("SceneManager")
@onready var dm: DialogManager = get_parent().get_node("DialogManager")


@onready var lm = get_node("LogicMap")

# Initialisation d'un level
func _ready() -> void:
	sm.player = $Player
	
	load_json_data()
	
	if sm.entry_warp_name: # Si le joueur provient d'un warp
		var entryWarp = lm.warps[sm.entry_warp_name]
		sm.player.position = Vector2((entryWarp[0]*16)+Vector2i(8,8))
		lm.init()
		sm.player.move(entryWarp[1].get_move_direction()) #Sort le joueur du warp
	else:
		lm.init()
	sm.player.enable()



func load_json_data():
	
	if sm.json_data:
		if sm.json_data["entities"]:
			for i in sm.json_data["entities"]:
				dm.create_dialog(str(i["id"]), i["actions"])
				lm.create_actor(Vector2i((-6+i["id"]), -7), str(i["id"]))
			
			#for i in range(10):
			#	lm.create_actor(Vector2i((-6+i), -7), "truc")
	else:
		print("No JSON Data Loaded.")
