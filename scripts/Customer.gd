# Pathfinding on a TileMap with Navigation2D (Godot 3.1 tutorial)
# GDquest <https://www.youtube.com/watch?v=0fPOt0Jw52s>

extends Node2D

enum {WAITING_IN_LINE, WAITING_MENU, DECIDING_FOOD, WAITING_FOOD, EATING, LEAVING}

export var speed:float = 150
var path := PoolVector2Array() setget set_path
var isMoving:bool = false

var angry:bool = false
onready var patience:float = Global.patience
onready var patience_bar = $Patience_bar

var table:Area2D

var status:int = WAITING_IN_LINE

func _ready() -> void:
	patience_bar.max_value = patience
	patience_bar.value = patience
	patience_bar.hide()

func _process(delta:float) -> void:
	if isMoving:
		var move_distance:float = speed * delta
		move_along_path(move_distance)
	
	if status == WAITING_MENU:
		patience_bar.show()
		patience -= delta
		patience_bar.value = patience
		if patience < 0:
			leave()
		elif patience < 2:
			infuriate()
	
	elif status == DECIDING_FOOD:
		patience_bar.hide()
		patience -= delta
		if patience <0:
			status = WAITING_FOOD
			patience_bar.show()
	
	elif status == EATING:
		patience_bar.hide()
		patience -= delta
		if patience <0:
			leave()
	
	elif status == LEAVING:
		if position.y > get_viewport_rect().size.y+64:
			queue_free()

func infuriate() -> void:
	if angry: 
		return
	angry = true

func leave() -> void:
	if status == LEAVING:
		return
	patience_bar.hide()
	status = LEAVING
	table.customer = null
	table = null
	if not angry:
		Global.player_money+=10

func move_along_path(distance:float) -> void:
	var start_point:Vector2 = position
	for i in range(path.size()): # loop through all path points
		var distance_to_next:float = start_point.distance_to(path[0])
		if distance <= distance_to_next:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif path.size() == 1: # when reaches the target
			position = path[0]
			isMoving = false
			status = WAITING_MENU
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func set_path(value:PoolVector2Array) -> void:
	path = value
	# avoid setting process to true on initializing
	if value.size() == 0: return

func receive_waiter() -> void:
	if status == WAITING_MENU:
		patience = Global.patience
		status = DECIDING_FOOD
	elif status == WAITING_FOOD:
		patience = Global.patience
		status = EATING
