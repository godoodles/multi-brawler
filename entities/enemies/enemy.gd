class_name Character
extends CharacterBody3D

@export var is_player := false
@export var max_health = 1
@onready var health = max_health
@export var attack_speed:int = 1
@export var attack_range:int = 1
@export var size := 1.0

@export var slots :Array[NodePath] = []

@onready var controller: Controller = $Controller
@onready var anim: AnimationPlayer = $AnimationPlayer

@export var movement_speed := 5.0
var movement_accel := 20.0
var movement_decel := 30.0

var target
var last_direction := Vector2()
var hit_tween

signal effect
signal died

@export var equips: Array[PackedScene] = []
#@export var equips: Array = []

@export var id := 1 :
	set(value):
		id = value
		# Give authority over the player input to the appropriate peer.
		if controller.get_child(0) and controller.get_child(0) is MultiplayerSynchronizer:
			controller.get_child(0).set_multiplayer_authority(id)

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
	if is_player and id == multiplayer.get_unique_id():
		$PlayerColor.hide()
	%HealthLabel.text = str(health)

	scale = Vector3.ONE * size
	%Head.scale = Vector3.ONE / lerp(1.0, size, 0.8)
	
	for e in equips:
		equip(e.instantiate())


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
	#velocity_v -= 30.0 * delta
	
	move_and_slide()
	control_animation()

func control_animation():
	var anim_play
	var anim_speed := 1.0
	
	if (velocity_h.length() <= 1.0 or controller.get_direction().length() < 0.1):
		anim_play = "idle"
	else:
		anim_play = "run"
		anim_speed = movement_speed / 3.5
	anim_speed /= size
	if anim.current_animation != anim_play:
		anim.play(anim_play, -1, anim_speed)
	if not is_zero_approx(velocity_h.x):
		$Body.scale.x = 1 if sign(velocity_h.x) == -1 else -1

func process_movement(delta, speed := -1.0, accel := -1.0, decel := -1.0):
	if speed == -1.0: speed = movement_speed
	if accel == -1.0: accel = movement_accel
	if decel == -1.0: decel = movement_decel
	var target_velocity_h := controller.get_direction() * speed
	var weight := accel if target_velocity_h.length() > 0.5 else decel
	velocity_h = lerp(velocity_h, target_velocity_h, weight * delta)

@rpc("call_local")
func hit(from, server_global_position:Vector3 = global_position):
	position = server_global_position
	health -= from.damage
	flash()
	knock_back(from.velocity.normalized() * from.knockback)
	
	ImpactText.popin(self, str(from.damage))

func flash(_duration := 0.1):
	pass
	#$Sprite3D.modulate = Color.CORAL

func knock_back(force:Vector3) -> void:
	if hit_tween:
		hit_tween.kill()
		
	force.y = 0.0
	
	if health <= 0:
		force *= 3.0

	hit_tween = create_tween()
	hit_tween.set_parallel(true)
	hit_tween.tween_property(self, "position", position + force, 0.15)
	#hit_tween.tween_property($Sprite3D, "modulate", Color.WHITE, 0.15)

	if health <= 0:
		died.emit()
		hit_tween.tween_property($Body, "scale", Vector3.ONE * 0.01, 0.1).set_delay(0.25)
		hit_tween.tween_property($Weapons, "scale", Vector3.ONE * 0.01, 0.1).set_delay(0.25)
		hit_tween.tween_property($ShadowDecal, "scale", Vector3.ONE * 0.01, 0.1).set_delay(0.25)
		hit_tween.tween_property($Body, "rotation:z", PI * 2.0, 0.5)
		#hit_tween.tween_property($Sprite3D, "modulate", Color.BLACK, 0.4)
	
	set_process_and_slots_process(false)

	if health > 0:
		hit_tween.finished.connect(set_process_and_slots_process.bind(true))
	else:
		$CollisionShape3D.position.y -= 100
		remove_from_group("mobs")
		if multiplayer.is_server():
			hit_tween.finished.connect(self.queue_free)

func set_process_and_slots_process(value:bool) -> void:
	set_physics_process(value)
	for slot in slots:
		get_node(slot).propagate_call("set_physics_process", [value])
