using Test, OWL2, RDF

@testset "Annotation" begin
    uri = "https://raw.githubusercontent.com/isskj2020/owl-update-sample-data/refs/heads/main/sample/mammals.xml"
    ex = Namespace("http://example.com/ex")
    onto1 = OWL2.load_owl(uri; mimetype = "application/rdf+xml")
    annotate!(onto1.axioms[1], ex.weight, Literal(0.5))
    annotate!(onto1.axioms[1], ex.weight, Literal(0.9))
    rep1 = manchester_syntax(onto1.axioms)

    OWL2.write_owl(onto1, joinpath(@__DIR__, "build", "annotation.nt"))
    @test length(onto1.axioms[1].ann_n) == 1
end

