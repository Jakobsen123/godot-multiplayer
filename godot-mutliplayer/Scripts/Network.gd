extends Node

const SERVER_IP = "172.20.128.28"
const SERVER_PORT = 8000
const HEARTBEAT_INTERVAL = 1.0
const DEBUG = false

var udp := PacketPeerUDP.new()
var connected := false
var heartbeat_timer := 0.0

var my_name := ""
var last_data := {}

var playerManager: Node3D


func _ready():
	# Bind to any free local port (1 MB receive buffer) instead of connect_to_host(),
	# which silently drops packets whose source doesn't exactly match the server.
	var error = udp.bind(0, "*", 1 << 20)
	if error != OK:
		print("UDP bind error: ", error)
		return

	error = udp.set_dest_address(SERVER_IP, SERVER_PORT)
	if error != OK:
		print("UDP set_dest_address error: ", error)
		return

	connected = true
	print("UDP ready on local port ", udp.get_local_port(), " -> ", SERVER_IP, ":", SERVER_PORT)


func _process(delta):
	if not connected:
		return

	receive_messages()

	# Keep the server aware of us even when nothing is being sent
	heartbeat_timer += delta
	if heartbeat_timer >= HEARTBEAT_INTERVAL and not last_data.is_empty():
		heartbeat_timer = 0.0
		last_data["t"] = Time.get_ticks_msec()
		send_message(JSON.stringify(last_data))


func send_player_data(type: String, player_name: String, player_position: Vector3, player_rotation_y: float, is_boosting: bool):
	my_name = player_name

	last_data = {
		"type": type,
		"name": player_name,
		"position": {
			"x": player_position.x,
			"y": player_position.y,
			"z": player_position.z
		},
		"rotation": player_rotation_y,
		"is_boosting": is_boosting,
		"t": Time.get_ticks_msec()
	}

	heartbeat_timer = 0.0
	send_message(JSON.stringify(last_data))


func send_message(message: String):
	if not connected:
		return
	var error = udp.put_packet(message.to_utf8_buffer())
	if DEBUG:
		print("SENT -> ", message, " (err ", error, ")")
	if error != OK:
		print("Send error: ", error)


func receive_messages():
	while udp.get_available_packet_count() > 0:
		var packet := udp.get_packet()
		var error := udp.get_packet_error()
		if error != OK:
			print("Receive error: ", error)
			continue

		var message := packet.get_string_from_utf8()
		if DEBUG:
			print("RECV from ", udp.get_packet_ip(), ":", udp.get_packet_port(), " -> ", message)

		var data = JSON.parse_string(message)
		if data is Dictionary:
			handle_message(data)


func get_my_name() -> String:
	# Fall back to the global username in case send_player_data() hasn't run yet
	if my_name != "":
		return my_name
	return str(Global.playerUsername)


func handle_message(data: Dictionary):
	if data.get("type") != "update_player" and data.get("type") != "delete_player":
		return
	if data.get("type") == "delete_player":
		print("Deleteplayerevent")
		playerManager.deletePlayers.append(data.get("name"))
		return

	var player_name := str(data.get("name", ""))
	if player_name == "":
		return

	# Ignore our own player
	if player_name.to_lower() == get_my_name().to_lower():
		return

	if not is_instance_valid(playerManager):
		if DEBUG:
			print("playerManager not set, dropping update for ", player_name)
		return

	var pos = data.get("position")
	if not (pos is Dictionary and pos.has("x") and pos.has("y") and pos.has("z")):
		return

	var player_position := Vector3(float(pos["x"]), float(pos["y"]), float(pos["z"]))
	var player_rotation := float(data.get("rotation", 0.0))
	var player_boosting := bool(data.get("is_boosting", false))
	var sender_t := float(data.get("t", Time.get_ticks_msec()))

	playerManager.updatePlayer(player_name, player_name, player_position, player_rotation, player_boosting, sender_t)
