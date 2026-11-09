using RDF
#
# Parsing Declarations
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function _parse_declarations!(g, decls, t)
    if t.object == owl.Class && !haskey(decls, t.subject)
        decls[t.subject] = Class(t.subject)
    end
    if t.object == rdfs.Datatype && !haskey(decls, t.subject)
        decls[t.subject] = DataType(t.subject)
    end
    if t.subject isa IRI && t.object == owl.ObjectProperty && !haskey(decls, t.subject)
        decls[t.subject] = ObjectProperty(t.subject)
    end
    if t.subject isa IRI && t.object == owl.DatatypeProperty && !haskey(decls, t.subject)
        decls[t.subject] = DataProperty(t.subject)
    end
    if t.subject isa IRI && t.object == owl.NamedIndividual && !haskey(decls, t.subject)
        decls[t.subject] = Individual(t.subject)
    end
    if t.subject isa IRI && t.object == owl.AnnotationProperty && !haskey(decls, t.subject)
        decls[t.subject] = AnnotationProperty(t.subject)
    end
    if t.subject isa IRI && t.predicate == rdf.type &&
        !startswith(string(t.object), string(owl)) &&
        !startswith(string(t.object), string(rdfs)) &&
        !startswith(string(t.object), string(rdf)) &&
        !haskey(decls, t.subject)
        decls[t.subject] = Individual(t.subject)
    end
end

