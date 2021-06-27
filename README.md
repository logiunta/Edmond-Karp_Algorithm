# Implementation of Edmond_Karp algorithm

Edmonds-Karp algorithm is just an implementation of the Ford-Fulkerson method that uses BFS for finding augmenting paths. 
The algorithm was first published by Yefim Dinitz in 1970, and later independently published by Jack Edmonds and Richard Karp in 1972.

# Complexity
The complexity can be given independently of the maximal flow. The algorithm runs in O(VE^2) time, even for irrational capacities. The intuition is, that every time we find an augmenting path one of the edges becomes saturated, and the distance from the edge to s will be longer, if it appears later again in an augmenting path. And the length of a simple paths is bounded by V.

# Integral flow theorem
The theorem simply says, that if every capacity in the network is integer, then the flow in each edge will be integer in the maximal flow.

# Max-flow min-cut theorem
A s-t-cut is a partition of the vertices of a flow network into two sets, such that a set includes the source s and the other one includes the sink t. The capacity of a s-t-cut is defined as the sum of capacities of the edges from the source side to the sink side.The max-flow min-cut theorem goes even further. It says that the capacity of the maximum flow has to be equal to the capacity of the minimum cut.


