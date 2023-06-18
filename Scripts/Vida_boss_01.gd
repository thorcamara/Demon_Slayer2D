extends ColorRect


func _ready():
	hide()
	$Barra_boss_01.color = Color(0.04, 0.50, 0.10, 1)

func _process(delta: float):
	if $Barra_boss_01.rect_size.x <= 296 and $Barra_boss_01.rect_size.x >= 148:
		$Barra_boss_01.color = Color(0.04, 0.50, 0.10, 1.00)
	elif $Barra_boss_01.rect_size.x < 148 and $Barra_boss_01.rect_size.x > 74:
		$Barra_boss_01.color = Color(1.00, 0.50, 0.10, 1.00)
	elif $Barra_boss_01.rect_size.x < 74:
		$Barra_boss_01.color = Color(0.76, 0.00, 0.00, 1.00)


func _on_Acionar_JogadorEntrou():
	show()

func _on_Guerreiro_trevas_mudar_status_guerreiro_escuridao(var Guerreiro_trevas):
	$Barra_boss_01.rect_size.x = 296 * Guerreiro_trevas.vida / Guerreiro_trevas.vida_maxima


func _on_Guerreiro_trevas_Guerreiro_trevas_morto():
	hide()
