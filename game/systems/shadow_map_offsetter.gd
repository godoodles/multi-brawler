extends Node2D

@onready var shadow_map := $ShadowManager


func _process(_delta: float) -> void:
	var player
	for p in get_tree().get_nodes_in_group("players"):
		if p.id == multiplayer.get_unique_id():
			player = p
	if player:
		shadow_map.position = -Vector2(player.position.x, player.position.z) * 8
