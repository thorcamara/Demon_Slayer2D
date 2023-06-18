extends Node2D


func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	Mundo.moedas = 0
	Mundo.level_00 = true

func _enter_tree():
	if Mundo.ultima_posicao_checkpoint:
		$Jogador.global_position = Mundo.ultima_posicao_checkpoint


func _on_Chegada0_Chegada_00():
	$Som_musica.stop()
