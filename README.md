# OWL2

Simple OWL2 type parser for Julia.

## DependsOn

- [PythonCall](https://github.com/JuliaPy/PythonCall.jl)
- [rdflib](https://github.com/RDFLib/rdflib)

## How to
```julia
using OWL2

axioms = OWL2.load_owl("./sample.xml")
for axiom in axioms
    @info axiom
end
```

## Support axioms

### References

- [OWL 2 Web Ontology Language Specification and Functional-Style Syntax](https://www.w3.org/TR/2012/REC-owl2-syntax-20121211)
- [OWL 2 Web Ontology Language Mapping to RDF Graphs](https://www.w3.org/TR/owl2-mapping-to-rdf)

### Axioms

| Implemented | Tested | OWL 2 Functional-Style Syntax |
|---|---|---|
| [x] | [ ] | Declaration( Class( IRI ) ) |
| [x] | [ ] | Declaration( Datatype( IRI ) ) |
| [x] | [ ] | Declaration( ObjectProperty( IRI ) ) |
| [x] | [ ] | Declaration( DataProperty( IRI ) ) |
| [x] | [ ] | Declaration( AnnotationProperty( IRI ) ) |
| [x] | [ ] | Declaration( NamedIndividual( IRI ) ) |
| [x] | [ ] | SubClassOf( CE(x) CE(y) ) |
| [x] | [ ] | EquivalentClasses( CE(x) CE(y) ) |
| [x] | [ ] | DisjointClasses( CE(x) CE(y) ) |
| [x] | [ ] | DisjointClasses( CE(y1) ... CE(yn) ) |
| [x] | [ ] | DisjointUnion( CE(IRI) CE(y1) ... CE(yn) ) |
| [x] | [ ] | SubObjectPropertyOf( OPE(x) OPE(y) ) |
| [x] | [ ] | SubObjectPropertyOf( ObjectPropertyChain( OPE(y1) ... OPE(yn) ) OPE(x) ) |
| [x] | [ ] | EquivalentObjectProperties( OPE(x) OPE(y) ) |
| [x] | [ ] | DisjointObjectProperties( OPE(x) OPE(y) ) |
| [x] | [ ] | DisjointObjectProperties( OPE(y1) ... OPE(yn) ) |
| [x] | [ ] | ObjectPropertyDomain( OPE(x) CE(y) ) |
| [x] | [ ] | ObjectPropertyRange( OPE(x) CE(y) ) |
| [x] | [ ] | InverseObjectProperties( OPE(x) OPE(y) ) |
| [x] | [ ] | FunctionalObjectProperty( OPE(x) ) |
| [x] | [ ] | InverseFunctionalObjectProperty( OPE(x) ) |
| [x] | [ ] | ReflexiveObjectProperty( OPE(x) ) |
| [x] | [ ] | IrreflexiveObjectProperty( OPE(x) ) |
| [x] | [ ] | SymmetricObjectProperty( OPE(x) ) |
| [x] | [ ] | AsymmetricObjectProperty( OPE(x) ) |
| [x] | [ ] | TransitiveObjectProperty( OPE(x) ) |
| [x] | [ ] | SubDataPropertyOf( DPE(x) DPE(y) ) |
| [x] | [ ] | EquivalentDataProperties( DPE(x) DPE(y) ) |
| [x] | [ ] | DisjointDataProperties( DPE(x) DPE(y) ) |
| [x] | [ ] | DisjointDataProperties( DPE(y1) ... DPE(yn) ) |
| [x] | [ ] | DataPropertyDomain( DPE(x) CE(y) ) |
| [x] | [ ] | DataPropertyRange( DPE(x) DR(y) ) |
| [x] | [ ] | FunctionalDataProperty( DPE(x) ) |
| [x] | [ ] | DatatypeDefinition( DR(IRI) DR(y) ) |
| [x] | [ ] | HasKey( CE(x) ( OPE(z1) ... OPE(zm) ) ( DPE(w1) ... DPE(wn) ) ) |
| [x] | [ ] | SameIndividual( x y ) |
| [x] | [ ] | DifferentIndividuals( x y ) |
| [x] | [ ] | DifferentIndividuals( x1 ... xn ) |
| [x] | [ ] | ClassAssertion( CE(y) x ) |
| [x] | [ ] | ObjectPropertyAssertion( OPE(IRI) x z ) |
| [x] | [ ] | NegativeObjectPropertyAssertion( OPE(y) w z ) |
| [x] | [ ] | DataPropertyAssertion( DPE(IRI) x lt ) |
| [x] | [ ] | NegativeDataPropertyAssertion( DPE(y) w lt ) |
| [x] | [ ] | AnnotationAssertion( owl:deprecated IRI "true"^^xsd:boolean ) |
| [x] | [ ] | AnnotationAssertion( owl:deprecated IRI "true"^^xsd:boolean ) |
| [x] | [ ] | SubAnnotationPropertyOf( AP(IRI) AP(IRI) ) |
| [x] | [ ] | AnnotationPropertyDomain( AP(IRI) IRI ) |
| [x] | [ ] | AnnotationPropertyRange( AP(IRI) IRI ) |
