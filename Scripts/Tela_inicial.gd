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

func _physics_process(delta):
	if !Mundo.controle_desligado:
		Mundo.controle_desligado = true
		
func _on_Botao_start_pressed():
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_levels.tscn")


func _on_Botao_controles_pressed():
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_controles.tscn")


func _on_Botao_quit_pressed():
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()


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

func _on_Botao_info_pressed() -> void:
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_Info.tscn")


func _on_Botao_creditos_pressed():
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Telas/Tela_creditos.tscn")
