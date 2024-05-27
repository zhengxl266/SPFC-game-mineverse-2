extends Control

@onready var resume_button = $MarginContainer/HBoxContainer/VBoxContainer/RESUME as Button
@onready var quit_button = $MarginContainer/HBoxContainer/VBoxContainer/QUIT as Button
# Called when the node enters the scene tree for the first time.
func _ready():
	resume_button.pressed.connect(_on_resume_pressed)
	quit_button.pressed.connect(_on_quit_pressed)


func _on_resume_pressed():
	#get_tree().paused = false
	Pausemanager.toggle_pause()
	queue_free()  


func _on_quit_pressed():
	get_tree().quit()
