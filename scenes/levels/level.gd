class_name Level extends Node

@export var player: Player
@export var warps: Array[Warp]
var data: LevelDataHandoff

func _ready() -> void:
	player.disable()
	#player.visible = false
	# if we don't us the SceneManager
	if data == null:
		enter_level()

func enter_level() -> void:
	if data != null:
		init_player_location()
	player.enable()
	#player.visible = true
	_connect_to_warps()

# teleport the player to the correct warp
func init_player_location() -> void:
	#var facing_direction : Vector2 = Vector2.ZERO
	if data != null:
		for warp in warps:
			if warp.name == data.entry_warp_name:
				#facing_direction = warp.get_move_direction()
				player.position = warp.get_player_entry_vector()
		# TODO Fix this shit
		#player.apply_direction_on_sprite(facing_direction)

# disable warps and player
# and create a handoff to pass data to the new scene
func _on_player_entered_warp(warp:Warp) -> void:
	_disconnect_from_warps()
	#player.disable()
	player.queue_free()
	data = LevelDataHandoff.new()
	data.entry_warp_name = warp.ENTRY_WARP_NAME
	data.move_dir = warp.get_move_direction()
	set_process(false)

func _connect_to_warps() -> void:
	for warp in warps:
		if not warp.player_entered_warp.is_connected(_on_player_entered_warp):
			warp.player_entered_warp.connect(_on_player_entered_warp)

func _disconnect_from_warps() -> void:
	for warp in warps:
		if not warp.player_entered_warp.is_connected(_on_player_entered_warp):
			warp.player_entered_warp.disconnect(_on_player_entered_warp)
