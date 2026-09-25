# OWL2

Simple OWL2 type parser for Julia.

## DependsOn

- [PythonCall](https://github.com/JuliaPy/PythonCall.jl)
- [rdflib](https://github.com/RDFLib/rdflib)

## How to
```julia
using OWL2

# load RDF/XML
axioms = OWL2.load_owl("./sample.xml")
for axiom in axioms
    @info axiom
end

# write it to N-triples.
write_owl_nt(axioms, "./out.ttl")

axioms = OWL2.load_owl("./out.ttl")
```

## Support axioms

### References

- [OWL 2 Web Ontology Language Specification and Functional-Style Syntax](https://www.w3.org/TR/2012/REC-owl2-syntax-20121211)
- [OWL 2 Web Ontology Language Mapping to RDF Graphs](https://www.w3.org/TR/owl2-mapping-to-rdf)

### Axioms

| Implemented | Tested | OWL 2 Functional-Style Syntax |
|---|---|---|
| &check; | - | Declaration( Class( IRI ) ) |
| &check; | - | Declaration( Datatype( IRI ) ) |
| &check; | - | Declaration( ObjectProperty( IRI ) ) |
| &check; | - | Declaration( DataProperty( IRI ) ) |
| &check; | - | Declaration( AnnotationProperty( IRI ) ) |
| &check; | - | Declaration( NamedIndividual( IRI ) ) |
| &check; | - | SubClassOf( CE(x) CE(y) ) |
| &check; | - | EquivalentClasses( CE(x) CE(y) ) |
| &check; | - | DisjointClasses( CE(x) CE(y) ) |
| &check; | - | DisjointClasses( CE(y1) ... CE(yn) ) |
| &check; | - | DisjointUnion( CE(IRI) CE(y1) ... CE(yn) ) |
| &check; | - | SubObjectPropertyOf( OPE(x) OPE(y) ) |
| &check; | - | SubObjectPropertyOf( ObjectPropertyChain( OPE(y1) ... OPE(yn) ) OPE(x) ) |
| &check; | - | EquivalentObjectProperties( OPE(x) OPE(y) ) |
| &check; | - | DisjointObjectProperties( OPE(x) OPE(y) ) |
| &check; | - | DisjointObjectProperties( OPE(y1) ... OPE(yn) ) |
| &check; | - | ObjectPropertyDomain( OPE(x) CE(y) ) |
| &check; | - | ObjectPropertyRange( OPE(x) CE(y) ) |
| &check; | - | InverseObjectProperties( OPE(x) OPE(y) ) |
| &check; | - | FunctionalObjectProperty( OPE(x) ) |
| &check; | - | InverseFunctionalObjectProperty( OPE(x) ) |
| &check; | - | ReflexiveObjectProperty( OPE(x) ) |
| &check; | - | IrreflexiveObjectProperty( OPE(x) ) |
| &check; | - | SymmetricObjectProperty( OPE(x) ) |
| &check; | - | AsymmetricObjectProperty( OPE(x) ) |
| &check; | - | TransitiveObjectProperty( OPE(x) ) |
| &check; | - | SubDataPropertyOf( DPE(x) DPE(y) ) |
| &check; | - | EquivalentDataProperties( DPE(x) DPE(y) ) |
| &check; | - | DisjointDataProperties( DPE(x) DPE(y) ) |
| &check; | - | DisjointDataProperties( DPE(y1) ... DPE(yn) ) |
| &check; | - | DataPropertyDomain( DPE(x) CE(y) ) |
| &check; | - | DataPropertyRange( DPE(x) DR(y) ) |
| &check; | - | FunctionalDataProperty( DPE(x) ) |
| &check; | - | DatatypeDefinition( DR(IRI) DR(y) ) |
| &check; | - | HasKey( CE(x) ( OPE(z1) ... OPE(zm) ) ( DPE(w1) ... DPE(wn) ) ) |
| &check; | - | SameIndividual( x y ) |
| &check; | - | DifferentIndividuals( x y ) |
| &check; | - | DifferentIndividuals( x1 ... xn ) |
| &check; | - | ClassAssertion( CE(y) x ) |
| &check; | - | ObjectPropertyAssertion( OPE(IRI) x z ) |
| &check; | - | NegativeObjectPropertyAssertion( OPE(y) w z ) |
| &check; | - | DataPropertyAssertion( DPE(IRI) x lt ) |
| &check; | - | NegativeDataPropertyAssertion( DPE(y) w lt ) |
| &check; | - | AnnotationAssertion( owl:deprecated IRI "true"^^xsd:boolean ) |
| &check; | - | AnnotationAssertion( owl:deprecated IRI "true"^^xsd:boolean ) |
| &check; | - | SubAnnotationPropertyOf( AP(IRI) AP(IRI) ) |
| &check; | - | AnnotationPropertyDomain( AP(IRI) IRI ) |
| &check; | - | AnnotationPropertyRange( AP(IRI) IRI ) |
