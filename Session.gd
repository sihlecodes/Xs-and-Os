extends RefCounted

var players: Array[Player]

var turns: int = 0
var channel: int

const MAX_PLAYERS: int = 2

func add_player(player: Player):
	if players.size() < MAX_PLAYERS:
		players.append(player)

func start():
	pass

func rpc(callable: Callable,  args: Array):
	for player in players:
		callable.rpc_id(player.id, args)
