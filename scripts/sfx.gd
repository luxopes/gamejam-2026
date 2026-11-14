class_name Sfx
## Přehrávání jednorázových zvuků.

const VOLUME_DB := -5.0


static func play(stream: AudioStream, volume_db := 0.0) -> void:
	if DisplayServer.get_name() == "headless":
		return
	var player := AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = volume_db + VOLUME_DB
	player.autoplay = true
	player.finished.connect(player.queue_free)
	# Zvuk dohraje i po smazání mince nebo výměně scény.
	(Engine.get_main_loop() as SceneTree).root.add_child.call_deferred(player)
