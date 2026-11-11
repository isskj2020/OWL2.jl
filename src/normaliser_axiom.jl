
function _normalise_axioms!(g, decls, exprs, axioms)
    _parse_declaration!(g, decls, axioms)
end

function _parse_declaration!(g, decls, axioms)
    for (id, d) in decls
        if d isa Class ||
            d isa DataType ||
            d isa ObjectProperty ||
            d isa DataProperty ||
            d isa AnnotationProperty ||
            d isa Individual
            if !(d.x isa BlankNode)
                push!(axioms, Declaration(ann_n = [], e = d))
            end
        end
    end
end

