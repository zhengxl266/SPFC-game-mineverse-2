extends Node2D
@onready var canvas_layer = $CanvasLayer
@onready var daynight_ui = $CanvasLayer/DayNightCycleUI
var night_music_playing = false

func _ready():
	var canvas_modulate = $CanvasModulate
	canvas_modulate.time_tick.connect(daynight_ui.set_daytime)
	canvas_modulate.connect("time_tick", Callable(self, "_on_time_tick"))
	
func _process(delta):
	change_scenes()


func _on_cliffside_world_portal_body_entered(body):
	if body.has_method("player"):
		Global.transition_scene = true

func change_scenes():
	if Global.transition_scene == true:
		if Global.current_scene == "cliff_side":
			get_tree().change_scene_to_file("res://scenes/world.tscn")
			Global.finish_change_scene()

func _on_time_tick(day,hour,minute):
	if (hour >= 18 or hour < 6) and !night_music_playing:
		BgmGlobal.play_music_night()
		night_music_playing = true
	elif (hour <18 and hour >=6) and night_music_playing:
		BgmGlobal.play_music_level()
		night_music_playing = false
