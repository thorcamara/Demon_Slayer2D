extends ColorRect


func _ready():
	hide()
	$Barra_boss.color = Color(0.04, 0.50, 0.10, 1)

func _process(delta: float):
	if $Barra_boss.rect_size.x <= 296 and $Barra_boss.rect_size.x >= 148:
		$Barra_boss.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Barra_boss.rect_size.x < 148 and $Barra_boss.rect_size.x > 74:
		$Barra_boss.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Barra_boss.rect_size.x < 74:
		$Barra_boss.color = Color(0.76, 0.00, 0.00, 1.00)

func _on_Muzan_mudar_status_muzan(var Muzan):
	$Barra_boss.rect_size.x = 296 * Muzan.vida / Muzan.vida_maxima


func _on_Acionar_JogadorEntrou():
	show()


func _on_Muzan_Muzan_morto():
	hide()
