class_name DialogBox extends CanvasLayer

@onready var paragraph_box : Panel = $ParagraphBox
@onready var paragraph_text_label : Label = $ParagraphBox/VBoxContainer/TextLabel
@onready var paragraph_name_label : Label = $ParagraphBox/VBoxContainer/NameLabel

@onready var mChoice_box : Panel = $ChoiceBox
@onready var mChoice_container: VBoxContainer = $ChoiceBox/VBoxContainer
@onready var mChoice_name_label : Label = $ChoiceBox/NameLabel

@onready var player : Player = get_parent().get_parent()

var dialogList : Array
var currentDialogue : int

var current_selected_choice : int = 0
var selected_choice : Array = []
var all_choice_node : Array

func _ready() -> void:
	hide_paragraph_box()
	hide_mChoice_box()

func _process(delta):
	if len(dialogList) > 0:
		match dialogList[currentDialogue]["type"]:
			"paragraph":
				dialog_paragraph_interact()
			"mcq":
				dialog_mcq_interact()

			
			
func dialog_init(tab: Array):
	if (tab[0].name == "Kaiou"):
		paragraph_text_label.label_settings.font_size = 60
	else:
		paragraph_text_label.label_settings.font_size = 14
	if(len(tab) >= 0):
		player.disable()
		dialogList = tab
		init_paragraph()

func dialog_paragraph_interact() -> void:
	if Input.is_action_just_released("interact") and paragraph_box.visible:
		if (not player.in_dialog):
			player.in_dialog = true
		else:
			paragraph_text_label.lines_skipped = paragraph_text_label.lines_skipped + paragraph_text_label.max_lines_visible
			if(currentDialogue >= len(dialogList)-1):
				end_of_dialogue()
			elif(paragraph_text_label.get_visible_line_count() <= 0):
				end_of_paragraph()
				

func dialog_mcq_interact() -> void:
	if mChoice_box.visible:
		if Input.is_action_just_released("interact"):
			if (not player.in_dialog):
				player.in_dialog = true
			else:
				if current_selected_choice == len(all_choice_node)-1:	# La ligne de validation à été sélectionner
					var res = await verif_mcq(selected_choice)
					# Test si fin de dialogue
					if(currentDialogue >= len(dialogList)-1):
						reset_of_mcq()
						end_of_dialogue()
					# Fin de qcm
					else:
						reset_of_mcq()
						currentDialogue += 1
						init_next()
					
				else:
					if current_selected_choice < len(all_choice_node)-1:
						var index_in_list = selected_choice.find(all_choice_node[current_selected_choice], 0)
						# Si déjà selectionner retirer de la liste et actualiser
						if index_in_list >= 0:
							selected_choice.remove_at(index_in_list)
							all_choice_node[current_selected_choice].not_selected()
						# Si pas dans la liste l'ajouter et actualiser
						else:
							selected_choice.append(all_choice_node[current_selected_choice])
							all_choice_node[current_selected_choice].selected()
		if Input.is_action_just_pressed("down"):
			all_choice_node[current_selected_choice].not_hover()
			current_selected_choice = (current_selected_choice + 1) % len(all_choice_node)
			all_choice_node[current_selected_choice].hover()
		if Input.is_action_just_pressed("up"):
			all_choice_node[current_selected_choice].not_hover()
			current_selected_choice -= 1
			if current_selected_choice < 0:
				current_selected_choice = len(all_choice_node)-1
			all_choice_node[current_selected_choice].hover()

func init_paragraph() -> void:
	paragraph_text_label.text = dialogList[currentDialogue]["text"]
	paragraph_name_label.text = dialogList[currentDialogue]["name"] +":"
	show_paragraph_box()

func end_of_paragraph() -> void:	#gere le cas ou l'on arrive à la fin d'un paragraphe
	hide_paragraph_box()
	paragraph_text_label.lines_skipped = 0
	currentDialogue += 1
	init_next()

func init_mcq() -> void:
	selected_choice = []
	current_selected_choice = 0
	init_paragraph()
	for choice in dialogList[currentDialogue]["questions"]:
		var temp = load("res://scenes/ui/dialog/choice_template.tscn").instantiate()
		mChoice_container.add_child(temp)
		temp.set_text(choice)
		all_choice_node.append(temp)
	var temp = load("res://scenes/ui/dialog/choice_template.tscn").instantiate()
	mChoice_container.add_child(temp)
	temp.set_text("Envoyer")
	all_choice_node.append(temp)
	all_choice_node[current_selected_choice].hover()
	show_mChoice_box()
	
func reset_of_mcq() -> void:
	hide_paragraph_box()
	hide_mChoice_box()
	for elt in all_choice_node:
		elt.queue_free()
	all_choice_node = []
	selected_choice = []
	current_selected_choice = 0
	
	
func init_next() -> void:
	match dialogList[currentDialogue]["type"]:
		"paragraph":
			init_paragraph()
		"mcq":
			init_mcq()
		_:
			pass
	
func verif_mcq(tab: Array) -> float:
	return 1.0

func end_of_dialogue() -> void:		#gere le cas ou l'on arrive à la fin d'un dialogue
	hide_paragraph_box()
	hide_mChoice_box()
	dialogList = []
	currentDialogue = 0
	paragraph_text_label.lines_skipped = 0
	player.enable()
	player.in_dialog = false
	
func hide_paragraph_box() -> void:
	paragraph_box.visible = false
func show_paragraph_box() -> void:
	paragraph_box.visible = true

func hide_mChoice_box() -> void:
	mChoice_box.visible = false
func show_mChoice_box() -> void:
	mChoice_box.visible = true
