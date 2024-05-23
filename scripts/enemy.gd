class_name Enemy
extends CharacterBody2D

@onready var damage_numbers_origin = $DamageNumbersOrigin
@export var speed = 40
var player_chasing = false
var player = null

var health = 100
var damage = 20
var player_inattack_range = false
var can_take_damage = true

func _physics_process(delta):
	deal_with_damage()
	update_health()
	
	if player_chasing == true:
		position += (player.position - position)/speed
		$AnimatedSprite2D.play("Walk")
		move_and_collide(Vector2(0,0))
		
		if(player.position.x-position.x)<0:
			$AnimatedSprite2D.flip_h = true
		else:
			$AnimatedSprite2D.flip_h = false
	else:
		$AnimatedSprite2D.play("Idle")

func _on_detection_space_body_entered(body):
	player = body
	player_chasing = true
	

func _on_detection_space_body_exited(body):
	player = null
	player_chasing = false

func enemy():
	pass


func _on_enemy_hitbox_body_entered(body):
	if body.has_method('player'):
		player_inattack_range = true

func _on_enemy_hitbox_body_exited(body):
	if body.has_method('player'):
		player_inattack_range = false

func deal_with_damage():
	if player_inattack_range and Global.player_current_attack == true:
		if can_take_damage == true:
			health -= damage
			DamageNumbers.display_number(damage,damage_numbers_origin.global_position)
			$take_damage_cd.start()
			can_take_damage = false
			if health <= 0:
				self.queue_free()


func _on_take_damage_cd_timeout():
	can_take_damage = true
	
func update_health():
	var healthbar = $hp_bar
	
	healthbar.value = health
	
	if health>= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true
