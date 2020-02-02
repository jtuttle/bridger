extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	$center_container/v_box_container/repeat_level_button.connect("pressed", self, "_repeat_pressed")
	$center_container/v_box_container/quit_button.connect("pressed", self, "_quit_pressed")
	pass # Replace with function body.


func _repeat_pressed():
	print("repeat button pressed")


func _quit_pressed():
	get_tree().quit()
