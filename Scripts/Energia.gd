extends ColorRect


func _ready():
	pass


func _on_Jogador_mudar_status_jogador(var Jogador):
	$Barra.rect_size.x = 128 * Jogador.energia / Jogador.energia_maxima
	
func _process(delta: float):
	$Energia_atual.text = String(Mundo.energia_jogador)
