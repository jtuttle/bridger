extends Node2D

const GRID_WIDTH = 20
const GRID_HEIGHT = 11

const PIECE_INITIAL_X = 10 # 22
const PIECE_INITIAL_Y = 2

onready var _timer = $timer # piece stepper 

onready var _tile_map = $tile_map

onready var _shape_factory = load("res://objects/shapes/shape_factory.gd").new()

var _piece
var _piece_x
var _piece_y

#has to be higher than this to be considered for passage
var _minimum_safe_row = 15 #lower than the 15th row before it is passable
const _tileset_max_cols = 19 #0..19
const _tileset_max_rows = 10 #0..10

#tile index information
const BLACK_TILE = 0
const WHITE_TILE = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	# Prevent randi() from returning same value on every run
	randomize()

	set_process_input(true)

	_place_minimum_level(_minimum_safe_row)

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
	
	if event.is_action_pressed("drop_piece"):
		_drop_piece()

func _start_level():
	_spawn_piece()

	_timer.connect("timeout", self, "_move_piece") 
	_timer.start()
	
	_move_piece()

	_column_top()

func _move_piece():
	print("move piece")
	
	_clear_piece()
	_piece_x -= 1
	_draw_piece()

	_timer.start()

func _drop_piece():
	print("drop piece!")

	_clear_piece()

	while _is_piece_airborn():
		_piece_y += 1

	_draw_piece()

	_spawn_piece()

func _spawn_piece():
	_piece = _shape_factory.next_shape()
	_piece_x = PIECE_INITIAL_X
	_piece_y = PIECE_INITIAL_Y
	_draw_piece()


func _is_piece_airborn():
	var coords = _piece.get_coords()
	
	for i in range(0, coords.size()):
		var row = coords[i]

		for j in range(0, row.size()):
			if row[j] == 1:
				var tile_x = _piece_x + j
				var tile_y = _piece_y + i + 1

				if _tile_map.get_cell(tile_x, tile_y) == WHITE_TILE:
					return false

	return true

func _draw_piece():
	var piece_coords = _piece.get_coords()
	
	for y in range(0, piece_coords.size()):
		var piece_row = piece_coords[y]

		for x in range(0, piece_row.size()):
			if piece_row[x] == 1:
				_tile_map.set_cell(_piece_x + x, _piece_y + y, WHITE_TILE)


func _clear_piece():
	var piece_coords = _piece.get_coords()

	for y in range(0, piece_coords.size()):
		var piece_row = piece_coords[y]

		for x in range(0, piece_row.size()):
			if piece_row[x] == 1:
				_tile_map.set_cell(_piece_x + x, _piece_y + y, BLACK_TILE)


func _check_path():
	print("check path")
	for col in range(_tileset_max_cols):
		 
		if _column_top(col) <= _minimum_safe_row:
			print("eligible column")
		
		for row in range(_tileset_max_rows):
			print(_tile_map.get_cell(col, row))



func _column_top(col : int = 0):
	var row = 0
	while _tile_map.get_cell(col, row) == BLACK_TILE:
		row += 1
		
	return row



func _place_minimum_level(min_row : int = 15):
	#draw rectangle at specified row in the grid, over the tilemap
	print("minimum level = ", min_row)
