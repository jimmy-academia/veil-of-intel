extends Node
class_name IntelState

var records: Dictionary = {}  # StringName -> IntelRecord

func update_record(
        object_id: StringName,
        position: Vector2,
        time: float,
        source: String,
        confidence: float = 1.0
    ) -> void:
    var record: IntelRecord = records.get(object_id, null)
    if record == null:
        record = IntelRecord.new()
        record.object_id = object_id
        records[object_id] = record

    record.last_seen_position = position
    record.last_seen_time = time
    record.source = source
    record.confidence = confidence

func get_record(object_id: StringName) -> IntelRecord:
    return records.get(object_id, null)

func get_age(object_id: StringName, current_time: float) -> float:
    var record: IntelRecord = records.get(object_id, null)
    if record == null:
        return 1e9
    return current_time - record.last_seen_time
