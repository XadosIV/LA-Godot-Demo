class_name Actors extends Node2D
@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D

var actorName : String = "Je n'ai pas de nom!"

@export var id : int

@export var showed : bool = true
@export var sprite : SpriteFrames
@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")
@onready var am: ActionManager = get_node("/root/ActionManager")
@export_enum("north", "east", "south", "west") var facing_direction_import = 0

var facing_direction : Vector2

var first_direction : Vector2

var isMoving = false
var distance_a_parcourir
var interacted = false

func _ready():
	if id == 0:
		return
	else:
		initialiser()

func initialiser():
	# Applique le sprite à un acteur et le met dans la bonne direction
	if sprite:
		animatedSprite.sprite_frames = sprite
	if not facing_direction:
		match facing_direction_import:
			1:
				facing_direction = Vector2.RIGHT
			2:
				facing_direction = Vector2.DOWN
			3:
				facing_direction = Vector2.LEFT
			_:
				facing_direction = Vector2.UP
	animatedSprite.play()
	animatedSprite.visible = showed
	first_direction = facing_direction
	
	#Connecte à l'actionManager
	am.actions_ended.connect(onEndInteraction)

func onEndInteraction():
	if interacted:
		interacted = false
		facing_direction = first_direction

func _process(delta):
	if isMoving:
		visualMove()
	apply_direction_to_sprite(facing_direction)

func look(directionString):
	match directionString:
		"N":
			facing_direction = Vector2.UP
		"S":
			facing_direction = Vector2.DOWN
		"E":
			facing_direction = Vector2.RIGHT
		"O":
			facing_direction = Vector2.LEFT
	

# Action quand le joueur interagit avec un acteur
func interact():
	am.loadPage(id)
	if not(am.actions_fifo[0].type == "dire" and am.actions_fifo[0].text.begins_with("LOOK")):
		facing_direction = Vector2.ZERO - sm.player.facing_direction
		apply_direction_to_sprite(facing_direction)
	interacted = true
	
	am.executeNextAction()

var fifo_actions = []

func do(args):
	fifo_actions = args
	next()
	
func next():
	if len(fifo_actions) == 0:
		am.executeNextAction()
	else:
		var action = fifo_actions.pop_front()
		print(action)
		if action.begins_with("."):
			next()
		elif action.begins_with("L"):
			look(action.split("")[1])
			next()
		elif action.begins_with("M"):
			move(Array(action.split("")))

func move(action):
	var direction = action[1]
	var cases = action[2]

	look(direction)

	distance_a_parcourir = int(cases) * 16
	isMoving = true

	#setCurrentMovement(direction)
func visualMove() -> void: #Gere le visuel du déplacement
	position = position + facing_direction
	distance_a_parcourir -= abs(facing_direction.x + facing_direction.y)
	if distance_a_parcourir == 0:
		isMoving = false
		next()

func apply_direction_to_sprite(direction : Vector2):
	if isMoving:
		match direction:
			Vector2.RIGHT:
				animatedSprite.animation = "move_right"
			Vector2.LEFT:
				animatedSprite.animation = "move_left"
			Vector2.UP:
				animatedSprite.animation = "move_up"
			_:
				animatedSprite.animation = "move_down"
	else:
		match direction:
			Vector2.RIGHT:
				animatedSprite.animation = "idle_right"
			Vector2.LEFT:
				animatedSprite.animation = "idle_left"
			Vector2.UP:
				animatedSprite.animation = "idle_up"
			_:
				animatedSprite.animation = "idle_down"
