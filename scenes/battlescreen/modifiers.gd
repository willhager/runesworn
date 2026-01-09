extends Label

func _on_mouse_entered() :
	tooltip_manager.show_tooltip("modifier", "lmao test text test test test test test test test test test test test test", Vector2(500, 500))
	
func _on_mouse_exited() :
	tooltip_manager.hide_tooltip()
	
