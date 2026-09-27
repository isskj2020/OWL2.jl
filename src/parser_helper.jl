find_owl_restriction_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_RDF_TYPE) && x.o == term_id(g, TERM_OWL_RESTRICTION), nodes)
find_owl_class_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_RDF_TYPE) && x.o == term_id(g, TERM_OWL_CLASS), nodes)
find_owl_datatype_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_RDF_TYPE) && x.o == term_id(g, TERM_RDFS_DATATYPE), nodes)
find_owl_on_class_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_OWL_ON_CLASS), nodes)
find_owl_on_property_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_OWL_ON_PROPERTY), nodes)
find_owl_on_properties_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_OWL_ON_PROPERTIES), nodes)
find_owl_on_data_range_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_OWL_ON_DATA_RANGE), nodes)
find_owl_on_datatype_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_OWL_ON_DATATYPE), nodes)
find_rdf_first_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_RDF_FIRST), nodes)
find_rdf_rest_nodes(g::Graph, nodes::Vector{TripleID}) = filter(x -> x.p == term_id(g, TERM_RDF_REST), nodes)

is_class(g, n) = n.p == term_id(g, TERM_RDF_TYPE) && n.o == term_id(g, TERM_OWL_CLASS)

function parse_chain_list!(g, id, out)
    chains = filter(x -> x.s == id, g.triples)

    first_nodes = find_rdf_first_nodes(g, chains)
    isempty(first_nodes) && return
    first_node = first(first_nodes)
    push!(out, first_node.o)
    rest_nodes = find_rdf_rest_nodes(g, chains)
    isempty(rest_nodes) && return
    rest_node = first(rest_nodes)

    if is_b_node(g, rest_node.o)
        parse_chain_list!(g, rest_node.o, out)
    end
end

function gen_class(g, id)
    name = g.names[id]
    if is_b_node(g, id)
        return ClassNodeID(name)
    else
        return Class(name)
    end
end

function gen_datatype(g, id)
    name = g.names[id]
    if is_b_node(g, id)
        return DataNodeID(name)
    else
        return DataType(name)
    end
end

function gen_individual(g, id)
    if is_b_node(g, id)
        return AnonymousIndividual(g.names[id])
    else
        return NamedIndividual(g.names[id])
    end
end
