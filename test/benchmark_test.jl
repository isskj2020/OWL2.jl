using OWL2, Test

@testset "Benchmark" begin
    for i in 1:10
        t0 = time_ns()
        axioms = OWL2.load_owl("test/res/pizza.owl")
        elapsed = round((time_ns() - t0) / 1e6, digits=4)
        @info "read $elapsed(ms)"
        t0 = time_ns()
        OWL2.write_owl_nt(axioms, "test_output.ttl")
        elapsed = round((time_ns() - t0) / 1e6, digits=4)
        @info "write $elapsed(ms)"
    end
end

