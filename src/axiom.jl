using RDF

#
# String representation:
# _fms: Manchester Syntax
# https://www.w3.org/TR/owl2-manchester-syntax

abstract type Axiom end
abstract type CExpression end
abstract type OPExpression end
abstract type DPExpression end
abstract type DataRange end

abstract type ClassAxiom <: Axiom end
abstract type ObjectPropertyAxiom <: Axiom end
abstract type DataPropertyAxiom <: Axiom end
abstract type Assertion <: Axiom end
abstract type AnnotationAxiom <: Axiom end

_fms(o::RDFTerm) = begin
    o isa IRI && return "<" * string(o) * ">"
    return string(o)
end
_fms(o::Vector{CExpression}) = join(map(x -> _fms(x), o), " and ")
_fms(o::Vector{OPExpression}) = join(map(x -> _fms(x), o), " and ")
_fms(o::Vector{DPExpression}) = join(map(x -> _fms(x), o), " and ")
_fms(o::Vector{DataRange}) = join(map(x -> _fms(x), o), ", ")
#_fms(o::CExpression) = _fms(o)
#_fms(o::OPExpression) = _fms(o)
#_fms(o::DPExpression) = _fms(o)
#_fms(o::DataRange) = _fms(o)

struct Class <: CExpression
    x::RDFTerm
end
_fms(o::Class) = _fms(o.x)

struct Literal
    x::RDFTerm
end
_fms(o::Literal) = _fms(o.x)
_fms(o::Vector{Literal}) = join(map(x -> _fms(x), o), ", ")


struct DataType <: DataRange
    x::RDFTerm
end
_fms(o::DataType) = _fms(o.x)
_fms(o::Vector{DataType}) = join(map(x -> _fms(x), o), ", ")

struct Individual
    x::RDFTerm
end
_fms(o::Individual) = _fms(o.x)
_fms(o::Vector{Individual}) = join(map(x -> _fms(x), o), ", ")

struct AnnotationProperty
    x::RDFTerm
end
_fms(o::AnnotationProperty) = _fms(o.x)

struct DataProperty <: DPExpression
    x::RDFTerm
end
_fms(o::DataProperty) = _fms(o.x)

struct ObjectProperty <: OPExpression
    x::RDFTerm
end
_fms(o::ObjectProperty) = _fms(o.x)

@kwdef mutable struct Annotation
    ap::AnnotationProperty
    av::RDFTerm
end
_fms(o::Annotation) = join([_fms(o.ap), _fms(o.av)], " ")
_fms(o::Vector{Annotation}) = join(map(x ->_fms(x), o), ", ")

@kwdef mutable struct Ontology
    g::Graph
    iri::Union{RDFTerm, Nothing} = nothing
    version::Union{RDFTerm, Nothing} = nothing
    imports::Vector{RDFTerm} = []
    annotations::Vector{Annotation} = []
    axioms::Vector{Axiom} = []
end

@kwdef mutable struct ObjectPropertyChain <: OPExpression
    ope_n::Vector{OPExpression}
end
_fms(o::ObjectPropertyChain) = join(map(x -> _fms(x), o.ope_n), " ")

@kwdef mutable struct ObjectInverseOf <: OPExpression
    ope::ObjectProperty
end
_fms(o::ObjectInverseOf) = join(["InverseOf:", _fms(o.ope)], " ")

@kwdef mutable struct ObjectIntersectionOf <: CExpression
    ce_n::Vector{CExpression}
end
_fms(o::ObjectIntersectionOf) = join(map(x -> _fms(x), o.ce_n), " and ")

@kwdef mutable struct ObjectUnionOf <: CExpression
    ce_n::Vector{CExpression}
end
_fms(o::ObjectUnionOf) = join(map(x -> _fms(x), o.ce_n), " or ")

@kwdef mutable struct ObjectComplementOf <: CExpression
    ce::CExpression
end
_fms(o::ObjectComplementOf) = "not " * _fms(o.ce)

@kwdef mutable struct ObjectOneOf <: CExpression
    a_n::Vector{Individual}
end
_fms(o::ObjectOneOf) = "{ " * _fms(o.a_n) * " }"

@kwdef mutable struct ObjectSomeValuesFrom <: CExpression
    ope::OPExpression
    ce::CExpression
end
_fms(o::ObjectSomeValuesFrom) = _fms(o.ope) * " some " * _fms(o.ce)

@kwdef mutable struct ObjectAllValuesFrom <: CExpression
    ope::OPExpression
    ce::CExpression
end
_fms(o::ObjectAllValuesFrom) = _fms(o.ope) * " only " * _fms(o.ce)

@kwdef mutable struct ObjectHasValue <: CExpression
    ope::OPExpression
    a::Individual
end
_fms(o::ObjectHasValue) = _fms(o.ope) * " value " * _fms(o.a)

@kwdef mutable struct ObjectHasSelf <: CExpression
    ope::OPExpression
end
_fms(o::ObjectHasSelf) = _fms(o.ope) * " Self"

@kwdef mutable struct ObjectMinCardinality <: CExpression
    n::UInt64
    ope::OPExpression
    ce::CExpression = Class(owl.Thing)
end
_fms(o::ObjectMinCardinality) = _fms(o.ope) * " min $n " * _fms(o.ce)

@kwdef mutable struct ObjectMaxCardinality <: CExpression
    n::UInt64
    ope::OPExpression
    ce::CExpression = Class(owl.Thing)
end
_fms(o::ObjectMaxCardinality) = _fms(o.ope) * " max $n " * _fms(o.ce)

@kwdef mutable struct ObjectExactCardinality <: CExpression
    n::UInt64
    ope::OPExpression
    ce::CExpression = Class(owl.Thing)
end
_fms(o::ObjectExactCardinality) = _fms(o.ope) * " exactly $n " * _fms(o.ce)

@kwdef mutable struct DataSomeValuesFrom <: CExpression
    dpe_n::Vector{DPExpression}
    dr::DataRange
end
_fms(o::DataSomeValuesFrom) = _fms(o.dpe_n) * " some " * _fms(o.dr)

@kwdef mutable struct DataAllValuesFrom <: CExpression
    dpe_n::Vector{DPExpression}
    dr::DataRange
end
_fms(o::DataAllValuesFrom) = _fms(o.dpe_n) * " only " * _fms(o.dr)

@kwdef mutable struct DataHasValue <: CExpression
    dpe::DPExpression
    lt::Literal
end
_fms(o::DataHasValue) = _fms(o.dpe) * " value " * _fms(o.lt)

@kwdef mutable struct DataMinCardinality <: CExpression
    n::UInt64
    dpe::DPExpression
    dr::DataRange = DataType(rdfs.Literal)
end
_fms(o::DataMinCardinality) = _fms(o.dpe) * " min $n " * _fms(o.dr)

@kwdef mutable struct DataMaxCardinality <: CExpression
    n::UInt64
    dpe::DPExpression
    dr::DataRange = DataType(rdfs.Literal)
end
_fms(o::DataMaxCardinality) = _fms(o.dpe) * " max $n " * _fms(o.dr)

@kwdef mutable struct DataExactCardinality <: CExpression
    n::UInt64
    dpe::DPExpression
    dr::DataRange = DataType(rdfs.Literal)
end
_fms(o::DataExactCardinality) = _fms(o.dpe) * " exactly $n " * _fms(o.dr)

@kwdef mutable struct DataIntersectionOf <: DataRange
    dr_n::Vector{DataRange}
end
_fms(o::DataIntersectionOf) = join(map(x -> _fms(x), o.dr_n), " and ")

@kwdef mutable struct DataUnionOf <: DataRange
    dr_n::Vector{DataRange}
end
_fms(o::DataUnionOf) = join(map(x -> _fms(x), o.dr_n), " or ")

@kwdef mutable struct DataComplementOf <: DataRange
    dr::DataRange
end
_fms(o::DataComplementOf) = "not " * _fms(o.dr)

@kwdef mutable struct DataOneOf <: DataRange
    lt_n::Vector{Literal}
end
_fms(o::DataOneOf) = "{ " * _fms(o.lt_n) * " }"

@kwdef mutable struct DataTypeRestriction <: DataRange
    dt::DataType
    f_n::Vector{RDFTerm}
    lt_n::Vector{Literal}
end
_fms(o::DataTypeRestriction) = begin
    str = _fms(o.dt) * "[ "
    str *= join([o.f_n[i] * " " * o.lt_n[i] for i in eachindex(o.f_n)], ", ")
    str *= " ]"
    return str
end

@kwdef mutable struct Declaration <: Axiom
    ann_n::Vector{Annotation} = []
    e::Any
end
_fms(o::Declaration) = begin
    o.e isa Class && return "Class:" * _fms(o.e)
    o.e isa ObjectProperty && return "ObjectProperty:" * _fms(o.e)
    o.e isa DataProperty && return "DataProperty:" * _fms(o.e)
    return _fms(o.e)
end

@kwdef mutable struct SubClassOf <: ClassAxiom
    ann_n::Vector{Annotation} = []
    ce1::CExpression
    ce2::CExpression
end
_fms(o::SubClassOf) = join([_fms(o.ce1), "SubClassOf:", _fms(o.ann_n), _fms(o.ce2)], " ")

@kwdef mutable struct EquivalentClasses <: ClassAxiom
    ann_n::Vector{Annotation} = []
    ce_n::Vector{CExpression}
end
_fms(o::EquivalentClasses) = join(["EquivalentTo:", _fms(o.ann_n), _fms(o.ce_n)], " ")

@kwdef mutable struct DisjointClasses <: ClassAxiom
    ann_n::Vector{Annotation} = []
    ce_n::Vector{CExpression}
end
_fms(o::DisjointClasses) = join(["DisjointClasses:", _fms(o.ann_n), _fms(o.ce_n)], " ")

@kwdef mutable struct DisjointUnion <: ClassAxiom
    ann_n::Vector{Annotation} = []
    c::Class
    ce_n::Vector{CExpression}
end
_fms(o::DisjointUnion) = join([_fms(c), "DisjointUnionOf:", _fms(o.ann_n), _fms(o.ce_n)], " ")

@kwdef mutable struct SubObjectPropertyOf <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope1::Union{OPExpression, ObjectPropertyChain}
    ope2::OPExpression
end
_fms(o::SubObjectPropertyOf) = begin
    if o.ope1 isa ObjectPropertyChain
        return join([_fms(o.ope2), "SubPropertyChain:", _fms(o.ann_n), _fms(o.ope1)], " ")
    else
        return join([_fms(o.ope2), "SubPropertyOf:", _fms(o.ann_n), _fms(o.ope1)], " ")
    end
end

@kwdef mutable struct EquivalentObjectProperties <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope_n::Vector{OPExpression}
end
_fms(o::EquivalentObjectProperties) = join(["EquivalentTo:", _fms(o.ann_n), _fms(o.ope_n)], " ")

@kwdef mutable struct DisjointObjectProperties <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope_n::Vector{OPExpression}
end
_fms(o::DisjointObjectProperties) = join(["DisjointWith:", _fms(o.ann_n), _fms(o.ope_n)], " ")

@kwdef mutable struct ObjectPropertyDomain <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
    ce::CExpression
end
_fms(o::ObjectPropertyDomain) = join([_fms(o.ope), "Domain:", _fms(o.ann_n), _fms(o.ce)], " ")

@kwdef mutable struct ObjectPropertyRange <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
    ce::CExpression
end
_fms(o::ObjectPropertyRange) = join([_fms(o.ope), "Range:", _fms(o.ann_n), _fms(o.ce)], " ")

@kwdef mutable struct InverseObjectProperties <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope1::OPExpression
    ope2::OPExpression
end
_fms(o::InverseObjectProperties) = join([_fms(o.ope1), "InverseOf:", _fms(o.ann_n), _fms(o.ope2)], " ")

@kwdef mutable struct FunctionalObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end
_fms(o::FunctionalObjectProperty) = join([_fms(o.ope), "Characteristics:", _fms(o.ann_n), "Functional"], " ")

@kwdef mutable struct InverseFunctionalObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end
_fms(o::InverseFunctionalObjectProperty) = join([_fms(o.ope), "Characteristics:", _fms(o.ann_n), "InverseFunctional"], " ")

@kwdef mutable struct ReflexiveObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end
_fms(o::ReflexiveObjectProperty) = join([_fms(o.ope), "Characteristics:", _fms(o.ann_n), "Reflexive"], " ")

@kwdef mutable struct IrreflexiveObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end
_fms(o::IrreflexiveObjectProperty) = join([_fms(o.ope), "Characteristics:", _fms(o.ann_n), "Irreflexive"], " ")

@kwdef mutable struct SymmetricObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end
_fms(o::SymmetricObjectProperty) = join([_fms(o.ope), "Characteristics:", _fms(o.ann_n), "Symmetric"], " ")

@kwdef mutable struct AsymmetricObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end
_fms(o::AsymmetricObjectProperty) = join([_fms(o.ope), "Characteristics:", _fms(o.ann_n), "Asymmetric"], " ")

@kwdef mutable struct TransitiveObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end
_fms(o::TransitiveObjectProperty) = join([_fms(o.ope), "Characteristics:", _fms(o.ann_n), "Transitive"], " ")

@kwdef mutable struct SubDataPropertyOf <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe1::DPExpression
    dpe2::DPExpression
end
_fms(o::SubDataPropertyOf) = join([_fms(o.dpe1), "SubPropertyOf:", _fms(o.ann_n), _fms(o.dpe2)], " ")

@kwdef mutable struct EquivalentDataProperties <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe_n::Vector{DPExpression}
end
_fms(o::EquivalentDataProperties) = join(["EquivalentTo:", _fms(o.ann_n), _fms(o.dpe_n)], " ")

@kwdef mutable struct DisjointDataProperties <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe_n::Vector{DPExpression}
end
_fms(o::DisjointDataProperties) = join(["DisjointWith:", _fms(o.ann_n), _fms(o.dpe_n)], " ")

@kwdef mutable struct DataPropertyDomain <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
    ce::CExpression
end
_fms(o::DataPropertyDomain) = join([_fms(o.dpe), "Domain:", _fms(o.ann_n), _fms(o.ce)], " ")

@kwdef mutable struct DataPropertyRange <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
    dr::DataRange
end
_fms(o::DataPropertyRange) = join([_fms(o.dpe), "Range:", _fms(o.ann_n), _fms(o.dr)], " ")

@kwdef mutable struct FunctionalDataProperty <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
end
_fms(o::FunctionalDataProperty) = join([_fms(o.dpe), "Characteristics:", _fms(o.ann_n), "Functional"], " ")

@kwdef mutable struct DatatypeDefinition <: Axiom
    ann_n::Vector{Annotation} = []
    dt::DataType
    dr::DataRange
end
_fms(o::DatatypeDefinition) = join([_fms(o.dt), "EquivalentTo:", _fms(o.ann_n), _fms(o.dr)], " ")

@kwdef mutable struct HasKey <: Axiom
    ann_n::Vector{Annotation} = []
    ce::CExpression
    ope_n::Vector{OPExpression}
    dpe_n::Vector{DPExpression}
end
_fms(o::HasKey) = join([_fms(o.ce), "HasKey:", _fms(o.ann_n), _fms(o.ope_n), _fms(o.dpe_n)], " ")

@kwdef mutable struct SameIndividual <: Assertion
    ann_n::Vector{Annotation} = []
    a_n::Vector{Individual}
end
_fms(o::SameIndividual) = join(["SameIndividual:", _fms(o.ann_n), _fms(o.a_n)], " ")

@kwdef mutable struct DifferentIndividuals <: Assertion
    ann_n::Vector{Annotation} = []
    a_n::Vector{Individual}
end
_fms(o::DifferentIndividuals) = join(["DifferentIndividuals:", _fms(o.ann_n), _fms(o.a_n)], " ")

@kwdef mutable struct ClassAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    ce::CExpression
    a::Individual
end
_fms(o::ClassAssertion) = join([_fms(o.a), "Types:", _fms(o.ann_n), _fms(o.ce)], " ")

@kwdef mutable struct ObjectPropertyAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    ope::OPExpression
    a1::Individual
    a2::Individual
end
_fms(o::ObjectPropertyAssertion) = join([_fms(o.a1), "Facts:", _fms(o.ann_n), _fms(o.ope), _fms(o.a2)], " ")

@kwdef mutable struct NegativeObjectPropertyAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    ope::OPExpression
    a1::Individual
    a2::Individual
end
_fms(o::NegativeObjectPropertyAssertion) = join([_fms(o.a1), "Facts:", _fms(o.ann_n), "not", _fms(o.ope), _fms(o.a2)], " ")

@kwdef mutable struct DataPropertyAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
    a::Individual
    lt::Literal
end
_fms(o::DataPropertyAssertion) = join([_fms(o.a), "Facts:", _fms(o.ann_n), _fms(o.dpe), _fms(o.lt)], " ")

@kwdef mutable struct NegativeDataPropertyAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
    a::Individual
    lt::Literal
end
_fms(o::NegativeDataPropertyAssertion) = join([_fms(o.a), "Facts:", _fms(o.ann_n), "not", _fms(o.dpe), _fms(o.lt)], " ")

@kwdef mutable struct AnnotationAssertion <: AnnotationAxiom
    ann_n::Vector{Annotation} = []
    ap::AnnotationProperty
    as::RDFTerm
    av::RDFTerm
end
_fms(o::AnnotationAssertion) = join([_fms(o.as), "Annotations:", _fms(o.ann_n), _fms(o.ap), _fms(o.av)], " ")

@kwdef struct SubAnnotationPropertyOf <: AnnotationAxiom
    ann_n::Vector{Annotation} = []
    ap1::AnnotationProperty
    ap2::AnnotationProperty
end
_fms(o::SubAnnotationPropertyOf) = join([_fms(o.as), "Annotations:", _fms(o.ann_n), _fms(o.ap), _fms(o.av)], " ")

@kwdef struct AnnotationPropertyDomain <: AnnotationAxiom
    ann_n::Vector{Annotation} = []
    ap::AnnotationProperty
    u::RDFTerm
end
_fms(o::AnnotationPropertyDomain) = join([_fms(o.ap), "Domain:", _fms(o.ann_n), _fms(o.u)], " ")

@kwdef struct AnnotationPropertyRange <: AnnotationAxiom
    ann_n::Vector{Annotation} = []
    ap::AnnotationProperty
    u::RDFTerm
end
_fms(o::AnnotationPropertyRange) = join([_fms(o.ap), "Range:", _fms(o.ann_n), _fms(o.u)], " ")

_fms(o::Vector{Axiom}) = map(x -> _fms(x), o)
