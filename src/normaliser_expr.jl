#
# Parsing Expressions
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function _normalise_expressions!(g, decls, exprs)
    for (k, v) in exprs
        if v isa ObjectSomeValuesFrom && v.ce isa Class
            v.ce = get(exprs, v.ce.x, v.ce)
        end
        if v isa DataSomeValuesFrom && v.dr isa DataType
            v.dr = get(exprs, v.dr.x, v.dr)
        end
        if v isa ObjectAllValuesFrom && v.ce isa Class
            v.ce = get(exprs, v.ce.x, v.ce)
        end
        if v isa DataAllValuesFrom && v.dr isa DataType
            v.dr = get(exprs, v.dr.x, v.dr)
        end
        if v isa ObjectIntersectionOf
            ce_n = Vector{CExpression}()
            for ce in v.ce_n
                push!(ce_n, get(exprs, ce.x, ce))
            end
            v.ce_n = ce_n
        end
        if v isa DataIntersectionOf
            dr_n = Vector{DataRange}()
            for dr in v.dr_n
                push!(dr_n, get(exprs, dr.x, dr))
            end
            v.dr_n = dr_n
        end
        if v isa ObjectUnionOf
            ce_n = Vector{CExpression}()
            for ce in v.ce_n
                push!(ce_n, get(exprs, ce.x, ce))
            end
            v.ce_n = ce_n
        end
        if v isa DataUnionOf
            dr_n = Vector{DataRange}()
            for dr in v.dr_n
                push!(dr_n, get(exprs, dr.x, dr))
            end
            v.dr_n = dr_n
        end
        if v isa ObjectComplementOf && v.ce isa Class
            v.ce = get(exprs, v.ce.x, v.ce)
        end
        if v isa DataComplementOf && v.dr isa DataType
            v.dr = get(exprs, v.dr.x, v.dr)
        end
        if v isa ObjectMinCardinality && v.ce isa Class
            v.ce = get(exprs, v.ce.x, v.ce)
        end
        if v isa DataMinCardinality && v.dr isa DataType
            v.dr = get(exprs, v.dr.x, v.dr)
        end
        if v isa ObjectMaxCardinality && v.ce isa Class
            v.ce = get(exprs, v.ce.x, v.ce)
        end
        if v isa DataMaxCardinality && v.dr isa DataType
            v.dr = get(exprs, v.dr.x, v.dr)
        end
        if v isa ObjectExactCardinality && v.ce isa Class
            v.ce = get(exprs, v.ce.x, v.ce)
        end
        if v isa DataExactCardinality && v.dr isa DataType
            v.dr = get(exprs, v.dr.x, v.dr)
        end
    end
end
