extends PointLight2D

@onready var gm: GameManager = get_tree().root.get_node("GameManager")

#TODO Opti les lumières
func _process(delta):
	if(gm.hour>9 and gm.hour < 21):
		self.energy = 0
	else:
		self.energy = 0.6
	
