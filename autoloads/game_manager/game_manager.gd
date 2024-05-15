extends Node

@onready var am = get_tree().root.get_node("ActionManager")
var inventory : Array = []

# Gestion du temps en jeu (cycle jour nuit)
const MINUTES_PER_DAY = 1440
const MINUTES_PER_HOURS = 60
const INGAME_TO_REAL_MINUTE_DURATION = (2 * PI) / MINUTES_PER_DAY

@export var ingameSpeed = 1.0
@export var initialHour = 11

var time:float = 0.0
var day = 0
var hour = 0
var minute = 0

func _ready():
	time = INGAME_TO_REAL_MINUTE_DURATION *initialHour *MINUTES_PER_HOURS

# Mise à jour du temps en jeu & mise à jour des variables correspondantes
func _process(delta):
	time += delta * INGAME_TO_REAL_MINUTE_DURATION * ingameSpeed
	_recalculate_time()
	
func _recalculate_time():
	var total_minutes = int(time / INGAME_TO_REAL_MINUTE_DURATION)
	day = int(total_minutes / MINUTES_PER_DAY)
	
	var current_day_minutes = total_minutes % MINUTES_PER_DAY
	
	hour = int(current_day_minutes / MINUTES_PER_HOURS)
	minute = int(current_day_minutes % MINUTES_PER_HOURS)

# Appelé par le joueur (Player.gd) lors de l'appui sur la touche d'inventaire (I par défaut)
func showInventory():
	print("-- Inventaire "+str(len(inventory)) + " --")
	for id in inventory:
		print("x " + am.getItemById(id).name)
