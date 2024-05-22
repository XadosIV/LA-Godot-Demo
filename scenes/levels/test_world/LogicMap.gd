class_name LogicMap extends TileMap

var posPlayer : Vector2
var actors : Dictionary
var warps : Dictionary
var items : Dictionary

var npc_scene = preload("res://scenes/props/actors/actor.tscn")

@onready var am : ActionsManager = get_tree().root.get_node("ActionManager")
@onready var player : Player = get_parent().get_node("Player")

func _ready() -> void:
	hide_map()
	load_map()

func init() -> void:
	posPlayer = local_to_map(player.position)

func load_map() -> void:
	actors = {}
	warps = {}
	items = {}
	
	var manif = false
	var pos1
	var pos2
	
	for child in get_children():
		var pos = local_to_map(child.position)
		if isActor(pos):
			actors[child.name] = [local_to_map(child.position), child]
		elif isWarp(pos):
			warps[child.name] = [local_to_map(child.position), child]
		elif isItem(pos):
			items[child.name] = [local_to_map(child.position), child]
		else:
			if child.name == "Manifestant":
				manif = true
				pos1 = local_to_map(child.position)
			elif child.name == "Manifestant2":
				manif = true
				pos2 = local_to_map(child.position)

	if manif:
		var sprites = all_sprites()
		if pos1 and pos2:
			for x in range(pos1.x, pos2.x+1):
				for y in range(pos1.y, pos2.y+1):
					var false_data = {"id":-2, "x":x, "y":y, "sprite":sprites[randi()%sprites.size()], "name":"ratio"}
					create_actor(false_data)
					#create_actor(-2, Vector2i(x,y), sprites[randi()%sprites.size()], false)

func all_sprites():
	var files = []
	var dir = DirAccess.open("res://scenes/characteres/players/resources/")
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		else:
			files.append(file)
	return files

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

func idToNpcNode(id):
	for k in actors:
		var node = actors[k][1]
		if node.id == id:
			return node
	return null

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

func suppr_actor(id):
	for child in get_children():
		if child is Actors:
			if child.id == id:
				set_cell(0, actors[child.name][0])
				child.queue_free()

func create_actor(data, load=true):
	if am.npcs_disparus.has(int(data.id)):
		return
	var npc = npc_scene.instantiate()
	add_child(npc)
	npc.id = data.id
	var mapPos = Vector2i(int(data["x"]), int(data["y"]))
	npc.position = mapPos * 16 + Vector2i(8,8)
	
	if not "argName" in data:
		data.argName = data.name
	
	#place holder tant que l'import ne prend pas en charge les sprites
	var res_path = "res://scenes/characteres/players/resources/"
	if data.sprite != null:
		res_path += data.sprite
	else:
		"Roki.tres"
	
	npc.sprite = load(res_path)
	var charToCut = 0
	if data.argName.begins_with("."):
		var args = data.argName.split(" ")
		for arg in args:
			charToCut += len(arg)+1
			if (arg == "." or arg.begins_with("_")):
				pass
			elif (arg.begins_with("D:")):
				var orientation = arg.split(":")[1]
				match orientation:
					"E":
						npc.facing_direction = Vector2.RIGHT
					"S":
						npc.facing_direction = Vector2.DOWN
					"O":
						npc.facing_direction = Vector2.LEFT
					"N":
						npc.facing_direction = Vector2.UP
			else:
				charToCut -= len(arg)+1
				break
		if data.name == data.argName:
			data.name = data.name.erase(0, charToCut)
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
