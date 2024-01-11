class_name Player extends CharacterBody2D

var position_x : int
var position_y : int
var healthPoints : int = 1
var facing_direction : Vector2 = Vector2.ZERO

@export var MAXHEALTH_POINT : int = 100
@export var SPEED : int = 300
@export var ACCELERATION : int = 100
@export var FRICTION : int = 300

@onready var animatedSprite = $AnimatedSprite2D

func _ready() -> void:
	healthPoints = MAXHEALTH_POINT
	facing_direction.y = 1

func _physics_process(delta) -> void:
	var input: Vector2 = Vector2.ZERO
	
	# Get the input direction
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("up", "down")
	
	
	if input.x or input.y:
		facing_direction = input
		apply_acceleration(input)
		apply_direction_on_sprite(input)
	else:
		apply_friction()
		apply_direction_on_sprite(input)

	move_and_slide()

func apply_friction() -> void:
	velocity.x = move_toward(velocity.x, 0, FRICTION)
	velocity.y = move_toward(velocity.y, 0, FRICTION)
	
func apply_acceleration(input: Vector2) -> void:
	input = input.normalized()
	velocity.x = move_toward(velocity.x, SPEED * input.x, ACCELERATION)
	velocity.y = move_toward(velocity.y, SPEED * input.y, ACCELERATION)
	
func apply_direction_on_sprite(input: Vector2) -> void:
	if (input == Vector2.ZERO):
		if (animatedSprite.animation != "idle_left" and facing_direction.x < 0):
			animatedSprite.animation = "idle_left"
		if (animatedSprite.animation != "idle_right" and facing_direction.x > 0):
			animatedSprite.animation = "idle_right"
		if (animatedSprite.animation != "idle_up" and facing_direction.y < 0):
			animatedSprite.animation = "idle_up"
		if (animatedSprite.animation != "idle_down" and facing_direction.y > 0):
			animatedSprite.animation = "idle_down"
	else:
		if (animatedSprite.animation != "move_left" and input.x < 0):
			animatedSprite.animation = "move_left"
		if (animatedSprite.animation != "move_right" and input.x > 0):
			animatedSprite.animation = "move_right"
		if (animatedSprite.animation != "move_up" and input.y < 0):
			animatedSprite.animation = "move_up"
		if (animatedSprite.animation != "move_down" and input.y > 0):
			animatedSprite.animation = "move_down"

