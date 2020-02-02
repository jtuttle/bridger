extends Node2D

const PIECE_INITIAL_X = 42 # 22
const PIECE_INITIAL_Y = 1

const SPEED_UP_FACTOR = 50.0

const PATH_OFFSET = 2

onready var _timer = $timer # piece stepper
var _timer_delay = 1

#TODO FIX THIS IF WE DO DYNAMIC LEVELS
onready var _tile_map : TileMap = $level_holder/level_1/tile_map #TODO MAKE THIS A DYNAMIC PATH
onready var _level = $level_holder/level_1

onready var _shape_factory = load("res://objects/shapes/shape_factory.gd").new()

onready var _player = $level_holder/level_1/player

var _victory = false

var _piece
var _piece_x
var _piece_y

#has to be higher than this to be considered for passage
var _minimum_safe_row = 8 #lower than this row before it is passable

const _level_cols = 40

#tile index information
const EMPTY_TILE = -1
const PATH_TILE = 5
const PIECE_TILE = 4

onready var _win_screen = $ui/win_screen
onready var _lose_screen = $ui/lose_screen

#sounds
onready var _drop_sound = $drop_sound
onready var _background_sound = $background_sound
onready var _ambient_sound = $ambient_sound
onready var _win_sound = $win_sound
onready var _lose_sound = $lose_sound

# The last recorded path
var _prev_path = []

#duration for sound fade in and fade out
const _fade_out_duration = 0.5
const _fade_in_duration = 0.25
const _ambient_volume_db = 0.0


func _ready():
	# Prevent randi() from returning same value on every run
	randomize()
	
	set_process_input(true)

	_win_screen.connect("NEXT_LEVEL", self, "_reset")
	_win_screen.connect("REPEAT_LEVEL", self, "_reset")
	_lose_screen.connect("REPEAT_LEVEL", self, "_reset")

	$background_sound.play()
	$ambient_sound.play()
	
	global.initialize_level(get_child(0))
	
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

		if _piece_is_too_far():
			_trash_piece()
		else:
			_draw_piece()
		
	if event.is_action_pressed("rotate_counter_clockwise"):
		_clear_piece()
		_piece.rotate_counter_clockwise()

		if _piece_is_too_far():
			_trash_piece()
		else:
			_draw_piece()
	
	if event.is_action_pressed("drop_piece"):
		_drop_piece()
	
	#replace this with a non-win version of the UI
	if event.is_action_pressed("bring_up_ui"):
		_win()

func _start_level():
	_prev_path = _get_path()
	_draw_path(_prev_path)
		
	_spawn_piece()

	_timer.connect("timeout", self, "_move_piece")
	_timer.set_wait_time(_timer_delay)
	_timer.start()
	
	fade_in(_background_sound)
	fade_in(_ambient_sound)
	
	_move_piece()

func fade_in(stream_player:AudioStreamPlayer):
	var tween = Tween.new()
	self.add_child(tween)
	tween.interpolate_property(stream_player, "volume_db", -80, _ambient_volume_db, _fade_in_duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	tween.start()
	yield(tween, "tween_completed")
	tween.queue_free()


func fade_out(stream_player:AudioStreamPlayer):
	var tween = Tween.new()
	self.add_child(tween)
	tween.interpolate_property(stream_player, "volume_db", stream_player.volume_db, -80, _fade_out_duration, Tween.TRANS_LINEAR, Tween.EASE_IN, 0)
	tween.start()
	yield(tween, "tween_completed")
	tween.queue_free()
	stream_player.stop()



func _move_piece():
	_clear_piece()
	_piece_x -= 1

	if _piece_is_too_far():
		_trash_piece()
	else:
		_draw_piece()
		_timer.start()

func _trash_piece():
	# something bad
	_piece = null
	_timer.stop()
	
	var top_of_pile = _column_top(0)
	if top_of_pile <= 0:
		_lose()
	
	else:
		_tile_map.set_cell(0, top_of_pile - 1, PIECE_TILE)
		_tile_map.set_cell(1, top_of_pile - 1, PIECE_TILE)
		_tile_map.set_cell(0, top_of_pile - 2, PIECE_TILE)
		_tile_map.set_cell(1, top_of_pile - 2, PIECE_TILE)
	
		_spawn_piece()
		_timer.start()


func _piece_is_too_far():
	var leftmost = _get_leftmost_col(_piece)
	return _piece_x + leftmost < 3

func _get_leftmost_col(piece):
	var leftmost = 100

	for row in piece.get_coords():
		for i in range(row.size()):
			if row[i] == 1 && i < leftmost:
				leftmost = i

	return leftmost

func _piece_is_far_enough():
	var rightmost = _get_rightmost_col(_piece)
	return _piece_x + rightmost < _level_cols - 3

func _get_rightmost_col(piece):
	var rightmost = 0

	for row in piece.get_coords():
		for i in range(row.size()):
			if row[i] == 1 && i > rightmost:
				rightmost = i

	return rightmost

func _drop_piece():
	if !_piece_is_far_enough():
		return

	_clear_piece()

	while _is_piece_airborn():
		_piece_y += 1

	_draw_piece()
	_drop_sound.play()
	
	_piece = null

	_clear_prev_path()
	_prev_path = _get_path()
	_draw_path(_prev_path)

#	var puff_loc = _tile_map.map_to_world(Vector2(_piece_x, _piece_y))
#	_level.puff(puff_loc)
	
	if _prev_path.size() == _level_cols - PATH_OFFSET:
		_win()

	if !_victory:
		_spawn_piece()


func _win():
	print("win!")

	_timer.stop()
	_victory = true
	
	_win_sound.play()

	#_level.move_player_on_path(_tile_map, _prev_path, PATH_OFFSET)
	var tops = []
	
	for i in range(3, _level_cols):
		tops.append(_column_top(i))
	
	_player.walk(tops)
	_show_win_screen()


func _lose():
	_timer.stop()
	_victory = true
	_lose_sound.play()
	_show_lose_screen()

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
				_tile_map.set_cell(_piece_x + x, _piece_y + y, PIECE_TILE)


func _clear_piece():
	var piece_coords = _piece.get_coords()

	for y in range(0, piece_coords.size()):
		var piece_row = piece_coords[y]

		for x in range(0, piece_row.size()):
			if piece_row[x] == 1:
				_tile_map.set_cell(_piece_x + x, _piece_y + y, EMPTY_TILE)

func _get_path():
	var path = [ _column_top(PATH_OFFSET) ]

	while PATH_OFFSET + path.size() < _level_cols:
		var next_top = _column_top(PATH_OFFSET + path.size())

		if next_top > _minimum_safe_row || abs(path.back() - next_top) > 1:
			break
		
		path.append(next_top)

	return path

func _draw_path(path : PoolIntArray):
	for col in range(path.size()):
		_tile_map.set_cell(PATH_OFFSET + col, path[col], PATH_TILE)

func _clear_prev_path():
	for col in range(_prev_path.size()):
		_tile_map.set_cell(PATH_OFFSET + col, _prev_path[col], PIECE_TILE)

	_prev_path.clear()
		
func _column_top(col : int = 0):
	var row = 0
	while _tile_map.get_cell(col, row) == EMPTY_TILE :
		row += 1
		
	return row

#manipulate the UI
func _reset():
	_hide_win_screen()
	_hide_lose_screen()

	# TODO: REFACTOR ME PLZ
	# Manually resetting controller state (barf)
	_tile_map = $level_holder/level_1/tile_map #TODO MAKE THIS A DYNAMIC PATH
	_level = $level_holder/level_1
	_player = $level_holder/level_1/player
	_timer.set_wait_time(_timer_delay)
	_piece = null
	_spawn_piece()
	_timer.start()

	_prev_path.clear()

	_victory = false

func _show_win_screen():
	$ui/color_rect.visible = true
	_win_screen.visible = true

func _hide_win_screen():
	$ui/color_rect.visible = false
	_win_screen.visible = false

func _show_lose_screen():
	$ui/color_rect.visible = true
	_lose_screen.visible = true

func _hide_lose_screen():
	$ui/color_rect.visible = false
	_lose_screen.visible = false
