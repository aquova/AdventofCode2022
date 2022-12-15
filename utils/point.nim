type Point*[T] = tuple
    x, y: T

proc newPoint*[T](x, y: T): Point[T] =
    result.x = x
    result.y = y

proc `+`*[T](a: Point[T], b: Point[T]): Point[T] =
    return (a.x + b.x, a.y + b.y)

proc `+=`*[T](a: var Point[T], b: Point[T]) =
    a = a + b

proc `-`*[T](a: Point[T], b: Point[T]): Point[T] =
    return (a.x - b.x, a.y - b.y)

proc `-=`*[T](a: var Point[T], b: Point[T]) =
    a = a - b

proc `*`*[T](a: Point[T], v: T): Point[T] =
    return (a.x * v, a.y * v)

proc `*=`*[T](a: var Point[T], v: T) =
    a = a * v

proc manhattan_dist*[T](a: Point[T], b: Point[T]): T =
    return abs(a.x - b.x) + abs(a.y - b.y)

iterator neighbors*[T](p: Point[T]): Point[T] =
    yield (p.x - 1, p.y)
    yield (p.x + 1, p.y)
    yield (p.x, p.y - 1)
    yield (p.x, p.y + 1)

