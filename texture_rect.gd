extends TextureRect

var bone_map = {
	0: "mixamorig_Head", # Nose
	11: "mixamorig_LeftArm", # Left Shoulder
	12: "mixamorig_RightArm", # Right Shoulder
	13: "mixamorig_LeftForeArm", # Left Elbow
	14: "mixamorig_RightForeArm", # Right Elbow
	15: "mixamorig_LeftHand", # Left Wrist
	16: "mixamorig_RightHand", # Right Wrist
}
@onready var camera: Camera3D = $"../../../Camera3D"
@onready var model: Node3D = $"../../../YBot"
@onready var skeleton: Skeleton3D = $"../../../YBot/Skeleton3D"
var socket: WebSocketPeer = WebSocketPeer.new()
var socket_url: String = "ws://localhost:8765"


## Called when the object receives a notification, which can be identified in `param what` by comparing it with a constant.
func _notification(what) -> void:

	# Check if notification is a "close request"
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
	if os_name == "Windows":

		# Use `taskkill` with the application name
		var args = ["taskkill", "/IM", "webcam_server.exe", "/F"]

		# Execute the given process in a blocking way
		OS.execute("cmd", ["/c"] + args)

	# Check if the current operating system is Unix-based
	elif os_name == "X11" or os_name == "OSX":

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


## Handle WebSocket data received.
func _on_websocket_data_received() -> void:

	# Convert UTF-8 encoded array to `String`
	var data_received = socket.get_packet().get_string_from_utf8()

	# Create an instance of and initialize the JSON class
	var json = JSON.new()

	# Parse the JSON provided
	json.parse(data_received)

	# Extract the parsed result
	var result_data = json.get_data()

	# Extract the Base64 image string from the parsed result
	var base_64_string = result_data["image"]

	# Convert the Base64 string to raw data
	var raw_data = Marshalls.base64_to_raw(base_64_string)

	# Create an Image from the raw data
	var image = Image.new()

	# Load an image from the binary contents of a JPEG file
	image.load_jpg_from_buffer(raw_data)

	# Creates a new `ImageTexture` and initializes it by allocating and setting the data from an `Image`
	var new_texture = ImageTexture.create_from_image(image)

	# Set _this_ node's Texture2D resource
	texture = new_texture

	# Get the "landmarks" from the json data
	var landmarks = result_data["landmarks"]

	# Update each of the model bone's positons
	update_model_bone_positions(landmarks)


## Translates the landmark coodinates into a Vector3. 
func landmark_to_vector3(landmark) -> Vector3:

	# Convert the JSON data to a Vector3
	var landmark_position = Vector3(landmark["x"], landmark["y"],landmark["z"])

	# Convert from 2D position to screen coordinates
	var screen_x = landmark_position.x * get_viewport().size.x
	var screen_y = landmark_position.y * get_viewport().size.y

	# Now convert to a 3D position (project ray from 2D into 3D)
	var ray_origin = camera.project_ray_origin(Vector2(screen_x, screen_y))
	var ray_direction = camera.project_ray_normal(Vector2(screen_x, screen_y))

	# Define a Z-depth (distance from the camera)
	var depth = (landmark_position.z * .05) + camera.position.z

	# Use the ray to find the 3D position at a given depth
	var landmark_position_3d = ray_origin + ray_direction * depth

	# Return the landmark's position
	return landmark_position_3d


## Function to update the rigged model's bones.
func update_model_bone_positions(landmarks):

	# Loop through each landmark and update the corresponding bone
	for i in range(landmarks.size()):

		# Check if this landmark is mapped to a bone
		if bone_map.has(i) and bone_map[i] != "":

			# Get the bone's name
			var bone_name = bone_map[i]

			# Get the bone's index
			var bone_idx: int = skeleton.find_bone(bone_name)

			# Get the bone's current pose
			var current_pose = skeleton.get_bone_global_pose(bone_idx)

			# Update the landmark values to a 3D position
			var landmark_position: Vector3 = landmark_to_vector3(landmarks[i])

			# Define the new pose
			var new_pose: Transform3D = Transform3D(current_pose.basis, landmark_position)

			# Apply the new pose
			skeleton.set_bone_global_pose(bone_idx, new_pose)
	
	# Set "mixammo_Spine2" to the midpoint of the shoulders
	var left_shoulder_idx = bone_map.keys().find(11)
	var right_shoulder_idx = bone_map.keys().find(12)
	if left_shoulder_idx != -1 and right_shoulder_idx != -1:
		var left_shoulder_pos = landmark_to_vector3(landmarks[left_shoulder_idx])
		var right_shoulder_pos = landmark_to_vector3(landmarks[right_shoulder_idx])
		var midpoint = (left_shoulder_pos + right_shoulder_pos) * .4
		var spine_bone_idx = skeleton.find_bone("mixamorig_Spine2")
		if spine_bone_idx != -1:
			var spine_current_pose = skeleton.get_bone_global_pose(spine_bone_idx)
			var spine_new_pose = Transform3D(spine_current_pose.basis, midpoint)
			skeleton.set_bone_global_pose(spine_bone_idx, spine_new_pose)
