using Random, RDF

add_triple!(g, axiom::Axiom) = add_ntps!(g, axiom, nothing)

add_ntps!(g, v::Vector, parent) = begin
    id = parent
    for x in v
        res = x
        while !(res isa RDFTerm)
            res = add_ntps!(g, res, id)
        end
        push!(g, Triple(id, rdf.first, res))
        newid = v[end] == x ? rdf.nil : blank_node_id()
        push!(g, Triple(id, rdf.rest, newid))
        id = newid
    end
    return id
end

add_ntps!(g, x::Literal, parent) = x.x

add_ntps!(g, x::Class, parent) = begin
    push!(g, Triple(x.x, rdf.type, owl.Class))
    return x.x
end

add_ntps!(g, x::DataType, parent) = begin
    push!(g, Triple(x.x, rdf.type, rdfs.Datatype))
    return x.x
end

add_ntps!(g, x::Individual, parent) = begin
    if !(x.x isa BlankNode)
        push!(g, Triple(x.x, rdf.type, owl.NamedIndividual))
    end
    return x.x
end

add_ntps!(g, x::AnnotationProperty, parent) = begin
    push!(g, Triple(x.x, rdf.type, owl.AnnotationProperty))
    return x.x
end

add_ntps!(g, x::DataProperty, parent) = begin
    push!(g, Triple(x.x, rdf.type, owl.DatatypeProperty))
    return x.x
end

add_ntps!(g, x::ObjectProperty, parent) = begin
    push!(g, Triple(x.x, rdf.type, owl.ObjectProperty))
    return x.x
end

add_ntps!(g, x::ObjectPropertyChain, parent) = begin
    return add_ntps!(g, x.ope_n, parent)
end

add_ntps!(g, x::ObjectInverseOf, parent) = begin
    push!(g, Triple(parent, owl.inverseOf, x.ope))
    return x.ope
end

add_ntps!(g, x::ObjectIntersectionOf, parent) = begin
    o = blank_node_id()
    if parent == nothing
        parent = blank_node_id()
    end
    push!(g, Triple(parent, owl.intersectionOf, o))
    return add_ntps!(g, x.ce_n, o)
end

add_ntps!(g, x::ObjectUnionOf, parent) = begin
    o = blank_node_id()
    if parent == nothing
        parent = blank_node_id()
    end
    push!(g, Triple(parent, owl.unionOf, o))
    return add_ntps!(g, x.ce_n, o)
end

add_ntps!(g, x::ObjectComplementOf, parent) = begin
    o = add_ntps!(g, x.ce, parent)
    push!(g, Triple(parent, owl.complementOf, o))
    return x.ce
end

add_ntps!(g, x::ObjectOneOf, parent) = begin
    o = blank_node_id()
    push!(g, Triple(parent, owl.oneOf, o))
    return add_ntps!(g, x.a_n, o)
end

add_ntps!(g, x::ObjectSomeValuesFrom, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.ope, id)
    push!(g, Triple(id, owl.onProperty, o))
    o = add_ntps!(g, x.ce, id)
    push!(g, Triple(id, owl.someValuesFrom, o))
    return id
end

add_ntps!(g, x::ObjectAllValuesFrom, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.ope, id)
    push!(g, Triple(id, owl.onProperty, o))
    o = add_ntps!(g, x.ce, id)
    push!(g, Triple(id, owl.allValuesFrom, o))
    return id
end

add_ntps!(g, x::ObjectHasValue, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.ope, id)
    push!(g, Triple(id, owl.onProperty, o))
    o = add_ntps!(g, x.a, id)
    push!(g, Triple(id, owl.hasValue, o))
    return id
end

add_ntps!(g, x::ObjectHasSelf, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.ope, id)
    push!(g, Triple(id, owl.onProperty, o))
    o = RDF.Literal(true)
    push!(g, Triple(id, owl.hasSelf, o))
    return id
end

add_ntps!(g, x::ObjectMinCardinality, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.ope, id)
    push!(g, Triple(id, owl.onProperty, o))
    if x.ce == nothing
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.minCardinality, o))
    else
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.minQualifiedCardinality, o))
        o = add_ntps!(g, x.ce, id)
        push!(g, Triple(id, owl.onClass, o))
    end
    return id
end

add_ntps!(g, x::ObjectMaxCardinality, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.ope, id)
    push!(g, Triple(id, owl.onProperty, o))
    if x.ce == nothing
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.maxCardinality, o))
    else
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.maxQualifiedCardinality, o))
        o = add_ntps!(g, x.ce, id)
        push!(g, Triple(id, owl.onClass, o))
    end
    return id
end

add_ntps!(g, x::ObjectExactCardinality, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.ope, id)
    push!(g, Triple(id, owl.onProperty, o))
    if x.ce == nothing
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.cardinality, o))
    else
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.qualifiedCardinality, o))
        o = add_ntps!(g, x.ce, id)
        push!(g, Triple(id, owl.onClass, o))
    end
    return id
end

add_ntps!(g, x::DataSomeValuesFrom, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    if length(x.dpe_n) == 1
        o = add_ntps!(g, first(x.dpe_n), id)
        push!(g, Triple(id, owl.onProperty, o))
    else
        o = blank_node_id()
        push!(g, Triple(id, owl.onProperties, o))
        add_ntps!(g, x.dpe_n, o)
    end
    o = add_ntps!(g, x.dr, id)
    push!(g, Triple(id, owl.someValuesFrom, o))
    return id
end

add_ntps!(g, x::DataAllValuesFrom, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    if length(x.dpe_n) == 1
        o = add_ntps!(g, first(x.dpe_n), id)
        push!(g, Triple(id, owl.onProperty, o))
    else
        o = blank_node_id()
        push!(g, Triple(id, owl.onProperties, o))
        add_ntps!(g, x.dpe_n, o)
    end
    o = add_ntps!(g, x.dr, id)
    push!(g, Triple(id, owl.allValuesFrom, o))
    return id
end

add_ntps!(g, x::DataHasValue, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.dpe, id)
    value = add_ntps!(g, t.lt, id)
    push!(g, Triple(id, owl.onProperty, o))
    push!(g, Triple(id, owl.hasValue, value))
    return id
end

add_ntps!(g, x::DataMinCardinality, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.dpe, id)
    push!(g, Triple(id, owl.onProperty, o))
    if x.dr == nothing
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.minCardinality, o))
    else
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.minQualifiedCardinality, o))
        o = add_ntps!(g, x.dr, id)
        push!(g, Triple(id, owl.onDataRange, o))
    end
    return id
end

add_ntps!(g, x::DataMaxCardinality, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.dpe, id)
    push!(g, Triple(id, owl.onProperty, o))
    if x.dr == nothing
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.maxCardinality, o))
    else
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.maxQualifiedCardinality, o))
        o = add_ntps!(g, x.dr, id)
        push!(g, Triple(id, owl.onDataRange, o))
    end
    return id
end

add_ntps!(g, x::DataExactCardinality, parent) = begin
    id = blank_node_id()
    push!(g, Triple(id, rdf.type, owl.Restriction))
    o = add_ntps!(g, x.dpe, id)
    push!(g, Triple(id, owl.onProperty, o))
    if x.dr == nothing
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.cardinality, o))
    else
        o = RDF.Literal(x.n)
        push!(g, Triple(id, owl.qualifiedCardinality, o))
        o = add_ntps!(g, x.dr, id)
        push!(g, Triple(id, owl.onDataRange, o))
    end
    return id
end

add_ntps!(g, x::DataIntersectionOf, parent) = begin
    id = blank_node_id()
    if parent == nothing
        parent = blank_node_id()
    end
    push!(g, Triple(parent, owl.intersectionOf, id))
    add_ntps!(g, x.dr_n, id)
    return parent
end

add_ntps!(g, x::DataUnionOf, parent) = begin
    id = blank_node_id()
    if parent == nothing
        parent = blank_node_id()
    end
    push!(g, Triple(parent, owl.unionOf, id))
    return parent
end

add_ntps!(g, x::DataComplementOf, parent) = begin
    o = add_ntps!(g, x.dr, parent)
    push!(g, Triple(parent, owl.datatypeComplementOf, o))
    return parent
end

add_ntps!(g, x::DataOneOf, parent) = begin
    o = blank_node_id()
    push!(g, Triple(parent, owl.oneOf, o))
    return add_ntps!(g, x.lt_n, o)
end

add_ntps!(g, x::DataTypeRestriction, parent) = begin
    sub = blank_node_id()
    push!(g, Triple(sub, rdf.type, rdfs.Datatype))
    o = add_ntps!(g, x.dt, parent)
    push!(g, Triple(sub, owl.onDatatype, o))
    o = blank_node_id()
    push!(g, Triple(sub, owl.withRestrictions, o))
    ids = [blank_node_id() for i in 1:length(x.f_n)]
    add_ntps!(g, ids, o)
    for i in eachindex(ids)
        lt = add_ntps!(g, x.lt_n[i], parent)
        push!(g, Triple(ids[i], x.f_n[i], lt))
    end
    return sub
end

add_ntps!(g, x::Declaration, parent) = add_ntps!(g, x.e, parent)

add_ntps!(g, x::SubClassOf, parent) = begin
    s = add_ntps!(g, x.ce1, parent)
    p = rdfs.subClassOf
    o = add_ntps!(g, x.ce2, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::EquivalentClasses, parent) = begin
    for i in eachindex(x.ce_n)
        if i == length(x.ce_n)
            # last
            if i % 2 == 1
                s = add_ntps!(g, x.ce_n[i-1], parent)
                p = owl.equivalentClass
                o = add_ntps!(g, x.ce_n[i], parent)
                push!(g, Triple(s, p, o))
            end
        else
            s = add_ntps!(g, x.ce_n[i], parent)
            p = owl.equivalentClass
            o = add_ntps!(g, x.ce_n[i+1], parent)
            push!(g, Triple(s, p, o))

        end
    end
    return parent
end

add_ntps!(g, x::DisjointClasses, parent) = begin
    if length(x.ce_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        push!(g, (id1, rdf.type, owl.allDisjointClasses))
        push!(g, (id1, owl.members, id2))
        add_ntps!(g, x.ce_n, id2)
    else
        s = add_ntps!(g, x.ce_n[1], parent)
        p = owl.disjointWith
        o = add_ntps!(g, x.ce_n[2], parent)
        push!(g, Triple(s, p, o))
    end
    return parent
end

add_ntps!(g, x::DisjointUnion, parent) = begin
    s = add_ntps!(g, x.c, parent)
    p = owl.disjointUnionOf
    o = blank_node_id()
    push!(g, Triple(s, p, o))
    add_ntps!(g, x.ce_n, o)
    return parent
end

add_ntps!(g, x::SubObjectPropertyOf, parent) = begin
    if x.ope1 isa OPExpression
        s = add_ntps!(g, x.ope1, parent)
        p = rdfs.subPropertyOf
        o = add_ntps!(g, x.ope2, parent)
        push!(g, Triple(s, p, o))
    elseif x.ope1 isa ObjectPropertyChain
        id = blank_node_id()
        s = add_ntps!(g, x.ope2, parent)
        p = owl.propertyChainAxiom
        o = id
        push!(g, Triple(s, p, o))
        add_ntps!(g, x.ope1, o)
    end
    return parent
end

add_ntps!(g, x::EquivalentObjectProperties, parent) = begin
    for i in eachindex(x.ope_n)
        if i == length(x.ope_n)
            # last
            if i % 2 == 1
                s = add_ntps!(g, x.ope_n[i-1], parent)
                p = owl.equivalentProperty
                o = add_ntps!(g, x.ope_n[i], parent)
                push!(g, Triple(s, p, o))
            end
        else
            s = add_ntps!(g, x.ope_n[i], parent)
            p = owl.equivalentProperty
            o = add_ntps!(g, x.ope_n[i+1], parent)
            push!(g, Triple(s, p, o))
        end
    end
    return parent
end

add_ntps!(g, x::DisjointObjectProperties, parent) = begin
    if length(x.ope_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        push!(g, (id1, rdf.type, owl.allDisjointProperties))
        push!(g, (id1, owl.members, id2))
        add_ntps!(g, x.ope_n, id2)
    else
        s = add_ntps!(g, x.ope_n[1], parent)
        p = owl.propertyDisjointWith
        o = add_ntps!(g, x.ope_n[2], parent)
        push!(g, Triple(s, p, o))
    end
    return parent
end

add_ntps!(g, x::ObjectPropertyDomain, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdfs.domain
    o = add_ntps!(g, x.ce, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::ObjectPropertyRange, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdfs.range
    o = add_ntps!(g, x.ce, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::InverseObjectProperties, parent) = begin
    s = add_ntps!(g, x.ope1, parent)
    p = owl.inverseOf
    o = add_ntps!(g, x.ope2, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::FunctionalObjectProperty, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdf.type
    o = owl.FunctionalProperty
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::InverseFunctionalObjectProperty, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdf.type
    o = owl.InverseFunctionalProperty
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::ReflexiveObjectProperty, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdf.type
    o = owl.ReflexiveProperty
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::IrreflexiveObjectProperty, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdf.type
    o = owl.IrreflexiveProperty
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::SymmetricObjectProperty, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdf.type
    o = owl.SymmetricProperty
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::AsymmetricObjectProperty, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdf.type
    o = owl.AsymmetricProperty
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::TransitiveObjectProperty, parent) = begin
    s = add_ntps!(g, x.ope, parent)
    p = rdf.type
    o = owl.TransitiveProperty
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::SubDataPropertyOf, parent) = begin
    s = add_ntps!(g, x.dpe1, parent)
    p = rdfs.subPropertyOf
    o = add_ntps!(g, x.dpe2, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::EquivalentDataProperties, parent) = begin
    for i in eachindex(x.dpe_n)
        if i == length(x.dpe_n)
            # last
            if i % 2 == 1
                s = add_ntps!(g, x.dpe_n[i-1], parent)
                p = owl.equivalentProperty
                o = add_ntps!(g, x.dpe_n[i], parent)
                push!(g, Triple(s, p, o))
            end
        else
            s = add_ntps!(g, x.dpe_n[i], parent)
            p = owl.equivalentProperty
            o = add_ntps!(g, x.dpe_n[i+1], parent)
            push!(g, Triple(s, p, o))
        end
    end
    return parent
end

add_ntps!(g, x::DisjointDataProperties, parent) = begin
    if length(x.dpe_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        push!(g, Triple(id1, rdf.type, owl.AllDisjointProperty))
        push!(g, (id1, owl.members, id2))
        add_ntps!(g, x.dpe_n, id2)
    else
        s = add_ntps!(g, x.dpe_n[1], parent)
        p = owl.propertyDisjointWith
        o = add_ntps!(g, x.dpe_n[2], parent)
        push!(g, Triple(s, p, o))
    end
    return parent
end

add_ntps!(g, x::DataPropertyDomain, parent) = begin
    s = add_ntps!(g, x.dpe, parent)
    p = rdfs.domain
    o = add_ntps!(g, x.ce, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::DataPropertyRange, parent) = begin
    s = add_ntps!(g, x.dpe, parent)
    p = rdfs.range
    o = add_ntps!(g, x.dr, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::FunctionalDataProperty, parent) = begin
    s = add_ntps!(g, x.dpe, parent)
    p = rdf.type
    o = owl.FunctionalProperty
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::DatatypeDefinition, parent) = begin
    s = add_ntps!(g, x.dt, parent)
    p = owl.equivalentClass
    o = add_ntps!(g, x.dr, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::HasKey, parent) = begin
    id = blank_node_id()
    s = add_ntps!(g, x.ce, parent)
    p = owl.hasKey
    o = id
    push!(g, Triple(s, p, o))
    list = Vector()
    for ope in x.ope_n
        push!(list, ope)
    end
    for dpe in x.dpe_n
        push!(list, dpe)
    end
    add_ntps!(g, list, id)
end

add_ntps!(g, x::SameIndividual, parent) = begin
    for a in x.a_n
        if i == length(x.a_n)
            # last
            if i % 2 == 1
                s = add_ntps!(g, x.a_n[i-1], parent)
                p = owl.sameAs
                o = add_ntps!(g, x.a_n[i], parent)
                push!(g, Triple(s, p, o))
            end
        else
            s = add_ntps!(g, x.a_n[i], parent)
            p = owl.sameAs
            o = add_ntps!(g, x.a_n[i+1], parent)
            push!(g, Triple(s, p, o))
        end
    end
    return parent
end

add_ntps!(g, x::DifferentIndividuals, parent) = begin
    if length(x.a_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        push!(g, Triple(id1, rdf.type, owl.AllDifferent))
        push!(g, Triple(id1, owl.members, id2))
        add_ntps!(g, x.a_n, id2)
    else
        s = add_ntps!(g, x.a_n[1], parent)
        p = owl.differentFrom
        o = add_ntps!(g, x.a_n[2], parent)
        push!(g, Triple(s, p, o))
    end
    return parent
end

add_ntps!(g, x::ClassAssertion, parent) = begin
    s = add_ntps!(g, x.a, parent)
    p = rdf.type
    o = add_ntps!(g, x.ce, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::ObjectPropertyAssertion, parent) = begin
    s = add_ntps!(g, x.a1, parent)
    p = add_ntpls!(g, x.ope, parent)
    o = add_ntps!(g, x.a2, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::NegativeObjectPropertyAssertion, parent) = begin
    id = blank_node_id()
    a1 = add_ntps!(g, x.a1, parent)
    ope = add_ntps!(g, x.ope, parent)
    a2 = add_ntps!(g, x.a2, parent)
    push!(g, Triple(id, rdf.type, owl.NegativePropertyAssertion))
    push!(g, Triple(id, owl.sourceIndividual, a1))
    push!(g, Triple(id, owl.assertionProperty, ope))
    push!(g, Triple(id, owl.targetIndividual, a2))
    return id
end

add_ntps!(g, x::DataPropertyAssertion, parent) = begin
    s = add_ntps!(g, x.a, parent)
    p = add_ntps!(g, x.dpe, parent)
    o = add_ntps!(g, x.lt, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::NegativeDataPropertyAssertion, parent) = begin
    id = blank_node_id()
    a = add_ntps!(g, x.a, parent)
    dpe = add_ntps!(g, x.dpe, parent)
    value = add_ntps!(g, x.lt, parent)
    push!(g, Triple(id, rdf.type, owl.NegativePropertyAssertion))
    push!(g, Triple(id, owl.sourceIndividual, a1))
    push!(g, Triple(id, owl.assertionProperty, dpe))
    push!(g, Triple(id, owl.targetValue, value))
    return id
end

add_ntps!(g, x::AnnotationAssertion, parent) = begin
    s = add_ntps!(g, x.ap, parent)
    p = x.as
    o = x.av
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::SubAnnotationPropertyOf, parent) = begin
    s = add_ntps!(g, x.ap1, parent)
    p = rdfs.subPropertyOf
    o = add_ntps!(g, x.ap2, parent)
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::AnnotationPropertyDomain, parent) = begin
    s = add_ntps!(g, x.ap, parent)
    p = rdfs.domain
    o = u
    push!(g, Triple(s, p, o))
    return parent
end

add_ntps!(g, x::AnnotationPropertyRange, parent) = begin
    s = add_ntps!(g, x.ap, parent)
    p = rdfs.range
    o = u
    push!(g, Triple(s, p, o))
    return parent
end

function blank_node_id()
    return BlankNode(rand(UInt32))
end
