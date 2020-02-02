extends Node2D

var _hazard_top

onready var _tile_map = $tile_map
const _tile_size = 24

# Called when the node enters the scene tree for the first time.
func _ready():
	_hazard_top = get_viewport_rect().size.y
	print(_hazard_top)


func set_hazard_top(top_row : int):
	#convert the row number to a bottom and top coordinate to float the hazard between
	var top_bound = _tile_map.map_to_world(Vector2(0, top_row))
	print("top: ", top_bound)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#
#	pass
