using RDF

function _write_rdf_graph!(ontology, g)
    if ontology.iri != nothing
        push!(g, Triple(ontology.iri, rdf.type, owl.Ontology))
        if ontology.version != nothing
            push!(g, Triple(ontology.iri, owl.versionIRI, ontology.version))
        end
        for i in ontology.imports
            push!(g, Triple(ontology.iri, owl.imports, i))
        end
        for a in ontology.annotations
            push!(g, Triple(ontology.iri, a.ap.x, a.av))
        end
    end
    for a in ontology.axioms
        add_triple!(g, a)
    end
    return g
end

