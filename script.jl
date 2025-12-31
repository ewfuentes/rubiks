
using GeometryBasics
using GLMakie
using StaticArrays

include("Transforms.jl")
include("Rubiks.jl")
include("Visualize.jl")

fig = Figure(size=(800, 600))
lscene = LScene(fig[1, 1])
identity_cube = CubeState()

display!(lscene, D' * L' * B' * U' * R' * F' * F * R * U * B * L * D)

display(fig)
wait(fig.scene)
