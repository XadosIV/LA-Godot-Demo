class_name DialogBox extends CanvasLayer

@onready var content_box : Panel = $ContentBox
@onready var text_label : Label = $ContentBox/VBoxContainer/TextLabel
@onready var player : Player = get_parent().get_parent()

signal dialog_ended

func _ready() -> void:
	hide_box()
	text_label.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."


func _process(delta):
	if text_label.visible and Input.is_action_just_pressed("interact") and content_box.visible:
		text_label.lines_skipped = text_label.lines_skipped + text_label.max_lines_visible
		if(text_label.get_visible_line_count() <= 0):
			end_of_paragraph()
			end_of_dialogue()
			

func dialog_init(json: JSON):
	player.in_dialog = true
	player.disable()
	show_box()

func end_of_paragraph() -> void:	#gere le cas ou l'on arrive à la fin d'un paragraphe
	text_label.lines_skipped = 0

func end_of_dialogue() -> void:		#gere le cas ou l'on arrive à la fin d'un dialogue
	hide_box()
	player.enable()
	await Input.is_action_just_released("interact")
	player.in_dialog = false
	emit_signal("dialog_ended")
	
func hide_box() -> void:
	content_box.visible = false
func show_box() -> void:
	content_box.visible = true
