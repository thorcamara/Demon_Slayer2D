extends ColorRect


func _ready():
	$AnimationPlayer.play("Resetado")

func _process(delta):
	if Mundo.ultimate_cooldown_pronto == true and Mundo.hinokami_ativado == false:
		$AnimationPlayer.play("Resetado")
	elif Mundo.ultimate_cooldown_pronto == true and Mundo.hinokami_ativado == true:
		$AnimationPlayer.play("Resetado_hinokami")
		
	if Mundo.ultimate_cooldown_pronto == false and Mundo.hinokami_ativado == false:
		$AnimationPlayer.play("Cooldown")
	elif Mundo.ultimate_cooldown_pronto == false and Mundo.hinokami_ativado == true:
		$AnimationPlayer.play("Cooldown_hinokami")
