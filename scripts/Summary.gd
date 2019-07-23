extends Node2D

onready var tween_node = $Tween

var going_up:bool = false

func _ready():
	tween_node.connect('tween_completed', self, 'timeout')
	get_node('Shop_button/Button').connect('button_down', self, 'open_shop')
	get_node('Next_Day/Button').connect('button_down', self, 'go_up')
	get_node('Shop/Exit').connect('button_down', self, 'close_shop')
	get_node('Shop/Shoes/Button').connect('button_down', self, 'buy_shoes')
	get_node('Shop/Etiquette/Button').connect('button_down', self, 'buy_etiquette')
	get_node('Shop/Cat_Ears/Button').connect('button_down', self, 'buy_cat_ears')
	
	go_down() # start animation

# update money every frame
func _process(delta:float) -> void:
	$Shop_button/Label.text = 'Banco: $' + str(Global.player_money)
	$Shop/Money.text = 'Banco: $' + str(Global.player_money)

# set text values
func initialize(profit:int, total_customers:int, happy_customers:int) -> void:
	$Profit.text = 'Lucro: $' + str(profit)
	$Total_customers.text = 'Clientes atendidos: ' + str(total_customers)
	$Happy_customers.text = 'Clientes satisfeitos: ' + str(happy_customers)
	$Next_Day/Label.text = 'Dia ' + str(Global.day+1) + ' de 7'

# animation to move downward
func go_down() -> void:
	tween_node.interpolate_property(self, 'position:y', position.y, 0, 3, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween_node.start()

# animation to move upward
func go_up() -> void:
	# when this animation finishes, whe should destroy this object
	if not going_up: going_up = true
	
	tween_node.interpolate_property(self, 'position:y', position.y, -1080, 4, Tween.TRANS_BOUNCE, Tween.EASE_OUT)
	tween_node.start()

func open_shop() -> void:
	var shop = $Shop
	tween_node.interpolate_property(shop, 'rect_position:x', shop.rect_position.x, 32, 1.2, Tween.TRANS_EXPO, Tween.EASE_OUT)
	tween_node.start()

func close_shop() -> void:
	var shop = $Shop
	tween_node.interpolate_property(shop, 'rect_position:x', shop.rect_position.x, -1880, 0.8, Tween.TRANS_EXPO, Tween.EASE_IN)
	tween_node.start()

func buy_shoes() -> void:
	if Global.player_money >= 50:
		Global.player_money -= 50
		Global.player_speed += 50

func buy_etiquette() -> void:
	if Global.player_money >= 50:
		Global.player_money -= 50
		Global.patience += 2

func buy_cat_ears() -> void:
	if Global.player_money >= 50:
		Global.player_money -= 50
		Global.spawn_delay -= 1

# destroy object when it finishes going up
func timeout(obj, key) -> void:
	if going_up:
		get_parent().next_day()
		queue_free()