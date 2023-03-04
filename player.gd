class_name Player
extends CharacterBody3D

@export var health = 10
@export var max_health = 10
@export var attack_speed:int = 1
@export var attack_range:int = 1

@export var slots :Array[NodePath] = []

@onready var controller: Controller = $Controller

@export var movement_speed := 6.0
var movement_accel := 10.0
var movement_decel := 20.0


var last_direction := Vector2()

signal effect

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
	$Sprite3D/Health.text = str(health)
	#equip_attack(preload("res://player/abilities/projectile.tscn").instantiate())
	equip(preload("res://player/abilities/slash.tscn").instantiate())
	equip(preload("res://player/abilities/hand_of_metal.tscn").instantiate())
	equip(preload("res://player/abilities/hand_of_metal.tscn").instantiate())
	equip(preload("res://player/abilities/projectile.tscn").instantiate())
	equip(preload("res://player/abilities/metal_foot.tscn").instantiate())
	#equip_attack(preload("res://player/abilities/slash.tscn").instantiate())

	#set_ability_special(load("res://player/ability_special_explosion.gd").new())
	#set_ability_dodge(load("res://player/ability_dodge_dash.gd").new())
#	set_ability_dodge(load("res://player/ability_dodge_jump.gd").new())

func equip(ability) -> void:
	ability.player = self
	for slot_path in slots:
		var slot := get_node(slot_path)
		if slot.try_add(ability):
			break

func _physics_process(delta):
	var controller_direction = controller.get_direction()
	if controller_direction != Vector2.ZERO:
		last_direction = controller_direction

	process_movement(delta)
	
	# Gravity
	velocity_v -= 30.0 * delta
	
	move_and_slide()

func process_movement(delta, speed := -1.0, accel := -1.0, decel := -1.0):
	if speed == -1.0: speed = movement_speed
	if accel == -1.0: accel = movement_accel
	if decel == -1.0: decel = movement_decel
	var target_velocity_h := controller.get_direction() * speed
	var weight := accel if target_velocity_h.length() > 0.5 else decel
	velocity_h = lerp(velocity_h, target_velocity_h, weight * delta)

@rpc("call_local")
func hit(from, server_global_position:Vector3 = global_position):
	health -= from.damage
	$Sprite3D/Health.text = str(health)
