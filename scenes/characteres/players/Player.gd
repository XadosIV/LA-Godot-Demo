class_name Player extends CharacterBody2D

var healthPoints : int = 1
var facing_direction : Vector2 = Vector2.ZERO
var movement_allowed : bool = true
var in_dialog : bool = false

var gridPos : Vector2 #correspond aux coordonnées du milieu de la case où est censé être le joueur
var isMoving : bool = false # est en train de se déplacer entre deux cases, mis à true par défaut pour le mouvement
							# d'entrée dans la zone
var currentMovement : Vector2 = Vector2(0, 0) # valeur par défaut hardcodé, à changer.
@onready var map : LogicMap = get_parent().get_node("LogicMap")
@onready var animatedSprite : AnimatedSprite2D = $AnimatedSprite2D
@onready var dialog_box : DialogBox = $Camera2D/DialogBox

@export var MAXHEALTH_POINT : int = 100
@export var SPEED_MULTIPLICATOR : float = 1.6 #attention, c'est bien un x1.X la vitesse
@export var SPEED_SPRINT : float = 1.6 #Ajouté au multiplicateur au moment de sprint

func _ready() -> void:
	healthPoints = MAXHEALTH_POINT

func move(direction : Vector2) -> void: #déplace le joueur dans la direction donnée
	if map.playerMove(direction): #renvoie true si le mouvement a été effectué
		gridPos = Vector2(map.posPlayer.x * 16 + 8, map.posPlayer.y * 16 + 8) #calcule le centre de la nouvelle tuile
	setCurrentMovement(direction)

func visualMove() -> void: #Gere le visuel du déplacement
	var multiplicator = SPEED_MULTIPLICATOR
	if Input.is_action_pressed("sprint"):
		multiplicator += SPEED_SPRINT
	var posAfter : Vector2 = position + currentMovement * multiplicator #calcule la position après déplacement
	
	#stocke la valeur avant déplacement, après déplacement, et la valeur souhaitée (milieu de la tuile)
	var tab = []
	var targetValue : int
	if currentMovement.x != 0: # on stocke que la valeur horizontal ou vertical selon le mouvement en cours
		targetValue = gridPos.x # milieu de la tuile
		tab.append_array([position.x, posAfter.x])
	else:
		targetValue = gridPos.y # milieu de la tuile
		tab.append_array([position.y, posAfter.y])
	tab.append(targetValue)
	tab.sort() # on trie le tableau pour trouver rapidement le médian

	if tab[1] == targetValue:
		# Si le médian est le milieu de la tuile, alors le joueur va dépasser la tuile durant le mouvement
		# On le place donc pile sur la tuile au lieu de le faire continuer d'avancer
		position = gridPos
	else:
		# Sinon on le fait avancer normalement
		position = posAfter

func setCurrentMovement(movement : Vector2) -> void: #Redéfinie le mouvement en cours, vecteur de taille 1 OU vecteur zero
	currentMovement = movement
	isMoving = movement != Vector2.ZERO
	apply_direction_on_sprite()

func playerMoveInput() -> bool: # Vérifie, et exécute, l'input de déplacement du joueur.
	var input: Vector2 = Vector2.ZERO
	# Get the input direction
	input.x = Input.get_axis("left", "right")
	input.y = Input.get_axis("up", "down")
	if input.x > 0: input.x = 1
	elif input.x < 0: input.x = -1
	if input.y > 0: input.y = 1
	elif input.y < 0: input.y = -1
	
	if (input.x or input.y):
		if input.x :
			move(Vector2(input.x, 0))
		elif input.y:
			move(Vector2(0, input.y))
		return true
	return false

func _process(delta) -> void:
	if isMoving and position != gridPos:
		visualMove()
	elif isMoving:
		# on check à la fin du mouvement, si il continue d'appuyer sur une touche
		# pour fluidifier le mouvement et ne pas l'arrêter
		if movement_allowed:
			if (not playerMoveInput()): 
				# Si c'est pas le cas, on l'arrête
				setCurrentMovement(Vector2.ZERO)
	else:
		# Si il y a aucun mouvement, on en attend un.
		if movement_allowed:
			playerMoveInput()
	
	if Input.is_action_just_released("interact") and movement_allowed and not in_dialog:
		await map.interact(facing_direction)

func enable():
	movement_allowed = true

func disable():
	movement_allowed = false

func apply_direction_on_sprite() -> void:
	if (currentMovement == Vector2.ZERO):
		if (animatedSprite.animation != "idle_left" and facing_direction.x < 0):
			animatedSprite.animation = "idle_left"
		if (animatedSprite.animation != "idle_right" and facing_direction.x > 0):
			animatedSprite.animation = "idle_right"
		if (animatedSprite.animation != "idle_up" and facing_direction.y < 0):
			animatedSprite.animation = "idle_up"
		if (animatedSprite.animation != "idle_down" and facing_direction.y > 0):
			animatedSprite.animation = "idle_down"
	else:
		if (animatedSprite.animation != "move_left" and currentMovement.x < 0):
			animatedSprite.animation = "move_left"
			facing_direction = Vector2.LEFT
		if (animatedSprite.animation != "move_right" and currentMovement.x > 0):
			animatedSprite.animation = "move_right"
			facing_direction = Vector2.RIGHT
		if (animatedSprite.animation != "move_up" and currentMovement.y < 0):
			animatedSprite.animation = "move_up"
			facing_direction = Vector2.UP
		if (animatedSprite.animation != "move_down" and currentMovement.y > 0):
			animatedSprite.animation = "move_down"
			facing_direction = Vector2.DOWN

func dialog(json: JSON):
	dialog_box.dialog_init(json)
