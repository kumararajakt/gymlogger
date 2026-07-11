function toInt(value, fallback) {
    var parsed = parseInt(value);
    return isNaN(parsed) ? fallback : parsed;
}

function normalizeWorkout(item) {
    item = item || {};

    return {
        exerciseId: item.exerciseId || "",
        name: item.name || "",
        gifUrl: item.gifUrl || "",
        bodyParts: item.bodyParts || "",
        targetMuscles: item.targetMuscles || "",
        secondaryMuscles: item.secondaryMuscles || "",
        equipments: item.equipments || "",
        instructions: item.instructions || "",
        sets: toInt(item.sets, 4),
        reps: toInt(item.reps, 8),
        weight: toInt(item.weight, 16),
        rest: toInt(item.rest, 75),
        expanded: item.expanded === true
    };
}

function normalizeWorkoutList(items) {
    var normalized = [];
    items = items || [];
    for (var i = 0; i < items.length; i++) {
        normalized.push(normalizeWorkout(items[i]));
    }
    return normalized;
}
