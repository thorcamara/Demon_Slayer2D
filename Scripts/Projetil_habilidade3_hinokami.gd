extends Area2D


var velocidade_projetil = 300

var movimento_projetil = Vector2.ZERO
var direcao = 1

var saude_projetil = 2

func _ready():
	pass

func set_direcao(dir):
	direcao = dir
	if direcao == 1:
		$Sprite.flip_h = false
	else:
		$Sprite.flip_h = true
		$Particles2D.scale.x = -$Particles2D.scale.x
		$Particles2D.position.x = -$Particles2D.position.x
		
	
func _physics_process(delta: float):
	movimento_projetil.x = velocidade_projetil * delta * direcao
	translate(movimento_projetil)


func _on_VisibilityNotifier2D_screen_exited():
	queue_free()

func _on_Projetil_habilidade3_hinokami_area_entered(area):
	if area.is_in_group("inimigos") or area.is_in_group("projeteis"):
		saude_projetil -= 1
		if saude_projetil <= 0:
			queue_free()
