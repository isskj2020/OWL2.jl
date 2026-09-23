abstract type Axiom end
abstract type CExpression end
abstract type OPExpression end
abstract type DPExpression end
abstract type DataRange end
abstract type Individual end

abstract type ClassAxiom <: Axiom end
abstract type ObjectPropertyAxiom <: Axiom end
abstract type DataPropertyAxiom <: Axiom end
abstract type Assertion <: Axiom end
abstract type AnnotationAxiom <: Axiom end


@kwdef struct Class <: CExpression
    x::String
end

@kwdef struct ClassNodeID <: CExpression
    x::String
end

@kwdef struct DataType <: DataRange
    x::String
end

@kwdef struct DataNodeID <: DataRange
    x::String
end


@kwdef struct PlainLiteral
    x::String
end

@kwdef struct NamedIndividual <: Individual
    x::String
end

@kwdef struct AnonymousIndividual <: Individual
    x::String
end

@kwdef struct AnnotationProperty
    x::String
end

@kwdef struct DataProperty <: DPExpression
    x::String
end

@kwdef struct ObjectProperty <: OPExpression
    x::String
end

@kwdef mutable struct ObjectPropertyChain <: OPExpression
    ope_n::Vector{OPExpression}
end

@kwdef mutable struct ObjectInverseOf <: OPExpression
    ope::ObjectProperty
end

@kwdef mutable struct ObjectIntersectionOf <: CExpression
    ce_n::Vector{CExpression}
end

@kwdef mutable struct ObjectUnionOf <: CExpression
    ce_n::Vector{CExpression}
end

@kwdef mutable struct ObjectComplementOf <: CExpression
    ce::CExpression
end

@kwdef mutable struct ObjectOneOf <: CExpression
    a_n::Vector{Individual}
end

@kwdef mutable struct ObjectSomeValuesFrom <: CExpression
    ope::OPExpression
    ce::CExpression
end

@kwdef mutable struct ObjectAllValuesFrom <: CExpression
    ope::OPExpression
    ce::CExpression
end

@kwdef mutable struct ObjectHasValue <: CExpression
    ope::OPExpression
    a::Individual
end

@kwdef mutable struct ObjectHasSelf <: CExpression
    ope::OPExpression
end

@kwdef mutable struct ObjectMinCardinality <: CExpression
    n::UInt64
    ope::OPExpression
    ce::CExpression
end

@kwdef mutable struct ObjectMaxCardinality <: CExpression
    n::UInt64
    ope::OPExpression
    ce::CExpression
end

@kwdef mutable struct ObjectExactCardinality <: CExpression
    n::UInt64
    ope::OPExpression
    ce::CExpression
end

@kwdef mutable struct DataSomeValuesFrom <: CExpression
    dpe_n::Vector{DPExpression}
    dr::DataRange
end

@kwdef mutable struct DataAllValuesFrom <: CExpression
    dpe_n::Vector{DPExpression}
    dr::DataRange
end

@kwdef mutable struct DataHasValue <: CExpression
    dpe::DPExpression
    lt::String
end

@kwdef mutable struct DataMinCardinality <: CExpression
    n::UInt64
    dpe::DPExpression
    dr::DataRange
end

@kwdef mutable struct DataMaxCardinality <: CExpression
    n::UInt64
    dpe::DPExpression
    dr::DataRange
end

@kwdef mutable struct DataExactCardinality <: CExpression
    n::UInt64
    dpe::DPExpression
    dr::DataRange
end

@kwdef mutable struct DataIntersectionOf <: DataRange
    dr_n::Vector{DataRange}
end

@kwdef mutable struct DataUnionOf <: DataRange
    dr_n::Vector{DataRange}
end

@kwdef mutable struct DataComplementOf <: DataRange
    dr::DataRange
end

@kwdef mutable struct DataOneOf <: DataRange
    lt_n::Vector{PlainLiteral}
end

@kwdef mutable struct DataTypeRestriction <: DataRange
    dt::DataType
    f_n::Vector{String}
    lt_n::Vector{PlainLiteral}
end

@kwdef mutable struct Annotation
    ann_n::Vector{Annotation} = []
    ap::AnnotationProperty
    av::String
end

@kwdef mutable struct Declaration <: Axiom
    ann_n::Vector{Annotation} = []
    e::Any
end

@kwdef mutable struct SubClassOf <: ClassAxiom
    ann_n::Vector{Annotation} = []
    ce1::CExpression
    ce2::CExpression
end

@kwdef mutable struct EquivalentClasses <: ClassAxiom
    ann_n::Vector{Annotation} = []
    ce_n::Vector{CExpression}
end

@kwdef mutable struct DisjointClasses <: ClassAxiom
    ann_n::Vector{Annotation} = []
    ce_n::Vector{CExpression}
end

@kwdef mutable struct DisjointUnion <: ClassAxiom
    ann_n::Vector{Annotation} = []
    c::Class
    ce_n::Vector{CExpression}
end

@kwdef mutable struct SubObjectPropertyOf <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope1::Union{OPExpression, ObjectPropertyChain}
    ope2::OPExpression
end

@kwdef mutable struct EquivalentObjectProperties <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope_n::Vector{OPExpression}
end

@kwdef mutable struct DisjointObjectProperties <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope_n::Vector{OPExpression}
end

@kwdef mutable struct InverseObjectProperties <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope1::OPExpression
    ope2::OPExpression
end

@kwdef mutable struct ObjectPropertyDomain <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
    ce::CExpression
end

@kwdef mutable struct ObjectPropertyRange <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
    ce::CExpression
end

@kwdef mutable struct FunctionalObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end

@kwdef mutable struct InverseFunctionalObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end

@kwdef mutable struct ReflexiveObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end

@kwdef mutable struct IrreflexiveObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end

@kwdef mutable struct SymmetricObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end

@kwdef mutable struct AsymmetricObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end

@kwdef mutable struct TransitiveObjectProperty <: ObjectPropertyAxiom
    ann_n::Vector{Annotation} = []
    ope::OPExpression
end

@kwdef mutable struct SubDataPropertyOf <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe1::DPExpression
    dpe2::DPExpression
end

@kwdef mutable struct EquivalentDataProperties <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe_n::Vector{DPExpression}
end

@kwdef mutable struct DisjointDataProperties <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe_n::Vector{DPExpression}
end

@kwdef mutable struct DataPropertyDomain <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
    ce::CExpression
end

@kwdef mutable struct DataPropertyRange <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
    dr::DataRange
end

@kwdef mutable struct FunctionalDataProperty <: DataPropertyAxiom
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
end

@kwdef mutable struct DatatypeDefinition <: Axiom
    ann_n::Vector{Annotation} = []
    dt::DataType
    dr::DataRange
end

@kwdef mutable struct HasKey <: Axiom
    ann_n::Vector{Annotation} = []
    ce::CExpression
    ope_n::Vector{OPExpression}
    dpe_n::Vector{DPExpression}
end

@kwdef mutable struct SameIndividual <: Assertion
    ann_n::Vector{Annotation} = []
    a_n::Vector{Individual}
end

@kwdef mutable struct DifferentIndividuals <: Assertion
    ann_n::Vector{Annotation} = []
    a_n::Vector{Individual}
end

@kwdef mutable struct ClassAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    ce::CExpression
    a::Individual
end

@kwdef mutable struct ObjectPropertyAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    ope::OPExpression
    a1::Individual
    a2::Individual
end

@kwdef mutable struct NegativeObjectPropertyAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    ope::OPExpression
    a1::Individual
    a2::Individual
end

@kwdef mutable struct DataPropertyAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
    a1::Individual
    a2::Individual
end

@kwdef mutable struct NegativeDataPropertyAssertion <: Assertion
    ann_n::Vector{Annotation} = []
    dpe::DPExpression
    a1::Individual
    a2::Individual
end

@kwdef mutable struct AnnotationAssertion <: AnnotationAxiom
    ann_n::Vector{Annotation} = []
    ap::AnnotationProperty
    as::String
    av::String
end

@kwdef struct SubAnnotationPropertyOf <: AnnotationAxiom
    ann_n::Vector{Annotation} = []
    ap1::AnnotationProperty
    ap2::AnnotationProperty
end


@kwdef struct AnnotationPropertyDomain <: AnnotationAxiom
    ann_n::Vector{Annotation} = []
    ap::AnnotationProperty
    u::String
end

@kwdef struct AnnotationPropertyRange <: AnnotationAxiom
    ann_n::Vector{Annotation} = []
    ap::AnnotationProperty
    u::String
end

