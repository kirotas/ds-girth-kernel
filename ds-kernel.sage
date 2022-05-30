
# rwb-graph kernelization algorithm for dominating sets in graphs
# of girth at least 5.

# See Kernelization: Theory of Parameterized Preprocessing
# Authors: Fomin, Lokshtanov, Saurabh, Zehavi
# Section 2.4

import sys
from enum import Enum

class Color(Enum):
    RED = 1
    WHITE = 2
    BLACK = 3

# Vertices which have not been locked into the dominating set
# which have more that k - |R| >= 0 black neighbors need to be added
# to the dominating set.

# Color the vertex added red, and its neighbors white.

# Note: Made a modification to require k - |R| >= 0 because the lemma
# from which this reduction rule is derived requires that k >= |R|
def reduction_1(G: Graph, k: Integer):
    for v in G.vertices():
        R = len(list(filter(lambda u:u[1]==Color.RED, G.get_vertices().items())))
        if G.get_vertex(v) == Color.RED:
            continue
        n = 0
        for u in G.neighbors(v):
            if G.get_vertex(u) == Color.BLACK:
                n = n + 1
        if n > k - R and k - R >= 0:
            G.set_vertex(v, Color.RED)
            k = k - 1
            for w in G.neighbors(v):
                if G.get_vertex(w) == Color.BLACK: 
                    G.set_vertex(w, Color.WHITE)
    return G, k

# White vertices which have no black neighbors can be deleted.
def reduction_2(G: Graph, k: Integer):
    for v in G.vertices():
        if G.get_vertex(v) != Color.WHITE:
            continue
        if any(G.get_vertex(u) == Color.BLACK for u in G.neighbors(v)):
            continue
        G.delete_vertex(v)
    return G, k
    

# Read the input graph and parameter k
G = graphs.StarGraph(8)
k = 1

# Check that the graph is of girth at least 5
if G.girth() < 5:
    err_msg = "Input graph girth is " + str(G.girth()) + " which is not >= 5."
    print(err_msg)
    sys.exit()

# Color the vertices of the graph to all black
for v in G.vertices():
    G.set_vertex(v, Color.BLACK)

# Apply reduction rules exhaustively
i = 1
while(True):
    i = i + 1
    G_prime = copy(G)
    G_prime, k = reduction_1(G_prime, k)
    G_prime, k = reduction_2(G_prime, k)
    if G.get_vertices() == G_prime.get_vertices(): # No changes made to the graph
        break
    G = G_prime # Update the graph

# Print the rwb-graph with the appropriate coloring on the vertices
red_vertices = [v[0] for v in list(filter(lambda u:u[1]==Color.RED, G.get_vertices().items()))]
white_vertices = [v[0] for v in list(filter(lambda u:u[1]==Color.WHITE, G.get_vertices().items()))]
black_vertices = [v[0] for v in list(filter(lambda u:u[1]==Color.BLACK, G.get_vertices().items()))]
d = {'#FF0000': red_vertices, '#FFFFFF': white_vertices, '#000000': black_vertices}
G.plot(vertex_colors = d, vertex_labels = False).save('rwb-graph.png')

# Convert final reduced instance back to a dominating set instance by adding
# pendant vertices to each of the red vertices
for v in list(filter(lambda u:u[1]==Color.RED, G.get_vertices().items())):
    G.add_edge(G.vertices()[v[0]], G.add_vertex())

# Save graph png
G.plot(vertex_labels = False).save('dom.png')