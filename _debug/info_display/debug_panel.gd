extends CanvasLayer

@onready var property_container = $Panel/VBoxContainer
@export var player : Player
@onready var current_scene_name = player.get_parent().get_name()
@onready var logic_map = player.get_parent().get_node("LogicMap")
@onready var gm: GameManager = get_tree().root.get_node("GameManager")

var property_fps
var property_position
var property_current_scene
var property_time
var property_show_logic_map

var show_logic_map: bool = false
var frames_per_second : String
var position_x: int
var position_y: int

func _ready() -> void:
	visible = false
	add_fps_debug_property()
	add_position_debug_property()
	add_current_scene_debug_property()
	add_show_logic_map_ebug_property()
	add_time_debug_property()

func _input(event) -> void:
	if visible and event.is_action_pressed("L_key"):
		show_logic_map = !show_logic_map
		if show_logic_map:
			logic_map.show_map()
		else:
			logic_map.hide_map()
	elif event.is_action_pressed("debug"):
		visible = !visible
		if show_logic_map and !visible:
			show_logic_map = !show_logic_map
			logic_map.hide_map()
			

func _process(delta) -> void:
	if visible:
		# Update FPS
		frames_per_second = str(Engine.get_frames_per_second())
		property_fps.text = "fps: " + frames_per_second

		# Update player position
		position_x = player.position.x
		position_y = player.position.y
		property_position.text = "X: " + str(position_x) + " ; Y: " + str(position_y)
		
		# Update logic map visibility
		property_show_logic_map.text = "show_logic_map: "+str(show_logic_map)
		
		#Update time
		property_time.text = "time: "+str(gm.time)+"\nhour: "+str(gm.hour)+":"+str(gm.minute)

func add_fps_debug_property() -> void:
	property_fps = Label.new()
	property_container.add_child(property_fps)
	property_fps.text = "fps: 0"

func add_position_debug_property() -> void:
	property_position = Label.new()
	property_container.add_child(property_position)
	property_position.text = "X: 0 ; Y: 0"

func add_current_scene_debug_property() -> void:
	property_current_scene = Label.new()
	property_container.add_child(property_current_scene)
	property_current_scene.text = "current_scene: "+current_scene_name
	
func add_show_logic_map_ebug_property() -> void:
	property_show_logic_map = Label.new()
	property_container.add_child(property_show_logic_map)
	property_show_logic_map.text = "show_logic_map: "+str(show_logic_map)

func add_time_debug_property() -> void:
	property_time = Label.new()
	property_container.add_child(property_time)
	property_time.text = "time: "+str(gm.time)+"\nhour: "+str(gm.hour)+":"+str(gm.minute)
