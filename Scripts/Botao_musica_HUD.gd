extends TextureButton

var musica_bus = AudioServer.get_bus_index("Musica")
var musica_mutada = false

func _ready() -> void:
	if Mundo.musica_mutada == false:
		$Slash.hide()
	elif Mundo.musica_mutada == true:
		$Slash.show()

func _on_Botao_musica_HUD_pressed() -> void:
	if Mundo.musica_mutada == false:
		Mundo.musica_mutada = true
	elif Mundo.musica_mutada == true:
		Mundo.musica_mutada = false
	
	if Mundo.musica_mutada == false:
		$Slash.hide()
	elif Mundo.musica_mutada == true:
		$Slash.show()
		
	$Som_pressionou.play()
	AudioServer.set_bus_mute(musica_bus, not AudioServer.is_bus_mute(musica_bus))
