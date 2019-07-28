extends Node2D

var index

func set_sprite(index:int) -> void:
	self.index = index
	$Food_sprite.set_texture(load('res://resource/comida'+str(index)+'.png'))