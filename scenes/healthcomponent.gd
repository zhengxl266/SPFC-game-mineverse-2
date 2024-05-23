extends Node2D

@export var Max_health:= 100
var health : float

func _ready():
	health = Max_health
	
func damage(attack: Attack):
	health -= attack.attack_damage
	
	if health <= 0:
		get_parent().queue_free()
