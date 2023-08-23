extends RefCounted

class_name Session

var player_ids: Array[int]

var turn: int = 0
var channel: int
var restart_request_outcomes: = {}

const MAX_PLAYERS: int = 2

func advance_turn():
	turn += 1

func add_restart_request_outcome(player_id: int, agreed: bool):
	restart_request_outcomes[player_id] = agreed

func restart_allowed() -> bool:
	var all_voted: = restart_request_outcomes.size() == MAX_PLAYERS
	var all_in_agreement: = restart_request_outcomes.values().all(func(x): return x)

	return all_voted and all_in_agreement

func restart():
	restart_request_outcomes.clear()
	turn = 0

func add_player_id(player_id: int):
	if player_ids.size() < MAX_PLAYERS:
		player_ids.append(player_id)
	else:
		printerr("Session: max player count has been reached")

func has_player_id(player_id: int):
	return player_ids.has(player_id)

func rpc_excluding(target_player_id: int, callable: Callable, arg1=null, arg2=null):
	for player_id in player_ids:
		if player_id != target_player_id:
			rpc_id(player_id, callable, arg1, arg2)

func rpc_id(player_id: int, callable: Callable, arg1=null, arg2=null):
	#	TODO: Fix errors / hackiness
	#	callable = callable.bindv(args) # (in Godot 4.2)

	if arg1 == null:
		callable.rpc_id(player_id)
	elif arg2 == null:
		callable.rpc_id(player_id, arg1)
	else:
		callable.rpc_id(player_id, arg1, arg2)

func rpc(callable: Callable, arg1=null, arg2=null):
	for player_id in player_ids:
		rpc_id(player_id, callable, arg1, arg2)

func _to_string() -> String:
	return "Session(%s, %s, %s)" % ([turn] + player_ids)
