from strutils import splitLines
import strscans
import strformat

const SIZE_THRESHOLD = 100000
const NEEDED_SPACE = 30_000_000
const TOTAL_SPACE = 70_000_000

type inode = ref object
    name: string
    size: int
    parent: inode
    children: seq[inode]

proc newInode(name: string, parent: inode): inode =
    var node = new(inode)
    node.parent = parent
    node.name = name
    return node

proc addChild(node: inode, child: inode) =
    node.children.add(child)

proc addFile(node: inode, filename: string, filesize: int) =
    var file = newInode(filename, node)
    file.size = filesize
    node.addChild(file)

proc getParent(node: inode): inode =
    return node.parent

proc findChild(node: inode, name: string): inode =
    for child in node.children:
        if child.name == name:
            return child

proc calcTotalSize(node: inode) =
    for child in node.children:
        child.calcTotalSize()
        node.size += child.size

proc isDirectory(node: inode): bool =
    return node.children.len() > 0

proc findSizeUnderThreshold(node: inode): int =
    if not node.isDirectory():
        return 0

    if node.size <= SIZE_THRESHOLD:
        result += node.size
    for child in node.children:
        result += child.findSizeUnderThreshold()

proc findSmallestToDelete(node: inode, needed: int): int =
    var best_fit = TOTAL_SPACE
    if not node.isDirectory():
        return best_fit

    for child in node.children:
        let best = child.findSmallestToDelete(needed)
        if best < best_fit and best > needed:
            best_fit = best

    if node.size > needed and node.size < best_fit:
        best_fit = node.size

    return best_fit

proc generateTree(input: string): inode =
    var tree = newInode("/", nil)
    var current_node = tree
    for line in input.splitLines():
        let is_root = line.scanTuple("$$ cd /")
        let (is_cd, node_name) = line.scanTuple("$$ cd $w")
        let is_back = line.scanTuple("$$ cd ..")
        let is_ls = line.scanTuple("$$ ls")
        let (is_node, child) = line.scanTuple("dir $w")
        let (is_file, filesize, filename) = line.scanTuple("$i $*")

        if is_root:
            # We already handled the root node
            discard
        elif is_back:
            current_node = current_node.getParent()
        elif is_cd:
            current_node = current_node.findChild(node_name)
        elif is_ls:
            # Do nothing
            discard
        elif is_node:
            var childDir = newInode(child, current_node)
            current_node.addChild(childDir)
        elif is_file:
            current_node.addFile(filename, filesize)
        else:
            assert(false, &"Invalid line type: {line}")

    tree.calcTotalSize()
    return tree

proc day7p1*(input: string): string =
    let tree = generateTree(input)
    return $tree.findSizeUnderThreshold()

proc day7p2*(input: string): string =
    let tree = generateTree(input)
    let unused = TOTAL_SPACE - tree.size
    return $tree.findSmallestToDelete(NEEDED_SPACE - unused)

when isMainModule:
    from strutils import stripLineEnd

    var f: File
    discard f.open("input.txt", FileMode.fmRead)
    var input = f.readAll()
    input.stripLineEnd()
    echo(day7p2(input))

