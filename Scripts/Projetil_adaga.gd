extends Area2D

var velocidade_projetil = 400

var movimento_projetil = Vector2.ZERO
var direcao = -1

var saude_projetil = 1

func _ready():
	self.rotation_degrees = -134

func set_direcao(dir):
	direcao = dir
	if direcao == 1:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true

		

func _physics_process(delta: float):
	print(self.rotation_degrees)
	movimento_projetil.x = velocidade_projetil * delta * direcao
	translate(movimento_projetil)

func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Projetil_adaga_area_entered(area):
	if area.is_in_group("projeteis") or area.is_in_group("espada"):
		velocidade_projetil = 0
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()
		

func _on_Projetil_adaga_body_entered(body):
	if body.name == "Jogador":
		velocidade_projetil = 0
		body.sofreu_dano(30)
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()
