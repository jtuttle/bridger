extends CenterContainer

# Called when the node enters the scene tree for the first time.
func _ready():
	$texture_button.connect("pressed", self, "_start_game")

func _start_game():
	get_tree().change_scene("res://objects/levels/game/game.tscn")
	
