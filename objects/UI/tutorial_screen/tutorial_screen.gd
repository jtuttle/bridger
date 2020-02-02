extends CenterContainer

signal REPEAT_LEVEL
signal NEXT_LEVEL

# Called when the node enters the scene tree for the first time.
func _ready():
	$v_box_container/next_level_button.connect("pressed", self, "_next_pressed")
	$v_box_container/repeat_level_button.connect("pressed", self, "_repeat_pressed")
	$v_box_container/quit_button.connect("pressed", self, "_quit_pressed")


func _next_pressed():
	global.load_next_level()
	emit_signal("NEXT_LEVEL")

func _repeat_pressed():
	global.load_level()
	emit_signal("REPEAT_LEVEL")


func _quit_pressed():
	get_tree().quit()
