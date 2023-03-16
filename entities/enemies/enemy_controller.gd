extends Controller

var target:Node3D

func get_direction() -> Vector2:
	if target == null:
		return Vector2.ZERO
	var v3 = get_parent().position.direction_to(target.position)
	return Vector2(v3.x, v3.z)

@rpc("call_local")
func set_target(_target):
	target = get_tree().get_nodes_in_group("players")[_target]
