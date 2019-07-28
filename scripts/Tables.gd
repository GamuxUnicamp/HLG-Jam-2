extends Node

onready var tables = get_children()

func get_available_table() -> Area2D:
	for table in tables:
		if table.customer == null and table.get_node('Food') == null:
			return table
	return null