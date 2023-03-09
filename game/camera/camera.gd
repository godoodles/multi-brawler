extends Node3D

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


func _process(_delta: float) -> void:
	var player
	for p in get_tree().get_nodes_in_group("players"):
		if p.id == multiplayer.get_unique_id():
			player = p
	if player:
		position_h = player.position_h
