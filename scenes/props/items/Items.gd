class_name Items extends Node2D
@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")
@onready var am: ActionsManager = get_tree().root.get_node("ActionManager")
@export var id: String

"""
Représente un item au sol.
"""


# Action quand le joueur interagi avec un item
func interact():
	var dialog = ParagraphDialog.new()
	var itemName = am.getItemById(id).name
	dialog.init("Information","Vous récupérez l'objet \""+itemName+"\".")
	sm.player.dialog_paragraph(dialog)
