extends Node3D

const PlayerScene := preload("res://entities/player/player.tscn")

@onready var entities := $Entities

func _ready():
	if multiplayer.is_server():
		setup_as_server()
		
	for alter in get_tree().get_nodes_in_group("alters"):
		alter.connect("capture_begin", _alter_capture_begin.bind(alter))
		alter.connect("capture_end", _alter_capture_end.bind(alter))
		alter.connect("effect", _effect)

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
	player.name = str(id)
	player.effect.connect(_effect.bind())
	player.died.connect(_player_died.bind(player))
	
	entities.add_child(player, true)


func del_player(id: int):
	prints("Peer dropped:", id)
	if not entities.has_node(str(id)):
		return
	entities.get_node(str(id)).queue_free()

func _effect(effect) -> void:
	entities.add_child(effect, true)

func _player_died(player) -> void:
	var alter = get_tree().get_first_node_in_group("alters")
	if alter:
		alter = alter.find_best_alter(player.position, player.color)
		
	if alter:
		alter.extinguish_candle(player.color)
		player.health = player.max_health
		player.position = alter.position

func _alter_capture_begin(alter:Alter) -> void:
	if multiplayer.is_server():
		$Spawners.spawn_wave(66)

func _alter_capture_end(alter:Alter) -> void:
	for player in get_tree().get_nodes_in_group("players"):
		alter.light_candle(player.color)
