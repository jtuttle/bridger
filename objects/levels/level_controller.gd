extends Node2D

const PIECE_INITIAL_X = 42 # 22
const PIECE_INITIAL_Y = 2

const SPEED_UP_FACTOR = 16.0

onready var _timer = $timer # piece stepper
var _timer_delay = 1

onready var _tile_map = $level_holder/level_1/tile_map #TODO MAKE THIS A DYNAMIC PATH
onready var _level = $level_holder/level_1

onready var _shape_factory = load("res://objects/shapes/shape_factory.gd").new()

onready var _player = null #$player

var _victory = false

var _piece
var _piece_x
var _piece_y

#has to be higher than this to be considered for passage
var _minimum_safe_row = 9 #lower than this row before it is passable

const _level_cols = 40

#tile index information
const EMPTY_TILE = -1
const WHITE_TILE = 1
const PATH_TILE = 2

onready var _win_screen = $ui/win_screen
onready var _lose_screen = $ui/lose_screen

# The last recorded path
var _prev_path = []

func _ready():
	# Prevent randi() from returning same value on every run
	randomize()
	
	set_process_input(true)

	_start_level()

func get_hazard_level():
	return _minimum_safe_row

func _input(event):
	if _victory: return

	if event.is_action_pressed("speed_up"):
		_timer.stop()
		_timer.set_wait_time(_timer_delay / SPEED_UP_FACTOR)
		_move_piece()
	
	if event.is_action_released("speed_up"):
		_timer.stop()
		_timer.set_wait_time(_timer_delay)
		_timer.start()

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
		
	if event.is_action_pressed("bring_up_ui"):
		_win()

func _start_level():
	_spawn_piece()

	_timer.connect("timeout", self, "_move_piece")
	_timer.set_wait_time(_timer_delay)
	_timer.start()
	
	_move_piece()

	_column_top()

func _move_piece():
	_clear_piece()
	_piece_x -= 1
	_draw_piece()

	_timer.start()

func _drop_piece():
	_clear_piece()

	while _is_piece_airborn():
		_piece_y += 1

	_draw_piece()

	_piece = null

	_clear_prev_path()
	_prev_path = _get_path()
	_draw_path(_prev_path)

	if _prev_path.size() == _level_cols:
		_win()

	if !_victory:
		_spawn_piece()


func _win():
	_timer.stop()
	_victory = true

#	var tops = []
	
#	for i in range(1, _level_cols):
#		tops.append(_column_top(i))
	
#	_player.walk(tops)
	_win_screen.visible = true


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

				if _tile_map.get_cell(tile_x, tile_y) != EMPTY_TILE:
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
				_tile_map.set_cell(_piece_x + x, _piece_y + y, EMPTY_TILE)

func _get_path():
	var path = [ _column_top(0) ]

	while path.size() < _level_cols + 1:
		var next_top = _column_top(path.size())

		if abs(path.back() - next_top) > 1:
			break
		
		path.append(next_top)

	return path

func _clear_prev_path():
	for col in range(_prev_path.size()):
		_tile_map.set_cell(col, _prev_path[col], WHITE_TILE)

	_prev_path.clear()

#replace the tiles at the array values in columns for the array indices
func _draw_path(path : PoolIntArray):
	print("drawing path")
	#draw the contiguous path
	for col in range(path.size()):
		_tile_map.set_cell(col, path[col], PATH_TILE)


func _column_top(col : int = 0):
	var row = 0
	while _tile_map.get_cell(col, row) == EMPTY_TILE :
		row += 1
		
	return row



func _place_minimum_level(min_row : int = 15):
	#draw rectangle at specified row in the grid, over the tilemap
	
	print("minimum level = ", min_row)
