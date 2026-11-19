extends Node3D

const PLAYER = preload("res://Scenes/player.tscn")

var players = {}
var myPlayerID := ""


func _ready():
	myPlayerID = Global.playerUsername
	Network.playerManager = self


func spawnPlayer(id: String, username: String, spawnPosition: Vector3, newRotation: float, boosting: bool, t: float):
	if players.has(id):
		return

	var player = PLAYER.instantiate()
	player.name = id
	player.isLocalPlayer = (id == myPlayerID)
	player.get_node("Label3D").text = username

	add_child(player)
	player.global_position = spawnPosition
	player.rotation.y = newRotation
	player.add_snapshot(t, spawnPosition, newRotation)
	player.set_boosting(boosting)

	players[id] = player


func updatePlayer(id: String, username: String, newPosition: Vector3, newRotation: float, boosting: bool, t: float):
	if not players.has(id):
		spawnPlayer(id, username, newPosition, newRotation, boosting, t)
		return

	var player = players[id]
	if not player.isLocalPlayer:
		player.add_snapshot(t, newPosition, newRotation)
		player.set_boosting(boosting)


func removePlayer(id: String):
	if players.has(id):
		players[id].queue_free()
		players.erase(id)
