extends CharacterBody2D

class_name Player

@export var speed: int = 100
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $hitboxComponent
@onready var damage_component: DamageComponent = $DamageComponent
@onready var sword_slash = $Sword_slash
@onready var death_sfx = $Death_sfx

var respawn_position: Vector2
var player_alive = true

var attack_ip = false
var current_dir = 'none'

func _ready():
	$AnimatedSprite2D.play('Front_idle')
	respawn_position = position

func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	attack()
	current_camera()
	update_health()

	if health_component.has_method("get_current_health") and health_component.get_current_health() <= 0 and player_alive:
		player_alive = false
		if health_component.has_method("set_current_health"):
			health_component.set_current_health(0)
		print("player has been slain")
		death_sfx.play()
		$AnimatedSprite2D.play("Death")
		game_over()

func player_movement(delta):
	if Input.is_action_pressed("ui_right"):
		current_dir = "right"
		play_anim(1)
		velocity.x = speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_left"):
		current_dir = "left"
		play_anim(1)
		velocity.x = -speed
		velocity.y = 0
	elif Input.is_action_pressed("ui_down"):
		current_dir = "down"
		play_anim(1)
		velocity.y = speed
		velocity.x = 0
	elif Input.is_action_pressed("ui_up"):
		current_dir = "up"
		play_anim(1)
		velocity.y = -speed
		velocity.x = 0
	else:
		play_anim(0)
		velocity.x = 0
		velocity.y = 0

	move_and_slide()


func play_anim(movement):
	var dir = current_dir
	var anim = $AnimatedSprite2D

	if dir == 'right':
		anim.flip_h = false
		if movement == 1:
			anim.play("Side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("Side_idle")

	if dir == 'left':
		anim.flip_h = true
		if movement == 1:
			anim.play("Side_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("Side_idle")

	if dir == 'down':
		anim.flip_h = false
		if movement == 1:
			anim.play("Front_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("Front_idle")

	if dir == 'up':
		anim.flip_h = false
		if movement == 1:
			anim.play("Back_walk")
		elif movement == 0:
			if attack_ip == false:
				anim.play("Back_idle")

	if not player_alive:
		anim.play("Death")
		
		
		
		
func player():
	pass

func _on_hitbox_component_body_entered(body):
	if body.has_method('enemy'):
		hitbox_component.enemy_in_range = true


func _on_hitbox_component_body_exited(body):
	if body.has_method('enemy'):
		hitbox_component.enemy_in_range = false



func enemy_attack():
	if hitbox_component.enemy_in_range and hitbox_component.enemy_attack_cd == true:
		health_component.take_damage(damage_component.damage_amount)
		hitbox_component.enemy_attack_cd = false
		$attack_cd.start()

func _on_attack_cd_timeout():
	hitbox_component.enemy_attack_cd = true

func attack():
	var dir = current_dir

	if Input.is_action_just_pressed("attack"):
		sword_slash.play()
		Global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("Side_attack")
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("Side_attack")
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("Front_attack")
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("Back_attack")
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attack_ip = false

func current_camera():
	if Global.current_scene == "world":
		$world_camera.enabled = true
		$cliff_side_camera.enabled = false
	elif Global.current_scene == "cliff_side":
		$world_camera.enabled = false
		$cliff_side_camera.enabled = true

func update_health():
	var healthbar = $hp_bar
	healthbar.value = health_component.current_health

	if health_component.current_health >= 100:
		healthbar.visible = false
	else:
		healthbar.visible = true

func _on_regen_timer_timeout():
	if health_component.current_health < 100:
		health_component.current_health += 15
		if health_component.current_health > 100:
			health_component.current_health = 100
	if health_component.current_health <= 0:
		health_component.current_health = 0

func game_over():
	Global.game_over = true
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://UI/game_over.tscn")

func respawn():
	position = respawn_position
	health_component.heal_to_max()
	player_alive = true


