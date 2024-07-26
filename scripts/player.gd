extends CharacterBody2D

class_name Player

signal attack_ended

@export var inv : Inv
@export var speed: int = 100
@onready var health_component: HealthComponent = $HealthComponent
@onready var hitbox_component: HitboxComponent = $hitboxComponent
@onready var damage_component: DamageComponent = $DamageComponent
@onready var sword_slash = $Sword_slash
@onready var death_sfx = $Death_sfx
@onready var xp_progress_bar = %ProgressBar
@onready var level_label =  %label
var sword_slash_on_cooldown = false

var respawn_position: Vector2
var player_alive = true

var attack_ip = false
var current_dir = 'none'

var input = Vector2.ZERO

var _level: int = 1

var speed_boosted = false
var speed_boost_amount = 0
var speed_boost_duration = 0
var speed_boost_timer: Timer
var base_speed: int = 100
const GROWTH_RATE: float = 1.2


var regeneration_boosted = false
var regeneration_boost_amount = 0
var regeneration_boost_duration = 0
var regeneration_boost_timer: Timer 

var permanent_hp_increase: int = 0
var permanent_speed_increase: int = 0

func _ready():
	base_speed = speed
	speed_boost_timer = Timer.new()
	add_child(speed_boost_timer)
	speed_boost_timer.one_shot = true
	speed_boost_timer.timeout.connect(_on_speed_boost_timer_timeout)
	
	regeneration_boost_timer = Timer.new()
	add_child(regeneration_boost_timer)
	regeneration_boost_timer.one_shot = true
	regeneration_boost_timer.timeout.connect(_on_regeneration_boost_timer_timeout)
	
	if inv == null:
		inv = load("res://inventory/playerinv.tres").duplicate()
	health_component.max_health = Global.player_max_health
	health_component.heal_to_max()
	PlayerStats.player_leveled_up.connect(_on_player_leveled_up)
	print(PlayerStats.XP_Table_Data)
	$AnimatedSprite2D.play('Front_idle')
	respawn_position = position
	xp_progress_bar.max_value = PlayerStats.get_max_xp_at(PlayerStats.level)
	xp_progress_bar.value = PlayerStats.current_xp
	set_level(PlayerStats.level)
	level_label.text = str(PlayerStats.level)
	damage_component.set_damage_by_level(_level, GROWTH_RATE)
	set_player_damage(_level)
	add_to_group("player")
	health_component.connect("max_health_changed", Callable(self, "_on_max_health_changed"))
	print("Initial damage amount for level ", _level, " is: ", damage_component.damage_amount)
	$hp_bar.max_value = health_component.max_health
	connect_attack_signal_to_enemies()
	
func _physics_process(delta):
	if health_component.has_method("get_current_health") and health_component.get_current_health() <= 0 and player_alive:
		player_alive = false
		velocity = Vector2.ZERO
		if health_component.has_method("set_current_health"):
			health_component.set_current_health(0)
		print("player has been slain")
		death_sfx.play()
		$AnimatedSprite2D.play("Death")
		game_over()
		
	if player_alive:
		player_movement(delta)
		enemy_attack()
		attack()
		current_camera()
		update_health()
		xp_progress_bar.value = PlayerStats.current_xp
		check_level_up()

func check_level_up():
	if PlayerStats.current_xp >= PlayerStats.get_max_xp_at(PlayerStats.level):
		PlayerStats.current_xp = 0
		PlayerStats.level += 1
		level = PlayerStats.level
		print("Player leveled up to level ", level)
		xp_progress_bar.max_value = PlayerStats.get_max_xp_at(PlayerStats.level)
		set_level(level)

func get_input():
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("ui_right"):
		input_vector.x += 1
	if Input.is_action_pressed("ui_left"):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_down"):
		input_vector.y += 1
	if Input.is_action_pressed("ui_up"):
		input_vector.y -= 1
	return input_vector.normalized()
	
func player_movement(delta):
	input = get_input()
	if not player_alive:
		velocity = Vector2.ZERO
		return
		
	if input == Vector2.ZERO:
		velocity = Vector2.ZERO
	else:
		velocity =input.normalized()*speed
	move_and_slide()

	if input != Vector2.ZERO:
		if input.x > 0:
			current_dir = "right"
		elif input.x < 0:
			current_dir = "left"
		elif input.y > 0:
			current_dir = "down"
		elif input.y < 0:
			current_dir = "up"
		play_anim(1)
	else:
		play_anim(0)


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
		var enemy = hitbox_component.get_overlapping_bodies().filter(func(body): return body.has_method('enemy'))[0]
		if enemy:
			health_component.take_damage(enemy.get_damage())
		hitbox_component.enemy_attack_cd = false
		$attack_cd.start()

func _on_attack_cd_timeout():
	hitbox_component.enemy_attack_cd = true

func attack():
	var dir = current_dir

	if Input.is_action_just_pressed("attack"):
		Global.player_current_attack = true
		attack_ip = true
		if dir == "right":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("Side_attack")
			if not sword_slash_on_cooldown:
				sword_slash.play()
				sword_slash_on_cooldown = true
				$sword_slash_timer.start()
			$deal_attack_timer.start()
		if dir == "left":
			$AnimatedSprite2D.flip_h = false
			$AnimatedSprite2D.play("Side_attack")
			if not sword_slash_on_cooldown:
				sword_slash.play()
				sword_slash_on_cooldown = true
				$sword_slash_timer.start()
			$deal_attack_timer.start()
		if dir == "down":
			$AnimatedSprite2D.play("Front_attack")
			if not sword_slash_on_cooldown:
				sword_slash.play()
				sword_slash_on_cooldown = true
				$sword_slash_timer.start()
			$deal_attack_timer.start()
		if dir == "up":
			$AnimatedSprite2D.play("Back_attack")
			if not sword_slash_on_cooldown:
				sword_slash.play()
				sword_slash_on_cooldown = true
				$sword_slash_timer.start()
			$deal_attack_timer.start()

func _on_deal_attack_timer_timeout():
	$deal_attack_timer.stop()
	Global.player_current_attack = false
	attack_ip = false
	emit_signal("attack_ended")

func _on_sword_slash_timer_timeout():
	sword_slash_on_cooldown = false

func connect_attack_signal_to_enemies():
	var enemies = get_tree().get_nodes_in_group("enemies")
	for enemy in enemies:
		if enemy.has_method("_on_player_attack_ended"):
			connect("attack_ended", Callable(enemy, "_on_player_attack_ended"))


func current_camera():
	if Global.current_scene == "world":
		$world_camera.enabled = true
		$cliff_side_camera.enabled = false
		$Grass_to_snow_camera.enabled = false
	elif Global.current_scene == "cliff_side":
		$world_camera.enabled = false
		$cliff_side_camera.enabled = true
		$Grass_to_snow_camera.enabled = false
	elif Global.current_scene == "grass_to_snow":
		$world_camera.enabled = false
		$cliff_side_camera.enabled = false
		$Grass_to_snow_camera.enabled = true


func _on_max_health_changed(new_max_health):
	$hp_bar.max_value = new_max_health
	update_health()

func update_health():
	var healthbar = $hp_bar
	healthbar.max_value = Global.player_max_health
	healthbar.value = health_component.current_health

	if health_component.current_health >= health_component.max_health:
		healthbar.visible = false
	else:
		healthbar.visible = true

func _on_regen_timer_timeout():
	if health_component.current_health < health_component.max_health && health_component.current_health > 0 :
		var regen_rate = health_component.regeneration_rate
		if regeneration_boosted:
			regen_rate += regeneration_boost_amount
		health_component.current_health += regen_rate
		if health_component.current_health > health_component.max_health:
			health_component.current_health = health_component.max_health
	if health_component.current_health <= 0:
		health_component.current_health = 0

func game_over():
	Global.game_over = true
	await get_tree().create_timer(1).timeout
	get_tree().change_scene_to_file("res://UI/game_over.tscn")
	reset_game()
	
func respawn():
	position = respawn_position
	health_component.heal_to_max()
	player_alive = true

func set_level(value:int) -> void:
	_level = value
	level_label.text = str(value)
	damage_component.set_damage_by_level(_level, GROWTH_RATE)
	
func get_level() -> int:
	return _level

var level: int = _level:
	set(value):
		set_level(value)

func _on_player_leveled_up(new_level):
	set_level(new_level)
	set_player_damage(new_level)
	Global.set_player_level(new_level)


func set_player_damage(level:int) -> void:
	var new_damage = damage_component.set_damage_by_level(level, GROWTH_RATE)
	print("Player damage updated to: ", damage_component.damage_amount)

func get_attack_damage():
	return damage_component.deal_damage()


func collect(item):
	inv.insert(item)

func use_item(slot_index: int):
	var slot = inv.slots[slot_index]
	if slot and slot.item:
		if slot.item.is_stone:
			if slot.item.permanent_hp_increase > 0:
				Global.player_max_health += slot.item.permanent_hp_increase
				health_component.increase_max_health(slot.item.permanent_hp_increase)
				health_component.current_health += slot.item.permanent_hp_increase
				print("Max health increased to: ", health_component.max_health)
				update_health()
			if slot.item.permanent_speed_increase > 0:
				permanent_speed_increase += slot.item.permanent_speed_increase
				base_speed += slot.item.permanent_speed_increase
				speed = base_speed
		elif slot.item.healing_amount > 0:
			health_component.current_health += slot.item.healing_amount
			if health_component.current_health > health_component.max_health:
				health_component.current_health = health_component.max_health
		elif slot.item.speed_increase > 0:
			apply_speed_boost(slot.item.speed_increase, slot.item.effect_duration)
		elif slot.item.regen_increase > 0:
			apply_regeneration_boost(slot.item.regen_increase, slot.item.effect_duration)
		
		slot.amount -= 1
		if slot.amount <= 0:
			slot.item = null
		inv.update.emit()
		
func _input(event):
	for i in range(4):
		if event.is_action_pressed("use_item_" + str(i + 1)): 
			if inv.slots.size() > 0:
				use_item(i)

func apply_speed_boost(amount: int, duration: float):
	speed_boost_amount = amount
	speed_boost_duration = duration
	speed = base_speed + speed_boost_amount
	speed_boosted = true
	speed_boost_timer.start(duration)

func _on_speed_boost_timer_timeout():
	speed = base_speed
	speed_boosted = false
	speed_boost_amount = 0
	speed_boost_duration = 0

func apply_regeneration_boost(amount: int, duration: float):
	regeneration_boost_amount = amount
	regeneration_boost_duration = duration
	health_component.regeneration_rate += regeneration_boost_amount
	regeneration_boosted = true
	regeneration_boost_timer.start(duration)

func _on_regeneration_boost_timer_timeout():
	health_component.regeneration_rate -= regeneration_boost_amount
	regeneration_boosted = false
	regeneration_boost_amount = 0
	regeneration_boost_duration = 0

func reset_game():
	Global.reset_game_state(inv)
	health_component.max_health = Global.player_max_health
	health_component.heal_to_max()
