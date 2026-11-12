using Random, RDF

_id_rotation = 1
_add_triple!(g, axiom::Axiom) = _add_triple!(g, axiom, nothing, Annotation[])


_add_triple!(g, t::Triple, annotations) = begin
    if isempty(annotations)
        push!(g, t)
    else
        for ann in annotations
            annotate!(g, t, ann.ap.x, ann.av)
        end
    end
end

_add_triple!(g, v::Vector, parent, annotations) = begin
    id = parent
    for x in v
        res = x
        while !(res isa RDFTerm)
            res = _add_triple!(g, res, id, annotations)
        end
        _add_triple!(g, Triple(id, rdf.first, res), annotations)
        newid = v[end] == x ? rdf.nil : blank_node_id()
        _add_triple!(g, Triple(id, rdf.rest, newid), annotations)
        id = newid
    end
    return id
end

_add_triples!(g, x, parent, annotations) = begin
    (x == nothing || x isa RDFTerm) && return x
    n = _add_triple!(g, x, parent, annotations)
    return _add_triples!(g, n, parent, annotations)
end

_add_triple!(g, x::Class, parent, annotations) = begin
    _add_triple!(g, Triple(x.x, rdf.type, owl.Class), annotations)
    return x.x
end

_add_triple!(g, x::Literal, parent, annotations) = x.x

_add_triple!(g, x::DataType, parent, annotations) = begin
    _add_triple!(g, Triple(x.x, rdf.type, rdfs.Datatype), annotations)
    return x.x
end

_add_triple!(g, x::Individual, parent, annotations) = begin
    if !(x.x isa BlankNode)
        _add_triple!(g, Triple(x.x, rdf.type, owl.NamedIndividual), annotations)
    end
    return x.x
end

_add_triple!(g, x::AnnotationProperty, parent, annotations) = begin
    _add_triple!(g, Triple(x.x, rdf.type, owl.AnnotationProperty), annotations)
    return x.x
end

_add_triple!(g, x::DataProperty, parent, annotations) = begin
    _add_triple!(g, Triple(x.x, rdf.type, owl.DatatypeProperty), annotations)
    return x.x
end

_add_triple!(g, x::ObjectProperty, parent, annotations) = begin
    _add_triple!(g, Triple(x.x, rdf.type, owl.ObjectProperty), annotations)
    return x.x
end

_add_triple!(g, x::ObjectPropertyChain, parent, annotations) = begin
    return _add_triples!(g, x.ope_n, parent, annotations)
end

_add_triple!(g, x::ObjectInverseOf, parent, annotations) = begin
    if parent == nothing
        parent = blank_node_id()
    end
    o = _add_triples!(g, x.ope, parent, annotations)
    _add_triple!(g, Triple(parent, owl.inverseOf, o), annotations)
    return x.ope
end

_add_triple!(g, x::ObjectIntersectionOf, parent, annotations) = begin
    o = blank_node_id()
    if parent == nothing
        parent = blank_node_id()
    end
    _add_triple!(g, Triple(parent, owl.intersectionOf, o), annotations)
    return _add_triples!(g, x.ce_n, o, annotations)
end

_add_triple!(g, x::ObjectUnionOf, parent, annotations) = begin
    o = blank_node_id()
    if parent == nothing
        parent = blank_node_id()
    end
    _add_triple!(g, Triple(parent, owl.unionOf, o), annotations)
    return _add_triples!(g, x.ce_n, o, annotations)
end

_add_triple!(g, x::ObjectComplementOf, parent, annotations) = begin
    o = _add_triple!(g, x.ce, parent, annotations)
    _add_triple!(g, Triple(parent, owl.complementOf, o), annotations)
    return x.ce
end

_add_triple!(g, x::ObjectOneOf, parent, annotations) = begin
    o = blank_node_id()
    _add_triple!(g, Triple(parent, owl.oneOf, o), annotations)
    return _add_triples!(g, x.a_n, o, annotations)
end

_add_triple!(g, x::ObjectSomeValuesFrom, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.ope, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    o = _add_triples!(g, x.ce, id, annotations)
    _add_triple!(g, Triple(id, owl.someValuesFrom, o), annotations)
    return id
end

_add_triple!(g, x::ObjectAllValuesFrom, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.ope, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    o = _add_triples!(g, x.ce, id, annotations)
    _add_triple!(g, Triple(id, owl.allValuesFrom, o), annotations)
    return id
end

_add_triple!(g, x::ObjectHasValue, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.ope, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    o = _add_triples!(g, x.a, id, annotations)
    _add_triple!(g, Triple(id, owl.hasValue, o), annotations)
    return id
end

_add_triple!(g, x::ObjectHasSelf, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.ope, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    o = RDF.Literal(true)
    _add_triple!(g, Triple(id, owl.hasSelf, o), annotations)
    return id
end

_add_triple!(g, x::ObjectMinCardinality, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.ope, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    if x.ce == nothing
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.minCardinality, o), annotations)
    else
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.minQualifiedCardinality, o), annotations)
        o = _add_triples!(g, x.ce, id, annotations)
        _add_triple!(g, Triple(id, owl.onClass, o), annotations)
    end
    return id
end

_add_triple!(g, x::ObjectMaxCardinality, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.ope, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    if x.ce == nothing
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.maxCardinality, o), annotations)
    else
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.maxQualifiedCardinality, o), annotations)
        o = _add_triples!(g, x.ce, id, annotations)
        _add_triple!(g, Triple(id, owl.onClass, o), annotations)
    end
    return id
end

_add_triple!(g, x::ObjectExactCardinality, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.ope, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    if x.ce == nothing
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.cardinality, o), annotations)
    else
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.qualifiedCardinality, o), annotations)
        o = _add_triples!(g, x.ce, id, annotations)
        _add_triple!(g, Triple(id, owl.onClass, o), annotations)
    end
    return id
end

_add_triple!(g, x::DataSomeValuesFrom, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    if length(x.dpe_n) == 1
        o = _add_triples!(g, first(x.dpe_n), id, annotations)
        _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    else
        o = blank_node_id()
        _add_triple!(g, Triple(id, owl.onProperties, o), annotations)
        _add_triples!(g, x.dpe_n, o, annotations)
    end
    o = _add_triples!(g, x.dr, id)
    _add_triple!(g, Triple(id, owl.someValuesFrom, o), annotations)
    return id
end

_add_triple!(g, x::DataAllValuesFrom, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    if length(x.dpe_n) == 1
        o = _add_triple!(g, first(x.dpe_n), id, annotations)
        _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    else
        o = blank_node_id()
        _add_triple!(g, Triple(id, owl.onProperties, o), annotations)
        _add_triples!(g, x.dpe_n, o, annotations)
    end
    o = _add_triples!(g, x.dr, id)
    _add_triple!(g, Triple(id, owl.allValuesFrom, o), annotations)
    return id
end

_add_triple!(g, x::DataHasValue, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.dpe, id, annotations)
    value = _add_triples!(g, t.lt, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    _add_triple!(g, Triple(id, owl.hasValue, value), annotations)
    return id
end

_add_triple!(g, x::DataMinCardinality, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.dpe, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    if x.dr == nothing
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.minCardinality, o), annotations)
    else
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.minQualifiedCardinality, o), annotations)
        o = _add_triples!(g, x.dr, id, annotations)
        _add_triple!(g, Triple(id, owl.onDataRange, o), annotations)
    end
    return id
end

_add_triple!(g, x::DataMaxCardinality, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.dpe, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    if x.dr == nothing
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.maxCardinality, o), annotations)
    else
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.maxQualifiedCardinality, o), annotations)
        o = _add_triples!(g, x.dr, id, annotations)
        _add_triple!(g, Triple(id, owl.onDataRange, o), annotations)
    end
    return id
end

_add_triple!(g, x::DataExactCardinality, parent, annotations) = begin
    id = blank_node_id()
    _add_triple!(g, Triple(id, rdf.type, owl.Restriction), annotations)
    o = _add_triples!(g, x.dpe, id, annotations)
    _add_triple!(g, Triple(id, owl.onProperty, o), annotations)
    if x.dr == nothing
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.cardinality, o), annotations)
    else
        o = RDF.Literal(x.n)
        _add_triple!(g, Triple(id, owl.qualifiedCardinality, o), annotations)
        o = _add_triples!(g, x.dr, id, annotations)
        _add_triple!(g, Triple(id, owl.onDataRange, o), annotations)
    end
    return id
end

_add_triple!(g, x::DataIntersectionOf, parent, annotations) = begin
    id = blank_node_id()
    if parent == nothing
        parent = blank_node_id()
    end
    _add_triple!(g, Triple(parent, owl.intersectionOf, id), annotations)
    _add_triples!(g, x.dr_n, id, annotations)
    return parent
end

_add_triple!(g, x::DataUnionOf, parent, annotations) = begin
    id = blank_node_id()
    if parent == nothing
        parent = blank_node_id()
    end
    _add_triple!(g, Triple(parent, owl.unionOf, id), annotations)
    return parent
end

_add_triple!(g, x::DataComplementOf, parent, annotations) = begin
    o = _add_triples!(g, x.dr, parent, annotations)
    _add_triple!(g, Triple(parent, owl.datatypeComplementOf, o), annotations)
    return parent
end

_add_triple!(g, x::DataOneOf, parent, annotations) = begin
    o = blank_node_id()
    _add_triple!(g, Triple(parent, owl.oneOf, o), annotations)
    return _add_triples!(g, x.lt_n, o, annotations)
end

_add_triple!(g, x::DataTypeRestriction, parent, annotations) = begin
    sub = blank_node_id()
    _add_triple!(g, Triple(sub, rdf.type, rdfs.Datatype), annotations)
    o = _add_triples!(g, x.dt, parent, annotations)
    _add_triple!(g, Triple(sub, owl.onDatatype, o), annotations)
    o = blank_node_id()
    _add_triple!(g, Triple(sub, owl.withRestrictions, o), annotations)
    ids = [blank_node_id() for i in 1:length(x.f_n)]
    _add_triples!(g, ids, o, annotations)
    for i in eachindex(ids)
        lt = _add_triples!(g, x.lt_n[i], parent, annotations)
        _add_triple!(g, Triple(ids[i], x.f_n[i], lt), annotations)
    end
    return sub
end

_add_triple!(g, x::Declaration, parent, annotations) = begin
    append!(annotations, x.ann_n)
    _add_triples!(g, x.e, parent, annotations)
    return parent
end

_add_triple!(g, x::SubClassOf, parent, annotations) = begin
    append!(annotations, x.ann_n)
    s = _add_triples!(g, x.ce1, parent, annotations)
    p = rdfs.subClassOf
    o = _add_triples!(g, x.ce2, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end


_add_triple!(g, x::EquivalentClasses, parent, annotations) = begin
    append!(annotations, x.ann_n)
    for i in eachindex(x.ce_n)
        if i == length(x.ce_n)
            # last
            if i % 2 == 1
                s = _add_triples!(g, x.ce_n[i-1], parent, annotations)
                p = owl.equivalentClass
                o = _add_triples!(g, x.ce_n[i], parent, annotations)
                _add_triple!(g, Triple(s, p, o), annotations)
            end
        else
            s = _add_triples!(g, x.ce_n[i], parent, annotations)
            p = owl.equivalentClass
            o = _add_triples!(g, x.ce_n[i+1], parent, annotations)
            _add_triple!(g, Triple(s, p, o), annotations)

        end
    end
    return parent
end

_add_triple!(g, x::DisjointClasses, parent, annotations) = begin
    append!(annotations, x.ann_n)
    if length(x.ce_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        _add_triple!(g, Triple(id1, rdf.type, owl.allDisjointClasses), annotations)
        _add_triple!(g, Triple(id1, owl.members, id2), annotations)
        _add_triples!(g, x.ce_n, id2, annotations)
    else
        s = _add_triples!(g, x.ce_n[1], parent, annotations)
        p = owl.disjointWith
        o = _add_triples!(g, x.ce_n[2], parent, annotations)
        _add_triple!(g, Triple(s, p, o), annotations)
    end
    return parent
end

_add_triple!(g, x::DisjointUnion, parent, annotations) = begin
    append!(annotations, x.ann_n)
    s = _add_triples!(g, x.c, parent, annotations)
    p = owl.disjointUnionOf
    o = blank_node_id()
    _add_triple!(g, Triple(s, p, o), annotations)
    _add_triples!(g, x.ce_n, o, annotations)
    return parent
end

_add_triple!(g, x::SubObjectPropertyOf, parent, annotations) = begin
    if x.ope1 isa OPExpression
        s = _add_triples!(g, x.ope1, parent, annotations)
        p = rdfs.subPropertyOf
        o = _add_triples!(g, x.ope2, parent, annotations)
        _add_triple!(g, Triple(s, p, o), annotations)
    elseif x.ope1 isa ObjectPropertyChain
        id = blank_node_id()
        s = _add_triples!(g, x.ope2, parent, annotations)
        p = owl.propertyChainAxiom
        o = id
        _add_triple!(g, Triple(s, p, o), annotations)
        _add_triples!(g, x.ope1, o, annotations)
    end
    return parent
end

_add_triple!(g, x::EquivalentObjectProperties, parent, annotations) = begin
    for i in eachindex(x.ope_n)
        if i == length(x.ope_n)
            # last
            if i % 2 == 1
                s = _add_triples!(g, x.ope_n[i-1], parent, annotations)
                p = owl.equivalentProperty
                o = _add_triples!(g, x.ope_n[i], parent, annotations)
                _add_triple!(g, Triple(s, p, o), annotations)
            end
        else
            s = _add_triples!(g, x.ope_n[i], parent, annotations)
            p = owl.equivalentProperty
            o = _add_triples!(g, x.ope_n[i+1], parent, annotations)
            _add_triple!(g, Triple(s, p, o), annotations)
        end
    end
    return parent
end

_add_triple!(g, x::DisjointObjectProperties, parent, annotations) = begin
    if length(x.ope_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        _add_triple!(g, Triple(id1, rdf.type, owl.allDisjointProperties), annotations)
        _add_triple!(g, Triple(id1, owl.members, id2), annotations)
        _add_triples!(g, x.ope_n, id2, annotations)
    else
        s = _add_triples!(g, x.ope_n[1], parent, annotations)
        p = owl.propertyDisjointWith
        o = _add_triples!(g, x.ope_n[2], parent, annotations)
        _add_triple!(g, Triple(s, p, o))
    end
    return parent
end

_add_triple!(g, x::ObjectPropertyDomain, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdfs.domain
    o = _add_triples!(g, x.ce, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::ObjectPropertyRange, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdfs.range
    o = _add_triples!(g, x.ce, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::InverseObjectProperties, parent, annotations) = begin
    s = _add_triples!(g, x.ope1, parent, annotations)
    p = owl.inverseOf
    o = _add_triples!(g, x.ope2, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::FunctionalObjectProperty, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdf.type
    o = owl.FunctionalProperty
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::InverseFunctionalObjectProperty, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdf.type
    o = owl.InverseFunctionalProperty
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::ReflexiveObjectProperty, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdf.type
    o = owl.ReflexiveProperty
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::IrreflexiveObjectProperty, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdf.type
    o = owl.IrreflexiveProperty
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::SymmetricObjectProperty, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdf.type
    o = owl.SymmetricProperty
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::AsymmetricObjectProperty, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdf.type
    o = owl.AsymmetricProperty
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::TransitiveObjectProperty, parent, annotations) = begin
    s = _add_triples!(g, x.ope, parent, annotations)
    p = rdf.type
    o = owl.TransitiveProperty
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::SubDataPropertyOf, parent, annotations) = begin
    s = _add_triples!(g, x.dpe1, parent, annotations)
    p = rdfs.subPropertyOf
    o = _add_triples!(g, x.dpe2, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::EquivalentDataProperties, parent, annotations) = begin
    for i in eachindex(x.dpe_n)
        if i == length(x.dpe_n)
            # last
            if i % 2 == 1
                s = _add_triples!(g, x.dpe_n[i-1], parent, annotations)
                p = owl.equivalentProperty
                o = _add_triples!(g, x.dpe_n[i], parent, annotations)
                _add_triple!(g, Triple(s, p, o), annotations)
            end
        else
            s = _add_triples!(g, x.dpe_n[i], parent, annotations)
            p = owl.equivalentProperty
            o = _add_triples!(g, x.dpe_n[i+1], parent, annotations)
            _add_triple!(g, Triple(s, p, o), annotations)
        end
    end
    return parent
end

_add_triple!(g, x::DisjointDataProperties, parent, annotations) = begin
    if length(x.dpe_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        _add_triple!(g, Triple(id1, rdf.type, owl.AllDisjointProperty), annotations)
        _add_triple!(g, Triple(id1, owl.members, id2), annotations)
        _add_triples!(g, x.dpe_n, id2, annotations)
    else
        s = _add_triples!(g, x.dpe_n[1], parent, annotations)
        p = owl.propertyDisjointWith
        o = _add_triples!(g, x.dpe_n[2], parent, annotations)
        _add_triple!(g, Triple(s, p, o), annotations)
    end
    return parent
end

_add_triple!(g, x::DataPropertyDomain, parent, annotations) = begin
    s = _add_triples!(g, x.dpe, parent, annotations)
    p = rdfs.domain
    o = _add_triples!(g, x.ce, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::DataPropertyRange, parent, annotations) = begin
    s = _add_triples!(g, x.dpe, parent, annotations)
    p = rdfs.range
    o = _add_triples!(g, x.dr, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::FunctionalDataProperty, parent, annotations) = begin
    s = _add_triples!(g, x.dpe, parent, annotations)
    p = rdf.type
    o = owl.FunctionalProperty
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::DatatypeDefinition, parent, annotations) = begin
    s = _add_triples!(g, x.dt, parent, annotations)
    p = owl.equivalentClass
    o = _add_triples!(g, x.dr, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::HasKey, parent, annotations) = begin
    id = blank_node_id()
    s = _add_triples!(g, x.ce, parent, annotations)
    p = owl.hasKey
    o = id
    _add_triple!(g, Triple(s, p, o), annotations)
    list = Vector()
    for ope in x.ope_n
        push!(list, ope)
    end
    for dpe in x.dpe_n
        push!(list, dpe)
    end
    _add_triples!(g, list, id, annotations)
end

_add_triple!(g, x::SameIndividual, parent, annotations) = begin
    for a in x.a_n
        if i == length(x.a_n)
            # last
            if i % 2 == 1
                s = _add_triples!(g, x.a_n[i-1], parent, annotations)
                p = owl.sameAs
                o = _add_triples!(g, x.a_n[i], parent, annotations)
                _add_triple!(g, Triple(s, p, o), annotations)
            end
        else
            s = _add_triples!(g, x.a_n[i], parent, annotations)
            p = owl.sameAs
            o = _add_triples!(g, x.a_n[i+1], parent, annotations)
            _add_triple!(g, Triple(s, p, o), annotations)
        end
    end
    return parent
end

_add_triple!(g, x::DifferentIndividuals, parent, annotations) = begin
    if length(x.a_n) > 2
        id1 = blank_node_id()
        id2 = blank_node_id()
        _add_triple!(g, Triple(id1, rdf.type, owl.AllDifferent), annotations)
        _add_triple!(g, Triple(id1, owl.members, id2), annotations)
        _add_triples!(g, x.a_n, id2, annotations)
    else
        s = _add_triples!(g, x.a_n[1], parent, annotatioins)
        p = owl.differentFrom
        o = _add_triples!(g, x.a_n[2], parent, annotations)
        _add_triple!(g, Triple(s, p, o), annotations)
    end
    return parent
end

_add_triple!(g, x::ClassAssertion, parent, annotations) = begin
    s = _add_triples!(g, x.a, parent, annotations)
    p = rdf.type
    o = _add_triples!(g, x.ce, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::ObjectPropertyAssertion, parent, annotations) = begin
    s = _add_triples!(g, x.a1, parent, annotations)
    p = _add_triples!(g, x.ope, parent, annotations)
    o = _add_triples!(g, x.a2, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::NegativeObjectPropertyAssertion, parent, annotations) = begin
    id = blank_node_id()
    a1 = _add_triples!(g, x.a1, parent, annotations)
    ope = _add_triples!(g, x.ope, parent, annotations)
    a2 = _add_triples!(g, x.a2, parent, annotations)
    _add_triple!(g, Triple(id, rdf.type, owl.NegativePropertyAssertion), annotations)
    _add_triple!(g, Triple(id, owl.sourceIndividual, a1), annotations)
    _add_triple!(g, Triple(id, owl.assertionProperty, ope), annotations)
    _add_triple!(g, Triple(id, owl.targetIndividual, a2), annotations)
    return id
end

_add_triple!(g, x::DataPropertyAssertion, parent, annotations) = begin
    s = _add_triples!(g, x.a, parent, annotations)
    p = _add_triples!(g, x.dpe, parent, annotations)
    o = _add_triples!(g, x.lt, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::NegativeDataPropertyAssertion, parent, annotations) = begin
    id = blank_node_id()
    a = _add_triples!(g, x.a, parent, annotations)
    dpe = _add_triples!(g, x.dpe, parent, annotations)
    value = _add_triples!(g, x.lt, parent, annotations)
    _add_triple!(g, Triple(id, rdf.type, owl.NegativePropertyAssertion), annotations)
    _add_triple!(g, Triple(id, owl.sourceIndividual, a), annotations)
    _add_triple!(g, Triple(id, owl.assertionProperty, dpe), annotations)
    _add_triple!(g, Triple(id, owl.targetValue, value), annotations)
    return id
end

_add_triple!(g, x::AnnotationAssertion, parent, annotations) = begin
    s = _add_triples!(g, x.ap, parent, annotations)
    p = x.as
    o = x.av
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::SubAnnotationPropertyOf, parent, annotations) = begin
    s = _add_triples!(g, x.ap1, parent, annotations)
    p = rdfs.subPropertyOf
    o = _add_triples!(g, x.ap2, parent, annotations)
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::AnnotationPropertyDomain, parent, annotations) = begin
    s = _add_triples!(g, x.ap, parent, annotations)
    p = rdfs.domain
    o = u
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

_add_triple!(g, x::AnnotationPropertyRange, parent, annotations) = begin
    s = _add_triples!(g, x.ap, parent, annotations)
    p = rdfs.range
    o = u
    _add_triple!(g, Triple(s, p, o), annotations)
    return parent
end

function blank_node_id()
    global _id_rotation += 1
    return BlankNode(_id_rotation)
end
