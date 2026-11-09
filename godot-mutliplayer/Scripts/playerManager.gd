extends Node3D

const PLAYER = preload("res://Scenes/player.tscn")

var players = {}
var myPlayerID = Global.playerUsername

func _ready():
	Network.playerManager = self

func spawnPlayer(id: String, username: String, spawnPosition: Vector3, newRotation: float):
	if players.has(id):
		return

	var player = PLAYER.instantiate()
	player.name = id
	player.isLocalPlayer = (id == myPlayerID)
	
	player.get_node("Label3D").text = username

	add_child(player)
	player.position = spawnPosition
	player.rotation.y = newRotation
	player.targetPos = spawnPosition
	player.targetRotation = newRotation

	players[id] = player

func updatePlayer(id: String, username:String, newPosition: Vector3, newRotation: float):
	if not players.has(id):
		spawnPlayer(id, username, newPosition, newRotation)
		return

	var player = players[id]

	if not player.isLocalPlayer:
		player.targetPos = newPosition
		player.targetRotation = newRotation

func removePlayer(id: String):
	if players.has(id):
		players[id].queue_free()
		players.erase(id)
		
