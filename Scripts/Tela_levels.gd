extends Control

var musica_bus = AudioServer.get_bus_index("Musica")
var musica_mutada = false

func _ready():
	if Mundo.musica_mutada == false:
		$CanvasLayer/Botao_musica/Slash.hide()
	elif Mundo.musica_mutada == true:
		$CanvasLayer/Botao_musica/Slash.show()
	yield(get_tree().create_timer(0.5), "timeout")
	$Som_musica.play()


func _on_Botao_monte_sagiri_pressed() -> void:
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_ordens_level_00.tscn")


func _on_Botao_monte_fujikasane_pressed() -> void:
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_ordens_level_01.tscn")


func _on_Botao_pico_da_neblina_pressed() -> void:
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_ordens_level_02.tscn")


func _on_Botao_musica_pressed() -> void:
	
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
	

func _on_Botao_voltar_pressed() -> void:
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_inicial.tscn")
