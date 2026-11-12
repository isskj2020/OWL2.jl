using OWL2, Test, RDF

function match_test(uri; mimetype::String)
    output_dir = joinpath(@__DIR__, "build")
    isdir(output_dir) || mkpath(output_dir)

    filename = basename(uri)
    output_filepath = joinpath(output_dir, "$filename.test.nt")

    OWL2._open_owl(uri) do rio
        g = read(rio, MIME(mimetype), Graph)
        for t in match(g)
            @info t
        end
        open(joinpath(output_dir, "$filename.origin.nt"), "w") do wio
            write(wio, :nt, g)
        end
    end
    OWL2._open_owl(uri) do rio
        open(joinpath(output_dir, filename), "w") do wio
            write(wio, rio)
        end
    end

    onto1 = OWL2.load_owl(uri; mimetype = mimetype)
    rep1 = manchester_syntax(onto1.axioms)
    OWL2.write_owl(onto1, output_filepath; type = :nt)
    onto2 = OWL2.load_owl(output_filepath; mimetype = "application/n-triples")
    rep2 = manchester_syntax(onto2.axioms)
    @test rep1 == rep2
end

@testset "OWL2 I/O matching" begin
   # https://github.com/isskj2020/owl-update-sample-data/blob/main/sample
    uri = "https://raw.githubusercontent.com/isskj2020/owl-update-sample-data/refs/heads/main/sample/mammals.xml"
    @testset "$uri" begin
        match_test(uri; mimetype = "application/rdf+xml")
    end
    uri = "https://raw.githubusercontent.com/isskj2020/owl-update-sample-data/refs/heads/main/sample/robots.xml"
    @testset "$uri" begin
        match_test(uri; mimetype = "application/rdf+xml")
    end

    uri = "https://raw.githubusercontent.com/isskj2020/owl-update-sample-data/refs/heads/main/sample/sample1.xml"
    @testset "$uri" begin
        match_test(uri; mimetype = "application/rdf+xml")
    end

    uri = "https://raw.githubusercontent.com/isskj2020/owl-update-sample-data/refs/heads/main/sample/sample2.xml"
    @testset "$uri" begin
        match_test(uri; mimetype = "application/rdf+xml")
    end

    uri = "https://raw.githubusercontent.com/isskj2020/owl-update-sample-data/refs/heads/main/sample/sample3.xml"
    @testset "$uri" begin
        match_test(uri; mimetype = "application/rdf+xml")
    end

    uri = "https://raw.githubusercontent.com/isskj2020/owl-update-sample-data/refs/heads/main/sample/sample4.xml"
    @testset "$uri" begin
        match_test(uri; mimetype = "application/rdf+xml")
    end
end

