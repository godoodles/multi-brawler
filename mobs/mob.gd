class_name Mob
extends Node3D

var target:Node3D

var health := 50

var flash_t := 0.0

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

func hit(from, damage: int):
	health -= damage
	flash()
	if health <= 0:
		die()
		return

func die():
	queue_free()

func flash(duration := 0.1):
	flash_t = duration
	$Sprite3D.modulate = Color.CORAL
