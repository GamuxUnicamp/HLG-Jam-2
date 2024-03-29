extends Node

export var randomness:float = 5

var customer_node:PackedScene = preload('res://scenes/Customer.tscn')
onready var tables:Node = get_parent().get_node('Tables')

var count = 0
var line = false

func _ready():
	set_process(false)
	yield(get_tree().create_timer(rand_range(Global.spawn_delay-randomness, Global.spawn_delay+randomness)), "timeout")
	set_process(true)

func _process(delta:float) -> void:
	spawn()

func spawn() -> void:
	set_process(false)
	
	var customer = customer_node.instance()
	add_child(customer)
	customer.position = Vector2(350,1150)
	count += 1
	
	# do not spawn more customers if there is no table available
	while tables.get_available_table() == null:
		if not line:
			line = true
		else:
			yield(get_tree().create_timer(1), "timeout")
	
	# choose random delay time
	randomize()
	yield(get_tree().create_timer(rand_range(Global.spawn_delay-randomness, Global.spawn_delay+randomness)), "timeout")
	
	set_process(true)