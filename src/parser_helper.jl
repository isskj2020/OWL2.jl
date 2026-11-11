using RDF

function _parse_chain_list!(g, term, out)
    chains = collect(match(g; subject = term))

    first_nodes = match(g; subject = term, predicate = rdf.first)
    isempty(first_nodes) && return
    first_node = first(first_nodes)
    push!(out, first_node.object)
    rest_nodes = match(g; subject = term, predicate = rdf.rest)
    isempty(rest_nodes) && return
    rest_node = first(rest_nodes)

    if rest_node.object isa BlankNode
        _parse_chain_list!(g, rest_node.object, out)
    end
end

