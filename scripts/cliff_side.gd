extends Node2D

@onready var canvas_layer = $CanvasLayer
@onready var daynight_ui = $CanvasLayer/DayNightCycleUI
var night_music_playing = false


func _ready():
	var canvas_modulate = $CanvasModulate
	canvas_modulate.time_tick.connect(daynight_ui.set_daytime)
	canvas_modulate.connect("time_tick", Callable(self, "_on_time_tick"))
	
func _process(delta):
	pass

func _on_cliffside_world_portal_body_entered(body):
	if body.has_method("player"):
		call_deferred("_defer_scene_transition")

func _defer_scene_transition():
	Global.transition_scene = true
	Global.target_scene = "world"
	get_tree().change_scene_to_file("res://scenes/world.tscn")
	Global.game_first_loadin = false
	Global.finish_change_scene()

func _on_time_tick(day, hour, minute):
	if (hour >= 18 or hour < 6) and not night_music_playing:
		BgmGlobal.play_music_night()
		night_music_playing = true
	elif (hour < 18 and hour >= 6) and night_music_playing:
		BgmGlobal.play_music_level()
		night_music_playing = false




