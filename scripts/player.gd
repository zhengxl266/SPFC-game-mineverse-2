extends CharacterBody2D

var enemy_attack_range = false
var enemy_attack_cd = true
var health = 200
var player_alive = true

var attack_ip = false

const speed = 100
var current_dir = 'none'

func _ready():
	$AnimatedSprite2D.play('Front_idle')

func _physics_process(delta):
	player_movement(delta)
	enemy_attack()
	attack()
	current_camera()
	
	if health <= 0:
		player_alive = false      #add "you died" screens and you died screen for future implementation
		health = 0
		print("player has been slain")
		self.queue_free()
		
	
	
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

func player():
	pass

func _on_player_hitbox_body_entered(body):
	if body.has_method('enemy'):
		enemy_attack_range = true

func _on_player_hitbox_body_exited(body):
	if body.has_method('enemy'):
		enemy_attack_range = false

func enemy_attack():
	if enemy_attack_range and enemy_attack_cd == true:
		health = health - 20
		enemy_attack_cd = false
		$attack_cd.start()
		print(health)

func _on_attack_cd_timeout():
	enemy_attack_cd = true

func attack():
	var dir = current_dir
	
	if Input.is_action_just_pressed("attack"):
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
