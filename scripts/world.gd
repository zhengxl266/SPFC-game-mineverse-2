extends Node2D
@onready var pause_menu_scene: PackedScene = preload("res://ui/pause_menu.tscn")
@onready var BGM = $BGM
@onready var canvas_layer = $CanvasLayer
@onready var daynight_ui = $CanvasLayer/DayNightCycleUI

func _ready():
	BgmGlobal.play_music_level()
	if Global.game_first_loadin == true:
		$player.position.x = Global.player_start_posx
		$player.position.y = Global.player_start_posy
		$player.respawn_position = Vector2(Global.player_start_posx, Global.player_start_posy)
	else:
		$player.position.x = Global.player_exit_cliffside_posx
		$player.position.y = Global.player_exit_cliffside_posy
		$player.respawn_position = Vector2(Global.player_exit_cliffside_posx, Global.player_exit_cliffside_posy)
	canvas_layer.visible = true
	var canvas_modulate = $CanvasModulate
	canvas_modulate.time_tick.connect(daynight_ui.set_daytime)
	


func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Escape key by default
		Pausemanager.toggle_pause()

func _process(delta):
	change_scene()
	


func _on_cliffside_portal_body_entered(body):
	if body.has_method("player"):
		Global.transition_scene = true


func change_scene():
	if Global.transition_scene == true:
		if Global.current_scene == "world":
			get_tree().change_scene_to_file("res://scenes/cliff_side.tscn")
			Global.game_first_loadin = false
			Global.finish_change_scene()


			
