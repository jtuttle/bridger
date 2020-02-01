var _coord_index = 0

func get_coords():
	return self._coords[_coord_index]

func rotate_clockwise():
	_coord_index = (_coord_index + 1) % self._coords.size()

func rotate_counter_clockwise():
	_coord_index = (_coord_index - 1) % self._coords.size()
