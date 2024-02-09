class_name LoadingScreen extends CanvasLayer
"""
Cette scène va permettre de cacher pour l'utilsateur la transition entre scène
"""


# Signal pour indiquer que la transition est en cours
signal transition_in_complete

@onready var progress_bar: ProgressBar = $Control/ProgressBar
@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var timer: Timer = $Timer

var starting_animation_name: String

func _ready() -> void:
	progress_bar.visible = false


# Lance l'animation pour cacher la transition
func start_transition(animation_name: String) -> void:
	if !anim_player.has_animation(animation_name):
		push_warning(animation_name+" animation does not exist")
		animation_name = "fade_to_black"
	starting_animation_name = animation_name
	anim_player.play(animation_name)
	
	timer.start()	# Lance le timer pour afficher une barre de chargement

# Joue l'animation quand la nouvelle scene est complètement charger
func finish_transition() -> void:
	if timer:
		timer.stop()
	
	var ending_animation_name: String = starting_animation_name.replace("to", "from")
	if !anim_player.has_animation(ending_animation_name):
		push_warning(ending_animation_name+" animation does not exist")
		ending_animation_name = "fade_from_black"
	anim_player.play(ending_animation_name)
	
	# atten jusqu'a ce que l'animation soit terminée
	await anim_player.animation_finished
	
	# Détruit le loading screen
	self.queue_free()
	
# Signal pour indiquer la moitier du chargement
func report_midpoint() -> void:
	transition_in_complete.emit()

# Ecoute le signal du timer pour afficher la barre de chargement
func _on_timer_timeout():
	progress_bar.visible = true

# Met à jour la progression de la barre de chargement
func update_bar(val:float) -> void:
	progress_bar.value = val
