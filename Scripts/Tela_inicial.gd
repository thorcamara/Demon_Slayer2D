extends Control


func _ready():
	$Som_musica.play()
	$Botao_start.grab_focus()

func _physics_process(delta):
	if !Mundo.controle_desligado:
		$Botao_start.grab_focus()
		Mundo.controle_desligado = true
		
func _on_Botao_start_pressed():
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Levels/Level_01.tscn")


func _on_Botao_controles_pressed():
#	var tela_controles = load("res://Scenes/Tela_controles.tscn").instance()
	$Som_musica.stop()
	$Som_pressionou.play()
#	get_tree().current_scene.add_child(tela_controles)
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().change_scene("res://Scenes/Tela_controles.tscn")


func _on_Botao_quit_pressed():
	$Som_musica.stop()
	$Som_pressionou.play()
	yield(get_tree().create_timer(0.5), "timeout")
	get_tree().quit()
