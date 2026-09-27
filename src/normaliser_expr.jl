#
# Parsing Expressions
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function normalise_expressions(g::Graph, decls::Dict{UInt64, Any}, exprs::Dict{UInt64, Any})
    for (k, v) in exprs
        if v isa ObjectSomeValuesFrom && v.ce isa ClassNodeID
            id = g.ids[v.ce.x]
            v.ce = deepcopy(exprs[id])
        end
        if v isa DataSomeValuesFrom && v.dr isa DataNodeID
            id = g.ids[v.dr.x]
            v.dr = deepcopy(exprs[id])
        end
        if v isa ObjectAllValuesFrom && v.ce isa ClassNodeID
            id = g.ids[v.ce.x]
            v.ce = deepcopy(exprs[id])
        end
        if v isa DataAllValuesFrom && v.dr isa DataNodeID
            id = g.ids[v.dr.x]
            v.dr = deepcopy(exprs[id])
        end
        if v isa ObjectIntersectionOf
            ce_n = Vector{CExpression}()
            for ce in v.ce_n
                if ce isa ClassNodeID
                    id = g.ids[ce.x]
                    push!(ce_n, deepcopy(exprs[id]))
                else
                    push!(ce_n, ce)
                end
            end
            v.ce_n = ce_n
        end
        if v isa DataIntersectionOf
            dr_n = Vector{DataRange}()
            for dr in v.dr_n
                if dr isa DataNodeID
                    id = g.ids[dr.x]
                    push!(dr_n, deepcopy(exprs[id]))
                else
                    push!(dr_n, dr)
                end
            end
            v.dr_n = dr_n
        end
        if v isa ObjectUnionOf
            ce_n = Vector{CExpression}()
            for ce in v.ce_n
                if ce isa ClassNodeID
                    id = g.ids[ce.x]
                    push!(ce_n, deepcopy(exprs[id]))
                else
                    push!(ce_n, ce)
                end
            end
            v.ce_n = ce_n
        end
        if v isa DataUnionOf
            dr_n = Vector{DataRange}()
            for dr in v.dr_n
                if dr isa DataNodeID
                    id = g.ids[dr.x]
                    push!(dr_n, deepcopy(exprs[id]))
                else
                    push!(dr_n, dr)
                end
            end
            v.dr_n = dr_n
        end
        if v isa ObjectComplementOf && v.ce isa ClassNodeID
            id = g.ids[v.ce.x]
            v.ce = deepcopy(exprs[id])
        end
        if v isa DataComplementOf && v.dr isa DataNodeID
            id = g.ids[v.dr.x]
            v.dr = deepcopy(exprs[id])
        end
        if v isa ObjectMinCardinality && v.ce isa ClassNodeID
            id = g.ids[v.ce.x]
            v.ce = deepcopy(exprs[id])
        end
        if v isa DataMinCardinality && v.dr isa DataNodeID
            id = g.ids[v.dr.x]
            v.dr = deepcopy(exprs[id])
        end
        if v isa ObjectMaxCardinality && v.ce isa ClassNodeID
            id = g.ids[v.ce.x]
            v.ce = deepcopy(exprs[id])
        end
        if v isa DataMaxCardinality && v.dr isa DataNodeID
            id = g.ids[v.dr.x]
            v.dr = deepcopy(exprs[id])
        end
        if v isa ObjectExactCardinality && v.ce isa ClassNodeID
            id = g.ids[v.ce.x]
            v.ce = deepcopy(exprs[id])
        end
        if v isa DataExactCardinality && v.dr isa DataNodeID
            id = g.ids[v.dr.x]
            v.dr = deepcopy(exprs[id])
        end
    end
end

