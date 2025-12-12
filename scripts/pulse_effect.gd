extends Node2D
class_name Messenger

signal order_arrived(order: Order, target_army: Army)
signal report_arrived(report_text: String, source_army: Army)

enum MessengerType { ORDER, REPORT }

@export var messenger_type: MessengerType = MessengerType.ORDER
@export var speed: float = 120.0

var path: PackedVector2Array = PackedVector2Array()
var path_index: int = 0
var payload_order: Order
var payload_report_text: String = ""
var target_army: Army
var source_army: Army
var arrived: bool = false

func setup_order(path_points: PackedVector2Array, order: Order, target: Army) -> void:
    messenger_type = MessengerType.ORDER
    path = path_points
    path_index = 0
    payload_order = order
    target_army = target
    arrived = false
    if path.size() > 0:
        global_position = path[0]

func setup_report(path_points: PackedVector2Array, report_text: String, source: Army) -> void:
    messenger_type = MessengerType.REPORT
    path = path_points
    path_index = 0
    payload_report_text = report_text
    source_army = source
    arrived = false
    if path.size() > 0:
        global_position = path[0]

func _process(delta: float) -> void:
    if arrived or path.size() == 0:
        return

    var target_pos: Vector2 = path[path_index]
    var direction := target_pos - global_position
    var distance_to_travel := speed * delta
    var distance_remaining := direction.length()

    if distance_remaining <= distance_to_travel:
        global_position = target_pos
        path_index += 1
        if path_index >= path.size():
            _on_reached_destination()
    else:
        var dir_norm := direction / distance_remaining
        global_position += dir_norm * distance_to_travel

func _on_reached_destination() -> void:
    arrived = true
    match messenger_type:
        MessengerType.ORDER:
            if payload_order != null and target_army != null:
                order_arrived.emit(payload_order, target_army)
        MessengerType.REPORT:
            report_arrived.emit(payload_report_text, source_army)

    queue_free()
