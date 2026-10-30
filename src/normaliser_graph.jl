using RDF


function normalise_graph!(g)
    sparql_dir = joinpath(@__DIR__, "sparql")
    ds = Dataset(; default_graph = g)
    for file in readdir(sparql_dir)
        normalise_graph!(ds, joinpath(sparql_dir, file))
    end
    return g
end

function normalise_graph!(ds, query_filepath)
    RDF.sparql_update!(ds, read(query_filepath, String))
    return ds
end
