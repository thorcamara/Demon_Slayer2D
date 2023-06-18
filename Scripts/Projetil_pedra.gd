extends Area2D

var velocidade_projetil = 400

var movimento_projetil = Vector2.ZERO
var direcao = -1

var saude_projetil = 1

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

func _on_Projetil_pedra_area_entered(area):
	if area.is_in_group("projeteis") or area.is_in_group("espada"):
		print("Colidiu area ", area.name)
		velocidade_projetil = 0
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()
		

func _on_Projetil_pedra_body_entered(body):
	if body.name == "Jogador":
		print("Colidiu player ", body.name)
		velocidade_projetil = 0
		body.sofreu_dano(30)
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()
