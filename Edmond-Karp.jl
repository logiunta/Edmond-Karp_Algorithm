# struct that defines the edge from input
mutable struct OutEdge
    flow :: Int
    capacity :: Int
end

# struct that defines the inverse edge
mutable struct InEdge
    capacity :: Int
end

# struct that defines the complete edge (necessary for residual graph)
mutable struct Edge
    e1 :: OutEdge
    e2 :: InEdge
end


# function that reads an input graph and creates its adjacency matrix
function readGraph(graph,n)
    for i in 1:n
        println("How many adjacent nodes does have the node ",i," ?")
        m = parse(Int,readline())
        for j in 1:m
            println("Insert the adjacent nodes in non-decreasing order")
            adj = parse(Int,readline())
            if (adj == i) error("A edge cannot link to itself")
            end
            println("Capacity of the edge (",i,",",adj,")")
            capacity = parse(Int,readline())
            edge = OutEdge(0,capacity)
            r_edge = InEdge(0)
            graph[i,adj] = Edge(edge,r_edge)
        end
    end
end


# function that runs bfs given a source and a sink, returning the path (augmenting) found
function bfs(graph,n,source,sink)
    queue = Array{Int}(undef,0)
    push!(queue,source)
    path = Array{Union{Tuple{Int,Int},Nothing}}(nothing,n)
    while(!isempty(queue))
        curr = popfirst!(queue)
        if(curr == sink)
            return path
        end
        for adj in 1:n
            node = graph[curr,adj]
            if(node != nothing && path[adj] == nothing && node.e1.capacity > node.e1.flow  && adj!=source)
                    path[adj] = (curr,adj)
                    push!(queue,adj)

            elseif(node == nothing)
                r_node = graph[adj,curr]
                if(r_node != nothing && path[adj] == nothing && r_node.e2.capacity > 0  && adj!=source)
                    path[adj] = (curr,adj)
                    push!(queue,adj)

                end
            end
        end
    end
    return path

end



# function that looks for an augmenting path at each iteration and makes modifications to the residual graph
function edmonds_karp(graph,source,sink,n,maxflow)
    ok = true
    it = 1
    while(ok==true)
        println("Iteration ",it)
        path = bfs(graph,n,source,sink)
        cammino = findPath(path,source,sink)
        if(path[sink] == nothing) # no more augmenting paths
            println("There are no more augmenting paths")
            cut = getCut(cammino,n)
            println("Minimum cut: ",cut)
            cutCapacity = first(cutEdges(cut,graph,n))
            edgesInCut = last(cutEdges(cut,graph,n))
            println("Capacity of this cut = ",cutCapacity)
            println("Saturated edges in the cut: ",edgesInCut)
            ok = false;

        else
            println("Shortest path found: ",cammino)
            pushflow = flow_toPush(graph,path,sink)
            graph = augmented_path(graph,path,pushflow,sink)
            println("Flow on this path: ",pushflow)
            maxflow += pushflow
        end
        it += 1
        println()
    end
    return maxflow
end

# function that, given a cut, returns the edges in the cut and the capacity of that cut
function cutEdges(cut,graph,n)
    cutCapacity = 0
    edgesInCut = Array{Tuple{Int,Int}}(undef,0)
    Ns = first(cut)
    Nt = last(cut)
    for i in 1:length(Ns)
        for j in 1:length(Nt)
            u = Ns[i]
            v = Nt[j]
            edge = graph[u,v]
            if (edge != nothing && edge.e1.capacity == edge.e1.flow)
                cutCapacity += edge.e1.flow
                push!(edgesInCut,(u,v))
            end
        end
    end
    return (cutCapacity,edgesInCut)
end


# function that, given a path, returns the cut
function getCut(path,n)
    others = Array{Int}(undef,0)
    dim = n - length(path)
    i = 1
    while (dim > 0)
        if (!in(i,path))
            dim -= 1
            push!(others,i)
        end
        i += 1
    end
    sorted = sort!(path)
    return (sorted,others)
end

# function that calculate the maximum flow which can be sent along the path
function flow_toPush(graph,path,sink)
    pushflow = typemax(Int)
    edge = path[sink]
    while (edge != nothing)
        u = first(edge)
        v = last(edge)
        if (graph[u,v] != nothing)
            residualflow = graph[u,v].e1.capacity - graph[u,v].e1.flow
        else
            #residualflow = graph[v,u].e1.capacity - graph[v,u].e1.flow
            residualflow = graph[v,u].e2.capacity
        end
        #println("pushflow: ",pushflow," , residualflow: ",residualflow)
        pushflow = min(pushflow,residualflow)
        edge = path[u]

    end
    return pushflow

end


# function that passes the found flux from the found augmenting path
function augmented_path(graph,path,maxflow,sink)
    edge = path[sink]
    while (edge != nothing)
        u = first(edge)
        v = last(edge)

        if (graph[u,v] == nothing) # arco inverso
            graph[v,u].e1.flow -= maxflow
            graph[v,u].e2.capacity -= maxflow
        else
            graph[u,v].e1.flow += maxflow
            graph[u,v].e2.capacity += maxflow
        end
        edge = path[u]
    end
    return graph
end

# function that returns the nodes belonging to the augmenting path found
function findPath(path,source,sink)
    cammino = Array{Int}(undef,0) 
    nodiSorgente = Array{Int}(undef,0)
    edge = path[sink]
    if (edge == nothing) # case in which increasing paths are no longer found and the minimum cut must be found
        cut = lastPath(graph,source,cammino)
        return cut
    else
        while (edge != nothing)
            u = first(edge)
            v = last(edge)
            pushfirst!(cammino,v)
            edge = path[u]
        end
        pushfirst!(cammino,source)
        return cammino
    end

end


# function the returns the first component of the cut (set of nodes that go from source to the node where the path stops)
function lastPath(graph,source,cammino)
    path = Array{Union{Tuple{Int,Int},Nothing}}(nothing,n)
    queue = Array{Int}(undef,0)
    push!(queue,source)
    while (!isempty(queue))
        curr = popfirst!(queue)
        push!(cammino,curr)
        for adj in 1:n
            trovato = false;
            node = graph[curr,adj]
            if (node != nothing && path[adj] == nothing && node.e1.capacity > node.e1.flow  && adj!=source) 
                path[adj] = (curr,adj)
                push!(queue,adj)
                
            elseif (node == nothing)
                r_node = graph[adj,curr]
                if (r_node != nothing && path[adj] == nothing && r_node.e2.capacity > 0  && adj!=source)
                    path[adj] = (curr,adj)
                    push!(queue,adj)
                end
            end
        end

    end
    return cammino
end

function checkSink(graph,sink,n)
    for i in 1:n
        if (graph[sink,i] != nothing)
            error(sink," is not a sink")
        end
    end
end


println("Insert the number of nodes ")
n = parse(Int,readline())
graph = Matrix{Union{Edge,Nothing}}(nothing,n,n)
readGraph(graph,n)
maxflow = 0
println("Source: ")
source = parse(Int,readline())
println("Sink: ")
sink = parse(Int,readline())
checkSink(graph,sink,n)
maxflow = edmonds_karp(graph,source,sink,n,maxflow)
println("Max flow in the graph from ",source," to ",sink," is: ",maxflow)
println("The theorem of MAXFLOW - MINCUT is respected, because maxflow and mincut are equal")
