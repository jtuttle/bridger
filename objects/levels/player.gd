extends Sprite

onready var _move_tween = $move

var _walk_path

func _ready():
	_move_tween.connect("tween_complete", self, "_on_move_complete")

func _on_move_complete(object, key):
	print("done?")
	_next_step()
	
func walk(column_tops):
	print(column_tops)
	_walk_path = column_tops
	_next_step()

func _next_step():
	var next_step = _walk_path.front()
	_walk_path.pop_front()
	print(next_step)
	print(_walk_path)

	var next_pos = Vector2(
		self.position.x + 24,
		(next_step - 1) * 24
	)
	
	_move_tween.interpolate_property(
		self, "transform/pos", 1,
		self.position, next_pos,
		Tween.TRANS_LINEAR, Tween.EASE_OUT
	)
	_move_tween.start()

	print("uuuuh")
