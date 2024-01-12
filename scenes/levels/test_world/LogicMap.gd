class_name LogicMap extends TileMap

var posPlayer : Vector2

var actors : Dictionary #<Vector2, Node2D>


func _ready() -> void:
	load_map()
	pass

func load_map() -> void: #pour plus tard
	for child in get_children():
		actors[str(local_to_map(child.position))] = child
	print(actors)

func init() -> void: #Stocke la position du player par rapport à la tilemap
	posPlayer = local_to_map(get_parent().get_node("Player").position)

func playerMove(movement) -> bool: # renvoie si le mouvement a pu être fait ou non
	var atlasCoord = get_cell_atlas_coords(0, posPlayer + movement)
	# coordonnée de la tuile devant le joueur sur le tileset
	
	if atlasCoord == Vector2i(3,0) or atlasCoord == Vector2i(-1,-1): #(3,0) = warp, (-1,-1) = void
		posPlayer += movement
		return true
	return false

func interact(movement) -> bool:
	var atlasCoord = get_cell_atlas_coords(0, posPlayer + movement)
	if atlasCoord == Vector2i(1,0): #Item
		set_cell(0, posPlayer+movement)
		return true
	elif atlasCoord == Vector2i(2,0):
		actors[str(posPlayer+movement)].interact()
		return true
	return false

func _process(delta) -> void:
	pass
