extends Node2D

var credits_panel

# Called when the node enters the scene tree for the first time.
func _ready():
	credits_panel = get_node("CreditsPanel")
	get_node("PlayButton").connect("button_down",self,"play_button_down")
	get_node("CreditsButton").connect("button_down",self,"credits_button_down")
	get_node("ExitButton").connect("button_down",self,"exit_button_down")
	get_node("CreditsPanel/CloseCreditsButton").connect("button_down",self,"close_credits_button")

func _input(event):
	if not event is InputEventMouseButton: return
	if $CreditsPanel.visible:
		$CreditsPanel.hide()

func play_button_down():
	yield(get_tree().create_timer(0.1), 'timeout')
	get_tree().change_scene("res://scenes/Intro.tscn")

func credits_button_down():
	yield(get_tree().create_timer(0.1), 'timeout')
	credits_panel.show()

func exit_button_down():
	get_tree().quit()

func close_credits_button():
	credits_panel.visible = false
