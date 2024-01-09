extends CharacterBody2D

var position_x : int
var position_y : int
var healthPoints : int = 1

@export var MAXHEALTHPOINT : int = 100
@export var SPEED : int = 300.0
@export var ACCELERATION : int = 100
@export var FRICTION : int = 300

@onready var animatedSprite = $AnimatedSprite2D

func _ready():
	healthPoints = MAXHEALTHPOINT

func _physics_process(delta):
	var input: Vector2 = Vector2.ZERO
	
	# Get the input direction
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("up", "down")
	
	
	if input.x or input.y:
		apply_acceleration(input)
		apply_direction_on_sprite(input)
	else:
		apply_friction()
		apply_direction_on_sprite(input)

	move_and_slide()

func apply_friction():
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	velocity.y = move_toward(velocity.y, 0, FRICTION)
	
func apply_acceleration(input: Vector2):
	input = input.normalized()
	velocity.x = move_toward(velocity.x, SPEED * input.x, ACCELERATION)
	velocity.y = move_toward(velocity.y, SPEED * input.y, ACCELERATION)
	
func apply_direction_on_sprite(input: Vector2):
	if (animatedSprite.animation != "move_left" and input.x < 0):
		animatedSprite.animation = "move_left"
	if (animatedSprite.animation != "move_right" and input.x > 0):
		animatedSprite.animation = "move_right"
	if (animatedSprite.animation != "move_up" and input.y < 0):
		animatedSprite.animation = "move_up"
	if (animatedSprite.animation != "move_down" and input.y > 0):
		animatedSprite.animation = "move_down"


