# Pathfinding on a TileMap with Navigation2D (Godot 3.1 tutorial)
# GDquest <https://www.youtube.com/watch?v=0fPOt0Jw52s>

extends Node2D

onready var navigation:Navigation2D = $Navigation
onready var path_line:Line2D = $Path
onready var player = $Player
onready var customers = $Customers
onready var tables = $Tables

export var working_time = 10

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
	player_movement()
	customer_movement()
	if time > working_time:
		customers.set_process(false)
		if customers.get_children() == []:
			end_day()
	
func player_movement() -> void:
		# function pre-requisites
	if player.interactions.size() == 0:
		if not Input.is_action_just_pressed('click'):
			return
	
	var target:PoolVector2Array
	if player.interactions.size() > 0:
		target = navigation.get_simple_path(player.global_position, player.interactions[0].global_position, false)
	else:
		target = navigation.get_simple_path(player.global_position, get_global_mouse_position(), false)
	
	if player.isMoving: return
	
	path_line.points = target
	player.path = target

func customer_movement() -> void:
	for customer in customers.get_children():
		if customer.status == customer.WAITING_IN_LINE:
			var table = tables.get_available_table()
			if table != null:
				customers.line = false
				customer.isMoving = true
				customer.status = customer.GOING_TO_TABLE
				customer.table = table
				table.customer = customer
				customer.path = navigation.get_simple_path(customer.global_position, table.global_position, false)
				break
			
			elif customers.line:
				customer.isMoving = true
				customer.path = navigation.get_simple_path(customer.global_position, Vector2(390,1060), false)
				break
		
		elif customer.status == customer.LEAVING:
			customer.isMoving = true
			customer.path = navigation.get_simple_path(customer.global_position, Vector2(390,1150), false)

func end_day() -> void:
	set_process(false)
	
	var summary = summary_node.instance()
	summary.initialize(player.profit, customers.count, happy_customers)
	add_child(summary)
	
	player.hide()
	tables.hide()
	customers.hide()

func next_day() -> void:
	Global.day += 1
	
	player.show()
	tables.show()
	customers.show()
	
	get_tree().reload_current_scene()