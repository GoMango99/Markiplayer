extends Node2D
class_name Multiplayer


var peer = ENetMultiplayerPeer.new()
var idCount = 5
@export var player_scene: PackedScene

@export var host: Button
@export var join: Button
@export var text: LineEdit

func _on_host_pressed():
	
	# Creates a server on port 135
	peer.create_server(135)
	host.disabled = true
	join.disabled = true
	multiplayer.multiplayer_peer = peer
	multiplayer.peer_connected.connect(_add_player)
	_add_player()
 
func _add_player(id = 1):
	# Instantiates a new player
	var newPlayer = player_scene.instantiate()
	newPlayer.name = str(id)
	call_deferred("add_child",newPlayer)
 
func _add_scene(scene: PackedScene):
	var newScene = scene.instantiate()
	newScene.name = str(idCount)
	idCount += 1
	call_deferred("add_child",newScene)
	

func _on_join_pressed():
	peer.create_client(text.text, 135)
	host.disabled = true
	join.disabled = true
	multiplayer.multiplayer_peer = peer
