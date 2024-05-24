extends Node2D

@onready var BGM = $BGM
var backgroundmusicOn = true

func _ready():
	if Global.game_first_loadin == true:
		$player.position.x = Global.player_start_posx
		$player.position.y = Global.player_start_posy
		$player.respawn_position = Vector2(Global.player_start_posx, Global.player_start_posy)
	else:
		$player.position.x = Global.player_exit_cliffside_posx
		$player.position.y = Global.player_exit_cliffside_posy
		$player.respawn_position = Vector2(Global.player_exit_cliffside_posx, Global.player_exit_cliffside_posy)


func _process(delta):
	change_scene()
	update_music_stats()


func _on_cliffside_portal_body_entered(body):
	if body.has_method("player"):
		Global.transition_scene = true


func change_scene():
	if Global.transition_scene == true:
		if Global.current_scene == "world":
			get_tree().change_scene_to_file("res://scenes/cliff_side.tscn")
			Global.game_first_loadin = false
			Global.finish_change_scene()

func update_music_stats():
	if backgroundmusicOn:
		if !BGM.playing:
			BGM.play()
	else:
		BGM.stop()
			
