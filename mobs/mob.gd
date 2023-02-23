extends Node3D

var target:Node3D

func _process(delta:float) -> void:
	if target:
		position = position.move_toward(target.position, delta)
