extends Node

const _level_path = "res://objects/levels/"
const _level_prefix = "level_"
const _level_suffix = ".tscn"
var _level_num = 1

var _level_holder

# Called when the node enters the scene tree for the first time.
func _ready():
#	_level_holder = get_node("/root/game/level_holder")
	pass # Replace with function body.

func initialize_level(level_holder):
	_level_holder = level_holder

func set_level_num(new_num : int):
	_level_num = new_num


func get_level_num():
	return _level_num


func get_level_name():
	return str(_level_prefix, str(_level_num))


func get_level_path():
	return str(_level_path, _level_prefix, str(_level_num), str("/", _level_prefix), str(_level_num), _level_suffix)


func get_game():
	return get_node("/root/game")


func load_next_level():
	print("load_next_level")
#	_level_num += 1
	load_level()


func load_level():
	print("load_level")
	# Remove the current level
	var level = _level_holder.get_child(0)
	level.name = "old_level"
	
	#load the next level
	var path = get_level_path()
	var next_level_resource = load(path)
	var next_level = next_level_resource.instance()
	_level_holder.add_child(next_level)
	
	_level_holder.remove_child(level)
	level.call_deferred("free")
