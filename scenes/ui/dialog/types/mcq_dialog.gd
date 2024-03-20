class_name McqDialog extends Node

var npc_name : String = "John Doe"
var text : String = "..."
var questions : Array = []

func init(npc_name : String, text : String, questions : Array):
	self.npc_name = npc_name
	self.text = text
	self.questions = questions
