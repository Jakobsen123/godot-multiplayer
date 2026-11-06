extends Node

var tcp = StreamPeerTCP.new()

const SERVER_IP = "172.20.128.28"
const SERVER_PORT = 9999

var connected = false
var send_timer = 0.0

var playerManager: Node3D

var receiveBuffer = ""


func _ready():
	playerManager = get_tree().current_scene.get_node("PlayerManager")
	
	var error = tcp.connect_to_host(SERVER_IP, SERVER_PORT)

	if error != OK:
		print("Connection error: ", error)

func receiveMessages():
	var available = tcp.get_available_bytes()
	
	if available > 0:
		var result = tcp.get_data(available)
	
		if result[0] == OK:
			receiveBuffer += result[1].get_string_from_utf8()
	
	while "\n" in receiveBuffer:
		var newlinePos = receiveBuffer.find("\n")
		var message = receiveBuffer.substr(0, newlinePos)
		
		receiveBuffer = receiveBuffer.substr(newlinePos + 1)
		
		var data = JSON.parse_string(message)
		
		if data is Dictionary:
			handle_message(data)

func _process(delta):
	tcp.poll()

	if tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:

		if not connected:
			connected = true
			print("Connected to server!")
			
		receiveMessages()

		send_timer += delta

		if send_timer >= 1.0:
			send_timer = 0.0

func send_player_data(player_name: String, player_position: Vector3, player_rotation_y: float):

	var data = {
		"type": "player_update",
		"name": player_name,
		"position": {
			"x": player_position.x,
			"y": player_position.y,
			"z": player_position.z
		},
		"rotation": player_rotation_y
	}

	var json = JSON.stringify(data)

	send_message(json)

func send_message(message: String):
	var data = (message + "\n").to_utf8_buffer()
	var error = tcp.put_data(data)

	if error != OK:
		print("Send error: ", error)
	else:
		print("Sent: ", message)

func handle_message(data: Dictionary):

	if data.get("type") == "player_update":

		var player_id = data["name"]

		var pos = data["position"]

		var player_position = Vector3(
			pos["x"],
			pos["y"],
			pos["z"]
	)
		var playerRotation = data["rotation"]

		playerManager.updatePlayer(player_id, player_position, playerRotation)
