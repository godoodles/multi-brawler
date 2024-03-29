class_name Player
extends CharacterBody3D

@export var health = 10
@export var max_health = 10
@export var attack_speed:int = 1
@export var attack_range:int = 1
@export var color := Color.RED
@export var slots :Array[NodePath] = []

@onready var controller: Controller = $Controller
@onready var anim: AnimationPlayer = $AnimationPlayer

@export var movement_speed := 5.0
var movement_accel := 20.0
var movement_decel := 30.0

var last_direction := Vector2()

signal effect
signal died

@export var id := 1 :
	set(value):
		id = value
		# Give authority over the player input to the appropriate peer.
		$Controller/PlayerInput.set_multiplayer_authority(id)

@onready var input = $Controller/PlayerInput
@onready var hit_cooldown = $HitCooldown

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
	position = Vector3(randf_range(-5, 5), 0.0, randf_range(-5, 5))
	
	if id == multiplayer.get_unique_id():
		$PlayerColor.hide()
	%HealthLabel.text = str(health)

	equip(preload("res://entities/abilities/slash.tscn").instantiate())
	equip(preload("res://entities/abilities/slash.tscn").instantiate())
	equip(preload("res://entities/abilities/hands/hand_of_normality.tscn").instantiate())
	equip(preload("res://entities/abilities/hands/hand_of_normality.tscn").instantiate())
	equip(preload("res://entities/abilities/legs/fast_legs.tscn").instantiate())
	equip(preload("res://entities/abilities/legs/fast_legs.tscn").instantiate())
	equip(preload("res://entities/abilities/heads/head_of_normality.tscn").instantiate())
	equip(preload("res://entities/abilities/bodies/body_of_normality.tscn").instantiate())

	# Adds itself to the tracked objects for revealing the shadow
	_e.shadow_add_dynamic_revealer.emit(self, 8.0)

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

	if id == multiplayer.get_unique_id():
		process_movement(delta)
	
		# Gravity
		velocity_v -= 30.0 * delta
	
	#if id == multiplayer.get_unique_id():
	move_and_slide()

	control_animation()

func control_animation():
	var anim_play = "idle" if velocity_h.length() <= 1.0 else "run"
	if anim.current_animation != anim_play:
		anim.play(anim_play)
	if not is_zero_approx(velocity_h.x):
		$Body.scale.x = 1 if sign(velocity_h.x) == -1 else -1

func process_movement(delta, speed := -1.0, accel := -1.0, decel := -1.0):
	if speed == -1.0: speed = movement_speed
	if accel == -1.0: accel = movement_accel
	if decel == -1.0: decel = movement_decel
	var target_velocity_h := controller.get_direction() * speed
	var weight := accel if target_velocity_h.length() > 0.5 else decel
	velocity_h = lerp(velocity_h, target_velocity_h, weight * delta)

func hit(from, _server_global_position:Vector3 = global_position):
	if hit_cooldown.time_left > 0:
		return

	hit_cooldown.start(0.5)

	health -= from.damage

	ImpactText.popin(self, str(-from.damage), Color.RED, 1.0)

	if id == multiplayer.get_unique_id():
		$HitMeter.hit()
		
	if health <= 0:
		died.emit()
