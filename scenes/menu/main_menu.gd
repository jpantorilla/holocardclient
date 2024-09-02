extends Control

# Buttons
@onready var server_connect_button = $MainButtons/ServerConnectButton
@onready var join_queue_button = $MainButtons/JoinQueueButton
@onready var join_match_button = $MainButtons/JoinMatchButton
@onready var leave_queue_button = $MainButtons/LeaveQueueButton

# Labels
@onready var server_status = $ServerStatus/ServerStatusLabel

# Other
@onready var server_info_list : ItemList = $ServerInfoList

enum MenuState {
	MenuState_ConnectingToServer,
	MenuState_Connected_Default,
	MenuState_Disconnected,
	MenuState_Queued,
}

var menu_state : MenuState = MenuState.MenuState_ConnectingToServer

var match_queues : Array[String] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_update_buttons()
	NetworkManager.connect("connected_to_server", _on_connected)
	NetworkManager.connect("disconnected_from_server", _on_disconnected)
	NetworkManager.connect("server_info", _on_server_info)
	NetworkManager.connect("join_operation_failed", _on_join_failed)

func _update_element(button, enabled_value, visibility_value):
	button.disabled = not enabled_value
	button.visible = visibility_value

func _update_buttons() -> void:
	match menu_state:
		MenuState.MenuState_ConnectingToServer:
			_update_element(server_connect_button, false, false)
			_update_element(join_queue_button, false, true)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, false, false)
			server_status.text = "Connecting to server..."
		MenuState.MenuState_Connected_Default:
			_update_element(server_connect_button, false, false)
			_update_element(join_queue_button, true, true)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, false, false)
			server_status.text = "Connected"
		MenuState.MenuState_Disconnected:
			_update_element(server_connect_button, true, true)
			_update_element(join_queue_button, false, false)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, false, false)
			server_status.text = "Disconnected from server"
		MenuState.MenuState_Queued:
			_update_element(server_connect_button, false, false)
			_update_element(join_queue_button, false, false)
			_update_element(join_match_button, false, false)
			_update_element(leave_queue_button, true, true)
		_:
			assert(false, "Unimplemented menu state")
			pass

func returned_from_game():
	pass

func settings_loaded():
	pass
	
func _on_connected():
	menu_state = MenuState.MenuState_Connected_Default
	_update_buttons()

func _on_disconnected():
	menu_state = MenuState.MenuState_Disconnected
	_update_buttons()
	server_info_list.clear()
	server_status.text = "Disconnected from server."

func _on_server_info(queue_info):
	server_info_list.clear()
	match_queues = []
	for queue in queue_info:
		var queue_str = "%s - %s" % [queue["queue_name"], queue["players_count"]]
		server_info_list.add_item(queue_str, null, false)
		match_queues.append(queue["queue_name"])

func _on_server_connect_button_pressed() -> void:
	menu_state = MenuState.MenuState_ConnectingToServer
	_update_buttons()
	NetworkManager.connect_to_server()

func _on_join_queue_button_pressed() -> void:
	menu_state = MenuState.MenuState_Queued
	_update_buttons()
	var oshi_id = "hSD01-001"
	var deck = {
		"hSD01-003": 4,
		"hSD01-004": 3,
		"hSD01-005": 3,
		"hSD01-006": 2,
		"hSD01-007": 2,
		"hSD01-008": 4,
		"hSD01-009": 3,
		"hSD01-010": 3,
		"hSD01-011": 2,
		"hSD01-012": 2,
		"hSD01-013": 2,
		"hSD01-014": 2,
		"hSD01-015": 2,
		"hSD01-016": 3,
		"hSD01-017": 3,
		"hSD01-018": 3,
		"hSD01-019": 3,
		"hSD01-020": 2,
		"hSD01-021": 2,
	}
	
	var cheer_deck = {
		"hY01-001": 10,
		"hY02-001": 10
	}
	
	NetworkManager.join_match_queue(match_queues[0], oshi_id, deck, cheer_deck)

func _on_join_failed() -> void:
	menu_state = MenuState.MenuState_Connected_Default
	_update_buttons()

func _on_leave_queue_button_pressed() -> void:
	menu_state = MenuState.MenuState_Connected_Default
	_update_buttons()
	NetworkManager.leave_match_queue()

func _on_debug_spew_button_toggled(toggled_on: bool) -> void:
	GlobalSettings.toggle_logging(toggled_on)
