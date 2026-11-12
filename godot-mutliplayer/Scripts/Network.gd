
extends Node

var udp = PacketPeerUDP.new()

const SERVER_IP = "172.20.128.28"
const SERVER_PORT = 8000

var connected = false
var send_timer = 0.0

var playerManager: Node3D


func _ready():
	var error = udp.set_dest_address(SERVER_IP, SERVER_PORT)

	if error != OK:
		print("UDP setup error: ", error)
	else:
		connected = true
		print("UDP ready!")


func receiveMessages():

	while udp.get_available_packet_count() > 0:

		var packet = udp.get_packet()
		var message = packet.get_string_from_utf8()

		var data = JSON.parse_string(message)

		if data is Dictionary:
			handle_message(data)


func _process(delta):

	receiveMessages()

	send_timer += delta

	if send_timer >= 1.0:
		send_timer = 0.0


func send_player_data(type: String, player_name: String, player_position: Vector3, player_rotation_y: float):

	var data = {
		"type": type,
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

	var data = message.to_utf8_buffer()

	var error = udp.put_packet(data)

	if error != OK:
		print("Send error: ", error)
	else:
		print("Sent: ", message)


func handle_message(data: Dictionary):

	if data.get("type") == "player_update":

		# PlayerManager registers itself when the game scene loads
		if not is_instance_valid(playerManager):
			return

		var player_id = data["name"]

		var pos = data["position"]

		var player_position = Vector3(
			pos["x"],
			pos["y"],
			pos["z"]
		)

		var playerRotation = data["rotation"]

		playerManager.updatePlayer(
			player_id,
			data["name"],
			player_position,
			playerRotation
		)
