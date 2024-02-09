class_name Warp extends Node2D

"""
Scène pour modéliser un warp
"""

# Signal emit quand le joueur entre dans le warp
signal player_entered_warp(warp: Warp, TRANSITION_TYPE:String)

@export_enum("north", "east", "south", "west") var ENTRY_DIRECTION
@export_enum("fade_to_black", "wipe_to_right") var TRANSITION_TYPE:String
@export var TARGETED_SCENE : String
@export var ENTRY_WARP_NAME : String
@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")

# Emet un signal quand le joueur prend un warp et lance le système de transition de scène
func warp():
	player_entered_warp.emit(self)
	sm.entry_warp_name = ENTRY_WARP_NAME
	SceneManager.load_new_scene(TARGETED_SCENE, TRANSITION_TYPE)

# Donne la direction de sortie du warp
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
