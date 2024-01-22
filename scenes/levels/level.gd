class_name Level extends Node

@onready var sm: SceneManager = get_parent().get_node("SceneManager")

func _ready() -> void:
	sm.player = $Player
	var lm = get_node("LogicMap")
	
	if sm.entry_warp_name:
		var entryWarp = lm.warps[sm.entry_warp_name]
		sm.player.position = Vector2((entryWarp[0]*16)+Vector2i(8,8))
		lm.init()
		sm.player.move(entryWarp[1].get_move_direction())
	else:
		lm.init()
	
	
	
	sm.player.enable()


	#player.apply_direction_on_sprite(facing_direction)"""
