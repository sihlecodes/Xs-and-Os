extends Node

const PORT = 9810

func _enter_tree() -> void:
	multiplayer.connection_failed.connect($Client._on_connection_failed)
	multiplayer.connected_to_server.connect($Client._on_connection_success)

	if "--server" in OS.get_cmdline_args():
		start_networking(true)
	else:
		start_networking(false)

func start_networking(is_server: bool):
	var peer = ENetMultiplayerPeer.new()

	if is_server:
		var error = peer.create_server(PORT)

		multiplayer.peer_connected.connect($Server._on_player_connected)
		multiplayer.peer_disconnected.connect($Server._on_player_disconnected)

		if error != OK:
			print("Error running the server...")
		else:
			print("Server is running at port ", PORT)
	else:
		peer.create_client("localhost", PORT)

	multiplayer.set_multiplayer_peer(peer)
