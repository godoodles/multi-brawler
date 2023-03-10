class_name Mob
extends Node3D

var target:Node3D

@export var health := 1
@export var speed := 1.0
@export var attack_speed:int = 1
@export var attack_range:int = 1

signal effect

var hit_tween:Tween

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

func _ready() -> void:
	for child in $Slot.get_children():
		child.player = self

func _physics_process(delta:float) -> void:
	if target:
		position = position.move_toward(target.position, delta * speed)

@rpc("call_local")
func hit(from, server_global_position:Vector3 = global_position):
	position = server_global_position
	health -= from.damage
	flash()
	knock_back(from.velocity.normalized() * from.knockback)

func flash(_duration := 0.1):
	$Sprite3D.modulate = Color.CORAL


func knock_back(force:Vector3) -> void:
	if hit_tween:
		hit_tween.kill()
		
	force.y = 0.0
	
	if health <= 0:
		force *= 2.0

	hit_tween = create_tween().bind_node(self)
	hit_tween.set_parallel(true)
	hit_tween.tween_property(self, "position", position + force, 0.15)
	hit_tween.tween_property($Sprite3D, "modulate", Color.WHITE, 0.15)
	set_process_and_slots_process(false)

	if health > 0:
		hit_tween.finished.connect(set_process_and_slots_process.bind(true))
	else:
		$Area3D.position.y -= 100
		remove_from_group("mobs")
		hit_tween.finished.connect(Callable($Sprite3D, "set_modulate").bind(Color.DIM_GRAY))


func set_process_and_slots_process(value:bool) -> void:
	set_physics_process(false)
	for child in $Slot.get_children():
		child.set_physics_process(value)
