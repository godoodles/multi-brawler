extends Node3D

const PlayerScene		:= preload("res://entities/player/player.tscn")
const EnemyKevinScene	:= preload("res://entities/enemies/kevin/enemy_kevin.tscn")

@onready var entities := $Entities

func _ready():
	if multiplayer.is_server():
		setup_as_server()
	

func setup_as_server():
	print("Setting up map on server")
	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)
	
	# Spawn already connected players
	for id in multiplayer.get_peers():
		print("spawning player:", id)
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not DisplayServer.get_name() == "headless":
		add_player(1)


func _exit_tree():
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)


func add_player(id: int):
	if multiplayer.is_server():
		print("Server:")
	prints("New peer:", id)
	var player = PlayerScene.instantiate()
	# Set player id.
	player.id = id

	# Randomize player position.
	player.position = Vector3(randf_range(-5, 5), 0.0, randf_range(-5, 5))
	player.name = str(id)
	player.effect.connect(_effect.bind())
	
	entities.add_child(player, true)


func del_player(id: int):
	prints("Peer dropped:", id)
	if not entities.has_node(str(id)):
		return
	entities.get_node(str(id)).queue_free()


func _effect(effect) -> void:
	entities.add_child(effect, true)
