extends Node2D

var credits_panel

# Called when the node enters the scene tree for the first time.
func _ready():
	credits_panel = get_node("CreditsPanel")
	get_node("PlayButton").connect("button_down",self,"play_button_down")
	get_node("CreditsButton").connect("button_down",self,"credits_button_down")
	get_node("ExitButton").connect("button_down",self,"exit_button_down")
	get_node("CreditsPanel/CloseCreditsButton").connect("button_down",self,"close_credits_button")

func play_button_down():
	get_tree().change_scene("res://scenes/Restaurant.tscn")

func credits_button_down():
	credits_panel.visible = true

func exit_button_down():
	get_tree().quit()

func close_credits_button():
	credits_panel.visible = false
