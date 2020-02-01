extends Node2D

var grid = []
const width = 20
const height = 11

#piece stepper
onready var _timer = $timer
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


func _move_piece():
	print("move piece")
	_timer.start()
	yield(_timer, "timeout")
	_move_piece()
	
	
func _init_level(level):
	
	
	for col in grid:
		for i in range(col.length - )	
	
