extends Node2D


func _ready():
	show()


func _on_Armadilha_corda2_JogadorCaiu():
	$Som_caiu.play()
	yield($Som_caiu, "finished")
	queue_free()
