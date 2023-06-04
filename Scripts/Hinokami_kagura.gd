extends ColorRect


func _ready():
	pass

func _on_Jogador_mudar_status_jogador(var Jogador):
	$Barra.rect_size.x = 128 * Jogador.hinokami / Jogador.hinokami_maxima
	
func _process(delta: float):
	$Hinokami_atual.text = String(Mundo.hinokami_jogador)
