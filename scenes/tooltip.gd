extends PopupPanel

@onready var title_label = $Panel/MarginContainer/VBoxContainer/Title
@onready var text_label = $Panel/MarginContainer/VBoxContainer/Text

func show_tooltip(title: String, text: String, global_pos: Vector2):
	title_label.text = title
	text_label.text = text
	
	reset_size()
	await get_tree().process_frame

	size = get_min_size()
	position = global_pos
	
	popup()
