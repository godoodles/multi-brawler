class_name Player
extends CharacterBody3D

@onready var controller: Controller = $Controller
@onready var body = %Body
@onready var hands = %Hands
@onready var legs = %Legs
@onready var head = %Head

var attacks := []
var ability_dodge
var ability_special

var movement_speed := 6.0
var movement_accel := 10.0
var movement_decel := 20.0

var active_ability: Ability

var last_direction := Vector2()

@export var id := 1 :
	set(value):
		id = value
		# Give authority over the player input to the appropriate peer.
		$Controller/PlayerInput.set_multiplayer_authority(id)

@onready var input = $Controller/PlayerInput

var position_h: Vector2:
	get:
		return Vector2(position.x, position.z)
	set(value):
		position.x = value.x
		position.z = value.y

var position_v: float:
	get:
		return position.y
	set(value):
		position.y = value

var velocity_h: Vector2:
	get:
		return Vector2(velocity.x, velocity.z)
	set(value):
		velocity.x = value.x
		velocity.z = value.y

var velocity_v: float:
	get:
		return velocity.y
	set(value):
		velocity.y = value

func _ready() -> void:
	equip_attack(load("res://player/ability_attack_slash.gd").new())
	equip_attack(load("res://player/ability_attack_slash.gd").new())
	equip_attack(load("res://player/ability_attack_slash.gd").new())
	equip_attack(load("res://player/ability_attack_slash.gd").new())
	
	set_ability_special(load("res://player/ability_special_explosion.gd").new())
	set_ability_dodge(load("res://player/ability_dodge_dash.gd").new())
#	set_ability_dodge(load("res://player/ability_dodge_jump.gd").new())

func equip_attack(attack):
	attacks.push_back(attack)
	attack.player = self
	hands.add_child(attack)

func set_ability_dodge(ability):
	ability_dodge = ability
	ability_dodge.player = self
	legs.add_child(ability)

func set_ability_special(ability):
	ability_special = ability
	ability_special.player = self
	head.add_child(ability)

func _physics_process(delta):
	var controller_direction = controller.get_direction()
	if controller_direction != Vector2.ZERO:
		last_direction = controller_direction
	
	if active_ability:
		active_ability.process_active(delta)
	else:
		# Using "since_pressed()" so abilities will activate if you press them a bit before another ability is finished
		for attack in attacks:
			attack.process_active(delta)
		if ability_dodge and ability_dodge.allow_use() and controller.dodge.since_pressd() < 0.2:
			activate_ability(ability_dodge)
			controller.dodge.consume()
		
		if ability_special and ability_special.allow_use() and controller.special.since_pressd() < 0.2:
			activate_ability(ability_special)
			controller.special.consume()
		
		process_movement(delta)
	
	# Gravity
	velocity_v -= 30.0 * delta
	
	move_and_slide()

func activate_ability(ability):
	active_ability = ability
	ability.activate()

func on_ability_complete(ability):
	active_ability = null

func process_movement(delta, speed := -1.0, accel := -1.0, decel := -1.0):
	if speed == -1.0: speed = movement_speed
	if accel == -1.0: accel = movement_accel
	if decel == -1.0: decel = movement_decel
	var target_velocity_h := controller.get_direction() * speed
	var weight := accel if target_velocity_h.length() > 0.5 else decel
	velocity_h = lerp(velocity_h, target_velocity_h, weight * delta)
