import strscans
import strutils

type Voxel = tuple
    x, y, z: int

proc get_neighbors(v: Voxel): seq[Voxel] =
    result.add((v.x, v.y, v.z - 1))
    result.add((v.x, v.y, v.z + 1))
    result.add((v.x, v.y - 1, v.z))
    result.add((v.x, v.y + 1, v.z))
    result.add((v.x - 1, v.y, v.z))
    result.add((v.x + 1, v.y, v.z))

proc num_neighbors(v: Voxel, voxels: seq[Voxel]): int =
    result = 0
    let neighbors = v.get_neighbors()
    for n in neighbors:
        if n in voxels:
            inc(result)

proc get_bounding_dim(voxels: seq[Voxel]): array[2, Voxel] =
    var min_values: Voxel = (0, 0, 0)
    var max_values: Voxel = (0, 0, 0)

    for v in voxels:
        min_values.x = min(min_values.x, v.x)
        min_values.y = min(min_values.y, v.y)
        min_values.z = min(min_values.z, v.z)

        max_values.x = max(max_values.x, v.x)
        max_values.y = max(max_values.y, v.y)
        max_values.z = max(max_values.z, v.z)

    # Add a buffer around it
    min_values = (min_values.x - 2, min_values.y - 2, min_values.z - 2)
    max_values = (max_values.x + 2, max_values.y + 2, max_values.z + 2)
    return [min_values, max_values]

proc in_bounds(v, min_boundary, max_boundary: Voxel): bool =
    return v.x >= min_boundary.x and v.y >= min_boundary.y and v.z >= min_boundary.z and v.x <= max_boundary.x and v.y <= max_boundary.y and v.z <= max_boundary.z

proc flood_fill_helper(v: Voxel, checked: var seq[Voxel], obsidian: seq[Voxel], min_boundary: Voxel, max_boundary: Voxel) =
    let neighbors = v.get_neighbors()
    for n in neighbors:
        if n.in_bounds(min_boundary, max_boundary):
            if n notin obsidian and n notin checked:
                checked.add(n)
                flood_fill_helper(n, checked, obsidian, min_boundary, max_boundary)

proc flood_fill(voxels: seq[Voxel]): seq[Voxel] =
    let boundaries = voxels.get_bounding_dim()
    let min_boundary = boundaries[0]
    let max_boundary = boundaries[1]
    var checked = @[min_boundary]
    flood_fill_helper(min_boundary, checked, voxels, min_boundary, max_boundary)
    return checked

proc day18p1*(input: string): string =
    var voxels: seq[Voxel]
    for line in input.splitLines():
        let (success, x, y, z) = line.scanTuple("$i,$i,$i")
        if success:
            voxels.add((x, y, z))
    var cnt = 0
    for v in voxels:
        cnt += 6 - v.num_neighbors(voxels)
    return $cnt

proc day18p2*(input: string): string =
    var voxels: seq[Voxel]
    for line in input.splitLines():
        let (success, x, y, z) = line.scanTuple("$i,$i,$i")
        if success:
            voxels.add((x, y, z))
    var cnt = 0
    let outside = voxels.flood_fill()
    for v in outside:
        cnt += v.num_neighbors(voxels)
    return $cnt
