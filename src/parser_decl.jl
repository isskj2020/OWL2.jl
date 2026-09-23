#
# Parsing Declarations
# https://www.w3.org/TR/owl2-mapping-to-rdf/
#

function parse_declarations(g::Graph, decls::Dict{UInt64, Any}, t::TripleID)
    if t.o == term_id(g, TERM_OWL_CLASS)
        decls[t.s] = gen_class(g, t.s)
    end
    if g.id_types[t.s] == URIRef && t.o == term_id(g, TERM_OWL_OBJECT_PROPERTY)
        decls[t.s] = ObjectProperty(g.names[t.s])
    end
    if g.id_types[t.s] == URIRef && t.o == term_id(g, TERM_RDFS_DATATYPE)
        decls[t.s] = DataType(g.names[t.s])
    end
    if g.id_types[t.s] == URIRef && t.o == term_id(g, TERM_OWL_DATATYPE_PROPERTY)
        decls[t.s] = DataProperty(g.names[t.s])
    end
    if g.id_types[t.s] == URIRef && t.o == term_id(g, TERM_OWL_NAMED_INDIVIDUAL)
        decls[t.s] = NamedIndividual(g.names[t.s])
    end
    if g.id_types[t.s] == URIRef && t.o == term_id(g, TERM_OWL_ANNOTATION_PROPERTY)
        decls[t.s] = AnnotationProperty(g.names[t.s])
    end
end

