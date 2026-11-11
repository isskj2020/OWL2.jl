#
# Parsing Expressions
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function _parse_expressions!(g, decls, exprs, t)
    _parse_some_values_from!(g, decls, exprs, t)
    _parse_all_values_from!(g, decls, exprs, t)
    _parse_intersection_of!(g, decls, exprs, t)
    _parse_union_of!(g, decls, exprs, t)
    _parse_complement_of!(g, decls, exprs, t)
    _parse_datatype_complement_of!(g, decls, exprs, t)
    _parse_one_of!(g, decls, exprs, t)
    _parse_has_value!(g, decls, exprs, t)
    _parse_has_self!(g, decls, exprs, t)
    _parse_min_cardinality!(g, decls, exprs, t)
    _parse_min_qualified_cardinality!(g, decls, exprs, t)
    _parse_inverse_of!(g, decls, exprs, t)
    _parse_with_restrictions!(g, decls, exprs, t)
end

# ObjectSomeValuesFrom( OPE CE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:someValuesFrom T(CE) .
#
# DataSomeValuesFrom( DPE DR )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:someValuesFrom T(DR) .
#
# DataSomeValuesFrom( DPE1 ... DPEn DR ), n ≥ 2
# _:x rdf:type owl:Restriction .
# _:x owl:onProperties T(SEQ DPE1 ... DPEn) .
# _:x owl:someValuesFrom T(DR) .
function _parse_some_values_from!(g, decls, exprs, t)
    t.predicate == owl.someValuesFrom || return

    _restriction(g, t)

    obj = get(decls, t.object, nothing)
    if obj isa CExpression
        # object property
        ope = _object_on_property(g, decls, t)
        exprs[t.subject] = ObjectSomeValuesFrom(ope = ope, ce = obj)
    elseif obj isa DataRange
        # data property
        dpe_n = _data_on_properties(g, decls, t)
        exprs[t.subject] = DataSomeValuesFrom(dpe_n = dpe_n, dr = obj)
    else
        throw(FormatError("$t $obj"))
    end
end

# ObjectAllValuesFrom( OPE CE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:allValuesFrom T(CE) .
#
# DataAllValuesFrom( DPE DR )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:allValuesFrom T(DR) .
#
# DataAllValuesFrom( DPE1 ... DPEn DR ), n ≥ 2
# _:x rdf:type owl:Restriction .
# _:x owl:onProperties T(SEQ DPE1 ... DPEn) .
# _:x owl:allValuesFrom T(DR) .
function _parse_all_values_from!(g, decls, exprs, t)
    t.predicate == owl.allValuesFrom || return

    _restriction(g, t)

    obj = get(decls, t.object, nothing)
    if obj isa CExpression
        # object property
        ope = _object_on_property(g, decls, t)
        exprs[t.subject] = ObjectAllValuesFrom(ope = ope, ce = obj)
    elseif obj isa DataRange
        # data property
        dpe_n = _data_on_properties(g, decls, t)
        exprs[t.subject] = DataAllValuesFrom(dpe_n = dpe_n, dr = obj)
    else
        throw(FormatError("$t $obj"))
    end
end

# ObjectIntersectionOf( CE1 ... CEn )
# _:x rdf:type owl:Class .
# _:x owl:intersectionOf T(SEQ CE1 ... CEn) .
#
# DataIntersectionOf( DR1 ... DRn )
# _:x rdf:type rdfs:Datatype .
# _:x owl:intersectionOf T(SEQ DR1 ... DRn) .
function _parse_intersection_of!(g, decls, exprs, t)
    t.predicate == owl.intersectionOf || return

    if !isempty(match(g; subject = t.subject, predicate = rdf.type, object = owl.Class))
        # object intersection of
        ce_n = _sequence_of_class_expressions(g, decls, t.object)
        exprs[t.subject] = ObjectIntersectionOf(ce_n = ce_n)
    elseif !isempty(match(g; subject = t.subject, predicate = rdf.type, object = rdfs.Datatype))
        # data intersection of
        dr_n = _sequence_of_data_ranges(g, decls, t.object)
        exprs[t.subject] = DataIntersectionOf(dr_n = dr_n)
    else
        throw(FormatError("$t $ts"))
    end
end

# ObjectUnionOf( CE1 ... CEn )
# _:x rdf:type owl:Class .
# _:x owl:unionOf T(SEQ CE1 ... CEn) .
#
# DataUnionOf( DR1 ... DRn )
# _:x rdf:type rdfs:Datatype .
# _:x owl:unionOf T(SEQ DR1 ... DRn) .
function _parse_union_of!(g, decls, exprs, t)
    t.predicate == owl.unionOf || return

    if !isempty(match(g; subject = t.subject, predicate = rdf.type, object = owl.Class))
        # object union of
        ce_n = _sequence_of_class_expressions(g, decls, t.object)
        exprs[t.subject] = ObjectUnionOf(ce_n = ce_n)
    elseif !isempty(match(g; subject = t.subject, predicate = rdf.type, object = rdfs.Datatype))
        # data union of
        dr_n = _sequence_of_data_ranges(g, decls, t.object)
        exprs[t.subject] = DataUnionOf(dr_n = dr_n)
    else
        throw(FormatError("$t"))
    end
end


# ObjectComplementOf( CE )
# _:x rdf:type owl:Class .
# _:x owl:complementOf T(CE) .
function _parse_complement_of!(g, decls, exprs, t)
    t.predicate == owl.complementOf || return

    if !isempty(match(g; subject = t.subject, predicate = rdf.type, object = owl.Class))
        ce = get(decls, t.object, Class(t.object))
        exprs[t.subject] = ObjectComplementOf(ce = ce)
    else
        throw(FormatError("$t"))
    end
end

# DataComplementOf( DR )
# _:x rdf:type rdfs:Datatype .
# _:x owl:datatypeComplementOf T(DR) .
function _parse_datatype_complement_of!(g, decls, exprs, t)
    t.predicate == owl.datatypeComplementOf || return

    if !isempty(match(g; subject = t.subject, predicate = rdf.type, object = rdfs.Datatype))
        dt = get(decls, t.object, DataType(t.object))
        exprs[t.subject] = DataComplementOf(dr = dt)
    else
        throw(FormatError("$t"))
    end
end

# ObjectOneOf( a1 ... an )
# _:x rdf:type owl:Class .
# _:x owl:oneOf T(SEQ a1 ... an) .
#
# DataOneOf( lt1 ... ltn )
# _:x rdf:type rdfs:Datatype .
# _:x owl:oneOf T(SEQ lt1 ... ltn) .
function _parse_one_of!(g, decls, exprs, t)
    t.predicate == owl.oneOf || return 

    if !isempty(match(g; subject = t.subject, predicate = rdf.type, object = owl.Class))
        # object one of
        a_n = Individual[]
        if t.object isa BlankNode
            terms = RDFTerm[]
            _parse_chain_list!(g, t.object, terms)
            for term in terms
                a = get(decls, term, Individual(term))
                push!(a_n, a)
            end
        end
        exprs[t.subject] = ObjectOneOf(a_n = a_n)
    elseif !isempty(match(g; subject = t.subject, predicate = rdf.type, object = rdfs.Datatype))
        # data one of
        lt_n = Literal[]
        if t.object isa BlankNode
            terms = RDFTerm[]
            _parse_chain_list!(g, t.object, terms)
            for term in terms
                push!(lt_n, Literal(term))
            end
        end
        exprs[t.subject] = DataOneOf(lt_n = lt_n)
    else
        throw(FormatError("$t"))
    end
end

# ObjectHasValue( OPE a )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:hasValue T(a) .
# 
# DataHasValue( DPE lt )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:hasValue T(lt) .
function _parse_has_value!(g, decls, exprs, t)
    t.predicate == owl.hasValue || return 

    _restriction(g, t)

    prop = get(decls, _on_property(g, t), nothing)
    if prop isa OPExpression
        # object has value 
        a = Individual(t.object)
        exprs[t.subject] = ObjectHasValue(ope = prop, a = a)
    elseif prop isa DPExpression
        # data has value 
        lt = _Literal(t.object)
        exprs[t.subject] = DataHasValue(dpe = prop, lt = lt)
    else
        throw(FormatError("$t $prop is unknown"))
    end
end

# ObjectHasSelf( OPE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:hasSelf "true"^^xsd:boolean .
function _parse_has_self!(g, decls, exprs, t)
    t.predicate == owl.hasSelf || return

    _restriction(g, t)

    ope = _object_on_property(g, decls, t)
    exprs[t.subject] = ObjectHasSelf(ope = ope)
end

# ObjectMinCardinality( n OPE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:minCardinality "n"^^xsd:nonNegativeInteger .
#
# DataMinCardinality( n DPE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:minCardinality "n"^^xsd:nonNegativeInteger .
function _parse_min_cardinality!(g, decls, exprs, t)
    t.predicate == owl.minCardinality || return

    _restriction(g, t)

    n = match(r"^\\\"(.+)\\\"", string(t.object))[1] |> x -> parse(Int, x)

    prop = get(decls, _on_property(g, t), nothing)
    if prop isa OPExpression
        exprs[t.subject] = ObjectMinCardinality(n = n, ope = prop)
    elseif prop isa DPExpression
        exprs[t.subject] = DataMinCardinality(n = n, dpe = prop)
    else
        throw(FormatError("$t"))
    end
end

# ObjectMinCardinality( n OPE CE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:minQualifiedCardinality "n"^^xsd:nonNegativeInteger .
# _:x owl:onClass T(CE) .
#
# DataMinCardinality( n DPE DR )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:minQualifiedCardinality "n"^^xsd:nonNegativeInteger .
# _:x owl:onDataRange T(DR) .
function _parse_min_qualified_cardinality!(g, decls, exprs, t)
    t.predicate == owl.minQualifiedCardinality || return

    _restriction(g, t)

    n = match(r"^\\\"(.+)\\\"", string(t.object))[1] |> x -> parse(Int, x)

    prop = get(decls, _on_property(g, t), nothing)
    if prop isa OPExpression
        class = match(g;
                      subject = t.subject,
                      predicate = owl.onClass,)
        isempty(class) && throw(FormatError("$t owl:onClass is missing"))
        class = first(class)
        ce = get(decls, class.object, Class(class.object))
        exprs[t.subject] = ObjectMinCardinality(n = n, ope = prop, ce = ce)
    elseif prop isa DPExpression
        dt = match(g;
                   subject = t.subject,
                   predicate = owl.onDataRange)
        isempty(dt) && throw(FormatError("$t owl:onDataRange is missing"))
        dt = first(dt)
        dt = get(decls, dt.object, DataType(dt.object))
        exprs[t.subject] = DataMinCardinality(n = n, dpe = prop, dr = dt)
    else
        throw(FormatError("$t $prop is unknown"))
    end
end

# ObjectMaxCardinality( n OPE CE )
#_:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:maxCardinality "n"^^xsd:nonNegativeInteger .
#
# DataMaxCardinality( n DPE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:maxCardinality "n"^^xsd:nonNegativeInteger .
function _parse_max_cardinality!(g, decls, exprs, t)
    t.predicate == owl.maxCardinality || return

    _restriction(g, t)

    n = match(r"^\\\"(.+)\\\"", string(t.object))[1] |> x -> parse(Int, x)

    prop = get(decls, _on_property(ts), nothing)
    if prop isa OPExpression
        exprs[t.subject] = ObjectMaxCardinality(n = n, ope = prop)
    elseif prop isa DPExpression
        exprs[t.subject] = DataMaxCardinality(n = n, dpe = prop)
    else
        throw(FormatError("$t $prop is unknown"))
    end
end

# ObjectMaxCardinality( n OPE CE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:maxQualifiedCardinality "n"^^xsd:nonNegativeInteger .
# _:x owl:onClass T(CE) .
#
# DataMaxCardinality( n DPE DR )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:maxQualifiedCardinality "n"^^xsd:nonNegativeInteger .
# _:x owl:onDataRange T(DR) .
function _parse_max_qualified_cardinality!(g, decls, exprs, t)
    t.predicate == owl.maxQualifiedCardinality || return

    _restriction(g, t)

    n = match(r"^\\\"(.+)\\\"", string(t.object))[1] |> x -> parse(Int, x)

    prop = get(decls, _on_property(ts), nothing)
    if prop isa OPExpression
        class = match(g;
                      subject = t.subject,
                      predicate = owl.onClass)
        isempty(class) && throw(FormatError("$t owl:onClass is missing"))
        class = first(class)
        ce = get(decls, class.object, Class(class.object))
        exprs[t.subject] = ObjectMaxCardinality(n = n, ope = prop, ce = ce)
    elseif prop isa DPExpression
        dt = match(g;
                   subject = t.subject,
                   predicate = owl.onDataRange)
        isempty(dt) && throw(FormatError("$t owl:onDataRange is missing"))
        dt = first(dt)
        dt = get(decls, dt.object, DataType(dt.object))
        exprs[t.subject] = DataMaxCardinality(n = n, dpe = prop, dr = dt)
    else
        throw(FormatError("$t $prop is unknown"))
    end
end

# ObjectExactCardinality( n OPE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:cardinality "n"^^xsd:nonNegativeInteger .
#
# DataExactCardinality( n DPE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:cardinality "n"^^xsd:nonNegativeInteger .
function _parse_exact_cardinality!(g, decls, exprs, t)
    t.predicate == owl.cardinality || return

    _restriction(g, t)

    n = match(r"^\\\"(.+)\\\"", string(t.object))[1] |> x -> parse(Int, x)

    prop = get(decls, _on_property(ts), nothing)
    if prop isa OPExpression
        exprs[t.subject] = ObjectExactCardinality(n = n, ope = prop)
    elseif prop isa DPExpression
        exprs[t.subject] = DataExactCardinality(n = n, dpe = prop)
    else
        throw(FormatError("$t $prop is unknown"))
    end
end

# ObjectExactCardinality( n OPE CE )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(OPE) .
# _:x owl:qualifiedCardinality "n"^^xsd:nonNegativeInteger .
# _:x owl:onClass T(CE) .
#
# DataExactCardinality( n DPE DR )
# _:x rdf:type owl:Restriction .
# _:x owl:onProperty T(DPE) .
# _:x owl:qualifiedCardinality "n"^^xsd:nonNegativeInteger .
# _:x owl:onDataRange T(DR) .
function _parse_exact_qualified_cardinality!(g, decls, exprs, t)
    t.predicate == owl.qualifiedCardinality || return

    _restriction(g, t)

    n = match(r"^\\\"(.+)\\\"", string(t.object))[1] |> x -> parse(Int, x)

    prop = get(decls, _on_property(ts), nothing)
    if prop isa OPExpression
        class = match(g;
                      subject = t.subject,
                      predicate = owl.onClass)
        isempty(classes) && throw(FormatError("$t owl:onClass is missing"))
        class = first(class)
        ce = get(decls, class.object, Class(class.object))
        exprs[t.subject] = ObjectExactCardinality(n = n, ope = prop, ce = ce)
    elseif prop isa DPExpression
        dt = match(g;
                   subject = t.subject,
                   predicate = owl.onDataRange)
        isempty(dts) && throw(FormatError("$t owl:onDataRange is missing"))
        dt = first(dt)
        dt = get(decls, dt.object, DataType(dt.object))
        exprs[t.subject] = DataExactCardinality(n = n, dpe = prop, dr = dt)
    else
        throw(FormatError("$t $prop is unknown"))
    end
end

# ObjectInverseOf( OP )
# _:x owl:inverseOf T(OP) .
function _parse_inverse_of!(g, decls, exprs, t)
    t.predicate == owl.inverseOf || return
    t.subject isa BlankNode || return

    ope = get(decls, t.object, ObjectProperty(t.object))
    exprs[t.subject] = ObjectInverseOf(ope = ope) 
end

# DatatypeRestriction( DT F1 lt1 ... Fn ltn)
# _:x rdf:type rdfs:Datatype .
# _:x owl:onDatatype T(DT) .
# _:x owl:withRestrictions T(SEQ _:y1 ... _:yn) .
# _:y1 F1 lt1 .
# ...
# _:yn Fn ltn .
function _parse_with_restrictions!(g, decls, exprs, t)
    t.predicate == owl.withRestrictions || return

    dt = match(g;
               subject = t.subject,
               predicate = rdf.type,
               object = rdfs.Datatype)
    isempty(dt) && throw(FormatError("$t rdfs:Datatype is missing"))

    dt = match(g;
               subject = t.subject,
               predicate = owl.onDatatype)
    isempty(dt) && throw(FormatError("$t owl.onDatatype is missing"))
    dt = first(dt)
    dt = get(decls, dt.object, DataType(dt.object))

    f_n = RDFTerm[]
    lt_n = Literal[]
    if t.object isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, t.object, terms)
        for term in terms
            if term isa BlankNode
                for n in match(g; subject = term)
                    push!(f_n, n.predicate)
                    push!(lt_n, Literal(n.object))
                end
            end
        end
    end
    isempty(f_n) && throw(FormatError("$t f_n is empty"))
    isempty(lt_n) && throw(FormatError("$t lt_n is empty"))
    exprs[t.subject] = DataTypeRestriction(dt = dt, f_n = f_n, lt_n = lt_n)
end

# _:x rdf:type owl:Restriction .
function _restriction(g, t)
    restriction = match(g;
                        subject = t.subject,
                        predicate = rdf.type,
                        object = owl.Restriction)
    isempty(restriction) && throw(FormatError("$t owl:Restriction is missing"))
    return first(restriction)
end

# _:x owl:onProperty T(?) .
function _on_property(g, t)
    prop = match(g;
                 subject = t.subject,
                 predicate = owl.onProperty)
    isempty(prop) && throw(FormatError("$t owl:onProperty"))
    prop = first(prop)
    return prop.object
end

# _:x owl:onProperty T(OPE) .
function _object_on_property(g, decls, t)
    # object property
    prop = match(g;
                 subject = t.subject,
                 predicate = owl.onProperty)
    isempty(prop) && throw(FormatError("$t owl:onProperty"))
    prop = first(prop)
    return get(decls, prop.object, ObjectProperty(prop.object))
end

# _:x owl:onProperty T(DPE) .
# _:x owl:onProperties T(SEQ DPE1 ... DPEn) .
function _data_on_properties(g, decls, t)
    prop = match(g;
                 subject = t.subject,
                 predicate = owl.onProperty)
    if isempty(prop)
        prop = match(g;
                     subject = t.subject,
                     predicate = owl.onProperties)
    end
    isempty(prop) && throw(FormatError("$t owl:onProperty/owl:onProperties"))
    prop = first(prop)

    dpe_n = DPExpression[]
    if prop.object isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, prop.object, terms)
        for term in terms
            dpe = get(decls, term, DataProperty(term))
            push!(dpe_n, dpe)
        end
    else
        dpe = get(decls, prop.object, DataProperty(prop.object))
        push!(dpe_n, dpe)
    end
    return dpe_n
end

#
# T(SEQ CE_1 ... CE_n)
#
function _sequence_of_class_expressions(g, decls, node)
    ce_n = CExpression[]
    if node isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, node, terms)
        for term in terms
            ce = get(decls, term, Class(term))
            push!(ce_n, ce)
        end
    end
    isempty(ce_n) && throw(FormatError("$node ce_n is empty"))
    return ce_n
end

#
# T(SEQ DR_1 ... DR_n)
#
function _sequence_of_data_ranges(g, decls, node)
    dr_n = DataRange[]
    if node isa BlankNode
        terms = RDFTerm[]
        _parse_chain_list!(g, node, terms)
        for term in terms
            dr = get(decls, term, DataType(term))
            push!(dr_n, dr)
        end
    end
    isempty(dr_n) && throw(FormatError("$node dr_n is empty"))
    return dr_n
end
