extends Area2D

var mouse_over:bool = false

onready var player:Node2D = get_tree().get_root().find_node("Player", true, false)
onready var slots:Node2D = $Slots
var food_node:PackedScene = preload('res://scenes/Food.tscn')

var busy_slots = 0

func _ready():
	connect("area_entered", self, "_on_area_enter")
	connect("mouse_entered", self, "_on_mouse_enter")
	connect("mouse_exited", self, "_on_mouse_exit")

func _process(delta):
	if self in player.interactions:
		get_node("Sprite").material.set_shader_param("width", 20)
	
	for slot in slots.get_children():
		if slot.is_class('TextureProgress') and slot.visible:
			if slot.value < slot.max_value:
				slot.value += delta
			elif slot.get_child_count() == 1:
				slot.get_child(0).show()

func _input(event):
	if Input.is_action_just_pressed('click') and mouse_over:
		if not self in player.interactions:
			player.interactions.push_back(self)

func _on_area_enter(area):
	if player.interactions.size() > 0 and player.interactions[0] == self:
		player.interactions.pop_front()
		get_node("Sprite").material.set_shader_param("width", 0)
		
		if busy_slots <= slots.get_child_count():
			while player.orders.size() > 0:
				for slot in slots.get_children():
					if not slot.visible:
						var food = food_node.instance()
						food.index = player.remove_order()
						slot.add_child(food)
						food.hide()
						busy_slots += 1
						slot.max_value = rand_range(5,10)
						slot.value = 0
						slot.show()
						break
		
		if player.hands == null:
			for slot in slots.get_children():
				if slot.visible and slot.get_child_count() == 1 and slot.get_child(0).visible:
					var food = slot.get_child(0)
					slot.remove_child(food)
					player.add_child(food)
					player.hands = food
					food.set_global_position(player.get_global_position() + Vector2(64,0))
					slot.hide()
					break

func _on_mouse_enter():
	mouse_over = true
	get_node("Sprite").material.set_shader_param("width", 10)

func _on_mouse_exit():
	mouse_over = false
	if not self in player.interactions:
		get_node("Sprite").material.set_shader_param("width", 0)