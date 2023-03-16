extends Controller

var target:Node3D

func get_direction() -> Vector2:
	var v3 = get_parent().position.direction_to(target.position)
	return Vector2(v3.x, v3.z)
