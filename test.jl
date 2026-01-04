
include("Rubiks.jl")

using Test

@testset "CubeStateTest" begin
    @test (FRU, :front) == (CubeState() * (FRU, :front))
    @test (BRU, :right) == (U * (FRU, :front))
    @test (BRU, :back) == (U * (FRU, :right))
    @test (BRU, :up) == (U * (FRU, :up))
    @test (RU, :right) == (U * (FU, :front))
    @test (RU, :up) == (U * (FU, :up))
    @test (FRU, :front) == ((F * R) * (FRU, :up))
    @test (FRU, :right) == (F * R * (FRU, :front))
    @test (FRU, :up) == (F * R * (FRU, :right))
    @test ((F * R) * (FRU, :right)) == (F * (R * (FRU, :right)))
end
