class_name Mob
extends Node3D

var target:Node3D

@export var health := 3

var flash_t := 0.0
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

func _process(delta:float) -> void:
	if target:
		position = position.move_toward(target.position, delta)
	if flash_t > 0:
		flash_t -= delta
		if flash_t <= 0:
			$Sprite3D.modulate = Color.WHITE

@rpc("call_local")
func hit(from, damage: int, velocity:Vector3):
	health -= damage
	flash()
	knock_back(velocity.normalized())

func flash(duration := 0.1):
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
	set_process(false)

	if health > 0:
		hit_tween.connect("finished", Callable(self, "set_process").bind(true))
	else:
		$Area3D.position.y -= 100
		hit_tween.connect("finished", Callable($Sprite3D, "set_modulate").bind(Color.DIM_GRAY))
