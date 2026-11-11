module OWL2

using RDF

const owl = Namespace("http://www.w3.org/2002/07/owl#")

include("axiom.jl")
include("graph.jl")
include("errors.jl")

include("normaliser_graph.jl")

include("parser_helper.jl")
include("parser_ontology.jl")
include("parser_decl.jl")
include("parser_expr.jl")
include("parser_axiom.jl")
include("normaliser_expr.jl")
include("normaliser_axiom.jl")

include("owl_writer.jl")
include("ntriple_writer.jl")

manchester_syntax(x) = _fms(x)

export manchester_syntax

function load_owl(uri; mimetype::String = "application/rdf+xml")
    return _parse_owl!(uri, mimetype)
end

function write_owl(ontology, filepath; type::Symbol = :nt)
    g = Graph()
    _write_rdf_graph!(ontology, g)
    open(filepath, "w") do io
        write(io, type, g)
    end
end

end 
