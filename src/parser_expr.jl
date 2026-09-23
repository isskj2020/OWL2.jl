#
# Parsing Expressions
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function parse_class_expressions(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    parse_some_values_from(g, decls, exprs, t)
    parse_all_values_from(g, decls, exprs, t)
    parse_intersection_of(g, decls, exprs, t)
    parse_union_of(g, decls, exprs, t)
    parse_complement_of(g, decls, exprs, t)
    parse_one_of(g, decls, exprs, t)
    parse_has_value(g, decls, exprs, t)
    parse_has_self(g, decls, exprs, t)
    parse_min_cardinality(g, decls, exprs, t)
    parse_min_qualified_cardinality(g, decls, exprs, t)
    parse_inverse_of(g, decls, exprs, t)
end

function parse_some_values_from(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_SOME_VALUES_FROM) && return
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))
    if get(decls, t.o, nothing) isa CExpression
        ope = ObjectProperty(g.names[prop.o])
        exprs[t.s] = ObjectSomeValuesFrom(ope = ope, ce = decls[t.o])
    else
        dpe = DataProperty(g.names[prop.o])
        dt = gen_datatype(g, t.o)
        exprs[t.s] = DataSomeValuesFrom(dpe_n = [dpe], dr = dt)
    end
end

function parse_all_values_from(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_ALL_VALUES_FROM) && return
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))

    if get(decls, t.o, nothing) isa CExpression
        ope = ObjectProperty(g.names[prop.o])
        exprs[t.s] = ObjectAllValuesFrom(ope = ope, ce = decls[t.o])
    else
        dpe = DataProperty(g.names[prop.o])
        dt = gen_datatype(g, t.o)
        exprs[t.s] = DataAllValuesFrom(dpe_n = [dpe], dr = dt)
    end
end

function parse_intersection_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_INTERSECTION_OF) && return
    nodes = filter(x -> t.s == x.s, g.triples)

    if !isempty(find_owl_class_nodes(g, nodes))
        # object intersection of
        ce_n = Vector{CExpression}()
        for n in nodes
            if g.id_types[n.o] == BNode
                chain_ids = Vector{UInt64}()
                parse_chain_list!(g, n.o, chain_ids)
                for id in chain_ids
                    push!(ce_n, gen_class(g, id))
                end
            end
        end
        exprs[t.s] = ObjectIntersectionOf(ce_n = ce_n)
    else
        # data intersection of
        dr_n = Vector{DataRange}()
        for n in nodes
            if g.id_types[n.o] == BNode
                chain_ids = Vector{UInt64}()
                parse_chain_list!(g, n.o, chain_ids)
                for id in chain_ids
                    push!(dr_n, gen_datatype(g, id))
                end
            end
        end
        exprs[t.s] = DataIntersectionOf(dr_n = dr_n)
    end
end

function parse_union_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_UNION_OF) && return
    nodes = filter(x -> t.s == x.s, g.triples)

    if !isempty(find_owl_class_nodes(g, nodes))
        # object union of
        ce_n = Vector{CExpression}()
        for n in nodes
            if g.id_types[n.o] == BNode
                chain_ids = Vector{UInt64}()
                parse_chain_list!(g, n.o, chain_ids)
                for id in chain_ids
                    push!(ce_n, gen_class(g, id))
                end
            end
        end
        exprs[t.s] = ObjectUnionOf(ce_n = ce_n)
    else
        # data union of
        dr_n = Vector{DataRange}()
        for n in nodes
            if g.id_types[n.o] == BNode
                chain_ids = Vector{UInt64}()
                parse_chain_list!(g, n.o, chain_ids)
                for id in chain_ids
                    push!(dr_n, gen_datatype(g, id))
                end
            end
        end
        exprs[t.s] = DataUnionOf(dr_n = dr_n)
    end

end

function parse_complement_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_COMPLEMENT_OF) &&
    t.p != term_id(g, TERM_OWL_DATATYPE_COMPLEMENT_OF) && return
    nodes = filter(x -> t.s == x.s, g.triples)

    if !isempty(find_owl_class_nodes(g, nodes))
        # object complement of
        ce = gen_class(g, t.o)
        exprs[t.s] = ObjectComplementOf(ce = ce)
    else
        # data complement of
        dt = gen_datatype(g, t.o)
        exprs[t.s] = DataComplementOf(dr = dt)
    end
end

function parse_one_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_ONE_OF) && return
    nodes = filter(x -> t.s == x.s, g.triples)

    if !isempty(find_owl_class_nodes(g, nodes))
        # object one of
        a_n = Vector{Individual}()
        for n in nodes
            if g.id_types[n.o] == BNode
                chain_ids = Vector{UInt64}()
                parse_chain_list!(g, n.o, chain_ids)
                for id in chain_ids
                    a = if g.id_types[id] == BNode
                        AnonymousIndividual(g.names[id])
                    else
                        NamedIndividual(g.names[id])
                    end
                    push!(a_n, a)
                end
            end
        end
        exprs[t.s] = ObjectOneOf(a_n = a_n)
    else
        # data one of
        lt_n = Vector{PlainLiteral}()
        for n in nodes
            if g.id_types[n.o] == BNode 
                chain_ids = Vector{UInt64}()
                parse_chain_list!(g, n.o, chain_ids)
                for id in chain_ids
                    push!(lt_n, PlainLiteral(g.names[id]))
                end
            end
        end
        exprs[t.s] = DataOneOf(lt_n = lt_n)
    end
end

function parse_has_value(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_HAS_VALUE) && return 
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))
    if g.id_types[t.o] == Literal
        # data has value 
        dpe = DataProperty(g.names[prop.o])
        lt = PlainLiteral(g.names[t.o])
        exprs[t.s] = DataHasValue(dpe = dpe, lt = lt)
    else
        # object has value 
        ope = ObjectProperty(g.names[prop.o])
        a = if g.id_types[t.o] == BNode
            AnonymousIndividual(g.names[t.o])
        else
            NamedIndividual(g.names[t.o])
        end
        exprs[t.s] = ObjectHasValue(ope = ope, a = a)
    end
end

function parse_has_self(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_HAS_SELF) && return 
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))
    ope = ObjectProperty(g.names[prop.o])
    exprs[t.s] = ObjectHasSelf(ope = ope)
end

function parse_min_cardinality(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_MIN_CARDINALITY) && return 
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))

    n = match(r"^\\\"(.+)\\\"", g.names[t.o])[1] |> x -> parse(Int, x)
    ope = ObjectProperty(g.names[prop.o])
    ce = Class(TERM_OWL_THING)
    exprs[t.s] = ObjectMinCardinality(n = n, ope = ope, ce = ce)
end

function parse_min_qualified_cardinality(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_MIN_QUALIFIED_CARDINALITY) && return 
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))

    n = match(r"^\\\"(.+)\\\"", g.names[t.o])[1] |> x -> parse(Int, x)

    classes = find_owl_on_class_nodes(g, nodes)
    if !isempty(classes)
        ce = gen_class(g, classes[1].o)
        ope = ObjectProperty(g.names[prop.o])
        exprs[t.s] = ObjectMinCardinality(n = n, ope = ope, ce = ce)
    end

    datatypes = find_owl_on_data_range_nodes(g, nodes)
    if !isempty(datatypes)
        dt = gen_datatype(g, datatypes[1].o)
        dpe = DataProperty(g.names[prop.o]) 
        exprs[t.s] = DataMinCardinality(n = n, dpe = dpe, dr = dt)
    end
end

function parse_max_cardinality(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_MAX_CARDINALITY) && return 
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))

    n = match(r"^\\\"(.+)\\\"", g.names[t.o])[1] |> x -> parse(Int, x)
    ope = ObjectProperty(g.names[prop.o])
    ce = Class(TERM_OWL_THING)
    exprs[t.s] = ObjectMinCardinality(n = n, ope = ope, ce = ce)
end

function parse_max_qualified_cardinality(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_MAX_QUALIFIED_CARDINALITY) && return 
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))

    n = match(r"^\\\"(.+)\\\"", g.names[t.o])[1] |> x -> parse(Int, x)

    classes = find_owl_on_class_nodes(g, nodes)
    if !isempty(classes)
        ce = gen_class(g, classes[1].o)
        ope = ObjectProperty(g.names[prop.o])
        exprs[t.s] = ObjectMaxCardinality(n = n, ope = ope, ce = ce)
    end

    datatypes = find_owl_on_data_range_nodes(g, nodes)
    if !isempty(datatypes)
        dt = gen_datatype(g, datatypes[1].o)
        dpe = DataProperty(g.names[prop.o]) 
        exprs[t.s] = DataMaxCardinality(n = n, dpe = dpe, dr = dt)
    end
end

function parse_exact_cardinality(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_CARDINALITY) && return 
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))

    n = match(r"^\\\"(.+)\\\"", g.names[t.o])[1] |> x -> parse(Int, x)
    ope = ObjectProperty(g.names[prop.o])
    ce = Class(TERM_OWL_THING)
    exprs[t.s] = ObjectExactCardinality(n = n, ope = ope, ce = ce)
end

function parse_exact_qualified_cardinality(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_QUALIFIED_CARDINALITY) && return 
    nodes = filter(x -> t.s == x.s, g.triples)
    @assert !isempty(find_owl_restriction_nodes(g, nodes))

    prop = first(find_owl_on_property_nodes(g, nodes))

    n = match(r"^\\\"(.+)\\\"", g.names[t.o])[1] |> x -> parse(Int, x)

    classes = find_owl_on_class_nodes(g, nodes)
    if !isempty(classes)
        ce = gen_class(g, classes[1].o)
        ope = ObjectProperty(g.names[prop.o])
        exprs[t.s] = ObjectExactCardinality(n = n, ope = ope, ce = ce)
    end

    datatypes = find_owl_on_data_range_nodes(g, nodes)
    if !isempty(datatypes)
        dt = gen_datatype(g, datatypes[1].o)
        dpe = DataProperty(g.names[prop.o]) 
        exprs[t.s] = DataExactCardinality(n = n, dpe = dpe, dr = dt)
    end
end

function parse_inverse_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, t::TripleID)
    t.p != term_id(g, TERM_OWL_INVERSE_OF) && return 

    if g.id_types[t.s] == BNode
        ope = ObjectProperty(g.names[t.o])
        exprs[t.s] = ObjectInverseOf(ope = ope) 
    end
end

