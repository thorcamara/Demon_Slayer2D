extends Control

var musica_bus = AudioServer.get_bus_index("Musica")
var musica_mutada = false

func _ready():
	$Corvo.hide()
	if Mundo.musica_mutada == false:
		$CanvasLayer/Botao_musica/Slash.hide()
	elif Mundo.musica_mutada == true:
		$CanvasLayer/Botao_musica/Slash.show()
	yield(get_tree().create_timer(0.5), "timeout")
	$Som_vitoria.play()
	yield(get_tree().create_timer(2), "timeout")
	$Corvo.show()
	$Som_corvo.play()


func _on_Botao_resposta_pressed():
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_vencedor.tscn")


func _on_Botao_musica_pressed():
	
	if Mundo.musica_mutada == false:
		Mundo.musica_mutada = true
	elif Mundo.musica_mutada == true:
		Mundo.musica_mutada = false
	
	if Mundo.musica_mutada == false:
		$CanvasLayer/Botao_musica/Slash.hide()
	elif Mundo.musica_mutada == true:
		$CanvasLayer/Botao_musica/Slash.show()
		
	$Som_pressionou.play()
	AudioServer.set_bus_mute(musica_bus, not AudioServer.is_bus_mute(musica_bus))
