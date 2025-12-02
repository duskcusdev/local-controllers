extends Control


func _ready():
	# Connect signals for controller connection/disconnection
	Input.joy_connection_changed.connect(_on_joy_connection_changed)
	
	# Initial scan
	update_controller_list()

func _on_joy_connection_changed(device: int, connected: bool):
	# Called whenever a controller is plugged in or unplugged
	update_controller_list()

func update_controller_list():
	# Clear the list
	for child in $VBoxContainer/Label2.get_children():
		child.queue_free()
	
	# Get all connected controllers
	var joypads = Input.get_connected_joypads()
	
	# Update count label (including keyboard as a device)
	$VBoxContainer/Label.text = "Connected Controllers: " + str(joypads.size())
	
	# Display each controller
	if joypads.size() == 0:
		var no_controller = Label.new()
		no_controller.text = "No controllers detected"
		no_controller.add_theme_color_override("font_color", Color(0.7, 0.7, 0.7))
		$VBoxContainer/Label2.add_child(no_controller)
	else:
		for device_id in joypads:
			var controller_info = VBoxContainer.new()
			
			# Controller header
			var header = Label.new()
			header.text = "Controller " + str(device_id)
			header.add_theme_font_size_override("font_size", 20)
			header.add_theme_color_override("font_color", Color(0.4, 0.8, 1.0))
			controller_info.add_child(header)
			
			# Controller name
			var name_label = Label.new()
			var controller_name = Input.get_joy_name(device_id)
			name_label.text = "  Name: " + controller_name
			controller_info.add_child(name_label)
			
			# Controller GUID
			var guid_label = Label.new()
			var guid = Input.get_joy_guid(device_id)
			guid_label.text = "  GUID: " + guid
			guid_label.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8))
			controller_info.add_child(guid_label)
			
			# Spacer
			var spacer = Control.new()
			spacer.custom_minimum_size = Vector2(0, 10)
			controller_info.add_child(spacer)
			
			$VBoxContainer/Label2.add_child(controller_info)

func _process(_delta):
	# Print keyboard inputs (Device -1)
	print_keyboard_input()
	
	# Print button presses and axis movements for all connected controllers
	var joypads = Input.get_connected_joypads()
	
	for device_id in joypads:
		# Check all standard buttons
		for button in range(JOY_BUTTON_MAX):
			if Input.is_joy_button_pressed(device_id, button):
				$VBoxContainer/Label.text = str("Controller ", device_id, " - Button ", button, " (", get_button_name(button), ") pressed")
		
		# Check analog sticks and triggers (axes)
		for axis in range(JOY_AXIS_MAX):
			var value = Input.get_joy_axis(device_id, axis)
			# Only print if axis is moved significantly (deadzone of 0.2)
			if abs(value) > 0.2:
				$VBoxContainer/Label.text = str("Controller ", device_id, " - Axis ", axis, " (", get_axis_name(axis), "): ", snappedf(value, 0.01))

func print_keyboard_input():
	# Check for key presses
	for key in range(KEY_SPACE, KEY_Z + 1):  # Common keys range
		if Input.is_physical_key_pressed(key):
			$VBoxContainer/Label.text = str("Keyboard (Device -1) - Key: ", OS.get_keycode_string(key))
	
	# Check arrow keys separately
	if Input.is_physical_key_pressed(KEY_UP):
		$VBoxContainer/Label.text = str("Keyboard (Device -1) - Key: UP")
	if Input.is_physical_key_pressed(KEY_DOWN):
		$VBoxContainer/Label.text = str("Keyboard (Device -1) - Key: DOWN")
	if Input.is_physical_key_pressed(KEY_LEFT):
		$VBoxContainer/Label.text = str("Keyboard (Device -1) - Key: LEFT")
	if Input.is_physical_key_pressed(KEY_RIGHT):
		$VBoxContainer/Label.text = str("Keyboard (Device -1) - Key: RIGHT")
	
	# Check mouse buttons
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_LEFT):
		$VBoxContainer/Label.text = str("Keyboard (Device -1) - Mouse: LEFT CLICK at ", get_viewport().get_mouse_position())
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_RIGHT):
		$VBoxContainer/Label.text = str("Keyboard (Device -1) - Mouse: RIGHT CLICK")
	if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
		$VBoxContainer/Label.text = str("Keyboard (Device -1) - Mouse: MIDDLE CLICK")

func get_button_name(button: int) -> String:
	match button:
		JOY_BUTTON_A: return "A/Cross"
		JOY_BUTTON_B: return "B/Circle"
		JOY_BUTTON_X: return "X/Square"
		JOY_BUTTON_Y: return "Y/Triangle"
		JOY_BUTTON_BACK: return "Back/Select"
		JOY_BUTTON_GUIDE: return "Guide/Home"
		JOY_BUTTON_START: return "Start"
		JOY_BUTTON_LEFT_STICK: return "L3"
		JOY_BUTTON_RIGHT_STICK: return "R3"
		JOY_BUTTON_LEFT_SHOULDER: return "L1/LB"
		JOY_BUTTON_RIGHT_SHOULDER: return "R1/RB"
		JOY_BUTTON_DPAD_UP: return "D-Pad Up"
		JOY_BUTTON_DPAD_DOWN: return "D-Pad Down"
		JOY_BUTTON_DPAD_LEFT: return "D-Pad Left"
		JOY_BUTTON_DPAD_RIGHT: return "D-Pad Right"
		_: return "Button " + str(button)

func get_axis_name(axis: int) -> String:
	match axis:
		JOY_AXIS_LEFT_X: return "Left Stick X"
		JOY_AXIS_LEFT_Y: return "Left Stick Y"
		JOY_AXIS_RIGHT_X: return "Right Stick X"
		JOY_AXIS_RIGHT_Y: return "Right Stick Y"
		JOY_AXIS_TRIGGER_LEFT: return "Left Trigger"
		JOY_AXIS_TRIGGER_RIGHT: return "Right Trigger"
		_: return "Axis " + str(axis)
