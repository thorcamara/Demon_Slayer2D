extends ColorRect


func _ready():
	$AnimationPlayer.play("Resetado")

func _process(delta):
	if Mundo.habilidade3_cooldown_pronto == true and Mundo.hinokami_ativado == false:
		$AnimationPlayer.play("Resetado")
	elif Mundo.habilidade3_cooldown_pronto == true and Mundo.hinokami_ativado == true:
		$AnimationPlayer.play("Resetado_hinokami")
		
	if Mundo.habilidade3_cooldown_pronto == false and Mundo.hinokami_ativado == false:
		$AnimationPlayer.play("Cooldown")
	elif Mundo.habilidade3_cooldown_pronto == false and Mundo.hinokami_ativado == true:
		$AnimationPlayer.play("Cooldown_hinokami")
