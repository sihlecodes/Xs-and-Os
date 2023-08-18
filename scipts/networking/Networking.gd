extends Node

const PORT = 9810

func _enter_tree() -> void:
	multiplayer.connection_failed.connect($Client._on_connection_failed)
	multiplayer.connected_to_server.connect($Client._on_connection_success)

	var peer: = ENetMultiplayerPeer.new()

	if "--server" in OS.get_cmdline_args():
		create_server(peer)
	else:
		create_client(peer)

	multiplayer.multiplayer_peer = peer

func create_server(peer: ENetMultiplayerPeer):
	var error = peer.create_server(PORT)

	multiplayer.peer_connected.connect(%Server._on_player_connected)
	multiplayer.peer_disconnected.connect(%Server._on_player_disconnected)

	if error != OK:
		print("Error running the server...")
	else:
		print("Server is running at port ", PORT)

func create_client(peer: ENetMultiplayerPeer):
	peer.create_client("localhost", PORT)
