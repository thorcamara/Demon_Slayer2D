extends ColorRect


func _ready():
	$Barra.color = Color(0.04, 0.50, 0.10, 1)

func _process(delta: float):
	if $Barra.rect_size.x <= 128 and $Barra.rect_size.x >= 64:
		$Barra.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Barra.rect_size.x < 64 and $Barra.rect_size.x > 32:
		$Barra.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Barra.rect_size.x < 32:
		$Barra.color = Color(0.76, 0.00, 0.00, 1.00)
	$Vida_atual.text = String(Mundo.vida_jogador)
	$Vida_max.text = String(Mundo.vida_maxima_jogador)

func _on_Jogador_mudar_status_jogador(var Jogador):
	$Barra.rect_size.x = 128 * Jogador.vida / Jogador.vida_maxima
