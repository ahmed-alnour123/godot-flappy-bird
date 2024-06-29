extends Node
class_name SocketConnection
## The port the server will listen on.
const PORT = 9080

var tcp_server := TCPServer.new()
var socket := WebSocketPeer.new()

signal message_recieved


func log_message(message: String) -> void:
	message_recieved.emit(message)



func _ready() -> void:
	if tcp_server.listen(PORT) != OK:
		log_message("Unable to start server.")
		set_process(false)


func _process(_delta: float) -> void:
	while tcp_server.is_connection_available():
		var conn: StreamPeerTCP = tcp_server.take_connection()
		assert(conn != null)
		socket.accept_stream(conn)

	socket.poll()

	if socket.get_ready_state() == WebSocketPeer.STATE_OPEN:
		while socket.get_available_packet_count():
			log_message(socket.get_packet().get_string_from_ascii())


func _exit_tree() -> void:
	socket.close()
	tcp_server.stop()


func _on_button_pong_pressed() -> void:
	socket.send_text("Pong")

func send_json(json:Dictionary):
	socket.send_text(JSON.stringify(json))
