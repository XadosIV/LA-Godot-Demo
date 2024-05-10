class_name LogicMap extends TileMap

var posPlayer : Vector2
var actors : Dictionary
var warps : Dictionary
var items : Dictionary

var npc_scene = preload("res://scenes/props/actors/actor.tscn")

@onready var player : Player = get_parent().get_node("Player")

func _ready() -> void:
	hide_map()
	load_map()

func init() -> void:
	posPlayer = local_to_map(player.position)

func load_map() -> void: # pour maintenant
	actors = {}
	warps = {}
	items = {}
	for child in get_children():
		var pos = local_to_map(child.position)
		if isActor(pos):
			actors[child.name] = [local_to_map(child.position), child]
		elif isWarp(pos):
			warps[child.name] = [local_to_map(child.position), child]
		elif isItem(pos):
			items[child.name] = [local_to_map(child.position), child]

func posToWarp(pos : Vector2) -> Warp :
	for name in warps:
		if warps[name][0] == Vector2i(pos):
			return warps[name][1]
	return null

func posToActor(pos : Vector2) -> Actors :
	for name in actors:
		if actors[name][0] == Vector2i(pos):
			return actors[name][1]
	return null
	
func posToItem(pos : Vector2) -> Items :
	for name in items:
		if items[name][0] == Vector2i(pos):
			return items[name][1]
	return null


func isTile(mapPos: Vector2, tileId : Vector2i) -> bool:
	return get_cell_atlas_coords(0, mapPos) == tileId

func isWarp(mapPos : Vector2) -> bool:
	return isTile(mapPos, Vector2i(3,0))

func isActor(mapPos : Vector2) -> bool:
	return isTile(mapPos, Vector2i(2,0))

func isWall(mapPos : Vector2) -> bool:
	return isTile(mapPos, Vector2i(0,0))

func isItem(mapPos : Vector2) -> bool:
	return isTile(mapPos, Vector2i(1,0))

func playerMove(movement) -> bool: # renvoie si le mouvement a pu être fait ou non
	var mapPos = posPlayer + movement
	get_parent().get_node("Player").gridPos = Vector2(posPlayer.x * 16 + 8, posPlayer.y * 16 + 8)
	# coordonnée de la tuile devant le joueur sur le tileset
	
	if isTile(mapPos, Vector2i(-1,-1)): #(3,0) = warp, (-1,-1) = void
		posPlayer += movement
		return true
	elif isWarp(mapPos):
		posPlayer += movement
		get_parent().get_node("Player").disable()
		var warp = posToWarp(posPlayer)
		warp.warp()
		return true
	return false

func interact(movement) -> bool:
	var mapPos = posPlayer + movement
	if isItem(mapPos): #Item
		var targeted_item : Items = posToItem(mapPos)
		targeted_item.interact()
		player.inventory_add(targeted_item.id)
		targeted_item.queue_free()
		set_cell(0, mapPos)
		
		return true
	elif isActor(mapPos):
		posToActor(mapPos).interact()
		return true
	return false

func create_actor(id, mapPos, sprite, load=true):
	var npc = npc_scene.instantiate()
	add_child(npc)
	npc.id = id
	npc.position = mapPos * 16 + Vector2i(8,8)
	
	#place holder tant que l'import ne prend pas en charge les sprites
	var res_path = "res://scenes/characteres/players/resources/"
	if sprite != null:
		res_path += sprite
	else:
		"Roki.tres"
	
	npc.sprite = load(res_path)
	npc._ready()
	set_cell(0, mapPos, get_tileset().get_source_id(0), Vector2i(2,0), 0)
	if load:
		load_map()

func _process(delta) -> void:
	pass

func hide_map():
	set_layer_modulate(0, Color(1.0, 1.0, 1.0, 0.0))
func show_map():
	set_layer_modulate(0, Color(1.0, 1.0, 1.0, 1.0))
