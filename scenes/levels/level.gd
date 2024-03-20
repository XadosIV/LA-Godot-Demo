class_name Level extends Node

@onready var sm: SceneManager = get_parent().get_node("SceneManager")
@onready var am: ActionsManager = get_parent().get_node("ActionManager")
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
	if am.json_data:
		for i in am.npcs:
			if i["id"] < 0:
				continue
			lm.create_actor(i["id"], Vector2i((-6+i["id"]), -7))
	else:
		print("No JSON Data Loaded.")
