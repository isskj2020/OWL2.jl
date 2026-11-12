using OWL2, Test

@testset "Benchmark" begin
    uri = "https://raw.githubusercontent.com/owlcs/owlapi/refs/heads/version5/contract/src/test/resources/pizza.owl"
    output_filepath = joinpath(@__DIR__, "build", "benchmark.nt")
    for i in 1:5
        t0 = time_ns()
        onto = OWL2.load_owl(uri; mimetype = "application/rdf+xml")
        elapsed = round((time_ns() - t0) / 1e6, digits=4)
        @info "read $elapsed(ms)"
        t0 = time_ns()
        OWL2.write_owl(onto, output_filepath; type = :nt)
        elapsed = round((time_ns() - t0) / 1e6, digits=4)
        @info "write $elapsed(ms)"
    end
end

