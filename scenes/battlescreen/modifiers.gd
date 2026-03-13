extends Label

func _on_mouse_entered() :
	tooltip_manager.show_tooltip("modifier", "modifier info", Vector2(350, 260))
	
func _on_mouse_exited() :
	tooltip_manager.hide_tooltip()
	
