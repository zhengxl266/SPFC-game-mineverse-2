extends Node

class_name DamageComponent

@export var damage_amount: int = 15
@export var crit_chance: float = 0.2
@export var crit_multiplier: float = 1.5 


func deal_damage(target: Node):
	var final_damage = damage_amount
	final_damage += randi()%(damage_amount/2)
	
	var is_critical = false
	var random_value = randf()
	if random_value <= crit_chance:
		final_damage*=crit_multiplier
		is_critical = true
		
	if target.has_method("take_damage"):
		target.take_damage(final_damage)
		
	return {
		"damage": final_damage,
		"is_critical": is_critical
	}
