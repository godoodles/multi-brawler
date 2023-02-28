# multiplayer.gd
extends Node

var server := "20.81.125.206"
var port = 4433 if OS.get_environment("GODOT_PORT").is_empty() else int(OS.get_environment("GODOT_PORT"))

var delta_sum := 0.0

func _ready():
	print(Version.checksum)
	
	get_tree().paused = false
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false

	set_process(false)
	
	if DisplayServer.get_name() == "headless":
		print("Starting dedicated server...")
		_host_buttom_pressed()
	#else:
	#	test()


func test() -> void:
	seed(5)
	
	if _host_buttom_pressed():
		get_window().position = Vector2i(0, 100)
		for i in 2:
			spawn_mob()
	else:
		_connect_pressed()
		get_window().position = Vector2i(get_window().size.x, 100)

func start_game():
	get_tree().paused = false
	set_process(true)

func _connect_pressed():
	# Start as client.
	if server == "":
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _host_buttom_pressed() -> bool:
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
	var player = preload("res://player.tscn").instantiate()
	# Set player id.
	player.id = id

	# Randomize player position.
	player.position = Vector3(randf_range(-5, 5), 0.0, randf_range(-5, 5))
	player.name = str(id)
	player.connect("attack", Callable(self, "_attack"))
	
	$entities.add_child(player, true)

func del_player(id: int):
	if not $entities.has_node(str(id)):
		return
	$entities.get_node(str(id)).queue_free()

func _attack(attack) -> void:
	$entities.add_child(attack, true)

func _mob_button_pressed():
	spawn_mob.rpc_id(1)

func _on_mob_100_button_pressed() -> void:
	for i in 100:
		spawn_mob.rpc_id(1)

@rpc("any_peer", "call_local")
func spawn_mob():
	var mob = preload("res://mobs/kevin.tscn").instantiate()
	mob.position = Vector3(randf_range(-10, 10), 0.0, randf_range(-10, 10))
	mob.target = $entities.get_child(0)
	$entities.add_child(mob, true)
