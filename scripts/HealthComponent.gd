extends Node

class_name HealthComponent

@export var max_health: int = 60
@export var regeneration_rate: int = 5

var current_health: int = max_health

func take_damage(amount: int):
	current_health -= amount
	if current_health <= 0:
		current_health = 0
		

func heal_to_max():
	current_health = max_health

func get_current_health() -> int:
	return current_health

func set_current_health(value: int):
	current_health = value

func regenerate():
	if current_health < max_health:
		current_health += regeneration_rate
		if current_health > max_health:
			current_health = max_health
