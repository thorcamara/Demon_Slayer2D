extends KinematicBody2D

var movimento = Vector2.ZERO
var gravidade = 720

func _ready():
	pass

func _physics_process(delta: float):
	movimento.y += gravidade * delta
	
	movimento = move_and_slide(movimento)
	
func _on_Area2D_body_entered(body):
	if body.is_in_group("jogador"):
		Mundo.vida_jogador += 30
		body.vida += 30
		$Som_vida.play()
		hide()
		$CollisionShape2D.set_deferred("disabled", true)
		yield($Som_vida, "finished")
		queue_free()
