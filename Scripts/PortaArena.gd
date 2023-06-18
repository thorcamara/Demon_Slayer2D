extends StaticBody2D

signal PortaFechada

func _ready():
	pass

func _on_Acionar_JogadorEntrou():
	$AnimationPlayer.play("ativada")



func _on_Guerreiro_trevas_Guerreiro_trevas_morto():
	$AnimationPlayer.play("desativada")


func _on_Acionar_02_JogadorEntrou():
	$AnimationPlayer.play("ativada")


func _on_Portador_morte_Portador_morte_morto():
	$AnimationPlayer.play("desativada")


func _on_Muzan_Muzan_morto():
	$AnimationPlayer.play("desativada")
