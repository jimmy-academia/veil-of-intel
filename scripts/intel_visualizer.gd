extends Node2D
class_name IntelVisualizer

@export var intel_state: IntelState
@export var game_controller: GameController

func _ready() -> void:
    set_process(true)

func _process(_delta: float) -> void:
    queue_redraw()

func _draw() -> void:
    if intel_state == null or game_controller == null:
        return

    var current_time: float = game_controller.current_time

    for object_id in intel_state.records.keys():
        var record: IntelRecord = intel_state.records[object_id]
        var age: float = current_time - record.last_seen_time

        var max_age: float = 60.0
        var t: float = clamp(age / max_age, 0.0, 1.0)

        var radius: float = 24.0 + 36.0 * t
        var color: Color = Color(0.2, 1.0 - t, 0.2, 0.8 - 0.6 * t)

        var pos_local: Vector2 = to_local(record.last_seen_position)
        draw_circle(pos_local, radius, color)
