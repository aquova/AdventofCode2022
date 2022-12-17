proc sign*(v: int): int =
    if v > 0:
        return 1
    elif v < 0:
        return -1
    return 0

proc rev*[T](s: seq[T]): seq[T] =
    var cp = s
    while cp.len() > 0:
        result.add(cp.pop())

proc `-`*[T](a: seq[T], b: seq[T]): seq[T] =
    for i in a:
        if i notin b:
            result.add(i)
