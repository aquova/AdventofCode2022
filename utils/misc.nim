proc sign*(v: int): int =
    if v > 0:
        return 1
    elif v < 0:
        return -1
    return 0

