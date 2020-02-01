extends Node2D

var grid = []
const width = 20
const height = 11

const I = [[0,1,0,0],[0,1,0,0],[0,1,0,0],[0,1,0,0]]
const O = [[1,1],[1,1]]
const T = [[0,1,0],[1,1,1],[0,0,0]]
const S = [[0,1,1],[1,1,0],[0,0,0]]
const Z = [[1,1,0],[0,1,1],[0,0,0]]
const J = [[1,0,0],[1,1,1],[0,0,0]]
const L = [[0,0,1],[1,1,1],[0,0,0]]

#piece stepper
onready var _timer = $timer
onready var _tile_map = $tile_map
var _step_time = 2 #1 second delay

# Called when the node enters the scene tree for the first time.
func _ready():

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

	_draw_piece(L, 2, 2)

func _move_piece():
	print("move piece")
	_timer.start()
	yield(_timer, "timeout")
	_move_piece()

func _draw_piece(piece, x, y):
	for i in range(0, piece.size()):
		var row = piece[i]

		for j in range(0, row.size()):
			_tile_map.set_cell(x + j, y + i, row[j])
