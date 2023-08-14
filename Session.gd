extends RefCounted

class_name Session

var player_ids: Array[int]

var turn: int = 0
var channel: int

const MAX_PLAYERS: int = 2

func add_player_id(player_id: int):
	if player_ids.size() < MAX_PLAYERS:
		player_ids.append(player_id)

func has_player_id(player_id: int):
	return player_ids.has(player_id)

func start():
	pass

func rpc(callable: Callable,  args: Array):
	for player_id in player_ids:
		callable.rpc_id(player_id, args)

func _to_string() -> String:
	return "Session(%s, %s, %s)" % ([turn] + player_ids)
