extends Node2D


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
