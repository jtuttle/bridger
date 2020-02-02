extends Node2D

onready var _sprite = $sprite
onready var _move_tween = $move

var _walk_path

func _ready():
	_move_tween.connect("tween_completed", self, "_on_move_complete")

func _on_move_complete(object, key):
	if(_walk_path.size() > 0):
		_next_step()
	else:
		_sprite.stop()
	
func walk(column_tops):
	# Add one more column to get player off the screen
	column_tops.append(column_tops.back())

	_sprite.play("run")
	_walk_path = column_tops
	_next_step()

func _next_step():
	var next_step = _walk_path.front()
	_walk_path.pop_front()

	var next_pos = Vector2(
		self.position.x + 24,
		next_step * 24
	)
	
	_move_tween.interpolate_property(
		self, "global_position",
		self.global_position, next_pos, 0.1,
		Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	_move_tween.start()
