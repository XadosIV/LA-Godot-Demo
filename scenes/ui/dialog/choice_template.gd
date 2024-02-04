class_name Choice extends Control

@onready var selector_icon : Panel = $SelectorIcon
@onready var text_label : Label = $Label

func _ready():
	not_hover()

func hover():
	selector_icon.visible = true

func not_hover():
	selector_icon.visible = false

func selected():
	text_label.modulate = Color(1, 0, 0, 1)

func not_selected():
	text_label.modulate = Color(1, 1, 1, 1)
	
func set_text(st: String = ""):
	text_label.text = st

func get_text():
	return text_label.text
