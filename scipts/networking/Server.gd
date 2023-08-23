extends Node

class_name Server

var players: = [] # lobby
var sessions: Array[Session] = []

# TODO: move board checking logic here

func start_game(session: Session):
	var types: = [ Piece.Types.X, Piece.Types.O ]

	for player_id in session.player_ids:
		var type: int = types.pop_at(randi() % types.size())

		%Client.set_player_type.rpc_id(player_id, type)

func get_player_session() -> Session:
	var player_id: = multiplayer.get_remote_sender_id()

	for session in sessions:
		if session.has_player_id(player_id):
			return session
	return

@rpc("any_peer")
func request_turn():
	var player_id: = multiplayer.get_remote_sender_id()
	var session: Session = get_player_session()

	# TODO: make players known session ids instead of getting sessions using player ids
	%Client.set_turn.rpc_id(player_id, session.turn)

@rpc("any_peer")
func request_set_cell_type(cell: Vector2, player_type: int):
	var session: Session = get_player_session()
	session.rpc(%Client.set_cell_type, cell, player_type)

@rpc("any_peer")
func request_show_text(message: String):
	var session: Session = get_player_session()
	session.rpc(%Client.show_text, message)

@rpc("any_peer")
func request_check():
	var session: Session = get_player_session()
	session.rpc(%Client.check)

@rpc("any_peer")
func request_restart():
	var session: Session = get_player_session()

	var player_id: = multiplayer.get_remote_sender_id()
	session.add_restart_request_outcome(player_id, true)

	if session.restart_allowed():
		session.rpc(%Client.restart)
		session.restart()
	else:
		session.rpc_excluding(player_id, %Client.show_restart_confirmation)

@rpc("any_peer")
func request_restart_cancel():
	var session: Session = get_player_session()

	session.add_restart_request_outcome(multiplayer.get_remote_sender_id(), false)

@rpc("any_peer")
func request_turn_advance():
	var session: Session = get_player_session()

	session.advance_turn()
	print(session)

func _on_player_connected(player_id: int):
	players.append(player_id)
	print("Player ", player_id, " has connected.")

	if players.size() >= 2:
		var session: = Session.new()

		session.add_player_id(players.pop_front())
		session.add_player_id(players.pop_front())

		start_game(session)

		sessions.append(session)

func _on_player_disconnected(player_id: int):
	# TODO: Implement some logic to delete sessions
	print("Player ", player_id, " disconnected.")
