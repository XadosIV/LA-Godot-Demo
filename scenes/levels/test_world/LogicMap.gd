class_name LogicMap extends TileMap

var posPlayer : Vector2
var actors : Dictionary
var warps : Dictionary

func _ready() -> void:
	load_map()

func init() -> void:
	posPlayer = local_to_map(get_parent().get_node("Player").position)

func load_map() -> void: # pour maintenant
	for child in get_children():
		var pos = local_to_map(child.position)
		if isActor(pos):
			actors[child.name] = [local_to_map(child.position), child]
		elif isWarp(pos):
			warps[child.name] = [local_to_map(child.position), child]

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
		set_cell(0, mapPos)
		return true
	elif isActor(mapPos):
		posToActor(mapPos).interact()
		return true
	return false

func _process(delta) -> void:
	pass
