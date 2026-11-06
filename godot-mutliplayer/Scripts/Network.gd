extends Node

var tcp = StreamPeerTCP.new()

const SERVER_IP = "172.20.128.28"
const SERVER_PORT = 9999

var connected = false
var send_timer = 0.0


func _ready():
	var error = tcp.connect_to_host(SERVER_IP, SERVER_PORT)

	if error != OK:
		print("Connection error: ", error)


func _process(delta):
	tcp.poll()

	if tcp.get_status() == StreamPeerTCP.STATUS_CONNECTED:

		if not connected:
			connected = true
			print("Connected to server!")

		send_timer += delta

		if send_timer >= 1.0:
			send_timer = 0.0

func send_player_data(player_name: String, player_position: Vector3):

	var data = {
		"type": "player_update",
		"name": player_name,
		"position": {
			"x": player_position.x,
			"y": player_position.y,
			"z": player_position.z
		}
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
