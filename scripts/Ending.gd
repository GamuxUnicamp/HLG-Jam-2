extends Node

func _input(event:InputEvent) -> void:
	if Input.is_action_just_pressed('click'):
		get_tree().change_scene("res://scenes/Main_Menu.tscn")