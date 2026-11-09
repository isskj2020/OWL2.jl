using RDF

#
# Parsing Ontology definition
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function _parse_ontology!(g)
    ontology = match(g; object = owl.Ontology)
    isempty(ontology) && return Ontology(g = g)
    ontology = first(ontology)

    iri = ontology.subject
    version = match(g; subject = iri, predicate = owl.versionIRI)
    if isempty(version)
        version = nothing
    else
        version = first(version).object
    end
    imports = map(x -> x.object, collect(match(g; subject = iri, predicate = owl.imports)))

    annotations = map(x -> Annotation(ap = AnnotationProperty(x.predicate), av = x.object),
                      collect(match(g; subject = iri, predicate = rdfs.comment)))

    return Ontology(g = g,
                    iri = iri,
                    version = version,
                    imports = imports,
                    annotations = annotations)
end

