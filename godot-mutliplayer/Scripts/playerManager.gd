extends Node3D

const PLAYER = preload("res://Scenes/player.tscn")

var players = {}

var myPlayerID = ""

func spawnPlayer(id: String, spawnPosition: Vector3):
	if players.has(id):
		return

	var player = PLAYER.instantiate()
	player.name = id
	
	player.isLocalPlayer = (id == myPlayerID)
	
	add_child(player)
	player.position = spawnPosition
	
	players[id] = player

func removePlayer(id: String):
	if players.has(id):
		players[id].queue_free()
		players.erase(id)
		
