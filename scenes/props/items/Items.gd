class_name Items extends Node2D
@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")
func interact():
	sm.player.dialog([{"type":"paragraph","name":self.get_name(),"avatar":"","text":"Vous récupérez l'objet \""+self.get_name()+"\"."}])
	print(self.get_name())
