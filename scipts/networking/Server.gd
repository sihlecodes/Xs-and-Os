extends Node

class_name Server

var pending_player_ids: Array[int] = [] # lobby
var sessions: Array[Session] = []

# TODO: move board checking logic here

func get_player_session() -> Session:
	var player_id: = multiplayer.get_remote_sender_id()

	for session in sessions:
		if session.has_player_id(player_id):
			return session
	return

@rpc("any_peer")
func request_update_display():
	var session: Session = get_player_session()

	var current_player_type: = session.get_current_player_type()
	session.rpc(%Client.show_current_player, current_player_type)

@rpc("any_peer")
func request_turn():
	var player_id: = multiplayer.get_remote_sender_id()
	var session: Session = get_player_session()

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

	if session.has_active_restart_request(player_id):
		return # prevent further requests until everyone has voted

	session.add_restart_request_outcome(player_id, true)

	if session.restart_allowed():
		session.rpc(%Client.restart)
		session.restart()

	elif session.restart_all_voted():
		session.clear_restart_requests()

	else:
		session.rpc_excluding(player_id, %Client.show_restart_confirmation)

@rpc("any_peer")
func request_restart_cancel():
	var session: Session = get_player_session()

	session.add_restart_request_outcome(multiplayer.get_remote_sender_id(), false)

	if session.restart_all_voted() and not session.restart_all_in_agreement():
		session.clear_restart_requests()

@rpc("any_peer")
func request_turn_advance():
	var session: Session = get_player_session()

	session.advance_turn()
	print(session)

func _get_players_per_session():
	return min(Piece.get_playable_count(), Session.MAX_PLAYERS)

func _create_session(player_ids: Array[int]):
	var session: = Session.new()
	var types: = Piece.get_playable_types()

	for i in range(_get_players_per_session()):
		var player_id: int = player_ids.pop_back()
		var type: int = types.pop_at(randi() % types.size())

		session.add_player(player_id, type)
		%Client.set_player_type.rpc_id(player_id, type)

	sessions.append(session)
	session.rpc(%Client.restart)

func _on_player_connected(player_id: int):
	pending_player_ids.append(player_id)
	print("Player ", player_id, " has connected.")

	if pending_player_ids.size() >= _get_players_per_session():
		_create_session(pending_player_ids)

func _on_player_disconnected(player_id: int):
	# TODO: Implement some logic to delete sessions
	print("Player ", player_id, " disconnected.")
