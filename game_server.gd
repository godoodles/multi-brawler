# multiplayer.gd
extends Node

const PlayerScene		:= preload("res://entities/player/player.tscn")
const EnemyKevinScene	:= preload("res://entities/enemies/kevin/enemy_kevin.tscn")

var server := "127.0.0.1"
var port = 4434 if OS.get_environment("GODOT_PORT").is_empty() else int(OS.get_environment("GODOT_PORT"))
var delta_sum := 0.0

@onready var entities := $Entities


func _ready():
	print(Version.checksum)
	
	_e.game_host.connect(start_as_server)
	_e.game_connect.connect(start_as_client)
	_e.debug_spawn_single_mob.connect(spawn_mobs.bind(1))
	_e.debug_spawn_multi_mobs.connect(spawn_mobs)
	_e.debug_spawn_wave.connect(spawn_wave)
	
	get_tree().paused = false
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	
	set_process(false)
	
	if DisplayServer.get_name() == "headless":
		print("Starting dedicated server...")
		start_as_server()
	else:
		test()


func test() -> void:
	seed(5)
	
	if start_as_server():
		get_window().position = Vector2i(0, 100)
		for i in 0:
			spawn_mob()
	else:
		start_as_client()
		get_window().position = Vector2i(get_window().size.x, 100)


func start_game():
	get_tree().paused = false
	set_process(true)


func start_as_client():
	# Start as client.
	if server == "":
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return
	multiplayer.multiplayer_peer = peer
	start_game()


func start_as_server() -> bool:
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	multiplayer.multiplayer_peer = peer
	start_game()

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not DisplayServer.get_name() == "headless":
		add_player(1)
		
	return true


func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)
	multiplayer.multiplayer_peer = null


func add_player(id: int):
	prints("new peer", id)
	var player = PlayerScene.instantiate()
	# Set player id.
	player.id = id

	# Randomize player position.
	player.position = Vector3(randf_range(-5, 5), 0.0, randf_range(-5, 5))
	player.name = str(id)
	player.effect.connect(_effect.bind())
	
	entities.add_child(player, true)


func del_player(id: int):
	if not $entities.has_node(str(id)):
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
