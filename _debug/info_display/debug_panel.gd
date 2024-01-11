extends CanvasLayer

@onready var property_container = $Panel/VBoxContainer
@onready var player = get_parent().get_parent()
@onready var current_scene_name = player.get_parent().get_name()

var property_fps
var property_position
var property_current_scene

var frames_per_second : String
var position_x: int
var position_y: int

func _ready() -> void:
	visible = false
	add_fps_debug_property()
	add_position_debug_property()
	add_current_scene_debug_property()

func _input(event) -> void:
	if event.is_action_pressed("debug"):
		visible = !visible

func _process(delta) -> void:
	if visible:
		# Update FPS
		frames_per_second = str(Engine.get_frames_per_second())
		property_fps.text = "fps: " + frames_per_second

		# Update player position
		position_x = player.position.x
		position_y = player.position.y
		property_position.text = "X: " + str(position_x) + " ; Y: " + str(position_y)

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
