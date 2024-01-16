class_name Warp extends Area2D

signal  player_entered_warp(warp: Warp, TRANSITION_TYPE:String)

@export_enum("north", "east", "south", "west") var ENTRY_DIRECTION
@export_enum("fade_to_black", "wipe_to_right") var TRANSITION_TYPE:String
@export var PUSH_DISTANCE: int = 16
@export var TARGETED_SCENE : String
@export var ENTRY_WARP_NAME : String

func _on_body_entered(body: CharacterBody2D):
	if body is Player:
		player_entered_warp.emit(self)
		
		SceneManager.load_new_scene(TARGETED_SCENE, TRANSITION_TYPE)
		queue_free()
		
# return the player starting location based on the warp location and the entry direction
func get_player_entry_vector() -> Vector2:
	var vector: Vector2 = Vector2.UP
	match ENTRY_DIRECTION:
		1:
			vector = Vector2.RIGHT
		2:
			vector = Vector2.DOWN
		3:
			vector = Vector2.LEFT
	return (vector * PUSH_DISTANCE) + self.position

# invert entry direction now the direction that the player cross the warp
func get_move_direction() -> Vector2:
	var dir: Vector2 = Vector2.DOWN
	match ENTRY_DIRECTION:
		1:
			dir = Vector2.LEFT
		2:
			dir = Vector2.UP
		3:
			dir = Vector2.RIGHT
	return dir
