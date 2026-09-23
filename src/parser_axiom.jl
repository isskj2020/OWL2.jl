#
# Parsing Axioms
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function parse_axioms(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    parse_sub_class_of(g, decls, exprs, axioms, t)
    parse_equivalent_class(g, decls, exprs, axioms, t)
    parse_equivalent_property(g, decls, exprs, axioms, t)
    parse_disjoint_with(g, decls, exprs, axioms, t)
    parse_disjoint_union_of(g, decls, exprs, axioms, t)
    parse_all_disjoint_classes(g, decls, exprs, axioms, t)
    parse_property_disjoint_with(g, decls, exprs, axioms, t)
    parse_sub_property_of(g, decls, exprs, axioms, t)
    parse_property_chain_axiom(g, decls, exprs, axioms, t)
    parse_domain(g, decls, exprs, axioms, t)
    parse_range(g, decls, exprs, axioms, t)
    parse_inverse_of(g, decls, exprs, axioms, t)
    parse_functional_property(g, decls, exprs, axioms, t)
    parse_inverse_functional_property(g, decls, exprs, axioms, t)
    parse_reflexive_property(g, decls, exprs, axioms, t)
    parse_irreflexive_property(g, decls, exprs, axioms, t)
    parse_symmetric_property(g, decls, exprs, axioms, t)
    parse_asymmetric_property(g, decls, exprs, axioms, t)
    parse_transitive_property(g, decls, exprs, axioms, t)
    parse_has_key(g, decls, exprs, axioms, t)
    parse_same_as(g, decls, exprs, axioms, t)
    parse_different_from(g, decls, exprs, axioms, t)
    parse_all_different(g, decls, exprs, axioms, t)
    parse_class_assertion(g, decls, exprs, axioms, t)
    parse_object_property_assertion(g, decls, exprs, axioms, t)
    parse_data_property_assertion(g, decls, exprs, axioms, t)
    parse_negative_property_assertion(g, decls, exprs, axioms, t)
    parse_deprecated_class(g, decls, exprs, axioms, t)
    parse_deprecated_property(g, decls, exprs, axioms, t)
end

function parse_declaration(g::Graph, decls::Dict{UInt64, Any}, axioms::Vector{Axiom})
    for (id, d) in decls
        if d isa Class || d isa DataType || 
            d isa ObjectProperty || d isa DataProperty || 
            d isa AnnotationProperty || d isa NamedIndividual
            push!(axioms, Declaration(e = d))
        end
    end
end

function parse_sub_class_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_RDFS_SUB_CLASS_OF) && return

    ce1 = get(exprs, t.s, get(decls, t.s, nothing))
    ce2 = get(exprs, t.o, get(decls, t.o, nothing))
    if ce1 isa CExpression && ce2 isa CExpression
        push!(axioms, SubClassOf(ce1 = ce1, ce2 = ce2)) 
    else
        @warn "unkown axiom ce1:$ce1 ce2:$ce2 t:$(string_triple(g, t))"
    end
end

function parse_equivalent_class(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_EQUIVALENT_CLASS) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    if sub isa CExpression
        obj = gen_class(g, t.o)
        push!(axioms, EquivalentClasses(ce_n = [sub, obj]))
    elseif sub isa DataRange
        dr = DataType(g.names[t.o])
        push!(axioms, DatatypeDefinition(dt = sub, dr = dr))
    else
        @warn "unknown axiom s:$sub t:$(string_triple(g, t))"
    end
end

function parse_equivalent_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_EQUIVALENT_PROPERTY) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    obj = get(exprs, t.o, get(decls, t.o, nothing))
    if sub isa OPExpression && obj isa OPExpression
        push!(axioms, EquivalentObjectProperties(ope_n = [sub, obj]))
    elseif sub isa DPExpression && obj isa DPExpression
        push!(axioms, EquivalentDataProperties(dpe_n = [sub, obj]))
    else
        @warn "unknown axiom s:$sub o:$obj t:$(string_triple(g, t))"
    end
end

function parse_disjoint_with(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_DISJOINT_WITH) && return

    ce1 = get(exprs, t.s, get(decls, t.s, nothing))
    ce2 = get(exprs, t.o, get(decls, t.o, nothing))
    if ce1 isa CExpression && ce2 isa CExpression
        push!(axioms, DisjointClasses(ce_n = [ce1, ce2])) 
    else
        @warn "unkown axiom ce1:$ce1 ce2:$ce2 t:$(string_triple(g, t))"
    end
end

function parse_all_disjoint_classes(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.o != term_id(g, TERM_OWL_ALL_DISJOINT_CLASSES) && return

    nodes = filter(x -> t.s == x.s, g.triples)
    ce_n = Vector{CExpression}()
    for n in nodes
        if t.s == n.s && g.id_types[n.s] == BNode && g.id_types[n.o] == BNode
            chain_ids = Vector{UInt64}()
            parse_chain_list!(g, n.o, chain_ids)
            for id in chain_ids
                push!(ce_n, gen_class(g, id))
            end
        end
    end
    push!(axioms, DisjointClasses(ce_n = ce_n))
end

function parse_disjoint_union_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_DISJOINT_UNION_OF) && return

    nodes = filter(x -> t.s == x.s, g.triples)
    ce_n = Vector{CExpression}()
    c = nothing
    for n in nodes
        if is_class(g, n)
            c = gen_class(g, n.s)
        elseif g.id_types[n.o] == BNode
            chain_ids = Vector{UInt64}()
            parse_chain_list!(g, n.o, chain_ids)
            for id in chain_ids
                push!(ce_n, gen_class(g, id))
            end
        end
    end
    if c isa CExpression && !isempty(ce_n)
        push!(axioms, DisjointUnion(c = c, ce_n = ce_n))
    else
        @warn "unknown axiom t:$(string_triple(g, t))"
    end
end

function parse_property_disjoint_with(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_PROPERTY_DISJOINT_WITH) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    obj = get(exprs, t.o, get(decls, t.o, nothing))
    if sub isa OPExpression && obj isa OPExpression
        push!(axioms, DisjointObjectProperties(ope_n = [sub, obj]))
    elseif sub isa DPExpression && obj isa DPExpression
        push!(axioms, DisjointDataProperties(dpe_n = [sub, obj]))
    else
        @warn "unkown axiom s:$sub o:$obj t:$(string_triple(g, t))"
    end
end

function parse_sub_property_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_RDFS_SUB_PROPERTY_OF) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    obj = get(exprs, t.o, get(decls, t.o, nothing))
    if sub isa OPExpression && obj isa OPExpression
        push!(axioms, SubObjectPropertyOf(ope1 = sub, ope2 = obj)) 
    elseif sub isa DPExpression && obj isa DPExpression
        push!(axioms, SubDataPropertyOf(dpe1 = sub, dpe2 = obj)) 
    elseif sub isa AnnotationProperty && obj isa AnnotationPropert
        push!(axioms, SubAnnotationPropertyOf(ap1 = sub, api2 = obj)) 
    else
        @warn "unkown axiom s:$sub o:$obj t:$(string_triple(g, t))"
    end
end

function parse_property_chain_axiom(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_PROPERTY_CHAIN_AXIOM) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    ope_n = Vector{OPExpression}()
    if sub isa OPExpression && g.id_types[t.o] == BNode
        chain_ids = Vector{UInt64}()
        parse_chain_list!(g, t.o, chain_ids)
        for id in chain_ids
            obj = get(exprs, id, get(decls, id, nothing))
            if obj isa OPExpression
                push!(ope_n, obj)
            else
                push!(ope_n, ObjectProperty(g.names[id]))
            end
        end
        push!(axioms, SubObjectPropertyOf(ope1 = ObjectPropertyChain(ope_n), ope2 = sub)) 
    else
        @warn "unkown axiom t:$(string_triple(g, t))"
    end
end

function parse_domain(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_RDFS_DOMAIN) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    if sub isa OPExpression
        ce = gen_class(g, t.o)
        push!(axioms, ObjectPropertyDomain(ope = sub, ce = ce))
    elseif sub isa DPExpression
        ce = gen_class(g, t.o)
        push!(axioms, DataPropertyDomain(dpe = sub, ce = ce))
    elseif sub isa AnnotationProperty
        u = g.names[t.o] 
        push!(axioms, AnnotationPropertyDomain(ap = sub, u = u))
    else
        @warn "unkown axiom s:$sub o:$obj t:$(string_triple(g, t))"
    end
end

function parse_range(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_RDFS_RANGE) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    if sub isa OPExpression
        ce = gen_class(g, t.o)
        push!(axioms, ObjectPropertyRange(ope = sub, ce = ce))
    elseif sub isa DPExpression
        dr = gen_datatype(g, t.o)
        push!(axioms, DataPropertyRange(dpe = sub, dr = dr))
    elseif sub isa AnnotationProperty
        u = g.names[t.o]
        push!(axioms, AnnotationPropertyRange(ap = sub, u = u))
    else
        @warn "unkown axiom s:$sub o:$obj t:$(string_triple(g, t))"
    end
end

function parse_inverse_of(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_INVERSE_OF) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    if sub isa OPExpression
        obj = ObjectProperty(g.names[t.o])
        push!(axioms, InverseObjectProperties(ope1 = sub, ope2 = obj))
    else
        @warn "unkown axiom s:$sub t:$(string_triple(g, t))"
    end
end

function parse_functional_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.p != term_id(g, TERM_RDF_TYPE) || 
     t.o != term_id(g, TERM_OWL_FUNCTIONAL_PROPERTY)) && return

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    if sub isa OPExpression
        push!(axioms, FunctionalObjectProperty(ope = sub))
    elseif sub isa DPExpression
        push!(axioms, FunctionalDataProperty(dpe = sub))
    else
        @warn "unkown axiom s:$sub t:$(string_triple(g, t))"
    end
end

function parse_inverse_functional_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.p != term_id(g, TERM_RDF_TYPE) || 
     t.o != term_id(g, TERM_OWL_INVERSE_FUNCTIONAL_PROPERTY)) && return

    ope = ObjectProperty(g.names[t.s])
    push!(axioms, InverseFunctionalObjectProperty(ope = ope))
end

function parse_reflexive_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.p != term_id(g, TERM_RDF_TYPE) || 
     t.o != term_id(g, TERM_OWL_REFLEXIVE_PROPERTY)) && return

    ope = ObjectProperty(g.names[t.s])
    push!(axioms, ReflexiveObjectProperty(ope = ope))
end

function parse_irreflexive_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.p != term_id(g, TERM_RDF_TYPE) || 
     t.o != term_id(g, TERM_OWL_IRREFLEXIVE_PROPERTY)) && return

    ope = ObjectProperty(g.names[t.s])
    push!(axioms, IrreflexiveObjectProperty(ope = ope))
end

function parse_symmetric_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.p != term_id(g, TERM_RDF_TYPE) || 
     t.o != term_id(g, TERM_OWL_SYMMETRIC_PROPERTY)) && return

    ope = ObjectProperty(g.names[t.s])
    push!(axioms, SymmetricObjectProperty(ope = ope))
end

function parse_asymmetric_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.p != term_id(g, TERM_RDF_TYPE) || 
     t.o != term_id(g, TERM_OWL_ASYMMETRIC_PROPERTY)) && return

    ope = ObjectProperty(g.names[t.s])
    push!(axioms, AsymmetricObjectProperty(ope = ope))
end

function parse_transitive_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.p != term_id(g, TERM_RDF_TYPE) || 
     t.o != term_id(g, TERM_OWL_ASYMMETRIC_PROPERTY)) && return

    ope = ObjectProperty(g.names[t.s])
    push!(axioms, TransitiveObjectProperty(ope = ope))
end

function parse_has_key(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_HAS_KEY) && return 

    sub = get(exprs, t.s, get(decls, t.s, nothing))
    if sub isa CExpression && g.id_types[t.o] == BNode
        chain_ids = Vector{UInt64}()
        parse_chain_list!(g, t.o, chain_ids)
        ope_n = Vector{OPExpression}()
        dpe_n = Vector{DPExpression}()
        for id in chain_ids
            obj = get(exprs, id, get(decls, id, nothing))
            if obj isa OPExpression
                push!(ope_n, obj)
            elseif obj isa DPExpression
                push!(dpe_n, obj)
            end
        end
        push!(axioms, HasKey(ce = sub, ope_n = ope_n, dpe_n = dpe_n))
    else
        @warn "unkown axiom s:$sub t:$(string_triple(g, t))"
    end
end

function parse_same_as(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_SAME_AS) && return

    sub = gen_individual(g, t.s)
    obj = gen_individual(g, t.o)
    push!(axioms, SameIndividual(a_n = [sub, obj]))
end

function parse_different_from(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_OWL_DIFFERENT_FROM) && return

    sub = gen_individual(g, t.s)
    obj = gen_individual(g, t.o)
    push!(axioms, DifferentIndividuals(a_n = [sub, obj]))
end

function parse_all_different(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.p != term_id(g, TERM_RDF_TYPE) || 
     t.o != term_id(g, TERM_OWL_ALL_DIFFERENT)) && return

    nodes = filter(x -> t.s == x.s, g.triples)
    for n in nodes
        if t.s == n.s && g.id_types[n.s] == BNode && g.id_types[n.o] == BNode
            chain_ids = Vector{UInt64}()
            parse_chain_list!(g, n.o, chain_ids)
            a_n = Vector{Individual}()
            for id in chain_ids
                push!(a_n, gen_individual(g, id))
            end
            push!(axioms, DifferentIndividuals(a_n = a_n))
        end
    end
end

function parse_class_assertion(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    t.p != term_id(g, TERM_RDF_TYPE) && return
    sub = get(exprs, t.o, get(decls, t.o, nothing))
    (sub == nothing || !(sub isa CExpression)) && return

    a = gen_individual(g, t.s)
    push!(axioms, ClassAssertion(ce = sub, a = a))
end

function parse_object_property_assertion(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    sub = get(exprs, t.p, get(decls, t.p, nothing))
    (sub == nothing || !(sub isa OPExpression)) && return

    a1 = gen_individual(g, t.s)
    a2 = gen_individual(g, t.o)
    push!(axioms, ObjectPropertyAssertion(ope = sub, a1 = a1, a2 = a2))
end

function parse_data_property_assertion(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    sub = get(exprs, t.p, get(decls, t.p, nothing))
    (sub == nothing || !(sub isa DPExpression)) && return

    a1 = gen_individual(g, t.s)
    a2 = gen_individual(g, t.o)
    push!(axioms, DataPropertyAssertion(dpe = sub, a1 = a1, a2 = a2))
end

function parse_negative_property_assertion(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.o != term_id(g, TERM_OWL_NEGATIVE_PROPERTY_ASSERTION) ||
     t.p != term_id(g, TERM_RDF_TYPE) ||
     g.id_types[t.s] != BNode) && return

    nodes = filter(x -> t.s == x.s, g.triples)
    src = nothing
    tgt = nothing
    prop = nothing
    for n in nodes
        if n.p == term_id(g, TERM_OWL_SOURCE_INDIVIDUAL)
            src = gen_individual(n.o)
        elseif n.p == term_id(g, TERM_OWL_TARGET_INDIVIDUAL)
            tgt = gen_individual(n.o)
        elseif n.p == term_id(g, TERM_OWL_ASSERTION_PROPERTY)
            prop = get(decls, n.o, get(expr, n.o, nothing))
        end
    end

    if src == nothing || tgt == nothing || prop == nothing
        @warn "unkown axiom ce1:$ce1 ce2:$ce2 t:$(string_triple(g, t))"
    end
    if prop isa OPExpression
        push!(axioms, NegativeObjectPropertyAssertion(ope = prop, a1 = src, a2 = tgt))
    elseif prop isa DPExpression
        push!(axioms, NegativeDataPropertyAssertion(dpe = prop, a1 = src, a2 = tgt))
    else
        @warn "unkown axiom ce1:$ce1 ce2:$ce2 t:$(string_triple(g, t))"
    end
end

function parse_deprecated_class(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.o != term_id(g, TERM_OWL_DEPRECATED_CLASS) ||
     t.p != term_id(g, TERM_RDF_TYPE)) && return

    ap = AnnotationProperty(TERM_OWL_DEPRECATED)
    as = g.names[t.s]
    av = "\"true\"^^$TERM_XSD_BOOLEAN"
    push!(axioms, AnnotationAssertion(ap = ap, as = as, av = av))
end

function parse_deprecated_property(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any}, axioms::Vector{Axiom}, t::TripleID)
    (t.o != term_id(g, TERM_OWL_DEPRECATED_PROPERTY) ||
     t.p != term_id(g, TERM_RDF_TYPE)) && return

    ap = AnnotationProperty(TERM_OWL_DEPRECATED)
    as = g.names[t.s]
    av = "\"true\"^^$TERM_XSD_BOOLEAN"
    push!(axioms, AnnotationAssertion(ap = ap, as = as, av = av))
end
