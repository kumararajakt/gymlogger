const BASE_URL = "https://oss.exercisedb.dev/api/v1"

function _request(url) {
    return new Promise(function(resolve, reject) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url, true)
        xhr.onreadystatechange = function() {
            if (xhr.readyState === 4) {
                if (xhr.status === 200) {
                    resolve(JSON.parse(xhr.responseText))
                } else {
                    reject("HTTP " + xhr.status)
                }
            }
        }
        xhr.send()
    })
}

function fetchExercises(params) {
    var url = BASE_URL + "/exercises?"
    var parts = []
    if (params.name) parts.push("name=" + encodeURIComponent(params.name))
    if (params.bodyParts) parts.push("bodyParts=" + encodeURIComponent(params.bodyParts))
    if (params.targetMuscles) parts.push("targetMuscles=" + encodeURIComponent(params.targetMuscles))
    if (params.secondaryMuscles) parts.push("secondaryMuscles=" + encodeURIComponent(params.secondaryMuscles))
    if (params.equipments) parts.push("equipments=" + encodeURIComponent(params.equipments))
    if (params.after) parts.push("after=" + params.after)
    if (params.limit) parts.push("limit=" + params.limit)
    url += parts.join("&")
    return _request(url)
}

function searchExercises(term) {
    var url = BASE_URL + "/exercises/search?search=" + encodeURIComponent(term) + "&threshold=0.5"
    return _request(url)
}

function fetchExerciseById(id) {
    return _request(BASE_URL + "/exercises/" + encodeURIComponent(id))
}

function fetchBodyParts() {
    return _request(BASE_URL + "/bodyparts")
}

function fetchEquipments() {
    return _request(BASE_URL + "/equipments")
}

function fetchMuscles() {
    return _request(BASE_URL + "/muscles")
}
