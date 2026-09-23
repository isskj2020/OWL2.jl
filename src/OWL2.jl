module OWL2

using PythonCall

include("terms.jl")

include("axiom.jl")
include("graph.jl")

include("parser_helper.jl")
include("parser_decl.jl")
include("parser_expr.jl")
include("parser_axiom.jl")
include("normaliser_expr.jl")
include("normaliser_axiom.jl")

function load_owl(filepath::String)
    rdflib = pyimport("rdflib")
    g = rdflib.Graph()
    g.parse(filepath)

    graph = Graph()
    for (s, p, o) in pyiter(g)
        add_triples!(graph, rdflib, s, p, o)
    end
    PythonCall.GC.gc()

    return compose!(graph)
end

end 
