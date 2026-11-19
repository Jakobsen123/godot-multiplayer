extends Node

const SERVER_IP = "172.20.128.28"
const SERVER_PORT = 8000
const HEARTBEAT_INTERVAL = 1.0

var udp := PacketPeerUDP.new()
var connected := false
var heartbeat_timer := 0.0

var my_name := ""
var last_data := {}

var playerManager: Node3D


func _ready():
	var error = udp.connect_to_host(SERVER_IP, SERVER_PORT)
	if error != OK:
		print("UDP setup error: ", error)
		return
	connected = true
	print("UDP ready!")


func _process(delta):
	if not connected:
		return

	receive_messages()

	# Keep the server aware of us even when standing still
	heartbeat_timer += delta
	if heartbeat_timer >= HEARTBEAT_INTERVAL and not last_data.is_empty():
		heartbeat_timer = 0.0
		send_message(JSON.stringify(last_data))


func send_player_data(type: String, player_name: String, player_position: Vector3, player_rotation_y: float):
	my_name = player_name

	last_data = {
		"type": type,
		"name": player_name,
		"position": {
			"x": player_position.x,
			"y": player_position.y,
			"z": player_position.z
		},
		"rotation": player_rotation_y
	}

	heartbeat_timer = 0.0
	send_message(JSON.stringify(last_data))


func send_message(message: String):
	var error = udp.put_packet(message.to_utf8_buffer())
	if error != OK:
		print("Send error: ", error)


func receive_messages():
	while udp.get_available_packet_count() > 0:
		var message = udp.get_packet().get_string_from_utf8()
		var data = JSON.parse_string(message)
		if data is Dictionary:
			handle_message(data)


func handle_message(data: Dictionary):
	if data.get("type") != "update_player":
		return

	# Ignore our own player echoed back by the server
	if data.get("name", "").to_lower() == my_name.to_lower():
		return

	if not is_instance_valid(playerManager):
		return

	var pos = data["position"]
	var player_position = Vector3(pos["x"], pos["y"], pos["z"])

	playerManager.updatePlayer(
		data["name"],
		data["name"],
		player_position,
		data["rotation"]
	)
