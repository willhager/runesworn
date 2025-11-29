extends Label

func _on_mouse_entered() :
	print("mouse entered modifier")
	tooltip_manager.show_tooltip("modifier", "lmao test text test test test test test test test test test test test test", Vector2(500, 500))
	
	
