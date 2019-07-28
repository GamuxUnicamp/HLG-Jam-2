# Pathfinding on a TileMap with Navigation2D (Godot 3.1 tutorial)
# GDquest <https://www.youtube.com/watch?v=0fPOt0Jw52s>

extends Node2D

onready var navigation:Navigation2D = $Navigation
onready var player = $Player
onready var customers = $Customers
onready var tables = $Tables

export var working_time = 80
var stuck_time = 0

var summary_node:PackedScene = preload('res://scenes/Summary.tscn')

var time = 0
var happy_customers = 0

func _ready() -> void:
	set_process(false)
	yield(get_tree().create_timer(0.2), 'timeout')
	set_process(true)

# _unhandled_input ignores user interface events
func _process(delta:float) -> void:
	time += delta
	player_movement(delta)
	customer_movement()
	if time > working_time:
		customers.set_process(false)
		if customers.get_children() == []:
			end_day()
	
func player_movement(delta:float) -> void:
		# function pre-requisites
	if player.interactions.size() == 0:
		if not Input.is_action_just_pressed('click'):
			return
	
	var target:PoolVector2Array
	if player.interactions.size() > 0:
		target = navigation.get_simple_path(player.global_position, player.interactions[0].global_position + Vector2(0,-100))
	else:
		target = navigation.get_simple_path(player.global_position, get_global_mouse_position())
	
	if target.size() == 2:
		if target[0].distance_to(target[1]) < 4:
			stuck_time += delta
			if stuck_time > 0.1:
				player.interactions.pop_front()
				player.set_process(false)
				player.get_node('AnimatedSprite').play('Idle Side')
				player.moving = false
				stuck_time = 0
				return
	
	if target[0].x < target[1].x:
		$Player/AnimatedSprite.flip_h = false
		if player.hands:
			player.hands.position.x = abs(player.hands.position.x)
	else:
		$Player/AnimatedSprite.flip_h = true
		if player.hands:
			player.hands.position.x = -abs(player.hands.position.x)
	$Player/AnimatedSprite.play('Walking Side')
	
	if player.moving: return
	
	player.path = target

func customer_movement() -> void:
	for customer in customers.get_children():
		if customer.status == customer.WAITING_IN_LINE:
			var table = tables.get_available_table()
			if table != null:
				customers.line = false
				customer.moving = true
				customer.status = customer.GOING_TO_TABLE
				customer.table = table
				table.customer = customer
				customer.path = navigation.get_simple_path(customer.global_position, table.global_position + Vector2(-128,0))
				break
			
			elif customers.line:
				customer.moving = true
				customer.path = navigation.get_simple_path(customer.global_position, Vector2(390,1060))
				break
		
		elif customer.status == customer.LEAVING:
			customer.moving = true
			customer.path = navigation.get_simple_path(customer.global_position, Vector2(390,1150))
		
		if customer.path.size() > 1:
			if customer.path[0].x < customer.path[1].x:
				customer.get_node('AnimatedSprite').flip_h = false
			else:
				customer.get_node('AnimatedSprite').flip_h = true

func end_day() -> void:
	set_process(false)
	
	var summary = summary_node.instance()
	summary.initialize(player.profit, customers.count, happy_customers)
	add_child(summary)
	
	player.hide()
	tables.hide()
	customers.hide()

func next_day() -> void:
	if Global.day == 7:
		yield(get_tree().create_timer(0.1), 'timeout')
		get_tree().change_scene("res://scenes/Ending.tscn")
	
	Global.day += 1
	
	Global.patience -= 5
	Global.spawn_delay -= 4
	
	player.show()
	tables.show()
	customers.show()
	
	get_tree().reload_current_scene()