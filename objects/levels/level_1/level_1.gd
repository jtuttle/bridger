extends Node2D


onready var _hazard = $hazard

var _hazard_top
var _hazard_bottom
var _hazard_tile_row

onready var _tile_map = $tile_map
const _tile_size = 24


var _float_max_x_radius = 5 #range from -20 to +20
var _float_max_y_radius = 5 #range from -20 to +20
var _float_max_rotation_range = 5 #range from -20 to +20
var _rotate = false #should we rotate at all? power ups might not
var _float = true #should we float at all?

var _float_running = false #float is running at the moment

onready var _initial_position
onready var _initial_transform

onready var _tween = $tween


# Called when the node enters the scene tree for the first time.
func _ready():
	#initialize to the bottom
	_hazard_tile_row = global.get_game().get_hazard_level()
	print("Hazard row: ", _hazard_tile_row)
	
	_hazard_top = _tile_map.map_to_world(Vector2(0, _hazard_tile_row))
	print("Hazard top: ", _hazard_top)
	
	_hazard.global_position = _hazard_top
	_initial_position = _hazard.global_position
	_initial_transform = _hazard.transform
	

func _process(delta):
	if _float && _float_running == false:
		_float_around()


func _float_around():  #oscillate like you are floating in space
	if _float:
		_float_running = true
		
		var position_offset = Vector2(rand_range(-(_float_max_x_radius), _float_max_x_radius), rand_range(-(_float_max_y_radius), _float_max_y_radius))
		var target_position = _initial_position + position_offset
		_tween.interpolate_property(_hazard, "global_position", _hazard.global_position, target_position, 5, Tween.TRANS_LINEAR, Tween.EASE_IN)

		_tween.start()
		
		yield(_tween, "tween_completed")
		_float_running = false
