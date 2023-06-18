extends Control

var master_bus = AudioServer.get_bus_index("Master")

func _ready():
	$Sprite.show()
	$Sprite2.hide()
	$Sprite3.hide()
	$Botao_retornar.grab_focus()


func _on_HSlider_value_changed(value: float):
	AudioServer.set_bus_volume_db(master_bus, value)

	if value > -15:
		$Sprite.show()
		$Sprite2.hide()
		$Sprite3.hide()
	elif value <= -15 and value != -30:
		$Sprite.hide()
		$Sprite2.show()
		$Sprite3.hide()
	elif value == -30:
		$Sprite.hide()
		$Sprite2.hide()
		$Sprite3.show()
	
	if value == -30:
		AudioServer.set_bus_volume_db(master_bus, true)
	else:
		AudioServer.set_bus_volume_db(master_bus, false)


func _on_Botao_retornar_pressed() -> void:
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	queue_free()
	get_tree().change_scene("res://Scenes/Tela_inicial.tscn")
	
