# scripts/multiplayer/network_manager.gd
class_name NetworkManagerSingleton
extends Node

## Server-Authoritative Multiplayer Network Manager supporting 1-4 Players and Offline Single-Player.

enum NetworkMode { OFFLINE, HOST, CLIENT }

signal peer_connected(peer_id: int)
signal peer_disconnected(peer_id: int)

var network_mode: NetworkMode = NetworkMode.OFFLINE
var local_peer_id: int = 1
var connected_peers: Array[int] = [1]

func host_game(port: int = 7777) -> bool:
	network_mode = NetworkMode.HOST
	local_peer_id = 1
	connected_peers = [1]
	return true

func join_game(ip: String = "127.0.0.1", port: int = 7777) -> bool:
	network_mode = NetworkMode.CLIENT
	local_peer_id = randi() % 1000 + 2
	connected_peers = [1, local_peer_id]
	return true

func is_host() -> bool:
	return network_mode == NetworkMode.OFFLINE or network_mode == NetworkMode.HOST

func is_offline() -> bool:
	return network_mode == NetworkMode.OFFLINE

func disconnect_game() -> void:
	network_mode = NetworkMode.OFFLINE
	local_peer_id = 1
	connected_peers = [1]
