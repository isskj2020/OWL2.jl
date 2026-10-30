module OWL2

using RDF

const owl = Namespace("http://www.w3.org/2002/07/owl#")

include("axiom.jl")
include("graph.jl")
include("errors.jl")

include("normaliser_graph.jl")

include("parser_helper.jl")
include("parser_decl.jl")
include("parser_expr.jl")
include("parser_axiom.jl")
include("normaliser_expr.jl")
include("normaliser_axiom.jl")

include("ntriple_writer.jl")

function load_owl(filepath; mimetype::String = "application/rdf+xml")
    return _parse_owl!(filepath, mimetype)
end

function write_owl(axioms, filepath; type::Symbol = :nt)
    g = Graph()
    for a in axioms
        add_triple!(g, a)
    end
    open(filepath, "w") do io
        write(io, type, g)
    end
end

end 
