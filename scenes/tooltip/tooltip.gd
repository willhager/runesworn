extends PopupPanel

@onready var title_label = $Panel/MarginContainer/VBoxContainer/Title
@onready var text_label = $Panel/MarginContainer/VBoxContainer/Text

var hide_timer: Timer

func _ready():
	hide_timer = Timer.new()
	hide_timer.one_shot = true
	hide_timer.wait_time = 0.05
	add_child(hide_timer)
	hide_timer.timeout.connect(_on_hide_timeout)
	print("min size =", get_min_size())

func show_tooltip(titleText: String, text: String, global_pos: Vector2):
	title_label.text = titleText
	text_label.text = text
	
	hide_timer.stop()
	await get_tree().process_frame
	popup()
	position = global_pos
	
func request_hide() :
	hide_timer.start()
	
func _on_hide_timeout():
	hide()
