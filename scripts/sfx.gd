class_name Sfx
## Jednorázové zvukové efekty. Přehrávač se přidá do kořene stromu, takže zvuk dohraje,
## i když jeho zdroj zmizí (sebraná mince) nebo se přepne svět; po dohrání se smaže.

## Společná hlasitost všech efektů (-5 dB je zhruba polovina původní hlasitosti)
const VOLUME_DB := -5.0


## Bez obrazovky (testy, kontrola z AGENTS.md) nehraje, stejně jako hudba: nic by nebylo
## slyšet a Godot by při ukončení hlásil nedohrané přehrávání jako chybu.
static func play(stream: AudioStream, volume_db := 0.0) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db + VOLUME_DB
	player.autoplay = true
	player.finished.connect(player.queue_free)
	(Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(player)
