# CRIMSON CRUISER DESIGN
*Create by Konstantin Freiherr von Stein*
_Thursday, November 28th, 2024_



> [Introduction](#1)
**Notable Files:**
> [NodeClass.Swift Walkthrough](#2)
> [3DPathFunctions.Swift Walkthrough](#3)



<a name="1"></a>
## Introduction 

Hi There!

This is quite an extensive codebase with a lot of "suplimentary" code that enables and manages specific data and features. 

The **most important code** responsible for the pathfinding functionality is in the NodeClass.swift file. It is very well documented and I would recommend starting here to understand how the application functions!



<a name="2"></a>
## NodeClass.Swift Walkthrough

This code is stored in ***CrimsonCruiser > FinalContent > NodeGraph > NodeClass.swift*** and can be reached by using the file navigator on the left side of the XCode window! 

**WebGraph Class**

The WebGraph Class serves as the core structure to manage nodes, their connections, and operations on the graph. As an ObservableObject, any updates and changes to its conntents will trigger UI Updates! Here’s a breakdown of its responsibilities:

**- Stores every waypoint and location in an array of Nodes**

``` swift
// The nodes in the graph.
@Published var nodes: [WebNode] = []
```


**- Stores every connection between Nodes in a dictionary**

``` swift
// The connections between nodes, represented as a dictionary where each key is a node ID, and the value is an array of connected node IDs.
@Published var connections: [UUID: [UUID]] = [:]
```

**- These are the two important variables that are used for the pathfinding algorithm. The class also contains all the relevant functions to manipulate these nodes.**


``` swift
func addNode(node: WebNode)
func connect(node1: WebNode, node2: WebNode)
func getConnections(for node: WebNode) -> [ WebNode ]
func getNode(name: String) -> WebNode?

etc...
```

**Dijkstras Algorithm!**

Dijkstra’s algorithm is the foundational method for finding the shortest path between two WebNodes in a graph! The code is EXTENSIVLEY documented in XCode. The algorithm initializes by assigning every node a tentative distance of infinity, except the starting node, which is set to zero. After this, it repeatedly selects unvisited neighboring nodes. Each time, the algorithm calculates the distances to its neighbors. It updates the distances and shortest paths found. Once the destination node is reached, the algorithm reconstructs the path by tracing back from the last node. This process continues until all nodes are visited or the destination node is reached, ensuring that the shortest path to each node is discovered. If the destination node is never found, the algorithm returns an empty array. All of these distances and paths are also stored in dictionaries, similar to how the connections are stored in the WebGraph Class.

All of the connections were established manually by me in a different application I wrote. Unfortunately I wasn't able to store these connections and retrieve them in a "clean" manner, so instead, I automated the generation of the code to create these connections and run this when the application launches! This code can be seen at the bottom of the NodeClass.Swift document in the ***preload()*** function!

<a name="3"></a>
## NodeClass.Swift Walkthrough

This code is stored in ***CrimsonCruiser > FinalContent > 3DView >  3DPathFunctions.swift*** 

The *appropraitely* named **navigateSceneTreeToCreateWebGraphNodes()** function is designed to traverse a 3D SceneKit file hierarchy recursively and add nodes to the WebGraph Class. This 3D environment contains each location and waypoint as an invisible node. The function begins by iterating over all nodes in the scene graph, starting from the root node. For each node, it checks if the node’s name contains a specific keyword (defined by the nodeType enumeration such as "locationNode"). If a match is found, it creates a corresponding WebNode object and adds the 2D coordinates extracted from the nodes worldPosition. The new WebNode is then added to the WebGraph, building up the  representation of the scene!

``` swift
/// Recursively nagivates the AnnotatedModel.scn and adds the nodes to the webGraph based on a nodes name that is provided by the nodeType Enum.
/// > Is called on ContentView's .onAppear() to load nodes into WebGraph network.
func navigateSceneTreeToCreateWebGraphNodes(scene: SCNScene, webGraph: WebGraph,  nodeType: nodeType) {
    print("Started Navigating Scene Kit")
    // function for recursive traversal
    func traverseNodes(node: SCNNode) {
        // Check if the node name contains "locationNode"
        if let nodeName = node.name, nodeName.contains(nodeType.rawValue) {
            let graphNode = WebNode(name: node.name ?? "Unknown", xpos: Float(node.worldPosition.x), zpos: Float(node.worldPosition.z))
            webGraph.addNode(graphNode)
        }
        // Recursively traverse child nodes
        for child in node.childNodes {
            traverseNodes(node: child)
        }
    }
    // Start traversal from the root node
    traverseNodes(node: scene.rootNode)
}
```
The internal function traverseNodes() is what is actually being run recursively! This function doesn't need a specific *break* point, becuase it is only called for the amount of children each node has. This prevents any kind of Infinite Loop. 

Throught the rest of this file there are many other function of interest that are all used to interact with the 3D Scene and the node data. These are documented so feel free to check them out. Many are unused in the final project however and served significant value in debugging. 


If you have any questions or are curious feel free to reach out to me or keep exploring the project files!

