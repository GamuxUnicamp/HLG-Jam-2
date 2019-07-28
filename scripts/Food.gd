extends Node2D

var index

func set_sprite(index:int) -> void:
	self.index = index
	match index:
		1: $Food_sprite.set_texture(preload('res://resource/comida1.png'))
		2: $Food_sprite.set_texture(preload('res://resource/comida2.png'))
		3: $Food_sprite.set_texture(preload('res://resource/comida3.png'))
		4: $Food_sprite.set_texture(preload('res://resource/comida4.png'))
		5: $Food_sprite.set_texture(preload('res://resource/comida5.png'))
		6: $Food_sprite.set_texture(preload('res://resource/comida6.png'))
		7: $Food_sprite.set_texture(preload('res://resource/comida7.png'))