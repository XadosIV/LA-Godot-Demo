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

@onready var player : Player = get_parent().get_parent()

# Variables pour la boite de dialogue (paragraphe)
var dialogList : Array
var currentDialogue : int

# Variables pour la boite de dialogue à choix multiple
var current_selected_choice : int = 0
var selected_choice : Array = []
var all_choice_node : Array

func _ready() -> void:
	hide_paragraph_box()
	hide_mChoice_box()

# Choisi quel interaction utiliser selon la nature du dialogue actif
func _process(delta):
	if len(dialogList) > 0:
		match dialogList[currentDialogue]["type"]:
			"paragraph":
				dialog_paragraph_interact()
			"mcq":
				dialog_mcq_interact()
			
# Initialise les boites de dialogue
func dialog_init(tab: Array):
	for i in tab:
		if (not "name" in i):
			i.name = ""
	if (tab[0].name == "Kaiou"):
		paragraph_text_label.label_settings.font_size = 60
	else:
		paragraph_text_label.label_settings.font_size = 14
	# Si on à des dialogues on désactive le joueur et ont initialise le paragraphe
	if(len(tab) >= 0):
		player.disable()
		dialogList = tab
		init_next()
		#init_paragraph()



func init_paragraph() -> void:
	paragraph_text_label.text = dialogList[currentDialogue]["text"]
	paragraph_name_label.text = dialogList[currentDialogue]["name"] +":"
	show_paragraph_box()

# Gere le fonctionnement de la boite de dialogue (paragraphe) en fonction des entrée de l'utilisateur
func dialog_paragraph_interact() -> void:
	if Input.is_action_just_released("interact") and paragraph_box.visible:
		if (not player.in_dialog):
			player.in_dialog = true
		else:
			paragraph_text_label.lines_skipped = paragraph_text_label.lines_skipped + paragraph_text_label.max_lines_visible
			if(currentDialogue >= len(dialogList)-1):	# Action si l'on est à la fin du dialogue
				end_of_dialogue()
			elif(paragraph_text_label.get_visible_line_count() <= 0):	# Action si l'on est à la fin d'un paragraph
				end_of_paragraph()
				
func end_of_paragraph() -> void:	#gere le cas ou l'on arrive à la fin d'un paragraphe
	hide_paragraph_box()
	paragraph_text_label.lines_skipped = 0
	currentDialogue += 1
	init_next()



"""

	Questions à choix multiples

"""

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
	mChoice_scroll_container.ensure_control_visible(all_choice_node[current_selected_choice])
	show_mChoice_box()

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

		if Input.is_action_just_pressed("down"): 	# Déplace le sélecteur de +1 dans la liste (vers le bas)
			all_choice_node[current_selected_choice].not_hover()
			current_selected_choice = (current_selected_choice + 1) % len(all_choice_node)
			all_choice_node[current_selected_choice].hover()
			mChoice_scroll_container.ensure_control_visible(all_choice_node[current_selected_choice])
			
		if Input.is_action_just_pressed("up"): 	# Déplace le sélecteur de -1 dans la liste (vers le haut)
			all_choice_node[current_selected_choice].not_hover()
			current_selected_choice -= 1
			if current_selected_choice < 0:
				current_selected_choice = len(all_choice_node)-1
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
	
# TODO Fonction qui renvoie le pourcentage de réussite à une question
func verif_mcq(tab: Array) -> float:
	return 1.0



# Init le prochain élement de dialogue
func init_next() -> void:
	match dialogList[currentDialogue]["type"]:
		"paragraph":
			init_paragraph()
		"mcq":
			init_mcq()
		_:
			pass

func end_of_dialogue() -> void:		#gere le cas ou l'on arrive à la fin d'un dialogue
	hide_paragraph_box()
	hide_mChoice_box()
	dialogList = []
	currentDialogue = 0
	paragraph_text_label.lines_skipped = 0
	player.enable()
	player.in_dialog = false
	var am : ActionManager = get_tree().root.get_node("ActionManager")
	am.executeNextAction()
	
func hide_paragraph_box() -> void:
	paragraph_box.visible = false
func show_paragraph_box() -> void:
	paragraph_box.visible = true

func hide_mChoice_box() -> void:
	mChoice_box.visible = false
func show_mChoice_box() -> void:
	mChoice_box.visible = true
