extends StaticBody2D

signal PortaFechada

func _ready():
	pass

func _on_Acionar_JogadorEntrou():
	$AnimationPlayer.play("ativada")


func _on_Muzan_Muzan_morto():
	$AnimationPlayer.play("desativada")
