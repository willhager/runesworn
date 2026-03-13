extends Label

var tooltip_title : String
var tooltip_body : String

func set_tooltip(title : String, body : String) :
	tooltip_title = title
	tooltip_body = body

func _on_mouse_entered() :
	if(tooltip_title) :
		tooltip_manager.show_tooltip(tooltip_title, tooltip_body, Vector2(310, 290))
	
func _on_mouse_exited() :
	if(tooltip_title) :
		tooltip_manager.hide_tooltip()
