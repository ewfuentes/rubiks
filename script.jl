
using GeometryBasics
using GLMakie
using StaticArrays

include("Transforms.jl")
include("Rubiks.jl")
include("Visualize.jl")
include("RubiksGAP.jl")

fig = Figure(size=(800, 600))
lscene = LScene(fig[1, 1])
identity_cube = CubeState()

print(to_perm(F * R))

display!(lscene, F * R )
display(fig)
wait(fig.scene)


