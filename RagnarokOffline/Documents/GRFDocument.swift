//
//  GRFDocument.swift
//  RagnarokOffline
//
//  Created by Leon Li on 2020/5/1.
//  Copyright © 2020 Leon & Vane. All rights reserved.
//

import grf

struct GRFTreeNode {

    fileprivate let grf: grf_handle
    fileprivate var node = grf_treenode(nil)

    var isDirectory: Bool {
        grf_tree_is_dir(node)
    }

    var name: String {
        if grf_tree_is_dir(node) {
            return grf_tree_get_name(node)
                .flatMap({ String(cString: $0, encoding: .koreanEUC) }) ?? ""
        } else {
            return grf_tree_get_file(node)
                .flatMap { grf_file_get_basename($0) }
                .flatMap { String(cString: $0, encoding: .koreanEUC) } ?? ""
        }
    }

    var path: String {
        if grf_tree_is_dir(node) {
            return grf_tree_get_name(node)
                .flatMap({ String(cString: $0, encoding: .koreanEUC) }) ?? ""
        } else {
            return grf_tree_get_file(node)
                .flatMap { grf_file_get_filename($0) }
                .flatMap { String(cString: $0, encoding: .koreanEUC) } ?? ""
        }
    }

    var contents: Data? {
        if grf_tree_is_dir(node) {
            return nil
        }

        guard let file = grf_tree_get_file(node) else {
            return nil
        }

        let size = grf_file_get_size(file)
        let ptr = malloc(Int(size))
        guard grf_file_get_contents(file, ptr) == size else {
            free(ptr)
            return nil
        }

        let contents = Data(bytesNoCopy: ptr!, count: Int(size), deallocator: .free)
        return contents
    }

    var children: [GRFTreeNode] {
        let count = grf_tree_dir_count_files(node)
        guard let list = grf_tree_list_node(node) else {
            return []
        }

        let children = (0..<count).map { i in
            let child = GRFTreeNode(grf: grf, node: list[Int(i)])
            return child
        }

        free(list)

        return children
    }
}

class GRFDocument {

    let url: URL

    private var grf: grf_handle?
    private var isLoaded = false

    init(fileURL url: URL) {
        self.url = url
    }

    deinit {
        if let grf {
            grf_free(grf)
        }
    }

    func node(atPath path: String) -> GRFTreeNode? {
        loadIfNeeded()

        guard let grf else {
            return nil
        }

        var currentNode = GRFTreeNode(grf: grf, node: grf_tree_get_root(grf))

        let pathComponents = path.lowercased().split(separator: "\\")
        for pathComponent in pathComponents {
            guard let childNode = currentNode.children.filter({ $0.name == pathComponent }).first else {
                return nil
            }
            currentNode = childNode
        }

        return currentNode
    }

    private func loadIfNeeded() {
        guard isLoaded == false else {
            return
        }

        grf = grf_load(url.path(), false)
        grf_create_tree(grf)

        isLoaded = true
    }
}
