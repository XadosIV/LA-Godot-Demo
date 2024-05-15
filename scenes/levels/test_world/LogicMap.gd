class_name LogicMap extends TileMap

var posPlayer : Vector2

# Dictionnaire de correspondances, faisant un lien entre Tuile et Node.
# Permet de savoir, lorsqu'on interagi avec une tuile, à quel ressource cela correspond.
# Remplis par la fonction load_map()
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

"""
Fonction de chargement
"""
# Remplis les dictionnaires de correspondances (acteurs, warps et items)
func load_map() -> void:
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

# Instancie et place un acteur sur la carte.
func create_actor(id, mapPos, sprite, load=true):
	var npc = npc_scene.instantiate()
	add_child(npc)
	npc.id = id
	npc.position = mapPos * 16 + Vector2i(8,8)
	
	var res_path = "res://scenes/characteres/players/resources/"
	if sprite != null:
		res_path += sprite
	else:
		res_path += "Roki.tres" # Sprite par défaut
	
	npc.sprite = load(res_path)
	npc._ready() # (Ne s'appelle pas tout seul ??? Merci Godot)
	
	# Ajoute la tuile Acteur
	set_cell(0, mapPos, get_tileset().get_source_id(0), Vector2i(2,0), 0)
	if load:
		load_map()


"""
	Fonctions de conversions par lecture des dictionnaires de correspondance
	Entrée : Vector2 (position)
	Sortie : Ressource (Acteur, Warp, Item)
"""
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

"""
Fonctions de test de tuile
"""
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

func isVoid(mapPos: Vector2) -> bool:
	return isTile(mapPos, Vector2i(-1,-1))

"""
Fonctions liées au joueur
"""
# Fonction de déplacement du joueur sur la LogicMap
func playerMove(movement) -> bool: # renvoie si le mouvement a pu être fait ou non
	var mapPos = posPlayer + movement

	# coordonnée de la tuile devant le joueur sur le tileset
	get_parent().get_node("Player").gridPos = Vector2(posPlayer.x * 16 + 8, posPlayer.y * 16 + 8)
	
	if isVoid(mapPos): 
		posPlayer += movement
		return true
	elif isWarp(mapPos):
		posPlayer += movement
		get_parent().get_node("Player").disable()
		var warp = posToWarp(posPlayer)
		warp.warp()
		return true
	# Le mouvement n'a pas pu être fait. (Obstacle)
	return false

func interact(facing) -> bool: # Renvoie si une interaction a été effectuée
	var mapPos = posPlayer + facing # Case sur laquelle on interagi
	if isItem(mapPos): # Récupération d'objet
		var targeted_item = posToItem(mapPos)
		targeted_item.interact() # Affichage de la boite de dialogue d'information
		player.inventory_add(targeted_item.id)
		targeted_item.queue_free() # Suppression du noeud
		set_cell(0, mapPos) # Suppression de la tuile
		return true
	elif isActor(mapPos): # Interaction avec un acteur
		posToActor(mapPos).interact()
		return true

	return false



func _process(delta) -> void:
	pass
func hide_map():
	set_layer_modulate(0, Color(1.0, 1.0, 1.0, 0.0))
func show_map():
	set_layer_modulate(0, Color(1.0, 1.0, 1.0, 1.0))
