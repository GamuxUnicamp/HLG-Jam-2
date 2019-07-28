# Pathfinding on a TileMap with Navigation2D (Godot 3.1 tutorial)
# GDquest <https://www.youtube.com/watch?v=0fPOt0Jw52s>

extends Node2D

enum { WAITING_IN_LINE, GOING_TO_TABLE, WAITING_MENU, DECIDING_FOOD, WAITING_TO_ORDER, WAITING_FOOD, EATING, LEAVING }

export var speed:float = 150
var path := PoolVector2Array() setget set_path
var moving:bool = false

var angry:bool = false
onready var patience:float = Global.patience
onready var patience_bar = $Patience_bar
onready var player = get_tree().get_root().find_node("Player", true, false)

var table:Area2D

var status:int = WAITING_IN_LINE
var desired_food:int

func _ready() -> void:
	$AnimatedSprite.set_sprite_frames(load('res://resource/Customer_'+str(int(rand_range(1,5.99)))+'.tres'))
	patience_bar.max_value = patience
	patience_bar.value = patience
	patience_bar.hide()

func _process(delta:float) -> void:
	if moving:
		var move_distance:float = speed * delta
		move_along_path(move_distance)
	
	match status:
		WAITING_MENU:
			patience -= delta
			patience_bar.value = patience
			if patience < 0:
				leave()
			elif patience < 2:
				infuriate()
	
		DECIDING_FOOD:
			patience -= delta
			if patience < 0:
				status = WAITING_TO_ORDER
				patience = Global.patience
				patience_bar.texture_progress = load("res://resource/pedido-papel.png")
				patience_bar.show()
	
		WAITING_TO_ORDER:
			patience -= delta
			patience_bar.value = patience
			if patience < 0:
				leave()
			elif patience < 2:
				infuriate()
	
		WAITING_FOOD:
			patience -= delta
			patience_bar.value = patience
			if patience < 0:
				leave()
			elif patience < 2:
				infuriate()
	
		EATING:
			patience -= delta
			if patience < 0:
				table.dirty = true
				table.money = int(rand_range(10,21))
				table.get_node('Food').get_node('Food_sprite').hide()
				get_parent().get_parent().happy_customers += 1
				leave()
	
		LEAVING:
			if position.y > get_viewport_rect().size.y+64:
				queue_free()

func infuriate() -> void:
	if angry: return
	angry = true

func leave() -> void:
	if status == LEAVING: return
	
	status = LEAVING
	if table and table.customer: table.customer = null
	table = null

func move_along_path(distance:float) -> void:
	var start_point:Vector2 = position
	for i in range(path.size()): # loop through all path points
		var distance_to_next:float = start_point.distance_to(path[0])
		if distance <= distance_to_next:
			position = start_point.linear_interpolate(path[0], distance / distance_to_next)
			break
		elif path.size() == 1: # when reaches the target
			position = path[0]
			moving = false
			status = WAITING_MENU
			patience_bar.show()
			$AnimatedSprite.play('Sit')
			break
		distance -= distance_to_next
		start_point = path[0]
		path.remove(0)

func set_path(value:PoolVector2Array) -> void:
	path = value
	# avoid setting process to true on initializing
	if value.size() == 0: return

func receive_waiter() -> void:
	match status:
		WAITING_MENU:
			patience_bar.hide()
			patience = rand_range(4, 15)
			status = DECIDING_FOOD
			$AnimatedSprite.play('Menu')
	
		WAITING_TO_ORDER:
			desired_food = int(rand_range(1,7.99))
			player.add_order(desired_food)
			status = WAITING_FOOD
			patience = Global.patience + 20
			patience_bar.texture_progress = load("res://resource/comida"+str(desired_food)+".png")
			patience_bar.max_value = patience
			patience_bar.show()
			$AnimatedSprite.play('Sit')
			
		WAITING_FOOD:
			if player.hands and player.hands.index == desired_food:
				var food = player.hands
				player.remove_child(food)
				table.add_child(food)
				player.hands = null
				patience = rand_range(10,30)
				patience_bar.value = patience
				patience_bar.hide()
				status = EATING
