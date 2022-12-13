from algorithm import sort
import strutils
import json

const DIVIDER_PACKET_A = "[[2]]"
const DIVIDER_PACKET_B = "[[6]]"

proc cmp(left: JsonNode, right: JsonNode): int =
  var idx = 0
  while idx < left.len():
    if idx >= right.len():
      return 1

    let l = left[idx]
    let r = right[idx]
    var check = 0
    if l == r:
      discard
    elif l.kind == JInt and r.kind == JInt:
      check = l.getInt().cmp(r.getInt())
    elif l.kind == JArray and r.kind == JArray:
      check = l.cmp(r)
    elif l.kind == JInt and r.kind == JArray:
      var new_array = newJArray()
      new_array.add(l)
      check = new_array.cmp(r)
    else:
      var new_array = newJArray()
      new_array.add(r)
      check = l.cmp(new_array)

    if check != 0:
      return check
    inc(idx)
  return if left.len() < right.len(): -1 else: 0

proc day13p1*(input: string): string =
  var sum = 0
  var idx = 0
  let pairs = input.split("\n\n")
  while idx < pairs.len():
    let pair = pairs[idx].split("\n")
    let left = parseJson(pair[0])
    let right = parseJson(pair[1])
    if left.cmp(right) == -1:
      sum += idx + 1
    inc(idx)
  return $sum

proc day13p2*(input: string): string =
  let input = input.replace("\n\n", "\n")
  var pairs = input.split("\n")
  pairs.add(DIVIDER_PACKET_A)
  pairs.add(DIVIDER_PACKET_B)

  var obj: seq[JsonNode]
  for item in pairs:
    obj.add(parseJson(item))
  sort(obj, cmp)

  var output = 1
  for idx, item in obj.pairs():
    if $item == DIVIDER_PACKET_A or $item == DIVIDER_PACKET_B:
      output *= (idx + 1)
  return $output
