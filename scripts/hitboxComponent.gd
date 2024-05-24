extends Area2D

class_name HitboxComponent

signal enemy_attacked

var enemy_in_range: bool = false
var enemy_attack_cd: bool = true

func _on_hitbox_body_entered(body):
	if body.has_method('enemy'):
		enemy_in_range = true

func _on_hitbox_body_exited(body):
	if body.has_method('enemy'):
		enemy_in_range = false

func _on_attack_cd_timeout():
	enemy_attack_cd = true

func enemy_attack():
	if enemy_in_range and enemy_attack_cd:
		enemy_attack_cd = false
		$attack_cd.start()
		emit_signal("enemy_attacked")
