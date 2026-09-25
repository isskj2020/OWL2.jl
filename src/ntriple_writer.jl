using Random


add_triple!(tps, axiom::Axiom) = add_ntps!(tps, axiom, nothing)

add_ntps!(tps, v::Vector, parent) = begin
    if parent == nothing
        @warn "vector $v"
    end
    id = parent
    for x in v
        res = add_ntps!(tps, x, id)
        push!(tps, (id, TERM_RDF_FIRST, res))
        newid = v[end] == x ? TERM_RDF_NIL : blank_node_id()
        push!(tps, (id, TERM_RDF_REST, newid))
        id = newid
    end
    return id
end

add_ntps!(tps, x::String, parent) = x

add_ntps!(tps, x::Class, parent) = begin
    push!(tps, (x.x, TERM_RDF_TYPE, TERM_OWL_CLASS))
    return x.x
end

add_ntps!(tps, x::ClassNodeID, parent) = x.x

add_ntps!(tps, x::DataType, parent) = begin
    push!(tps, (x.x, TERM_RDF_TYPE, TERM_RDFS_DATATYPE))
    return x.x
end

add_ntps!(tps, x::DataNodeID, parent) = x.x

add_ntps!(tps, x::NamedIndividual, parent) = begin
    push!(tps, (x.x, TERM_RDF_TYPE, TERM_OWL_NAMED_INDIVIDUAL))
    return x.x
end

add_ntps!(tps, x::AnonymousIndividual, parent) = x.x

add_ntps!(tps, x::AnnotationProperty, parent) = begin
    push!(tps, (x.x, TERM_RDF_TYPE, TERM_OWL_ANNOTATION_PROPERTY))
    return x.x
end

add_ntps!(tps, x::DataProperty, parent) = begin
    push!(tps, (x.x, TERM_RDF_TYPE, TERM_OWL_DATATYPE_PROPERTY))
    return x.x
end

add_ntps!(tps, x::ObjectProperty, parent) = begin
    push!(tps, (x.x, TERM_RDF_TYPE, TERM_OWL_OBJECT_PROPERTY))
    return x.x
end

add_ntps!(tps, x::ObjectPropertyChain, parent) = begin
    return add_ntps!(tps, x.ope_n, parent)
end

add_ntps!(tps, x::ObjectInverseOf, parent) = begin
    push!(tps, (parent, TERM_OWL_INVERSE_OF, x.ope))
    return x.ope
end

add_ntps!(tps, x::ObjectIntersectionOf, parent) = begin
    o = blank_node_id()
    push!(tps, (parent, TERM_OWL_INTERSECTION_OF, o))
    return add_ntps!(tps, x.ce_n, o)
end

add_ntps!(tps, x::ObjectUnionOf, parent) = begin
    o = blank_node_id()
    push!(tps, (parent, TERM_OWL_UNION_OF, o))
    return add_ntps!(tps, x.ce_n, o)
end

add_ntps!(tps, x::ObjectComplementOf, parent) = begin
    o = add_ntps!(tps, x.ce, parent)
    push!(tps, (parent, TERM_OWL_COMPLEMENT_OF, o))
    return x.ce
end

add_ntps!(tps, x::ObjectOneOf, parent) = begin
    o = blank_node_id()
    push!(tps, (parent, TERM_OWL_ONE_OF, o))
    return add_ntps!(tps, x.a_n, o)
end

add_ntps!(tps, x::ObjectSomeValuesFrom, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.ope, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    o = add_ntps!(tps, x.ce, id)
    push!(tps, (id, TERM_OWL_SOME_VALUES_FROM, o))
    return id
end

add_ntps!(tps, x::ObjectAllValuesFrom, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.ope, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    o = add_ntps!(tps, x.ce, id)
    push!(tps, (id, TERM_OWL_ALL_VALUES_FROM, o))
    return id
end

add_ntps!(tps, x::ObjectHasValue, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.ope, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    o = add_ntps!(tps, x.a, id)
    push!(tps, (id, TERM_OWL_HAS_VALUE, o))
    return id
end

add_ntps!(tps, x::ObjectHasSelf, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.ope, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    push!(tps, (id, TERM_OWL_HAS_SELF, x."\"true\"^^$TERM_XSD_BOOLEAN"))
    return id
end

add_ntps!(tps, x::ObjectMinCardinality, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.ope, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    if x.ce == nothing
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_MIN_CARDINALITY, o))
    else
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_MIN_QUALIFIED_CARDINALITY, o))
        o = add_ntps!(tps, x.ce, id)
        push!(tps, (id, TERM_OWL_ON_CLASS, o))
    end
    return id
end

add_ntps!(tps, x::ObjectMaxCardinality, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.ope, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    if x.ce == nothing
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_MAX_CARDINALITY, o))
    else
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_MAX_QUALIFIED_CARDINALITY, o))
        o = add_ntps!(tps, x.ce, id)
        push!(tps, (id, TERM_OWL_ON_CLASS, o))
    end
    return id
end

add_ntps!(tps, x::ObjectExactCardinality, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.ope, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    if x.ce == nothing
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_CARDINALITY, o))
    else
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_QUALIFIED_CARDINALITY, o))
        o = add_ntps!(tps, x.ce, id)
        push!(tps, (id, TERM_OWL_ON_CLASS, o))
    end
    return id
end

add_ntps!(tps, x::DataSomeValuesFrom, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    if length(x.dpe_n) == 1
        o = add_ntps!(tps, first(x.dpe_n), id)
        push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    else
        o = blank_node_id()
        push!(tps, (id, TERM_OWL_ON_PROPERTIES, o))
        add_ntps!(tps, x.dpe_n, o)
    end
    o = add_ntps!(tps, x.dr, id)
    push!(tps, (id, TERM_OWL_SOME_VALUES_FROM, o))
    return id
end

add_ntps!(tps, x::DataAllValuesFrom, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    if length(x.dpe_n) == 1
        o = add_ntps!(tps, first(x.dpe_n), id)
        push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    else
        o = blank_node_id()
        push!(tps, (id, TERM_OWL_ON_PROPERTIES, o))
        add_ntps!(tps, x.dpe_n, o)
    end
    o = add_ntps!(tps, x.dr, id)
    push!(tps, (id, TERM_OWL_ALL_VALUES_FROM, o))
    return id
end

add_ntps!(tps, x::DataHasValue, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.dpe, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    push!(tps, (id, TERM_OWL_HAS_VALUE, t.lt))
    return id
end

add_ntps!(tps, x::DataMinCardinality, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.dpe, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    if x.dr == nothing
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_MIN_CARDINALITY, o))
    else
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_MIN_QUALIFIED_CARDINALITY, o))
        o = add_ntps!(tps, x.dr, id)
        push!(tps, (id, TERM_OWL_ON_DATA_RANGE, o))
    end
    return id
end

add_ntps!(tps, x::DataMaxCardinality, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.dpe, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    if x.dr == nothing
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_MAX_CARDINALITY, o))
    else
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_MAX_QUALIFIED_CARDINALITY, o))
        o = add_ntps!(tps, x.dr, id)
        push!(tps, (id, TERM_OWL_ON_DATA_RANGE, o))
    end
    return id
end

add_ntps!(tps, x::DataExactCardinality, parent) = begin
    id = blank_node_id()
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_RESTRICTION))
    o = add_ntps!(tps, x.dpe, id)
    push!(tps, (id, TERM_OWL_ON_PROPERTY, o))
    if x.dr == nothing
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_CARDINALITY, o))
    else
        o = "\"$(x.n)\"^^$TERM_XSD_NON_NEGATIVE_INTEGER"
        push!(tps, (id, TERM_OWL_QUALIFIED_CARDINALITY, o))
        o = add_ntps!(tps, x.dr, id)
        push!(tps, (id, TERM_OWL_ON_DATA_RANGE, o))
    end
    return id
end

add_ntps!(tps, x::DataIntersectionOf, parent) = begin
    id = blank_node_id()
    push!(tps, (parent, TERM_OWL_INTERSECTION_OF, id))
    add_ntps!(tps, x.dr_n, id)
    return parent
end

add_ntps!(tps, x::DataUnionOf, parent) = begin
    id = blank_node_id()
    push!(tps, (parent, TERM_OWL_UNION_OF, id))
    return parent
end

add_ntps!(tps, x::DataComplementOf, parent) = begin
    o = add_ntps!(tps, x.dr, parent)
    push!(tps, (parent, TERM_OWL_DATATYPE_COMPLEMENT_OF, o))
    return parent
end

add_ntps!(tps, x::DataOneOf, parent) = begin
    o = blank_node_id()
    push!(tps, (parent, TERM_OWL_ONE_OF, o))
    return add_ntps!(tps, x.lt_n, o)
end

add_ntps!(tps, x::DataTypeRestriction, parent) = begin
    o = add_ntps!(tps, x.dt, parent)
    push!(tps, (parent, TERM_OWL_ON_DATA_TYPE, o))
    o = blank_node_id()
    push!(tps, (parent, TERM_OWL_WITH_RESTRICTION, o))
    ids = [blank_node_id() for i in 1:length(x.f_n)]
    add_ntps!(tps, ids, o)
    for i in eachindex(ids)
        push!(tps, (ids[i], x.f_n[i], x.lt_n[i]))
    end
    return parent
end

add_ntps!(tps, x::Declaration, parent) = add_ntps!(tps, x.e, parent)

add_ntps!(tps, x::SubClassOf, parent) = begin
    s = add_ntps!(tps, x.ce1, parent)
    p = TERM_RDFS_SUB_CLASS_OF
    o = add_ntps!(tps, x.ce2, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::EquivalentClasses, parent) = begin
    for i in eachindex(x.ce_n)
        if i == length(x.ce_n)
            # last
            if i % 2 == 1
                s = add_ntps!(tps, x.ce_n[i-1], parent)
                p = TERM_OWL_EQUIVALENT_CLASS
                o = add_ntps!(tps, x.ce_n[i], parent)
                push!(tps, (s, p, o))
            end
        else
            s = add_ntps!(tps, x.ce_n[i], parent)
            p = TERM_OWL_EQUIVALENT_CLASS
            o = add_ntps!(tps, x.ce_n[i+1], parent)
            push!(tps, (s, p, o))

        end
    end
    return parent
end

add_ntps!(tps, x::DisjointClasses, parent) = begin
    if length(x.ce_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        push!(tps, (id1, TERM_RDF_TYPE, TERM_OWL_ALL_DISJOINT_CLASSES))
        push!(tps, (id1, TERM_OWL_MEMBERS, id2))
        add_ntps!(tps, x.ce_n, id2)
    else
        s = add_ntps!(tps, x.ce_n[1], parent)
        p = TERM_OWL_DISJOINT_WITH
        o = add_ntps!(tps, x.ce_n[2], parent)
        push!(tps, (s, p, o))
    end
    return parent
end

add_ntps!(tps, x::DisjointUnion, parent) = begin
    s = add_ntps!(tps, x.c, parent)
    p = TERM_OWL_DISJOINT_UNION_OF
    o = blank_node_id()
    push!(tps, (s, p, o))
    add_ntps!(tps, x.ce_n, o)
    return parent
end

add_ntps!(tps, x::SubObjectPropertyOf, parent) = begin
    if x.ope1 isa OPExpression
        s = add_ntps!(tps, x.ope1, parent)
        p = TERM_RDFS_SUB_PROPERTY_OF
        o = add_ntps!(tps, x.ope2, parent)
        push!(tps, (s, p, o))
    elseif x.ope1 isa ObjectPropertyChain
        id = blank_node_id()
        s = add_ntps!(tps, x.ope2, parent)
        p = TERM_OWL_PROPERTY_CHAIN_AXIOM
        o = id
        push!(tps, (s, p, o))
        add_ntps!(tps, x.ope1, o)
    end
    return parent
end

add_ntps!(tps, x::EquivalentObjectProperties, parent) = begin
    for i in eachindex(x.ope_n)
        if i == length(x.ope_n)
            # last
            if i % 2 == 1
                s = add_ntps!(tps, x.ope_n[i-1], parent)
                p = TERM_OWL_EQUIVALENT_PROPERTY
                o = add_ntps!(tps, x.ope_n[i], parent)
                push!(tps, (s, p, o))
            end
        else
            s = add_ntps!(tps, x.ope_n[i], parent)
            p = TERM_OWL_EQUIVALENT_PROPERTY
            o = add_ntps!(tps, x.ope_n[i+1], parent)
            push!(tps, (s, p, o))
        end
    end
    return parent
end

add_ntps!(tps, x::DisjointObjectProperties, parent) = begin
    if length(x.ope_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        push!(tps, (id1, TERM_RDF_TYPE, TERM_OWL_ALL_DISJOINT_PROPERTIES))
        push!(tps, (id1, TERM_OWL_MEMBERS, id2))
        add_ntps!(tps, x.ope_n, id2)
    else
        s = add_ntps!(tps, x.ope_n[1], parent)
        p = TERM_OWL_PROPERTY_DISJOINT_WITH
        o = add_ntps!(tps, x.ope_n[2], parent)
        push!(tps, (s, p, o))
    end
    return parent
end

add_ntps!(tps, x::ObjectPropertyDomain, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDFS_DOMAIN
    o = add_ntps!(tps, x.ce, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::ObjectPropertyRange, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDFS_RANGE
    o = add_ntps!(tps, x.ce, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::InverseObjectProperties, parent) = begin
    s = add_ntps!(tps, x.ope1, parent)
    p = TERM_OWL_INVERSE_OF
    o = add_ntps!(tps, x.ope2, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::FunctionalObjectProperty, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDF_TYPE
    o = TERM_OWL_FUNCTIONAL_PROPERTY
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::InverseFunctionalObjectProperty, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDF_TYPE
    o = TERM_OWL_INVERSE_FUNCTIONAL_PROPERTY
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::ReflexiveObjectProperty, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDF_TYPE
    o = TERM_OWL_REFLEXIVE_PROPERTY
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::IrreflexiveObjectProperty, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDF_TYPE
    o = TERM_OWL_IRREFLEXIVE_PROPERTY
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::SymmetricObjectProperty, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDF_TYPE
    o = TERM_OWL_SYMMETRIC_PROPERTY
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::AsymmetricObjectProperty, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDF_TYPE
    o = TERM_OWL_ASYMMETRIC_PROPERTY
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::TransitiveObjectProperty, parent) = begin
    s = add_ntps!(tps, x.ope, parent)
    p = TERM_RDF_TYPE
    o = TERM_OWL_TRANSITIVE_PROPERTY
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::SubDataPropertyOf, parent) = begin
    s = add_ntps!(tps, x.dpe1, parent)
    p = TERM_RDFS_SUB_PROPERTY_OF
    o = add_ntps!(tps, x.dpe2, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::EquivalentDataProperties, parent) = begin
    for i in eachindex(x.dpe_n)
        if i == length(x.dpe_n)
            # last
            if i % 2 == 1
                s = add_ntps!(tps, x.dpe_n[i-1], parent)
                p = TERM_OWL_EQUIVALENT_PROPERTY
                o = add_ntps!(tps, x.dpe_n[i], parent)
                push!(tps, (s, p, o))
            end
        else
            s = add_ntps!(tps, x.dpe_n[i], parent)
            p = TERM_OWL_EQUIVALENT_PROPERTY
            o = add_ntps!(tps, x.dpe_n[i+1], parent)
            push!(tps, (s, p, o))
        end
    end
    return parent
end

add_ntps!(tps, x::DisjointDataProperties, parent) = begin
    if length(x.dpe_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        push!(tps, (id1, TERM_RDF_TYPE, TERM_OWL_ALL_DISJOINT_PROPERTIES))
        push!(tps, (id1, TERM_OWL_MEMBERS, id2))
        add_ntps!(tps, x.dpe_n, id2)
    else
        s = add_ntps!(tps, x.dpe_n[1], parent)
        p = TERM_OWL_PROPERTY_DISJOINT_WITH
        o = add_ntps!(tps, x.dpe_n[2], parent)
        push!(tps, (s, p, o))
    end
    return parent
end

add_ntps!(tps, x::DataPropertyDomain, parent) = begin
    s = add_ntps!(tps, x.dpe, parent)
    p = TERM_RDFS_DOMAIN
    o = add_ntps!(tps, x.ce, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::DataPropertyRange, parent) = begin
    s = add_ntps!(tps, x.dpe, parent)
    p = TERM_RDFS_RANGE
    o = add_ntps!(tps, x.ce, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::FunctionalDataProperty, parent) = begin
    s = add_ntps!(tps, x.dpe, parent)
    p = TERM_RDF_TYPE
    o = TERM_OWL_FUNCTIONAL_PROPERTY
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::DatatypeDefinition, parent) = begin
    s = add_ntps!(tps, x.dt, parent)
    p = TERM_OWL_EQUIVALENT_CLASS
    o = add_ntps!(tps, x.dr, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::HasKey, parent) = begin
    id = blank_node_id()
    s = add_ntps!(tps, x.ce, parent)
    p = TERM_OWL_HAS_KEY
    o = id
    push!(tps, (s, p, o))
    list = merge(x.ope_n, x.dpe_n)
    add_ntps!(tps, list, id2)
end

add_ntps!(tps, x::SameIndividual, parent) = begin
    for a in x.a_n
        if i == length(x.a_n)
            # last
            if i % 2 == 1
                s = add_ntps!(tps, x.a_n[i-1], parent)
                p = TERM_OWL_SAME_AS
                o = add_ntps!(tps, x.a_n[i], parent)
                push!(tps, (s, p, o))
            end
        else
            s = add_ntps!(tps, x.a_n[i], parent)
            p = TERM_OWL_SAME_AS
            o = add_ntps!(tps, x.a_n[i+1], parent)
            push!(tps, (s, p, o))
        end
    end
    return parent
end

add_ntps!(tps, x::DifferentIndividuals, parent) = begin
    if length(x.a_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        push!(tps, (id1, TERM_RDF_TYPE, TERM_OWL_ALL_DIFFERENT))
        push!(tps, (id1, TERM_OWL_MEMBERS, id2))
        add_ntps!(tps, x.a_n, id2)
    else
        s = add_ntps!(tps, x.a_n[1], parent)
        p = TERM_OWL_DIFFERENT_FROM
        o = add_ntps!(tps, x.a_n[2], parent)
        push!(tps, (s, p, o))
    end
    return parent
end

add_ntps!(tps, x::ClassAssertion, parent) = begin
    s = add_ntps!(tps, x.ce, parent)
    p = TERM_RDF_TYPE
    o = add_ntps!(tps, x.a, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::ObjectPropertyAssertion, parent) = begin
    s = add_ntps!(tps, x.a1, parent)
    p = add_ntpls!(tps, x.ope, parent)
    o = add_ntps!(tps, x.a2, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::NegativeObjectPropertyAssertion, parent) = begin
    id = blank_node_id()
    a1 = add_ntps!(tps, x.a1, parent)
    ope = add_ntps!(tps, x.ope, parent)
    a2 = add_ntps!(tps, x.a2, parent)
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_NEGATIVE_PROPERTY_ASSERTION))
    push!(tps, (id, TERM_OWL_SOURCE_INDIVIDUAL, a1))
    push!(tps, (id, TERM_OWL_ASSERTION_PROPERTY, ope))
    push!(tps, (id, TERM_OWL_TARGET_VALUE, a2))
    return id
end

add_ntps!(tps, x::DataPropertyAssertion, parent) = begin
    s = add_ntps!(tps, x.a1, parent)
    p = add_ntpls!(tps, x.dpe, parent)
    o = add_ntps!(tps, x.a2, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::NegativeDataPropertyAssertion, parent) = begin
    id = blank_node_id()
    a1 = add_ntps!(tps, x.a1, parent)
    dpe = add_ntps!(tps, x.dpe, parent)
    a2 = add_ntps!(tps, x.a2, parent)
    push!(tps, (id, TERM_RDF_TYPE, TERM_OWL_NEGATIVE_PROPERTY_ASSERTION))
    push!(tps, (id, TERM_OWL_SOURCE_INDIVIDUAL, a1))
    push!(tps, (id, TERM_OWL_ASSERTION_PROPERTY, dpe))
    push!(tps, (id, TERM_OWL_TARGET_VALUE, a2))
    return id
end

add_ntps!(tps, x::AnnotationAssertion, parent) = begin
    s = add_ntps!(tps, x.ap, parent)
    p = x.as
    o = x.av
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::SubAnnotationPropertyOf, parent) = begin
    s = add_ntps!(tps, x.ap1, parent)
    p = TERM_RDFS_SUB_PROPERTY_OF
    o = add_ntps!(tps, x.ap2, parent)
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::AnnotationPropertyDomain, parent) = begin
    s = add_ntps!(tps, x.ap, parent)
    p = TERM_RDFS_DOMAIN
    o = u
    push!(tps, (s, p, o))
    return parent
end

add_ntps!(tps, x::AnnotationPropertyRange, parent) = begin
    s = add_ntps!(tps, x.ap, parent)
    p = TERM_RDFS_RANGE
    o = u
    push!(tps, (s, p, o))
    return parent
end
