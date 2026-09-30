using Random, PythonCall, Base.Threads

@enum TermType URIRefType BNodeType LiteralType VariableType

struct TripleID
    s::UInt64
    p::UInt64
    o::UInt64
end

@kwdef mutable struct Graph
    triples::Vector{TripleID} = TripleID[]
    names::Vector{String} = Vector()
    ids::Dict{String, UInt64} = Dict()
    id_types::Dict{UInt64, TermType} = Dict()
    term_map::Dict{UInt64, UInt64} = Dict()
end


term_id(g::Graph, x::String) = get(g.ids, x, -1)
blank_node_id() = "_:" * randstring(12)

is_uri_ref(g, id) = g.id_types[id] == URIRefType
is_b_node(g, id) = g.id_types[id] == BNodeType
is_literal(g, id) = g.id_types[id] == LiteralType
is_variable(g, id) = g.id_types[id] == VariableType

function string_triple(g::Graph, t::TripleID)
    return "$(g.names[t.s]) $(g.names[t.p]) $(g.names[t.o]) ."
end

function literal_id!(g::Graph, literal::String, type::TermType)
    if literal in g.names
        return g.ids[literal]
    end
    push!(g.names, literal)
    id = length(g.names)
    g.ids[literal] = id
    g.id_types[id] = type
    return id
end

function compose!(g::Graph)
    owl_thing_id = literal_id!(g, TERM_OWL_THING, URIRefType)

    decls = Dict{UInt64, Any}()
    exprs = Dict{UInt64, Any}()

    decls[owl_thing_id] = gen_class(g, owl_thing_id)

    for t in g.triples
        parse_declarations(g, decls, t)
    end

    for t in g.triples
        parse_class_expressions(g, decls, exprs, t)
    end

    normalise_expressions(g, decls, exprs)

    axioms = Vector{Axiom}()
    for t in g.triples
        parse_axioms(g, decls, exprs, axioms, t)
    end

    normalise_axioms(g, decls, exprs, axioms)

    return axioms
end

function add_triples!(g::Graph, filepath)
    rdflib = pyimport("rdflib")
    rdf_g = rdflib.Graph()
    rdf_g.parse(filepath)
    for (s, p, o) in pyiter(rdf_g)
        sid = literal_id!(g, string(s.n3()), rdf_type(rdflib, s))
        pid = literal_id!(g, string(p.n3()), rdf_type(rdflib, p))
        oid = literal_id!(g, string(o.n3()), rdf_type(rdflib, o))
        push!(g.triples, TripleID(sid, pid, oid))
    end
    PythonCall.GC.gc()
end

function rdf_type(rdflib, x)
    pyconvert(Bool, pytype(x) == rdflib.term.BNode) && return BNodeType
    pyconvert(Bool, pytype(x) == rdflib.term.URIRef) && return URIRefType
    pyconvert(Bool, pytype(x) == rdflib.term.Literal) && return LiteralType
    pyconvert(Bool, pytype(x) == rdflib.term.Variable) && return VariableType
end
