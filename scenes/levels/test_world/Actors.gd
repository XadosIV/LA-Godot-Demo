class_name Actors extends Node2D

@export_enum("je_mur", "qcm", "hummm", "droite", "r_barree", "jcm") var DIALOG_CHOICE : String

var je_mur : Array = [{"type":"paragraph","name":"Mur","avatar":"","text":"Je Mur"}]
var hummm : Array = [{"type":"paragraph","name":"Panneau","avatar":"","text":"Hummmm ......"}]
var droite : Array = [{"type":"paragraph","name":"Panneau","avatar":"","text":"<- Vers Le Bourget Du Lac"}]
var jcm : Array = [
	{
		"type":"paragraph",
		"name":"JCM",
		"avatar":"",
		"text":"Ah, il y a plus que ce que l'œil peut voir, mon ami. Ces couleurs cachent un secret que seules mes fleurs connaissent. Chaque pétale, chaque tige, a un rôle à jouer. Elles font partie de quelque chose de plus grand."
	},
	{
		"type":"paragraph",
		"name":"JCM",
		"avatar":"",
		"text":"Mais j'ai une question pour toi."
	},
	{
		"type":"mcq",
		"name":"JCM",
		"avatar":"",
		"text":"Quelles sont les couleurs de mes fleurs",
		"questions":["1- Bleue","2- Rouge","3- Blanche","4- Jaune"]
	}
]
var r_barree : Array = [{"type":"paragraph","name":"Panneau","avatar":"","text":"Route Barrée"}]
var qcm : Array = [
	{
		"type":"paragraph",
		"name":"JCM",
		"avatar":"",
		"text":"Non"
	},
	{
		"type":"mcq",
		"name":"JCM",
		"avatar":"",
		"text":"Ceci est une question?",
		"questions":["1- La réponse 1","2- La réponse 2","3- La réponse 3","4- La réponse 4"]
	}
]
@export var actorName : String = "..."

@onready var sm: SceneManager = get_tree().root.get_node("SceneManager")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func interact():
	match DIALOG_CHOICE:
		"je_mur":
			sm.player.dialog(je_mur)
		"hummm":
			sm.player.dialog(hummm)
		"droite":
			sm.player.dialog(droite)
		"jcm":
			sm.player.dialog(jcm)
		"r_barree":
			sm.player.dialog(r_barree)
		"qcm":
			sm.player.dialog(qcm)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
