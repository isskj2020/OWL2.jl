using RDF

function _find_triple(ts;
        subject::Union{RDFTerm, Nothing} = nothing,
        predicate::Union{RDFTerm, Nothing} = nothing,
        object::Union{RDFTerm, Nothing} = nothing)
    ret = _find_triples(ts; subject = subject, predicate = predicate, object = object)
    isempty(ret) && return nothing
    return first(ret)
end


function _find_triples(ts;
        subject::Union{RDFTerm, Nothing} = nothing,
        predicate::Union{RDFTerm, Nothing} = nothing,
        object::Union{RDFTerm, Nothing} = nothing)
    ret = ts
    if subject != nothing
        ret = filter(x -> x.subject == subject, ret)
    end
    if predicate != nothing
        ret = filter(x -> x.predicate == predicate, ret)
    end
    if object != nothing
        ret = filter(x -> x.object == object, ret)
    end
    return ret
end

function _parse_blank_node(g, str)
    n = match(r"^_:(.+)", str)[1]
    return parse(Int32, n; base = 16)
end


is_class(t) = t.predicate == rdf.type && t.object == owl.Class

function parse_chain_list!(g, term, out)
    chains = collect(match(g; subject = term))

    first_node = _find_triple(chains; predicate = rdf.first)
    first_node == nothing && return
    push!(out, first_node.object)
    rest_node = _find_triple(chains; predicate = rdf.rest)
    rest_node == nothing && return

    if rest_node.object isa BlankNode
        parse_chain_list!(g, rest_node.object, out)
    end
end

