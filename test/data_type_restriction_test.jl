using OWL2, PythonCall, Test

@testset "DatatypeRestriction" begin
    axioms = OWL2.load_owl(joinpath("test/res/datatype_restriction.xml"))
    OWL2.write_owl_nt(axioms, "test_output.ttl")
    OWL2.load_owl("test_output.ttl")
end
