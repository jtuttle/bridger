extends CenterContainer


# Called when the node enters the scene tree for the first time.
func _ready():
	$v_box_container/next_level_button.connect("pressed", self, "_next_pressed")
	$v_box_container/repeat_level_button.connect("pressed", self, "_repeat_pressed")
	$v_box_container/quit_button.connect("pressed", self, "_quit_pressed")


func _next_pressed():
	print("next level button pressed")

func _repeat_pressed():
	print("repeat button pressed")


func _quit_pressed():
	get_tree().quit()
