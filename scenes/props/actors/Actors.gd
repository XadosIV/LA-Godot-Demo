class_name Actors extends Node2D
@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D

@export var DIALOG_NAME : String

var actorName : String = "Je n'ai pas de nom!"
@export var showed : bool = true
@export var sprite : SpriteFrames
@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")
@export_enum("north", "east", "south", "west") var facing_direction

func _ready():
	
	# Applique le sprite à un acteur et le met dans la bonne direction
	if sprite:
		animatedSprite.sprite_frames = sprite
		animatedSprite.animation = "idle_up"
		match facing_direction:
			1:
				animatedSprite.animation = "idle_left"
			2:
				animatedSprite.animation = "idle_down"
			3:
				animatedSprite.animation = "idle_right"
	animatedSprite.visible = showed

# Action quand le joueur interagit avec un acteur
func interact():
	var dm = get_tree().root.get_node("/root/DialogManager")
	
	if dm.dialog_exists(DIALOG_NAME):
		sm.player.dialog(dm.get_dialog(DIALOG_NAME))
