extends PopupPanel

@onready var title_label = $Panel/MarginContainer/VBoxContainer/Title
@onready var text_label = $Panel/MarginContainer/VBoxContainer/Text


var hide_timer: Timer

func _ready():
	hide_timer = Timer.new()
	hide_timer.one_shot = true
	hide_timer.wait_time = 0.05  # small delay, enough to catch fast switches
	add_child(hide_timer)
	hide_timer.timeout.connect(_on_hide_timeout)

func show_tooltip(titleText: String, text: String, global_pos: Vector2):
	title_label.text = titleText
	text_label.text = text
	
	hide_timer.stop()
	popup()
	size = Vector2.ZERO
	call_deferred("_finish_popup", global_pos)

func _finish_popup(global_pos: Vector2):
	position = global_pos
	
func request_hide() :
	hide_timer.start()
	
func _on_hide_timeout():
	hide()
