extends KinematicBody2D

var velocidade_projetil = 400

var movimento_projetil = Vector2.ZERO
var direcao = 1

var gravidade = 1

var saude_projetil = 1

func _ready():
	$Som_1.play()
	yield($Som_1, "finished")

func _physics_process(delta: float):
	movimento_projetil.y += gravidade
	translate(movimento_projetil)
	
	movimento_projetil = move_and_slide(movimento_projetil)
	
	caiu_chao()


func caiu_chao():
	yield(get_tree().create_timer(0.5), "timeout")
	$Detector.monitoring = false

		
func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Detector_area_entered(area):
	if area.is_in_group("projeteis") or area.is_in_group("espada"):
		velocidade_projetil = 0
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()

func _on_Detector_body_entered(body):
	if body.name == "Jogador":
		velocidade_projetil = 0
		body.sofreu_dano(250)
		$CollisionShape2D.set_deferred("disabled", true)
		queue_free()
