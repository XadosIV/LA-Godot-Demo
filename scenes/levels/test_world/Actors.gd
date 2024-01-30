class_name Actors extends Node2D

@export var test : JSON
@export var actorName : String = "..."

@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact():
	sm.player.dialog(test)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
