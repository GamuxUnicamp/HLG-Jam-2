# Pathfinding on a TileMap with Navigation2D (Godot 3.1 tutorial)
# GDquest <https://www.youtube.com/watch?v=0fPOt0Jw52s>

extends Node2D

var path := PoolVector2Array() setget set_path
var moving:bool = false
var interactions:Array = []
var orders:Array = []
onready var orders_node = $Order
var hands = null
var profit = 0

func _ready() -> void:
	set_process(false)

func _process(delta:float) -> void:
	var move_distance:float = Global.player_speed * delta
	move_along_path(move_distance)

func move_along_path(distance:float) -> void:
	var start_point:Vector2 = position
	moving = true
	
	for i in range(path.size()): # loop through all path points
		var distance_to_next:float = start_point.distance_to(path[0])
		if distance <= distance_to_next:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif path.size() == 1: # when player reaches the target
			position = path[0]
			set_process(false)
			$AnimatedSprite.play('Idle Side')
			moving = false
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func set_path(value:PoolVector2Array) -> void:
	path = value
	
	# avoid setting process to true on initializing
	if value.size() == 0: return
	set_process(true)

func add_order(food_index:int) -> void:
	if orders.size() == 0:
		orders_node.show()
		orders_node.get_node('Label').text = str(1)
	else:
		var orders_number = int(orders_node.get_node('Label').text)
		orders_node.get_node('Label').text = str(orders_number + 1)
	
	orders.append(food_index)

func remove_order() -> int:
	var order = orders.front()
	orders.erase(order)
	
	if orders.size() == 0:
		orders_node.hide()
	else:
		var orders_number = int(orders_node.get_node('Label').text)
		orders_node.get_node('Label').text = str(orders_number - 1)
	
	return order