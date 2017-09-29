---
layout: post
html_title: Spreading In-Complete Information
title: The Internet vs. The Shortest and Longest Path Problems
---

Whilst revising algorithms and complexity theory, I came across the longest path problem again and read it was NP-hard. 
Then I thought to myself, isn't this just equivalent to finding the shortest path in the graph with the edge weights negated? 
I decided to use Google to confirm my intuition (looking back I should have tried to prove it to myself beforehand). My search 
was simply of the form: can the longest path problem be solved with a shortest path algorithm, e.g. is it possible to 
use Dijkstra's to find the longest path in the graph? I came across many sources claiming you cannot "because longest path is NP-hard". I was 
a bit confused, went through the examples some websites provided and still I thought to myself, isn't this still just 
equivalent to the shortest path on -G? Well, it is. It's pretty obvious if you think about it but many sources say 
otherwise. In fact upon further reading of Wikipedia, they [claim](https://en.wikipedia.org/wiki/Longest_path_problem#Acyclic_graphs_and_critical_paths) it to 
be so; although under their "Acyclic graphs and critical paths" section.

Note, when I say 'path' I mean a simple path: one without repeated vertices. Also, I am talking
about graphs with weighted edges. I believe when people refer to the longest path problem
they usually speak about the problem in the context in a graph of which is unweighted or when 
it has positive cycles. And when people say shortest path they mean it in the context of no 
negative cycles. However, I feel as if a lot of people don't realise these implicit constraints when
speaking about them, well maybe that's just me. Anyway, this post will consider the longest and
shortest path problems in general (arbitrary graphs).

For some graph the shortest and longest path in G are different, this is clear. However, the shortest path in -G
is the same as the longest path in G, which is what I see people [refute](https://stackoverflow.com/a/10462763/1427533). For an unweighted 
setting this statement still holds true if you assign the weights of the edges to some constant (say 1).

If this is not clear, consider an undirected graph with three nodes and three edges: (A, B) with a weight
of -1, (B, C) with a weight of -1 and finally (A, C) with a weight of -1. This graph clearly has a
negative cycle. The shortest path from A -> B is A -> C -> B with a total weight of -2, however the 
shortest path from C -> B is C -> A -> B with a total weight of -2. That is there is no optimal 
sub-structure for this problem. If we negate the edges, it is clear that this is the longest path problem for a graph
with a positively weighted cycle.

To answer my Google search: we can use a shortest path algorithm to find the longest path, assuming there is no positive cycle in the graph. As the longest 
path problem is equivalent the shortest path problem on the graph -G. I am _not_ claiming the longest path can be solved in polynomial time, rather the 
opposite: the shortest path _cannot_ be solved in polynomial time (in general). I think a lot of the confusion stems from missing information about these 
two problem's equivalence. However, I think most of the confusion likely stems from language, i.e. for what types of paths are you considering, when you
say "shortest path" does that mean for graphs with positive (>=0) weights?, etc.

Basically all I'm trying to say is, online tutorials, blogs, forums and etc. potentially have an explanation to 
something that can be easily mis-interpreted. In the context of shortest paths vs. longest paths there are no 
explanations of what is meant when people refer to the "shortest path problem" when people ask questions similar 
to "can you solve longest path with Dijkstra". There is clearly some understanding that they are 
equivalent problems, but downright saying they're are not is misleading in my opinion. Clearly people are confused on 
the terminology. The terminology for these two problems actually really frustrates me, but oh well, it can't be helped.

Basically, fuck English.
