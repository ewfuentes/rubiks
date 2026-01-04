
using GeometryBasics
using GLMakie
using StaticArrays
using GAP

include("Transforms.jl")
include("Rubiks.jl")
include("Visualize.jl")
include("RubiksGAP.jl")
include("Beginner.jl")

identity_cube = CubeState()

# print(to_perm(F * R))

# fig = Figure(size=(800, 600))
# lscene = LScene(fig[1, 1])
# display!(lscene, F * R )
# display(fig)
# wait(fig.scene)

build_beginner_lookups()