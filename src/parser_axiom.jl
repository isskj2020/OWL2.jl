#
# Parsing Axioms
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function _parse_axioms!(g, decls, exprs, axioms, t)
    _parse_sub_class_of!(g, decls, exprs, axioms, t)
    _parse_equivalent_class!(g, decls, exprs, axioms, t)
    _parse_equivalent_property!(g, decls, exprs, axioms, t)
    _parse_disjoint_with!(g, decls, exprs, axioms, t)
    _parse_disjoint_union_of!(g, decls, exprs, axioms, t)
    _parse_all_disjoint_classes!(g, decls, exprs, axioms, t)
    _parse_property_disjoint_with!(g, decls, exprs, axioms, t)
    _parse_sub_property_of!(g, decls, exprs, axioms, t)
    _parse_property_chain_axiom!(g, decls, exprs, axioms, t)
    _parse_domain!(g, decls, exprs, axioms, t)
    _parse_range!(g, decls, exprs, axioms, t)
    _parse_inverse_of!(g, decls, exprs, axioms, t)
    _parse_functional_property!(g, decls, exprs, axioms, t)
    _parse_inverse_functional_property!(g, decls, exprs, axioms, t)
    _parse_reflexive_property!(g, decls, exprs, axioms, t)
    _parse_irreflexive_property!(g, decls, exprs, axioms, t)
    _parse_symmetric_property!(g, decls, exprs, axioms, t)
    _parse_asymmetric_property!(g, decls, exprs, axioms, t)
    _parse_transitive_property!(g, decls, exprs, axioms, t)
    _parse_has_key!(g, decls, exprs, axioms, t)
    _parse_same_as!(g, decls, exprs, axioms, t)
    _parse_different_from!(g, decls, exprs, axioms, t)
    _parse_all_different!(g, decls, exprs, axioms, t)
    _parse_class_assertion!(g, decls, exprs, axioms, t)
    _parse_object_property_assertion!(g, decls, exprs, axioms, t)
    _parse_data_property_assertion!(g, decls, exprs, axioms, t)
    _parse_negative_property_assertion!(g, decls, exprs, axioms, t)
    _parse_deprecated_class!(g, decls, exprs, axioms, t)
    _parse_deprecated_property!(g, decls, exprs, axioms, t)
end

# T(CE1) rdfs:subClassOf T(CE2) .
function _parse_sub_class_of!(g, decls, exprs, axioms, t)
    t.predicate == rdfs.subClassOf || return

    ce1 = get(exprs, t.subject, get(decls, t.subject, nothing))
    if ce1 == nothing
        ce1 = Class(t.subject)
        decls[t.subject] = ce1
    end
    ce2 = get(exprs, t.object, get(decls, t.object, nothing))
    if ce2 == nothing
        ce2 = Class(t.subject)
        decls[t.subject] = ce2
    end
    if ce1 isa CExpression && ce2 isa CExpression
        push!(axioms, SubClassOf(ce1 = ce1, ce2 = ce2)) 
    else
        throw(FormatError("$t T($ce1) rdfs:subClassOf T($ce2)"))
    end
end

# T(CE1) owl:equivalentClass T(CE2) .
# T(DT) owl:equivalentClass T(DR) .
function _parse_equivalent_class!(g, decls, exprs, axioms, t)
    t.predicate == owl.equivalentClass || return

    sub = get(exprs, t.subject, get(decls, t.subject, nothing))
    obj = get(exprs, t.object, get(decls, t.object, nothing))
    if sub isa CExpression && obj isa CExpression
        push!(axioms, EquivalentClasses(ce_n = [sub, obj]))
    elseif sub isa DataRange && obj isa DataRange
        push!(axioms, DatatypeDefinition(dt = sub, dr = dr))
    else
        throw(FormatError("$t T($sub) owl:equivalentClass T($obj)"))
    end
end

# T(OPE1) owl:equivalentProperty T(OPE2) .
# T(DPE1) owl:equivalentProperty T(DPE2) .
function _parse_equivalent_property!(g, decls, exprs, axioms, t)
    t.predicate == owl.equivalentProperty || return

    sub = get(exprs, t.subject, get(decls, t.subject, nothing))
    obj = get(exprs, t.object, get(decls, t.object, nothing))
    if sub isa OPExpression && obj isa OPExpression
        push!(axioms, EquivalentObjectProperties(ope_n = [sub, obj]))
    elseif sub isa DPExpression && obj isa DPExpression
        push!(axioms, EquivalentDataProperties(dpe_n = [sub, obj]))
    else
        throw(FormatError("$t T($sub) owl:equivalentProperty T($obj)"))
    end
end

# T(CE1) owl:disjointWith T(CE2) .
function _parse_disjoint_with!(g, decls, exprs, axioms, t)
    t.predicate == owl.disjointWith || return

    ce1 = get(exprs, t.subject, get(decls, t.subject, nothing))
    ce2 = get(exprs, t.object, get(decls, t.object, nothing))
    if ce1 isa CExpression && ce2 isa CExpression
        push!(axioms, DisjointClasses(ce_n = [ce1, ce2])) 
    else
        throw(FormatError("$t T($ce1) owl:disjointWith T($ce2)"))
    end
end

# _:x rdf:type owl:AllDisjointClasses .
# _:x owl:members T(SEQ CE1 ... CEn) .
function _parse_all_disjoint_classes!(g, decls, exprs, axioms, t)
    t.object == owl.AllDisjointClasses || return

    members = collect(match(g; subject = t.subject, predicate = owl.members))
    if isempty(members)
        throw(FormatError("$t owl:members is empty"))
    end
    members = first(members)
    ce_n = CExpression[]
    if members.object isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, members.object, terms)
        for term in terms
            ce = get(exprs, term, get(decls, term, Class(term)))
            push!(ce_n, ce)
        end
    end
    if isempty(ce_n)
        throw(FormatError("$t ce_n is empty"))
    end
    push!(axioms, DisjointClasses(ce_n = ce_n))
end

# T(C) owl:disjointUnionOf T(SEQ CE1 ... CEn) .
function _parse_disjoint_union_of!(g, decls, exprs, axioms, t)
    t.predicate == owl.disjointUnionOf || return

    ce = get(exprs, t.subject, get(decls, t.subject, nothing))
    if ce == nothing
        ce = Class(t.subject)
    end
    if !(ce isa CExpression)
        throw(FormatError("$t $ce is not CExpression"))
    end
    ce_n = CExpression[]
    if t.object isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, t.object, terms)
        for term in terms
            ce = get(exprs, term, get(decls, term, Class(term)))
            push!(ce_n, ce)
        end
    end
    if isempty(ce_n)
        throw(FormatError("$t ce_n is empty"))
    end
    push!(axioms, DisjointUnion(c = c, ce_n = ce_n))
end

# T(OPE1) owl:propertyDisjointWith T(OPE2) .
# T(DPE1) owl:propertyDisjointWith T(DPE2) .
function _parse_property_disjoint_with!(g, decls, exprs, axioms, t)
    t.predicate == owl.propertyDisjointWith || return

    sub = get(exprs, t.subject, get(decls, t.subject, nothing))
    obj = get(exprs, t.object, get(decls, t.object, nothing))
    if sub isa OPExpression && obj isa OPExpression
        push!(axioms, DisjointObjectProperties(ope_n = [sub, obj]))
    elseif sub isa DPExpression && obj isa DPExpression
        push!(axioms, DisjointDataProperties(dpe_n = [sub, obj]))
    else
        throw(FormatError("$t T($sub) owl:propertyDisjointWith T($obj)"))
    end
end

# T(OPE1) rdfs:subPropertyOf T(OPE2) .
# T(DPE1) rdfs:subPropertyOf T(DPE2) .
# T(AP1) rdfs:subPropertyOf T(AP2) .
function _parse_sub_property_of!(g, decls, exprs, axioms, t)
    t.predicate == rdfs.subPropertyOf || return

    sub = get(exprs, t.subject, get(decls, t.subject, nothing))
    obj = get(exprs, t.object, get(decls, t.object, nothing))
    if sub isa OPExpression && obj isa OPExpression
        push!(axioms, SubObjectPropertyOf(ope1 = sub, ope2 = obj)) 
    elseif sub isa DPExpression && obj isa DPExpression
        push!(axioms, SubDataPropertyOf(dpe1 = sub, dpe2 = obj)) 
    elseif sub isa AnnotationProperty && obj isa AnnotationPropert
        push!(axioms, SubAnnotationPropertyOf(ap1 = sub, api2 = obj)) 
    else
        throw(FormatError("$t T($sub) rdfs.subPropertyOf T($obj)"))
    end
end

# T(OPE) owl:propertyChainAxiom T(SEQ OPE1 ... OPEn) .
function _parse_property_chain_axiom!(g, decls, exprs, axioms, t)
    t.predicate == owl.propertyChainAxiom || return

    ope = get(exprs, t.subject, get(decls, t.subject, nothing))
    if ope == nothing
        ope = ObjectProperty(t.subject)
    end
    if !(ope isa OPExpression)
        throw(FormatError("$t $ope is not OPExpression"))
    end
    ope_n = OPExpression[]
    if t.object isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, t.object, terms)
        for term in terms
            op = get(exprs, term, get(decls, term, ObjectProperty(term)))
            push!(ope_n, ObjectProperty(term))
        end
    end
    if isempty(ope_n)
        throw(FormatError("$t ope_n is empty"))
    end
    push!(axioms, SubObjectPropertyOf(ope1 = ObjectPropertyChain(ope_n), ope2 = ope)) 
end

# T(OPE) rdfs:domain T(CE) .
# T(DPE) rdfs:domain T(CE) .
# T(AP) rdfs:domain T(U) .
function _parse_domain!(g, decls, exprs, axioms, t)
    t.predicate == rdfs.domain || return

    sub = get(exprs, t.subject, get(decls, t.subject, nothing))
    if sub isa OPExpression
        ce = get(exprs, t.object, get(decls, t.object, Class(t.object)))
        push!(axioms, ObjectPropertyDomain(ope = sub, ce = ce))
    elseif sub isa DPExpression
        ce = get(exprs, t.object, get(decls, t.object, Class(t.object)))
        push!(axioms, DataPropertyDomain(dpe = sub, ce = ce))
    elseif sub isa AnnotationProperty
        u = string(t.object)
        push!(axioms, AnnotationPropertyDomain(ap = sub, u = u))
    else
        throw(FormatError("$t T($sub) rdfs.domain"))
    end
end

# T(OPE) rdfs:range T(CE) .
# T(DPE) rdfs:range T(DR) .
# T(AP) rdfs:range T(U) .
function _parse_range!(g, decls, exprs, axioms, t)
    t.predicate == rdfs.range || return

    sub = get(exprs, t.subject, get(decls, t.subject, nothing))
    if sub isa OPExpression
        ce = get(exprs, t.object, get(decls, t.object, Class(t.object)))
        push!(axioms, ObjectPropertyRange(ope = sub, ce = ce))
    elseif sub isa DPExpression
        dr = get(exprs, t.object, get(decls, t.object, DataType(t.object)))
        push!(axioms, DataPropertyRange(dpe = sub, dr = dr))
    elseif sub isa AnnotationProperty
        u = string(t.object)
        push!(axioms, AnnotationPropertyRange(ap = sub, u = u))
    else
        throw(FormatError("$t T($sub) rdfs.range"))
    end
end

# _:x owl:inverseOf T(OP) .
# T(OPE1) owl:inverseOf T(OPE2) .
function _parse_inverse_of!(g, decls, exprs, axioms, t)
    (t.predicate == owl.inverseOf && !(t.subject isa BlankNode)) || return

    sub = get(exprs, t.subject, get(decls, t.subject, nothing))
    obj = get(exprs, t.object, get(decls, t.object, nothing))
    if sub isa OPExpression && obj isa OPExpression
        push!(axioms, InverseObjectProperties(ope1 = sub, ope2 = obj))
    else
        throw(FormatError("$t T($sub) owl:inverseOf T($obj)"))
    end
end

# T(OPE) rdf:type owl:FunctionalProperty .
# T(DPE) rdf:type owl:FunctionalProperty .
function _parse_functional_property!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.FunctionalProperty) || return

    sub = get(exprs, t.subject, get(decls, t.subject, nothing))
    if sub isa OPExpression
        push!(axioms, FunctionalObjectProperty(ope = sub))
    elseif sub isa DPExpression
        push!(axioms, FunctionalDataProperty(dpe = sub))
    else
        throw(FormatError("$t T($sub)"))
    end
end

# T(OPE) rdf:type owl:InverseFunctionalProperty .
function _parse_inverse_functional_property!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.InverseFunctionalProperty) || return

    ope = get(exprs, t.subject, get(decls, t.subject, ObjectProperty(t.subject)))
    push!(axioms, InverseFunctionalObjectProperty(ope = ope))
end

# T(OPE) rdf:type owl:ReflexiveProperty .
function _parse_reflexive_property!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.ReflexiveProperty) || return

    ope = get(exprs, t.subject, get(decls, t.subject, ObjectProperty(t.subject)))
    push!(axioms, ReflexiveObjectProperty(ope = ope))
end

# T(OPE) rdf:type owl:IrreflexiveProperty .
function _parse_irreflexive_property!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.IrreflexiveProperty) || return

    ope = get(exprs, t.subject, get(decls, t.subject, ObjectProperty(t.subject)))
    push!(axioms, IrreflexiveObjectProperty(ope = ope))
end

# T(OPE) rdf:type owl:SymmetricProperty .
function _parse_symmetric_property!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.SymmetricProperty) || return

    ope = get(exprs, t.subject, get(decls, t.subject, ObjectProperty(t.subject)))
    push!(axioms, SymmetricObjectProperty(ope = ope))
end

# T(OPE) rdf:type owl:AsymmetricProperty .
function _parse_asymmetric_property!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.AsymmetricProperty) || return

    ope = get(exprs, t.subject, get(decls, t.subject, ObjectProperty(t.subject)))
    push!(axioms, AsymmetricObjectProperty(ope = ope))
end

# T(OPE) rdf:type owl:TransitiveProperty .
function _parse_transitive_property!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.TransitiveProperty) || return

    ope = get(exprs, t.subject, get(decls, t.subject, ObjectProperty(t.subject)))
    push!(axioms, TransitiveObjectProperty(ope = ope))
end

# T(CE) owl:hasKey T(SEQ OPE1 ... OPEm DPE1 ... DPEn ) .
function _parse_has_key!(g, decls, exprs, axioms, t)
    t.predicate == owl.hasKey || return

    ce = get(exprs, t.subject, get(decls, t.subject, Class(t.subject)))
    if t.object isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, t.object, terms)
        ope_n = Vector{OPExpression}()
        dpe_n = Vector{DPExpression}()
        for term in terms
            obj = get(exprs, term, get(decls, term, nothing))
            if obj isa OPExpression
                push!(ope_n, obj)
            elseif obj isa DPExpression
                push!(dpe_n, obj)
            end
        end
        push!(axioms, HasKey(ce = ce, ope_n = ope_n, dpe_n = dpe_n))
    else
        throw(FormatError("$t T($ce)"))
    end
end

# T(a1) owl:sameAs T(a2) .
function _parse_same_as!(g, decls, exprs, axioms, t)
    t.predicate == owl.sameAs || return

    sub = get(decls, t.subject, Individual(t.subject))
    obj = get(decls, t.object, Individual(t.object))
    push!(axioms, SameIndividual(a_n = [sub, obj]))
end

# T(a1) owl:differentFrom T(a2) .
function _parse_different_from!(g, decls, exprs, axioms, t)
    t.predicate == owl.differentFrom || return

    sub = get(decls, t.subject, Individual(t.subject))
    obj = get(decls, t.object, Individual(t.object))
    push!(axioms, DifferentIndividuals(a_n = [sub, obj]))
end

# _:x rdf:type owl:AllDifferent .
# _:x owl:members T(SEQ a1 ... an) .
function _parse_all_different!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.AllDifferent) || return

    members = collect(match(g; subject = t.subject, predicate = owl.members))
    if isempty(members)
        members = collect(match(g; subject = t.subject, predicate = owl.distinctMembers))
    end
    if isempty(members)
        throw(FormatError("$t $members is missing"))
    end
    members = first(members)
    a_n = Individual[]
    if members.object isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, members.object, terms)
        for term in terms
            a = get(decls, term, Individual(term))
            push!(a_n, a)
        end
    else
        throw(FormatError("$t owl:members $members"))
    end
    if isempty(a_n)
        throw(FormatError("$t a_n is empty"))
    end
    push!(axioms, DifferentIndividuals(a_n = a_n))
end

# T(a) rdf:type T(CE) .
function _parse_class_assertion!(g, decls, exprs, axioms, t)
    t.predicate == rdf.type || return

    sub = get(decls, t.subject, nothing)
    obj = get(exprs, t.object, get(decls, t.object, nothing))
    if sub isa Individual
        # && obj isa CExpression
        obj = Class(t.object)
        push!(axioms, ClassAssertion(ce = obj, a = sub))
    end
end

# T(a1) T(OP) T(a2) .
function _parse_object_property_assertion!(g, decls, exprs, axioms, t)
    ope = get(exprs, t.predicate, get(decls, t.predicate, nothing))
    if ope isa OPExpression
        a1 = get(decls, t.subject, Individual(t.subject))
        a2 = get(decls, t.object, Individual(t.object))
        push!(axioms, ObjectPropertyAssertion(ope = ope, a1 = a1, a2 = a2))
    end
end

# T(a) T(DPE) T(lt) .
function _parse_data_property_assertion!(g, decls, exprs, axioms, t)
    dpe = get(exprs, t.predicate, get(decls, t.predicate, nothing))
    if dpe isa DPExpression
        a1 = get(decls, t.subject, Individual(t.subject))
        lt = get(decls, t.object, Literal(t.object))
        push!(axioms, DataPropertyAssertion(dpe = dpe, a = a, lt = lt))
    end
end

# NegativeObjectPropertyAssertion( OPE a1 a2 )
# _:x rdf:type owl:NegativePropertyAssertion .
# _:x owl:sourceIndividual T(a1) .
# _:x owl:assertionProperty T(OPE) .
# _:x owl:targetIndividual T(a2) .
#
# NegativeDataPropertyAssertion( DPE a lt )
# _:x rdf:type owl:NegativePropertyAssertion .
# _:x owl:sourceIndividual T(a) .
# _:x owl:assertionProperty T(DPE) .
# _:x owl:targetValue T(lt) .
function _parse_negative_property_assertion!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.NegativePropertyAssertion) || return

    prop = match(g; subject = t.subject, predicate = owl.assertionProperty)
    isempty(prop) && throw(FormatError("$t"))
    prop = first(prop)
    prop = get(exprs, prop.object, get(decls, prop.object, nothing))
    if prop isa OPExpression
        source = match(g; subject = t.subject, predicate = owl.sourceIndividual)
        isempty(source) && throw(FormatError("$t $prop owl:sourceIndividual is missing"))
        source = first(source)
        a1 = get(decls, source.object, Individual(source.object))

        target = match(g; subject = t.subject, predicate = owl.targetIndividual)
        isempty(target) && throw(FormatError("$t $prop owl:targetIndividual is missing"))
        target = first(target)
        a2 = get(decls, target.object, Individual(target.object))
        push!(axioms, NegativeObjectPropertyAssertion(ope = prop, a1 = a1, a2 = a2))

    elseif prop isa DPExpression
        source = match(g; subject = t.subject, predicate = owl.sourceIndividual)
        isempty(source) && throw(FormatError("$t $prop owl:sourceIndividual is missing"))
        source = first(source)
        a1 = get(decls, source.object, Individual(source.object))

        target = match(g; subject = t.subject, predicate = owl.targetValue)
        isempty(target) && throw(FormatError("$t $prop owl:targetValue is missing"))
        target = first(target)
        target_value = string(target.object)
        push!(axioms, NegativeDataPropertyAssertion(dpe = prop, a1 = a1, lt = target_value))
    else
        throw(FormatError("$t $prop"))
    end
end

# *:x rdf:type owl:DeprecatedClass .
function _parse_deprecated_class!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.DeprecatedClass) || return

    ap = AnnotationProperty(owl.deprecated)
    as = string(t.subject)
    av = "\"true\"^^$(string(xsd.boolean))"
    push!(axioms, AnnotationAssertion(ap = ap, as = as, av = av))
end

# *:x rdf:type owl:DeprecatedProperty .
function _parse_deprecated_property!(g, decls, exprs, axioms, t)
    (t.predicate == rdf.type && t.object == owl.DeprecatedProperty) || return

    ap = AnnotationProperty(owl.deprecated)
    as = string(t.subject)
    av = "\"true\"^^$(xsd.boolean)"
    push!(axioms, AnnotationAssertion(ap = ap, as = as, av = av))
end

