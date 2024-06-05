class_name Enemy

extends CharacterBody2D

@onready var hitbox_component: HitboxComponent = $hitboxComponent
@onready var health_component: HealthComponent = $HealthComponent
@onready var damage_component: DamageComponent = $DamageComponent
@onready var damage_numbers_origin = $DamageNumbersOrigin

@export var speed = 40
@export var max_health = 60
@export var xp_value = 50

var player_chasing = false
var player = null
var player_inattack_range = false
var can_take_damage = true
var current_health = 0

func _ready():
	current_health = max_health

func _physics_process(delta):
	deal_with_damage()
	update_health()

	if player_chasing:
		position += (player.position - position) / speed
		$AnimatedSprite2D.play("Walk")
		move_and_collide(Vector2.ZERO)
		$AnimatedSprite2D.flip_h = player.position.x - position.x < 0
	else:
		$AnimatedSprite2D.play("Idle")

func _on_detection_space_body_entered(body):
	player = body
	player_chasing = true
	hitbox_component.set_process(true)

func _on_detection_space_body_exited(body):
	player = null
	player_chasing = false
	hitbox_component.set_process(false)

func enemy():
	pass

func _on_hitbox_component_body_entered(body):
	if body.has_method('player'):
		player_inattack_range = true


func _on_hitbox_component_body_exited(body):
	if body.has_method('player'):
		player_inattack_range = false


func deal_with_damage():
	if player_inattack_range and Global.player_current_attack == true:
		if can_take_damage == true:
			var damage_info = damage_component.deal_damage(self)
			var damage_taken = damage_info["damage"]
			var is_critical = damage_info["is_critical"]
			current_health -= damage_taken
			DamageNumbers.display_number(damage_taken, damage_numbers_origin.global_position,is_critical)
			$take_damage_cd.start()
			can_take_damage = false
			if current_health <= 0:
				die()
				
func die():
	PlayerStats.gain_xp(xp_value)
	queue_free()

func _on_take_damage_cd_timeout():
	can_take_damage = true

func update_health():
	var healthbar = $hp_bar
	healthbar.value = current_health
	healthbar.visible = current_health < max_health


