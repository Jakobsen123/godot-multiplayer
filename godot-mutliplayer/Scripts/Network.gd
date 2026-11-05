extends Node

var socket = WebSocketPeer.new()

const serverURL = '172.20.128.28:9999'

func connectToServer():
	var error = socket.connect_to_url(serverURL)
	
	if error != OK:
		print("connection Failed ", error)
	
func _process(delta: float) -> void:
	socket.poll()
	
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count() > 0:
			var packet = socket.get_packet()
			print(packet.get_string_from_utf8())
		
func sendMessage(message: String):
	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		socket.send_text(message)
