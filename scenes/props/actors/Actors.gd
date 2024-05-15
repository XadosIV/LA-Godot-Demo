class_name Actors extends Node2D
@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D
@export var id : int # id du pnj correspondant
@export var showed : bool = true
@export var sprite : SpriteFrames
@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")
@onready var actionsManager: ActionManager = get_node("/root/ActionManager")
@export_enum("north", "east", "south", "west") var facing_direction_import = 0

var facing_direction : Vector2

func _ready():
	# Applique le sprite à un acteur et le met dans la bonne direction
	if sprite:
		animatedSprite.sprite_frames = sprite
		match facing_direction_import:
			1:
				facing_direction = Vector2.RIGHT
			2:
				facing_direction = Vector2.DOWN
			3:
				facing_direction = Vector2.LEFT
			_:
				facing_direction = Vector2.UP
		apply_direction_to_sprite(facing_direction)
		animatedSprite.play()
	animatedSprite.visible = showed



# Action quand le joueur interagit avec un acteur
# (charge la page du pnj correspondant)
func interact():
	facing_direction = Vector2.ZERO - sm.player.facing_direction
	apply_direction_to_sprite(facing_direction)
	actionsManager.interact(id)

func apply_direction_to_sprite(direction : Vector2):
	animatedSprite.sprite_frames = sprite
	match direction:
		Vector2.RIGHT:
			animatedSprite.animation = "idle_right"
		Vector2.LEFT:
			animatedSprite.animation = "idle_left"
		Vector2.UP:
			animatedSprite.animation = "idle_up"
		_:
			animatedSprite.animation = "idle_down"
