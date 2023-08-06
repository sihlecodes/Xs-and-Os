extends Node

const PORT = 9810
var players: = []

func _enter_tree() -> void:
	multiplayer.connection_failed.connect(_on_connection_failed)
	multiplayer.connected_to_server.connect(_on_connection_success)

	if "--server" in OS.get_cmdline_args():
		start_networking(true)
	else:
		start_networking(false)

func start_networking(is_server: bool):
	var peer = ENetMultiplayerPeer.new()

	if is_server:
		var error = peer.create_server(PORT, 2)

		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)

		if error != OK:
			print("Error running the server...")
		else:
			print("Server is running at port ", PORT)
	else:
		peer.create_client("localhost", PORT)

	multiplayer.set_multiplayer_peer(peer)

func _on_connection_success():
	print("Connection was successful")

func _on_connection_failed():
	print("Connection error")

func _on_player_connected(id: int):
	players.append(id)
	print("Player ", id, " has connected.")

	if players.size() == 2:
		%Game.start_game()

func _on_player_disconnected(id: int):
	players.erase(id)
	print("Player ", id, " disconnected.")
