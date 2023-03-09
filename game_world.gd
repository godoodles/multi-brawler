extends Node3D

const PlayerScene		:= preload("res://entities/player/player.tscn")
const EnemyKevinScene	:= preload("res://entities/enemies/kevin/enemy_kevin.tscn")

@onready var entities := $Entities

func _ready():
	_e.debug_spawn_single_mob.connect(spawn_mobs.bind(1))
	_e.debug_spawn_multi_mobs.connect(spawn_mobs)
	_e.debug_spawn_wave.connect(spawn_wave)
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


func spawn_mobs(amount:int):
	for i in amount:
		spawn_mob.rpc_id(1)


func spawn_wave(amount:=100):
	for i in amount:
		spawn_mob.rpc_id(1)
		await get_tree().create_timer(0.3).timeout


@rpc("any_peer", "call_local")
func spawn_mob():
	var mob = EnemyKevinScene.instantiate()
	mob.position = Vector3(randf_range(-20, 20), 0.0, randf_range(-20, 20))
	mob.target = entities.get_child(0)
	mob.effect.connect(_effect.bind())
	entities.add_child(mob, true)
