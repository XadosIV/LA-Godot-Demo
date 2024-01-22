class_name Warp extends Node2D

signal player_entered_warp(warp: Warp, TRANSITION_TYPE:String)

@export_enum("north", "east", "south", "west") var ENTRY_DIRECTION
@export_enum("fade_to_black", "wipe_to_right") var TRANSITION_TYPE:String
@export var TARGETED_SCENE : String
@export var ENTRY_WARP_NAME : String
@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")

func warp():
	player_entered_warp.emit(self)
	sm.entry_warp_name = ENTRY_WARP_NAME
	SceneManager.load_new_scene(TARGETED_SCENE, TRANSITION_TYPE)

# invert entry direction now the direction that the player cross the warp
func get_move_direction() -> Vector2:
	var dir: Vector2 = Vector2.UP
	match ENTRY_DIRECTION:
		1:
			dir = Vector2.LEFT
		2:
			dir = Vector2.DOWN
		3:
			dir = Vector2.RIGHT
	return dir
