extends Node
class_name HealthComponent

signal health_depleted

@export var max_health: int = 60
@export var regeneration_rate: int = 5
var current_health: int = max_health

func _ready():
	current_health = max_health

func take_damage(amount: int):
	current_health -= amount
	print("Current health: ", current_health)
	if current_health <= 0:
		current_health = 0
		print("Health depleted, emitting signal")
		emit_signal("health_depleted")

func heal_to_max():
	current_health = max_health

func get_current_health() -> int:
	return current_health

func set_current_health(value: int):
	current_health = value
	if current_health <= 0:
		current_health = 0
		emit_signal("health_depleted")

func regenerate():
	if current_health < max_health:
		current_health += regeneration_rate
		if current_health > max_health:
			current_health = max_health
			
func increase_max_health(amount: int):
	max_health += amount
	current_health += amount
