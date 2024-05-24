extends Node

class_name DamageComponent

@export var damage_amount: int = 20

func deal_damage(target: Node):
	if target.has_method("take_damage"):
		target.take_damage(damage_amount)
