extends Area2D

var velocidade_projetil = 300

var movimento_projetil = Vector2.ZERO
var direcao = 1

func _ready():
	pass

func set_direcao(dir):
	direcao = dir
	if direcao == 1:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
		
	
func _physics_process(delta: float):
	movimento_projetil.x = velocidade_projetil * delta * direcao
	translate(movimento_projetil)
	
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Bomba_area_entered(area):
	if area.is_in_group("projeteis") or area.is_in_group("espada"):
		print("Bomba causou dano")
		$AnimationPlayer.play("Colidiu")
		$Som_bomba.play()
		velocidade_projetil = 0
		$CollisionShape2D.set_deferred("disabled", true)
		yield($AnimationPlayer, "animation_finished")
		queue_free()


func _on_Bomba_body_entered(body):
	if body.name == "Jogador":
		print("Bomba causou dano")
		$AnimationPlayer.play("Colidiu")
		$Som_bomba.play()
		velocidade_projetil = 0
		body._sofreu_dano(30)
		$CollisionShape2D.set_deferred("disabled", true)
		yield($AnimationPlayer, "animation_finished")
		queue_free()
