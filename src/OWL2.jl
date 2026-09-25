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

include("ntriple_writer.jl")

function load_owl(filepath)
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

function to_triples(axioms::Vector{Axiom})
    tps = Tuple[]
    io = stdout
    for a in axioms
        add_triple!(tps, a)
    end
    unique!(tps)
    return tps
end

function write_owl_nt(axioms, filepath)
    tps = to_triples(axioms)
    open(filepath, "w") do io
        for t in tps
            println(io, "$(t[1]) $(t[2]) $(t[3]) .")
        end
    end
end

end 
