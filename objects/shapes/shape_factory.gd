var I = load("res://objects/shapes/shape_i.gd")
var O = load("res://objects/shapes/shape_o.gd")
var T = load("res://objects/shapes/shape_t.gd")
var S = load("res://objects/shapes/shape_s.gd")
var Z = load("res://objects/shapes/shape_z.gd")
var J = load("res://objects/shapes/shape_j.gd")
var L = load("res://objects/shapes/shape_l.gd")

var _shapes = [I, O, T, S, Z, J, L]

func next_shape():
	return T.new()
	#return _shapes[randi() % _shapes.size()].new()
