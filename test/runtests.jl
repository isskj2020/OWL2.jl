using Test

@testset "OWL2" begin
    include("benchmark_test.jl")
    include("test_io.jl")
    include("test_annotation.jl")
end

