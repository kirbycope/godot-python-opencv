extends TextureRect

var socket: WebSocketPeer = WebSocketPeer.new()
var socket_url = "ws://localhost:8765"


## Called when the object receives a notification, which can be identified in `param what` by comparing it with a constant. See also `notification`.
func _notification(what) -> void:

	# Check if notifcation is a "close request"
	if what == NOTIFICATION_WM_CLOSE_REQUEST:

		# Stop the webcam server
		webcam_server_stop()

		# Close _this_ application
		get_tree().quit()


## Called when the node is "ready", i.e. when both the node and its children have entered the scene tree.
func _ready() -> void:

	# Start the webcam server
	webcam_server_start()

	# Connect _this_ app to the webcam server
	webcam_server_connect()


## Called every frame. '_delta' is the elapsed time since the previous frame.
func _process(_delta) -> void:

	# Updates the connection state and receive incoming packets
	socket.poll()

	# Returns the ready state of the connection
	var state = socket.get_ready_state()

	# Check if the connection is open and ready to communicate
	if state == WebSocketPeer.STATE_OPEN:

		# While there are packets in the buffer
		while socket.get_available_packet_count():

			# Handle the packet data
			_on_websocket_data_received()

	# Check if the connection is closed or couldn't be opened
	elif state == WebSocketPeer.STATE_CLOSED:

		# Stop processing _this_ node
		set_process(false)


## Starts the Webcam server.
func webcam_server_start() -> void:

	# Define the path to the server executable
	var executable_path = "res://dist/webcam_server.exe"

	# Get the absolute, native OS path corresponding to the localized `param path`
	var absolute_path = ProjectSettings.globalize_path(executable_path)

	# Request the OS to open a resource identified by `param uri` with the most appropriate program.
	var result = OS.shell_open(absolute_path)

	# Check if there was an issue loading the executable
	if result != OK: print("Failed to launch Python script.")


## Closes the application based on the operating system
func webcam_server_stop() -> void:

	# Get the current operating system
	var os_name = OS.get_name()

	# Check if the operating system is Windows
	if os_name== "Windows":

		# Use `taskkill` with the application name
		var args = ["taskkill", "/IM", "webcam_server.exe", "/F"]

		# Execute the given process in a blocking way
		OS.execute("cmd", ["/c"] + args)

	# Check if the current opersing system is Unix-based
	elif os_name == "X11" or OS.get_name() == "OSX":

		# Use `pkill` with the application name
		var args = ["pkill", "webcam_server"]

		# Execute the given process in a blocking way
		OS.execute("sh", ["-c"] + args)


## Connects to the webcam server.
func webcam_server_connect() -> void:

	# Initiate connection to the given `URL`
	var result = socket.connect_to_url(socket_url)

	# Check if there was an issue connecting to the server
	if result != OK: print("Unable to connect")


## Handle WebSocket data recieved.
func _on_websocket_data_received() -> void:

	# Convert UTF-8 encoded array to `String`
	var base_64_string = socket.get_packet().get_string_from_utf8()
	
	# Check if there is data to process
	if base_64_string:

		# Convert the Base64 string to raw data
		var raw_data = Marshalls.base64_to_raw(base_64_string)

		# Create an Image from the raw data
		var image = Image.new()

		# Load an image from the binary contents of a JPEG file
		var result = image.load_jpg_from_buffer(raw_data)

		# Check if the image loaded from the buffer
		if !result:

			# Creates a new `ImageTexture` and initializes it by allocating and setting the data from an `Image`
			var new_texture = ImageTexture.create_from_image(image)

			# Set _this_ node's Texture2D resource
			texture = new_texture
