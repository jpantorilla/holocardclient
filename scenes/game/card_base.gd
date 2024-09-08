class_name CardBase
extends Node2D

signal clicked_card(card_id, card)
signal hover_card(card_id, card, hover)

const DefaultCardSize = Vector2(250.0, 350.0)
const DefaultCardScale = 0.4

const CheerIndicatorScene = preload("res://scenes/game/cheer_indicator.tscn")
const CardTextInfoScene = preload("res://scenes/game/card_text_info.tscn")

@onready var card_image : TextureRect = $OuterMargin/InnerMargin/PanelContainer/CardImageHolder/CardImage
@onready var card_id_label = $OuterMargin/InnerMargin/PanelContainer/Overlay/HBoxContainer2/PanelContainer/MarginContainer/CardIdLabel
@onready var card_def_label = $OuterMargin/InnerMargin/PanelContainer/Overlay/HBoxContainer/PanelContainer/MarginContainer/CardDefLabel
@onready var cheer_indicators = $OuterMargin/InnerMargin/PanelContainer/CheerIndicators/PanelContainer/CheerVBox
@onready var info_highlight = $OuterMargin/Highlight
@onready var selection_button = $OuterMargin/Button
@onready var damage_indicator = $OuterMargin/DamageIndicator
@onready var damage_label = $OuterMargin/DamageIndicator/HBox/MarginContainer/MarginContainer/CenterContainer/DamageLabel
@onready var card_text_info_container = $OuterMargin/InnerMargin/PanelContainer/Overlay/PanelContainer/CardTextContainer

@export var is_big_card : bool = false

var _card_id
var _definition_id
var _definition

var _cheer : Dictionary = {}
var damage = 0
var dead = false
var _card_type
var _attached_cards = []

var _selected = false
var _selectable = false
var _resting = false

func _ready():
	info_highlight.visible = false
	if is_big_card:
		visible = false
		selection_button.visible = false

func create_card(definition, definition_id, card_id, card_type):
	_definition = definition
	_definition_id = definition_id
	_card_id = card_id
	_card_type = card_type

func set_button_visible(button_visible):
	if button_visible:
		selection_button.modulate = Color(1, 1, 1, 1)
	else:
		selection_button.modulate = Color(1, 1, 1, 0)

func initialize_graphics():
	card_image.texture = load("res://assets/cards/" + _definition_id + ".png")
	set_button_visible(false)
	scale = Vector2(DefaultCardScale, DefaultCardScale)
	_update_stats()
	_update_english_text()

func _update_english_text():
	# Remove any previous text.
	var children = card_text_info_container.get_children()
	for child in children:
		card_text_info_container.remove_child(child)
		child.queue_free()

	var english_data = Strings.build_english_card_text(_definition)
	for info_data in english_data:
		var new_info : CardTextInfo = CardTextInfoScene.instantiate()
		card_text_info_container.add_child(new_info)
		new_info.set_text(info_data["colors"], info_data["text"])

func get_texture():
	return card_image.texture

func copy_graphics(card : CardBase):
	selection_button.visible = false
	card_image.texture = card.get_texture()
	_card_id = card._card_id
	_definition_id = card._definition_id
	_definition = card._definition
	_cheer = card._cheer
	damage = card.damage
	dead = card.dead
	_card_type = card._card_type
	_attached_cards = card._attached_cards
	set_selected(card._selected)
	set_info_highlight(card.info_highlight.visible)
	_update_stats()
	_update_english_text()
	card_image.mouse_filter = Control.MOUSE_FILTER_IGNORE

func is_holomem_card():
	return _card_type in ["holomem_debut", "holomem_bloom", "holomem_spot"]

func set_selected(is_selected : bool) -> void:
	_selected = is_selected
	info_highlight.visible = is_selected

func set_selectable(is_selectable : bool) -> void:
	_selectable = is_selectable
	set_button_visible(is_selectable)

func set_info_highlight(is_highlighted : bool) -> void:
	info_highlight.visible = is_highlighted

func get_or_create_cheer_indicator(color):
	for cheer_indicator in cheer_indicators.get_children():
		if cheer_indicator.color == color:
			return cheer_indicator
	var cheer_indicator = CheerIndicatorScene.instantiate()
	cheer_indicators.add_child(cheer_indicator)
	cheer_indicator.set_cheer(color, 0)
	return cheer_indicator

func remove_cheer_indicator(color):
	for cheer_indicator in cheer_indicators.get_children():
		if cheer_indicator.color == color:
			cheer_indicators.remove_child(cheer_indicator)
			cheer_indicator.queue_free()
			break

func _update_stats():
	card_def_label.text = _definition_id
	# Use only the card_id part after _ if there is a _.
	# This is to avoid the card_id being too long.
	var small_id = _card_id
	if "_" in _card_id:
		small_id = _card_id.split("_")[1]
	card_id_label.text = small_id
	var cheer_counts = get_cheer_counts()
	for color in cheer_counts:
		var count = cheer_counts[color]
		if count > 0:
			var cheer_indicator = get_or_create_cheer_indicator(color)
			cheer_indicator.set_cheer(color, count)
		else:
			remove_cheer_indicator(color)

	damage_indicator.visible = damage > 0
	damage_label.text = str(damage)

func attach_cheer(card_id, colors : Array):
	_cheer[card_id] = colors
	_update_stats()

func remove_attached(card_id):
	if card_id in _cheer:
		_cheer.erase(card_id)
		_update_stats()
	elif card_id in _attached_cards:
		_attached_cards.erase(card_id)
		_update_stats()

func remove_cheer(card_id):
	_cheer.erase(card_id)
	_update_stats()

func add_damage(amount, is_dead : bool):
	damage += amount
	dead = is_dead
	_update_stats()

func set_resting(is_resting):
	_resting = is_resting
	rotation_degrees = 0
	if _resting:
		rotation_degrees = 90

func attach_card(card_id):
	_attached_cards.append(card_id)
	_update_stats()

func remove_all_attached_cards():
	var previously_attached = _attached_cards
	_attached_cards = []
	_update_stats()
	return previously_attached

func remove_all_attached_cheer():
	var cheer = _cheer.duplicate()
	_cheer = {}
	return cheer

func get_cheer_counts():
	var blue = 0
	var green = 0
	var red = 0
	var white = 0
	for cheer_id in _cheer:
		var colors = _cheer[cheer_id]
		if "blue" in colors:
			blue += 1
		if "green" in colors:
			green += 1
		if "red" in colors:
			red += 1
		if "white" in colors:
			white += 1
	return {
		"blue": blue,
		"green": green,
		"red": red,
		"white": white,
	}


func _on_button_pressed() -> void:
	if _selectable:
		clicked_card.emit(_card_id, self)

func _on_button_mouse_entered() -> void:
	if not is_big_card:
		hover_card.emit(_card_id, self, true)

func _on_button_mouse_exited() -> void:
	if not is_big_card:
		hover_card.emit(_card_id, self, false)
