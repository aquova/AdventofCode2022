const output_p = document.getElementById("output")

document.getElementById("fileinput").addEventListener("change", function(e) {
    let file = e.target.files[0]
    if (!file) {
        alert("Failed to read file")
        return
    }

    let fr = new FileReader()
    fr.onload = function(e) {
        let buffer = fr.result
        buffer = buffer.replace(/\n$/, "") // Remove trailing new lines
        let selected = document.querySelector("input[name='aoc']:checked").value
        let output = execute(selected, buffer)
        output_p.innerHTML = output
    }
    fr.readAsText(file)
}, false)
