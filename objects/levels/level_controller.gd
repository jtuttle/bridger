extends Node2D

const GRID_WIDTH = 20
const GRID_HEIGHT = 11

const PIECE_INITIAL_X = 22
const PIECE_INITIAL_Y = 2

var grid = []

onready var _timer = $timer # piece stepper 

onready var _tile_map = $tile_map

onready var _shape_factory = load("res://objects/shapes/shape_factory.gd").new()

var _piece
var _piece_x = PIECE_INITIAL_X
var _piece_y = PIECE_INITIAL_Y

# Called when the node enters the scene tree for the first time.
func _ready():
	# Prevent randi() from returning same value on every run
	randomize()

	set_process_input(true)

	#set up the grid data structure
	for x in range(GRID_WIDTH):
		grid.append([])
		for y in range(GRID_HEIGHT):
			grid[x].append(0)
			
	_start_level()

func _input(event):
	if event.is_action_pressed("rotate_clockwise"):
		_clear_piece()
		_piece.rotate_clockwise()
		_draw_piece()
		
	if event.is_action_pressed("rotate_counter_clockwise"):
		_clear_piece()
		_piece.rotate_counter_clockwise()
		_draw_piece()

func _start_level():
	_piece = _shape_factory.next_shape()

	_timer.connect("timeout", self, "_move_piece") 
	_timer.start()
	
	_move_piece()

func _move_piece():
	print("move piece")
	
	_clear_piece()
	_piece_x -= 1
	_draw_piece()

	_timer.start()

func _draw_piece():
	var coords = _piece.get_coords()
	
	for i in range(0, coords.size()):
		var row = coords[i]

		for j in range(0, row.size()):
			_tile_map.set_cell(_piece_x + j, _piece_y + i, row[j])

func _clear_piece():
	var coords = _piece.get_coords()

	for i in range(0, coords.size()):
		var row = coords[i]

		for j in range(0, row.size()):
			_tile_map.set_cell(_piece_x + j, _piece_y + i, 0)
