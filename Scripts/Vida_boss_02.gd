extends ColorRect


func _ready():
	hide()
	$Barra_boss_02.color = Color(0.04, 0.50, 0.10, 1)

func _process(delta: float):
	if $Barra_boss_02.rect_size.x <= 296 and $Barra_boss_02.rect_size.x >= 148:
		$Barra_boss_02.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Barra_boss_02.rect_size.x < 148 and $Barra_boss_02.rect_size.x > 74:
		$Barra_boss_02.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Barra_boss_02.rect_size.x < 74:
		$Barra_boss_02.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Portador_morte_mudar_status_portador_morte(var Portador_morte):
	$Barra_boss_02.rect_size.x = 296 * Portador_morte.vida / Portador_morte.vida_maxima

func _on_Acionar_02_JogadorEntrou():
	show()

func _on_Portador_morte_Portador_morte_morto():
	hide()
