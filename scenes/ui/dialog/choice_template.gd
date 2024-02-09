class_name Choice extends Control

@onready var selector_icon : TextureRect = $SelectorIcon
@onready var text_label : Label = $Label
"""
Cette scène est un template pour les boîte de dialogue à option elle remprésente une ligne de la sélection
"""


func _ready():
	not_hover()

# Affiche l'icon du selecteur
func hover():
	selector_icon.visible = true

# Cache l'icon du selecteur
func not_hover():
	selector_icon.visible = false

# Change la couleur du texte pour indiquer que l'utilisateur l'a sélectionné
func selected():
	text_label.modulate = Color(1, 0, 0, 1)

# Change la couleur du texte pour indiquer que l'utilisateur l'a desélectionné
func not_selected():
	text_label.modulate = Color(1, 1, 1, 1)

func set_text(st: String = ""):
	text_label.text = st

func get_text():
	return text_label.text
