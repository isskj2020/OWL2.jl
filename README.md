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
|         | -       | Ontology( ontologyIRI versionIRI ... ) |
| &check; | -       | Declaration( Datatype( DT ) ) |
| &check; | -       | Declaration( Class( C ) ) |
| &check; | -       | Declaration( ObjectProperty( OP ) ) |
| &check; | -       | Declaration( DataProperty( DP ) ) |
| &check; | -       | Declaration( AnnotationProperty( AP ) ) |
| &check; | -       | Declaration( NamedIndividual( \*:a ) ) |
| &check; | -       | ObjectInverseOf( OP ) |
| &check; | -       | DataIntersectionOf( DR1 ... DRn ) |
| &check; | -       | DataUnionOf( DR1 ... DRn ) |
| &check; | -       | DataComplementOf( DR ) |
| &check; | -       | DataOneOf( lt1 ... ltn ) |
| &check; | &check; | DatatypeRestriction( DT  F1 lt1   ... ) |
| &check; | -       | ObjectIntersectionOf( CE1 ... CEn ) |
| &check; | -       | ObjectUnionOf( CE1 ... CEn ) |
| &check; | -       | ObjectComplementOf( CE ) |
| &check; | -       | ObjectOneOf( a1 ... an ) |
| &check; | -       | ObjectSomeValuesFrom( OPE CE ) |
| &check; | -       | ObjectAllValuesFrom( OPE CE ) |
| &check; | -       | ObjectHasValue( OPE a ) |
| &check; | -       | ObjectHasSelf( OPE ) |
| &check; | -       | ObjectMinCardinality( n OPE ) |
| &check; | -       | ObjectMinCardinality( n OPE CE ) |
| &check; | -       | ObjectMaxCardinality( n OPE ) |
| &check; | -       | ObjectMaxCardinality( n OPE CE ) |
| &check; | -       | ObjectExactCardinality( n OPE ) |
| &check; | -       | ObjectExactCardinality( n OPE CE ) |
| &check; | -       | DataSomeValuesFrom( DPE DR ) |
| &check; | -       | DataSomeValuesFrom( DPE1 ... DPEn DR ), n ≥ 2 |
| &check; | -       | DataAllValuesFrom( DPE DR ) |
| &check; | -       | DataAllValuesFrom( DPE1 ... DPEn DR ), n ≥ 2 |
| &check; | -       | DataHasValue( DPE lt ) |
| &check; | -       | DataMinCardinality( n DPE ) |
| &check; | -       | DataMinCardinality( n DPE DR ) |
| &check; | -       | DataMaxCardinality( n DPE ) |
| &check; | -       | DataMaxCardinality( n DPE DR ) |
| &check; | -       | DataExactCardinality( n DPE ) |
| &check; | -       | DataExactCardinality( n DPE DR ) |
| &check; | -       | SubClassOf( CE1 CE2 ) |
| &check; | -       | EquivalentClasses( CE1 ... CEn ) |
| &check; | -       | DisjointClasses( CE1 CE2 ) |
| &check; | -       | DisjointClasses( CE1 ... CEn ), n > 2 |
| &check; | -       | DisjointUnion( C CE1 ... CEn ) |
| &check; | -       | SubObjectPropertyOf( OPE1 OPE2 ) |
| &check; | -       | SubObjectPropertyOf( ObjectPropertyChain( OPE1 ... OPEn ) OPE ) |
| &check; | -       | EquivalentObjectProperties( OPE1 ... OPEn ) |
| &check; | -       | DisjointObjectProperties( OPE1 OPE2 ) |
| &check; | -       | DisjointObjectProperties( OPE1 ... OPEn ), n > 2 |
| &check; | -       | ObjectPropertyDomain( OPE CE ) |
| &check; | -       | ObjectPropertyRange( OPE CE ) |
| &check; | -       | InverseObjectProperties( OPE1 OPE2 ) |
| &check; | -       | FunctionalObjectProperty( OPE ) |
| &check; | -       | InverseFunctionalObjectProperty( OPE ) |
| &check; | -       | ReflexiveObjectProperty( OPE ) |
| &check; | -       | IrreflexiveObjectProperty( OPE ) |
| &check; | -       | SymmetricObjectProperty( OPE ) |
| &check; | -       | AsymmetricObjectProperty( OPE ) |
| &check; | -       | TransitiveObjectProperty( OPE ) |
| &check; | -       | SubDataPropertyOf( DPE1 DPE2 ) |
| &check; | -       | EquivalentDataProperties( DPE1 ... DPEn ) |
| &check; | -       | DisjointDataProperties( DPE1 DPE2 ) |
| &check; | -       | DisjointDataProperties( DPE1 ... DPEn ), n > 2 |
| &check; | -       | DataPropertyDomain( DPE CE ) |
| &check; | -       | DataPropertyRange( DPE DR ) |
| &check; | -       | FunctionalDataProperty( DPE ) |
| &check; | -       | DatatypeDefinition( DT DR ) |
| &check; | -       | HasKey( CE ( OPE1 ... OPEm ) ( DPE1 ... DPEn ) ) |
| &check; | -       | SameIndividual( a1 ... an ) |
| &check; | -       | DifferentIndividuals( a1 a2 ) |
| &check; | -       | DifferentIndividuals( a1 ... an ), n > 2 |
| &check; | -       | ClassAssertion( CE a ) |
| &check; | -       | ObjectPropertyAssertion( OP a1 a2 ) |
| &check; | -       | ObjectPropertyAssertion( ObjectInverseOf( OP ) a1 a2 ) |
| &check; | -       | NegativeObjectPropertyAssertion( OPE a1 a2 ) |
| &check; | -       | DataPropertyAssertion( DPE a lt ) |
| &check; | -       | NegativeDataPropertyAssertion( DPE a lt ) |
| &check; | -       | AnnotationAssertion( AP as av ) |
| &check; | -       | SubAnnotationPropertyOf( AP1 AP2 ) |
| &check; | -       | AnnotationPropertyDomain( AP U ) |
| &check; | -       | AnnotationPropertyRange( AP U ) |
