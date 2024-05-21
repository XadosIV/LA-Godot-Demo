class_name DialogBox extends CanvasLayer

# Récupération des Nodes piur la boite de dialogue (paragraphe)
@onready var paragraph_box : Panel = $ParagraphBox
@onready var paragraph_text_label : Label = $ParagraphBox/VBoxContainer/TextLabel
@onready var paragraph_name_label : Label = $ParagraphBox/VBoxContainer/NameLabel

# Récupération des Nodes piur la boite de dialogue à choix multiple
@onready var mChoice_box : Panel = $ChoiceBox
@onready var mChoice_scroll_container: ScrollContainer = $ChoiceBox/ScrollContainer
@onready var mChoice_container: VBoxContainer = $ChoiceBox/ScrollContainer/VBoxContainer
@onready var mChoice_name_label : Label = $ChoiceBox/NameLabel

@export var player : Player

# Variables pour la boite de dialogue à choix multiple
var current_selected_choice : int = 0
var selected_choice : Array = []
var all_choice_node : Array

var dialog_paragraph : ParagraphDialog = null
var dialog_mcq : McqDialog = null
var type = -1 # 0 = paragraph, 1 = mcq, 2 = choice

func _ready() -> void:
	hide_paragraph_box()
	hide_mChoice_box()

# Choisi quel interaction utiliser selon la nature du dialogue actif
func _process(delta):
	match type:
		0:
			dialog_paragraph_interact()
		1:
			dialog_mcq_interact()
		2:
			dialog_choice_interact()

func kaiou_diff(dialog):
	if dialog.text.begins_with("*"):
		dialog.npc_name = "Information"
	
	if dialog.npc_name == "Kaiou":
		paragraph_text_label.label_settings.font_size = randi() % 20 + 14
		paragraph_name_label.label_settings.font_size = randi() % 40 + 18
	else:
		paragraph_text_label.label_settings.font_size = 14
		paragraph_name_label.label_settings.font_size = 18

func init_paragraph(dialog: ParagraphDialog) -> void:
	type = 0
	kaiou_diff(dialog)
	dialog_paragraph = dialog
	player.disable()
	paragraph_text_label.text = dialog_paragraph.text
	paragraph_name_label.text = dialog_paragraph.npc_name
	show_paragraph_box()

# Gere le fonctionnement de la boite de dialogue (paragraphe) en fonction des entrée de l'utilisateur
func dialog_paragraph_interact() -> void:
	if (not player.in_dialog):
		player.in_dialog = true
	elif Input.is_action_just_pressed("interact") and paragraph_box.visible:
		paragraph_text_label.lines_skipped = paragraph_text_label.lines_skipped + paragraph_text_label.max_lines_visible
		if(paragraph_text_label.get_visible_line_count() <= 0):	# Action si l'on est à la fin d'un paragraph
			end_of_paragraph()
				
func end_of_paragraph() -> void:	#gere le cas ou l'on arrive à la fin d'un paragraphe
	type = -1
	hide_paragraph_box()
	paragraph_text_label.lines_skipped = 0
	dialog_paragraph = null
	player.enable()
	player.in_dialog = false
	# Envoi signal de la prochain action au manager
	var am : ActionManager = get_tree().root.get_node("ActionManager")
	am.executeNextAction()


"""

	Questions à choix multiples

"""
func init_mcq(dialogue : McqDialog) -> void:
	type = 1
	kaiou_diff(dialogue)
	dialog_mcq = dialogue
	player.disable()
	selected_choice = []
	current_selected_choice = 0
	paragraph_text_label.text = dialog_mcq.text
	paragraph_name_label.text = dialog_mcq.npc_name
	for i in range(dialog_mcq.questions.size()):
		var temp = load("res://scenes/ui/dialog/choice_template.tscn").instantiate()
		mChoice_container.add_child(temp)
		temp.set_text(dialog_mcq.questions[i])
		temp.set_id(i)
		all_choice_node.append(temp)
	var temp = load("res://scenes/ui/dialog/choice_template.tscn").instantiate()
	mChoice_container.add_child(temp)
	temp.set_text("Envoyer")
	all_choice_node.append(temp)
	all_choice_node[current_selected_choice].hover()
	mChoice_scroll_container.ensure_control_visible(all_choice_node[current_selected_choice])
	show_mChoice_box()
	show_paragraph_box()

func init_choice(dialogue : McqDialog) -> void:
	type = 2
	kaiou_diff(dialogue)
	dialog_mcq = dialogue
	player.disable()
	selected_choice = []
	current_selected_choice = 0
	paragraph_text_label.text = dialog_mcq.text
	paragraph_name_label.text = dialog_mcq.npc_name
	for i in range(dialog_mcq.questions.size()):
		var temp = load("res://scenes/ui/dialog/choice_template.tscn").instantiate()
		mChoice_container.add_child(temp)
		temp.set_text(dialog_mcq.questions[i])
		temp.set_id(i)
		all_choice_node.append(temp)
	all_choice_node[current_selected_choice].hover()
	mChoice_scroll_container.ensure_control_visible(all_choice_node[current_selected_choice])
	show_mChoice_box()
	show_paragraph_box()
	
func dialog_choice_interact() -> void:
	if mChoice_box.visible:
		if (not player.in_dialog):
			player.in_dialog = true
		elif Input.is_action_just_pressed("interact"):
			var index_in_list = selected_choice.find(all_choice_node[current_selected_choice], 0)
			# Si déjà selectionné retirer de la liste et actualiser
			if index_in_list >= 0:
				selected_choice.remove_at(index_in_list)
				all_choice_node[current_selected_choice].not_selected()
			# Si pas dans la liste l'ajouter et actualiser
			else:
				selected_choice.append(all_choice_node[current_selected_choice])
				all_choice_node[current_selected_choice].selected()
			end_of_choice()

		if Input.is_action_just_pressed("down"): 	# Déplace le sélecteur de +1 dans la liste (vers le bas)
			all_choice_node[current_selected_choice].not_hover()
			current_selected_choice = posmod(current_selected_choice + 1, len(all_choice_node))
			all_choice_node[current_selected_choice].hover()
			mChoice_scroll_container.ensure_control_visible(all_choice_node[current_selected_choice])
			
		if Input.is_action_just_pressed("up"): 	# Déplace le sélecteur de -1 dans la liste (vers le haut)
			all_choice_node[current_selected_choice].not_hover()
			current_selected_choice = posmod(current_selected_choice - 1, len(all_choice_node))
			all_choice_node[current_selected_choice].hover()
			mChoice_scroll_container.ensure_control_visible(all_choice_node[current_selected_choice])



func dialog_mcq_interact() -> void:
	if mChoice_box.visible:
		if (not player.in_dialog):
			player.in_dialog = true
		elif Input.is_action_just_pressed("interact"):
			if posmod(current_selected_choice, len(all_choice_node)) == len(all_choice_node)-1:	# La ligne de validation à été sélectionner
				end_of_mcq()
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

		if Input.is_action_just_pressed("down"): 	# Déplace le sélecteur de +1 dans la liste (vers le bas)
			all_choice_node[current_selected_choice].not_hover()
			current_selected_choice = posmod(current_selected_choice + 1, len(all_choice_node))
			all_choice_node[current_selected_choice].hover()
			mChoice_scroll_container.ensure_control_visible(all_choice_node[current_selected_choice])
			
		if Input.is_action_just_pressed("up"): 	# Déplace le sélecteur de -1 dans la liste (vers le haut)
			all_choice_node[current_selected_choice].not_hover()
			current_selected_choice = posmod(current_selected_choice - 1, len(all_choice_node))
			all_choice_node[current_selected_choice].hover()
			mChoice_scroll_container.ensure_control_visible(all_choice_node[current_selected_choice])

# Vide la boite de dialogue à choix multiple	
func reset_of_mcq() -> void:
	hide_paragraph_box()
	hide_mChoice_box()
	for elt in all_choice_node:
		elt.queue_free()
	all_choice_node = []
	selected_choice = []
	current_selected_choice = 0

func convert_choices_to_text ():
	var res = []
	for elt in selected_choice:
		res += [elt.get_id()]
	return res
	
func end_of_mcq ():
	type = -1
	hide_paragraph_box()
	hide_mChoice_box()
	paragraph_text_label.lines_skipped = 0
	dialog_mcq = null
	var answers = convert_choices_to_text()
	reset_of_mcq()
	player.enable()
	player.in_dialog = false
	
	#l'appel de ma fonction magique
	var am : ActionManager = get_tree().root.get_node("ActionManager")
	am.exo_result(answers)

func end_of_choice ():
	type = -1
	hide_paragraph_box()
	hide_mChoice_box()
	paragraph_text_label.lines_skipped = 0
	dialog_mcq = null
	var answers = convert_choices_to_text()
	reset_of_mcq()
	player.enable()
	player.in_dialog = false
	
	#l'appel de ma fonction magique
	var am : ActionManager = get_tree().root.get_node("ActionManager")
	am.choice_result(answers)
	
func hide_paragraph_box() -> void:
	paragraph_box.visible = false
func show_paragraph_box() -> void:
	paragraph_box.visible = true

func hide_mChoice_box() -> void:
	mChoice_box.visible = false
func show_mChoice_box() -> void:
	mChoice_box.visible = true
