extends Node2D

var grid = []
const width = 20
const height = 11

#piece stepper
onready var _timer = $timer
var _step_time = 2 #1 second delay

onready var _tile_map = $tile_map

onready var _shape_factory = load("res://objects/shapes/shape_factory.gd").new()

# Called when the node enters the scene tree for the first time.
func _ready():
	# Prevent randi() from returning same value on every run
	randomize()

	#set up the grid data structure
	for x in range(width):
		grid.append([])
		for y in range(height):
			grid[x].append(0)
			
	_start_level()

func _start_level():
	_timer.wait_time = _step_time
	_move_piece()

	_tile_map.set_cell(2, 2, 0)

	var piece = _shape_factory.next_shape()
	
	_draw_piece(piece.get_coords(), 2, 2)

func _move_piece():
	print("move piece")
	_timer.start()
	yield(_timer, "timeout")
	_move_piece()

func _draw_piece(piece_coords, x, y):
	for i in range(0, piece_coords.size()):
		var row = piece_coords[i]

		for j in range(0, row.size()):
			_tile_map.set_cell(x + j, y + i, row[j])
