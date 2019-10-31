//
//  AdjacencyListGraph.swift
//  Graph
//
//  Created by Andrew McKnight on 5/13/16.
//

import Foundation

private class EdgeList<T> where T: Hashable {
  var vertex: Vertex<T>
  var edges: [Edge<T>]?

  init(vertex: Vertex<T>) {
    self.vertex = vertex
  }

  func addEdge(_ edge: Edge<T>) {
    edges?.append(edge)
  }
}

open class AdjacencyListGraph<T>: AbstractGraph<T> where T: Hashable {
  private var adjacencyList: [EdgeList<T>] = []

  public required init() {
    super.init()
  }

  public required init(fromGraph graph: AbstractGraph<T>) {
    super.init(fromGraph: graph)
  }

  open override var vertices: [Vertex<T>] {
    adjacencyList.map { $0.vertex }
  }

  open override var edges: [Edge<T>] {
    Array(adjacencyList.flatMap { $0.edges ?? [] }.reduce(into: Set<Edge<T>>()) { $0.insert($1) })
  }

  open override func createVertex(_ data: T) -> Vertex<T> {
    if let match = vertices.first(where: { $0.data == data }) {
      return match
    }

    // if the vertex doesn't exist, create a new one
    let vertex = Vertex(data: data, index: adjacencyList.count)
    adjacencyList.append(EdgeList(vertex: vertex))
    return vertex
  }

  open override func addDirectedEdge(_ from: Vertex<T>, to: Vertex<T>, withWeight weight: Double?) {
    // works
    let edge = Edge(from: from, to: to, weight: weight)
    let edgeList = adjacencyList[from.index]
    if edgeList.edges != nil {
        edgeList.addEdge(edge)
    } else {
        edgeList.edges = [edge]
    }
  }

  open override func addUndirectedEdge(_ vertices: (Vertex<T>, Vertex<T>), withWeight weight: Double?) {
    addDirectedEdge(vertices.0, to: vertices.1, withWeight: weight)
    addDirectedEdge(vertices.1, to: vertices.0, withWeight: weight)
  }

  open override func weightFrom(_ sourceVertex: Vertex<T>, to destinationVertex: Vertex<T>) -> Double? {
    guard let edges = adjacencyList[sourceVertex.index].edges else {
      return nil
    }

    return edges.first { $0.to == destinationVertex }?.weight
  }

  open override func edgesFrom(_ sourceVertex: Vertex<T>) -> [Edge<T>] {
    return adjacencyList[sourceVertex.index].edges ?? []
  }

  open override var description: String {
    var rows = [String]()
    for edgeList in adjacencyList {

      guard let edges = edgeList.edges else {
        continue
      }

      var row = [String]()
      for edge in edges {
        var value = "\(edge.to.data)"
        if edge.weight != nil {
          value = "(\(value): \(edge.weight!))"
        }
        row.append(value)
      }

      rows.append("\(edgeList.vertex.data) -> [\(row.joined(separator: ", "))]")
    }

    return rows.joined(separator: "\n")
  }
}