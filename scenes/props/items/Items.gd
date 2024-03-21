class_name Items extends Node2D
@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")
@export var id: String
# Action quand le joueur interagit avec un item
func interact():
	var test = ParagraphDialog.new()
	test.init(self.get_name(),"Vous récupérez l'objet \""+self.get_name()+"\".")
	sm.player.dialog_paragraph(test)
