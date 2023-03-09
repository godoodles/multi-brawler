# multiplayer.gd
extends Node

const GameWorld := preload("res://game_world.tscn")

var server := "127.0.0.1"
var port = 4434 if OS.get_environment("GODOT_PORT").is_empty() else int(OS.get_environment("GODOT_PORT"))
var delta_sum := 0.0

@onready var game_viewport := $MainGameViewportContainer/MainGameViewport

func _ready():
	print(Version.checksum)
	
	_e.game_host.connect(start_as_server)
	_e.game_connect.connect(start_as_client)
	
	# Start paused.
	get_tree().paused = true
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
	else:
		start_as_client()
		get_window().position = Vector2i(get_window().size.x, 100)


func start_game():
	for g in game_viewport.get_children():
		g.queue_free()
	
	print("Adding world")
	var new_game := GameWorld.instantiate()
	game_viewport.add_child(new_game)
	get_tree().paused = false
	set_process(true)


func start_as_server() -> bool:
	print("Start as Server")
	get_window().title = "Brawler - SERVER"
	# Start as server.
	var peer = ENetMultiplayerPeer.new()
	peer.create_server(port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return false
	
	multiplayer.multiplayer_peer = peer
	start_game()
	
	return true


func start_as_client():
	print("Start as Client")
	get_window().title = "Brawler - CLIENT"
	# Start as client.
	if server == "":
		return
	var peer = ENetMultiplayerPeer.new()
	peer.create_client(server, port)
	if peer.get_connection_status() == MultiplayerPeer.CONNECTION_DISCONNECTED:
		return
	
	multiplayer.multiplayer_peer = peer
	start_game()


func _exit_tree():
	if not multiplayer.is_server():
		return
	multiplayer.multiplayer_peer = null
