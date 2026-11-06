extends Control

@onready var input = $LineEdit
@onready var joinKnapp = $Button


func _on_button_pressed() -> void:
	
	var username = input.text
	
	if username == null:
		return
	
	Global.playerUsername = username
	get_tree().change_scene_to_file("res://Scenes/test_area.tscn")
