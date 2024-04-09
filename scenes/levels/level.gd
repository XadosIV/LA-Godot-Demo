class_name Level extends Node

@onready var sm: SceneManager = get_parent().get_node("SceneManager")
@onready var am: ActionsManager = get_parent().get_node("ActionManager")
@onready var lm = get_node("LogicMap")
@onready var current_scene_path = ""
@onready var current_scene_name = ""
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

#func get_scene_file_path():
#	return super()

func load_json_data():
	current_scene_path = self.get_scene_file_path().split("/")
	current_scene_name = current_scene_path[len(current_scene_path)-1]
	if am.json_data:
		for i in am.npcs:
			if i["id"] < 0:
				continue
			#print(i["map"] + " - " +self.current_scene_name+" == "+ str((i["map"] == self.current_scene_name)))
			if(i["map"] == self.current_scene_name):
				print(Vector2i(i["x"], i["y"]))
				lm.create_actor(i["id"], Vector2i(i["x"], i["y"]), i["sprite"])
	else:
		print("No JSON Data Loaded.")
