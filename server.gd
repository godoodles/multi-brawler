# multiplayer.gd
extends Node

const PORT = 4433

var delta_sum := 0.0

func _ready():
	# Start paused.
	get_tree().paused = false
	# You can save bandwidth by disabling server relay and peer notifications.
	multiplayer.server_relay = false
	
	set_process(false)

	# Automatically start the server in headless mode.
	#if DisplayServer.get_name() == "headless":
	#	print("Automatically starting dedicated server.")
	#	_on_host_pressed.call_deferred()

func start_game():
	get_tree().paused = false
	set_process(true)

func _connect_pressed():
	# Start as client.
	var txt : String = "127.0.0.1"
	if txt == "":
		OS.alert("Need a remote to connect to.")
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(txt, PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer client.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

func _host_buttom_pressed():
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(PORT)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		OS.alert("Failed to start multiplayer server.")
		return
	multiplayer.multiplayer_peer = peer
	start_game()

	# We only need to spawn players on the server.
	if not multiplayer.is_server():
		return

	multiplayer.peer_connected.connect(add_player)
	multiplayer.peer_disconnected.connect(del_player)

	# Spawn already connected players
	for id in multiplayer.get_peers():
		add_player(id)

	# Spawn the local player unless this is a dedicated server export.
	if not OS.has_feature("dedicated_server"):
		add_player(1)
		
	$mob_button.disabled = false
	$mob_100_button.disabled = false

func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.peer_connected.disconnect(add_player)
	multiplayer.peer_disconnected.disconnect(del_player)

func add_player(id: int):
	var player = preload("res://player.tscn").instantiate()
	# Set player id.
	player.id = id

	# Randomize player position.
	player.position = Vector3(randf_range(-5, 5), 0.0, randf_range(-5, 5))
	player.name = str(id)
	$entities.add_child(player, true)

func del_player(id: int):
	if not $entities.has_node(str(id)):
		return
	$entities.get_node(str(id)).queue_free()

func _mob_button_pressed():
	spawn_mob()

func _on_mob_100_button_pressed() -> void:
	for i in 100:
		spawn_mob()

func spawn_mob():
	var mob = preload("res://mobs/kevin.tscn").instantiate()
	mob.position = Vector3(randf_range(-10, 10), 0.0, randf_range(-10, 10))
	mob.target = $entities.get_child(0)
	$entities.add_child(mob, true)
