using Random, PythonCall

@enum TermType URIRef BNode Literal Variable

struct TripleID
    s::UInt64
    p::UInt64
    o::UInt64
end


struct Term
    x::String
    type::TermType
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

function string_triple(g::Graph, t::TripleID)
    return "$(g.names[t.s]) $(g.names[t.p]) $(g.names[t.o]) ."
end


function literal_id!(g::Graph, term::Term)
    if term.x in g.names
        return g.ids[term.x]
    end
    push!(g.names, term.x)
    id = length(g.names)
    g.ids[term.x] = id
    g.id_types[id] = term.type
    return id
end

function add_triples!(g::Graph, rdflib, s, p, o)
    sid = literal_id!(g, convert_term(rdflib, s))
    pid = literal_id!(g, convert_term(rdflib, p))
    oid = literal_id!(g, convert_term(rdflib, o))
    push!(g.triples, TripleID(sid, pid, oid))
end


function compose!(g::Graph)
    owl_thing_id = literal_id!(g, Term(TERM_OWL_THING, URIRef))

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
    parse_declaration(g, decls, axioms)

    @debug "== declarations =="
    for (k, v) in decls
        @debug v
    end
    @debug "== expressions =="
    for (k, v) in exprs
        @debug "$(g.names[k]) => $v"
    end

    @debug "== axioms =="
    for axiom in axioms
        @debug axiom
    end
    return axioms
end

function convert_term(rdflib, x)
    pyconvert(Bool, pytype(x) == rdflib.term.BNode) && return Term(string(x.n3()), BNode)
    pyconvert(Bool, pytype(x) == rdflib.term.URIRef) && return Term(string(x.n3()), URIRef)
    pyconvert(Bool, pytype(x) == rdflib.term.Literal) && return Term(string(x.n3()), Literal)
    pyconvert(Bool, pytype(x) == rdflib.term.Variable) && return Term(string(x.n3()), Variable)
end
