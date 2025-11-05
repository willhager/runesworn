extends ItemList

signal item_hovered(index : int)

var last_hovered = -1
func _process(_delta: float) -> void:
	var local_pos := get_local_mouse_position()
	if get_rect().has_point(local_pos):
		for i in range(item_count):
			if get_item_rect(i).has_point(local_pos):
				if i != last_hovered:
					emit_signal("item_hovered", i)
					last_hovered = i
					return
	last_hovered = -1
