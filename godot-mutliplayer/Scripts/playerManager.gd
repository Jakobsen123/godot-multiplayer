extends Node3D

const PLAYER = preload("res://Scenes/player.tscn")

var players = {}

var myPlayerID = "Jakob"

func spawnPlayer(id: String, spawnPosition: Vector3, rotation: float):
	if players.has(id):
		return

	var player = PLAYER.instantiate()
	player.name = id
	
	player.isLocalPlayer = (id == myPlayerID)
	
	add_child(player)
	player.position = spawnPosition
	player.rotation.y = rotation
	
	players[id] = player

func updatePlayer(id: String, newPosition: Vector3, rotation: float):

	if not players.has(id):
		spawnPlayer(id, newPosition, rotation)

	var player = players[id]

	if not player.isLocalPlayer:
		player.targetPos = newPosition

func removePlayer(id: String):
	if players.has(id):
		players[id].queue_free()
		players.erase(id)
		
