using Random, RDF, EzXML


function _parse_owl!(filepath, mimetype)
    decls = Dict{RDFTerm, Any}()
    exprs = Dict{RDFTerm, Any}()
    axioms = Vector{Axiom}()

    decls[owl.Thing] = Class(owl.Thing)

    return open(realpath(filepath)) do io
        g = read(io, MIME(mimetype), Graph)

        normalise_graph!(g)

        ontology = _parse_ontology!(g)

        for t in match(g)
            _parse_declarations!(g, decls, t)
        end

        for t in match(g)
            _parse_expressions!(g, decls, exprs, t)
        end
        _normalise_expressions!(g, decls, exprs)

        for t in match(g)
            _parse_axioms!(g, decls, exprs, axioms, t)
        end

        _normalise_axioms!(g, decls, exprs, axioms)

        ontology.g = g
        append!(ontology.axioms, axioms)
        ontology
    end
end

