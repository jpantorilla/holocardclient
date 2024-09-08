extends Node

var card_data = []
var card_definitions_path = "res://data/card_definitions.json"

const CardBaseScene = preload("res://scenes/game/card_base.tscn")

func _ready():
	card_data = load_json_file(card_definitions_path)

func load_json_file(file_path : String):
	if FileAccess.file_exists(file_path):
		var data = FileAccess.open(file_path, FileAccess.READ)
		var json = JSON.parse_string(data.get_as_text())
		return json
	else:
		print("Card definitions file doesn't exist")

func get_card(definition_id) -> Dictionary:
	for card in card_data:
		if card['card_id'] == definition_id:
			return card
	assert(false, "Missing card definition: " + definition_id)
	return {}

func test_create_card(card_id : String, definition_id : String) -> CardBase:
	var definition = CardDatabase.get_card(definition_id)
	var card_type = definition["card_type"]
	var new_card : CardBase = CardBaseScene.instantiate()
	new_card.create_card(definition, definition_id, card_id, card_type)
	return new_card
