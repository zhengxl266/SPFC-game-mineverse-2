extends Enemy

@onready var animated_sprite = $AnimatedSprite2D
@onready var attack_timer = $AttackTimer
var can_attack = true
var is_attacking = false
var is_hurt = false
var is_dying = false
var facing_right = false

@export var item_drop_position: Vector2 = Vector2.ZERO

func _ready():
	super._ready()
	speed = 120
	xp_value = 1000
	base_damage = 300
	attack_timer = Timer.new()
	attack_timer.one_shot = true
	attack_timer.wait_time = 2.0  
	add_child(attack_timer)
	attack_timer.connect("timeout", Callable(self, "_on_attack_timer_timeout"))
	animated_sprite.connect("animation_finished", Callable(self, "_on_animation_finished"))
	if not health_component.is_connected("health_depleted", Callable(self, "die")):
		health_component.connect("health_depleted", Callable(self, "die"))
	print("Health depleted signal connected")
	item_drop_position = Vector2(413,140)
	
func _physics_process(delta):
	deal_with_damage()
	update_health()
	
	if is_attacking or is_hurt:
		return 
	
	if player_inattack_range and can_attack:
		attack()
	elif player_chasing:
		chase_player()
	else:
		animated_sprite.play("Idle")
		
	if health_component.get_current_health() <= 0:
		return
		
func _process(delta):
	if is_dying:
		return
	if health_component.get_current_health() <= 0 and not is_queued_for_deletion():
		die()
		
func chase_player():
	if player:
		var direction = (player.position - position).normalized()
		position += (player.position - position) / speed
		animated_sprite.play("Walk")
		move_and_collide(Vector2.ZERO)
		facing_right = direction.x >0
		animated_sprite.flip_h = facing_right

func deal_with_damage():
	if player_inattack_range and Global.player_current_attack == true:
		if can_take_damage == true:
			if player and player.has_method("get_attack_damage"):
				var damage_info = player.get_attack_damage()
				var damage_taken = damage_info["damage"]
				var is_critical = damage_info["is_critical"]
				print("Player dealt damage: ", damage_taken)
				health_component.take_damage(damage_taken)
				DamageNumbers.display_number(damage_taken, damage_numbers_origin.global_position, is_critical)
				$take_damage_cd.start()
				can_take_damage = false
				if health_component.get_current_health() <= 0:
					die()
				else:
					play_hurt_animation()

func play_hurt_animation():
	is_hurt = true
	animated_sprite.play("hurt")
	animated_sprite.flip_h = facing_right

func die():
	if is_dying:
		print("Already dying, skipping")
		return
	is_dying = true
	print("Nightborne die() function called")
	is_attacking = false
	is_hurt = false
	player_chasing = false
	
	set_physics_process(false)  
	set_process(false)
	print("Processes stopped")
	
	if animated_sprite.sprite_frames.has_animation("death"):
		animated_sprite.play("death")
		print("Death animation started")
		await animated_sprite.animation_finished
		print("Death animation finished naturally")
	else:
		print("Error: Death animation not found")
		await get_tree().create_timer(0.1).timeout
		
	

	PlayerStats.gain_xp(xp_value)
	
	var roll = randf()
	var cumulative_chance = 0.0
	
	for drop_item in drop_items:
		cumulative_chance += drop_item.drop_chance
		if roll <= cumulative_chance:
			var item_instance = drop_item.item_scene.instantiate()
			if item_instance:
				if item_drop_position != Vector2.ZERO:
					item_instance.global_position = item_drop_position
				else:
					item_instance.global_position = global_position
				get_parent().add_child(item_instance)
			break  
	

	queue_free()
	print("Nightborne queued for deletion")
	
func attack():
	if can_attack and not is_attacking:
		is_attacking = true
		can_attack = false
		animated_sprite.play("attack")
		animated_sprite.flip_h = facing_right
		attack_timer.start()

func _on_animation_finished():
	if animated_sprite.animation == "attack":
		is_attacking = false
		if player_inattack_range and player:
			var damage_info = {"damage": damage_component.damage_amount, "is_critical": false}
			player.health_component.take_damage(damage_info["damage"])
	
	if animated_sprite.animation in ["attack", "hurt"]:
		resume_chase_or_idle()

func resume_chase_or_idle():
	is_attacking = false
	is_hurt = false
	if player_chasing:
		chase_player()
	else:
		animated_sprite.play("Idle")
		animated_sprite.flip_h = facing_right

func _on_attack_timer_timeout():
	can_attack = true

func _on_detection_space_body_entered(body):
	player = body
	player_chasing = true
	hitbox_component.set_process(true)
	resume_chase_or_idle()

func _on_detection_space_body_exited(body):
	player = null
	player_chasing = false
	hitbox_component.set_process(false)
	animated_sprite.play("Idle")

func _on_take_damage_cd_timeout():
	can_take_damage = true

func _on_player_attack_ended():
	Global.player_current_attack = false






