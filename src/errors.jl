using RDF

abstract type OWL2Error <: Exception end

struct FormatError <: OWL2Error
    message::String
end

Base.show(io::IO, e::FormatError) = print(io, "FormatError: ", e.message)

