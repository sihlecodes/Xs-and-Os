extends Node

const PORT = 9810
var players: = [] # lobby
var sessions: Array[Session] = []

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
		var error = peer.create_server(PORT)

		multiplayer.peer_connected.connect(_on_player_connected)
		multiplayer.peer_disconnected.connect(_on_player_disconnected)

		if error != OK:
			print("Error running the server...")
		else:
			print("Server is running at port ", PORT)
	else:
		peer.create_client("localhost", PORT)

	multiplayer.set_multiplayer_peer(peer)

func get_player_session(player_id: int) -> Session:
	for session in sessions:
		if session.has_player_id(player_id):
			return session
	return

@rpc("any_peer")
func poll_turn():
	var player_id: = multiplayer.get_remote_sender_id()

	# TODO: make players known session ids instead of getting sessions using player ids
	var session: Session = get_player_session(player_id)
	%Game.set_turn.rpc_id(player_id, session.turn)

@rpc("any_peer")
func request_turn_advance():
	var player_id: = multiplayer.get_remote_sender_id()
	var session: Session = get_player_session(player_id)
	# TODO: increase security by adding a handshake protocol
	session.turn += 1
	print(session)

func _on_connection_success():
	print("Connection was successful")

func _on_connection_failed():
	print("Connection error")

func _on_player_connected(player_id: int):
	players.append(player_id)
	print("Player ", player_id, " has connected.")

	if players.size() >= 2:
		# TODO: Add players to the session
		var session: = Session.new()

		session.add_player_id(players.pop_front())
		session.add_player_id(players.pop_front())

		%Game.start_game(session)

		sessions.append(session)

func _on_player_disconnected(player_id: int):
	# TODO: Implement some logic to delete sessions
	print("Player ", player_id, " disconnected.")
