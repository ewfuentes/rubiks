
using GeometryBasics
using GLMakie
using Rotations
using CoordinateTransformations
using StaticArrays

# precedence: F/B, R/L, U/D
@enum CornerCubie FRU FRD FLU FLD BRU BRD BLU BLD 
@enum EdgeCubie FR FL FU FD BR BL BU BD LU LD RU RD

struct Transform
	r::Mat3d
	t::Vec3d
end

const FACE_COLORS = Dict(
	:front => :red,
	:right => :blue,
	:back => :orange,
	:left => :green,
	:up => :white,
	:down => :yellow
)

const AXIS_FROM_FACE = Dict(
	:front => :FB,
	:back => :FB,
	:right => :RL,
	:left => :RL,
	:up => :UD,
	:down => :UD)

const FACES_FROM_CUBIES = Dict(
    FRU => (:front, :right, :up),
    FRD => (:front, :right, :down),
    FLU => (:front, :left, :up),
    FLD => (:front, :left, :down),
    BRU => (:back, :right, :up),
    BRD => (:back, :right, :down),
    BLU => (:back, :left, :up),
    BLD => (:back, :left, :down),
    FR => (:front, :right),
    FL => (:front, :left),
    FU => (:front, :up),
    FD => (:front, :down),
    BR => (:back, :right),
    BL => (:back, :left),
    BU => (:back, :up),
    BD => (:back, :down),
    LU => (:left, :up),
    LD => (:left, :down),
    RU => (:right, :up),
    RD => (:right, :down),
	:front => (:front,),
	:back => (:back,),
	:right => (:right,),
	:left => (:left,),
	:up => (:up,),
	:down => (:down,),
)

const WORLD_FROM_CUBIES = Dict(
	:front => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, 1, 0), Vec3d(0, 0, 1)), Vec3d(1, 0, 0)),
	:back => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, 1, 0), Vec3d(0, 0, -1)), Vec3d(-1, 0, 0)),
	:right => Transform(hcat(Vec3d(0, 1, 0), Vec3d(0, 0, 1), Vec3d(1, 0, 0)), Vec3d(0, 1, 0)),
	:left => Transform(hcat(Vec3d(0, -1, 0), Vec3d(0, 0, 1), Vec3d(-1, 0, 0)), Vec3d(0, -1, 0)),
	:up => Transform(hcat(Vec3d(0, 0, 1), Vec3d(0, 1, 0), Vec3d(-1, 0, 0)), Vec3d(0, 0, 1)),
	:down => Transform(hcat(Vec3d(0, 0, -1), Vec3d(0, 1, 0), Vec3d(1, 0, 0)), Vec3d(0, 0, -1)),

	FRU => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, 1, 0), Vec3d(0, 0, 1)),
					 Vec3d(1, 1, 1)),
	FRD => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, 1, 0), Vec3d(0, 0, -1)),
					 Vec3d(1, 1, -1)),
	FLU => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, -1, 0), Vec3d(0, 0, 1)),
					 Vec3d(1, -1, 1)),
	FLD => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, -1, 0), Vec3d(0, 0, -1)),
					 Vec3d(1, -1, -1)),
	BRU => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, 1, 0), Vec3d(0, 0, 1)),
					 Vec3d(-1, 1, 1)),
	BRD => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, 1, 0), Vec3d(0, 0, -1)),
					 Vec3d(-1, 1, -1)),
	BLU => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, -1, 0), Vec3d(0, 0, 1)),
					 Vec3d(-1, -1, 1)),
	BLD => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, -1, 0), Vec3d(0, 0, -1)),
					 Vec3d(-1, -1, -1)),

	FR => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, 1, 0), Vec3d(0, 0, 1)),
					Vec3d(1, 1, 0)),
	FL => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, -1, 0), Vec3d(0, 0, 1)),
					Vec3d(1, -1, 0)),
	FU => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, 0, 1), Vec3d(0, -1, 0)),
					Vec3d(1, 0, 1)),
	FD => Transform(hcat(Vec3d(1, 0, 0), Vec3d(0, 0, -1), Vec3d(0, 1, 0)),
					Vec3d(1, 0, -1)),
	BR => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, 1, 0), Vec3d(0, 0, -1)),
					Vec3d(-1, 1, 0)),
	BL => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, -1, 0), Vec3d(0, 0, 1)),
					Vec3d(-1, -1, 0)),
	BU => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, 0, 1), Vec3d(0, 1, 0)),
					Vec3d(-1, 0, 1)),
	BD => Transform(hcat(Vec3d(-1, 0, 0), Vec3d(0, 0, -1), Vec3d(0, -1, 0)),
					Vec3d(-1, 0, -1)),
	LU => Transform(hcat(Vec3d(0, -1, 0), Vec3d(0, 0, 1), Vec3d(-1, 0, 0)),
					Vec3d(0, -1, 1)),
	LD => Transform(hcat(Vec3d(0, -1, 0), Vec3d(0, 0, -1), Vec3d(1, 0, 0)),
					Vec3d(0, -1, -1)),
	RU => Transform(hcat(Vec3d(0, 1, 0), Vec3d(0, 0, 1), Vec3d(1, 0, 0)),
					Vec3d(0, 1, 1)),
	RD => Transform(hcat(Vec3d(0, 1, 0), Vec3d(0, 0, -1), Vec3d(-1, 0, 0)),
					Vec3d(0, 1, -1)),
)


Transform() = Transform(one(Mat3d), zero(Vec3d)) 
Transform(r::StaticMatrix{3, 3}) = Transform(Mat3d(r), zero(Vec3d)) 
Transform(t::Vec3d) = Transform(one(Mat3d), t) 

function Base.:*(a_from_b::Transform, b_from_c::Transform)
	Transform(a_from_b.r * b_from_c.r, a_from_b * b_from_c.t)
end

function Base.:*(a_from_b::Transform, p_in_b::Vec3d)
	a_from_b.r * p_in_b + a_from_b.t
end

mutable struct Corner
	cubie::CornerCubie
	axis_perm::{3, Symbol}
end

mutable struct Edge
	cubie::EdgeCubie
	axis_perm::NTuple{3, Symbol}
end

mutable struct CubeState
	corners::Dict{CornerCubie, Corner}
	edges::Dict{EdgeCubie, Edge}
end

function CubeState(; corner_overrides=Dict(), edge_overrides=Dict())
	corners = Dict(c => Corner(c, AXIS_FROM_FACE[FACES_FROM_CUBIES[c]])
				   for c in instances(CornerCubie))
	edges = Dict(c => Edge(c, AXIS_FROM_FACE[FACES_FROM_CUBIES[c]])
				 for c in instances(EdgeCubie))
	merge!(corners, corner_overrides)
	merge!(edges, edge_overrides)
	CubeState(corners, edges)
end

const U = CubeState(

	corner_overrides = 
	Dict(
		 FRU => Corner(FLU, (:LR, :FB, :UD)),
		 FLU => Corner(BLU, (:FB, :FB, :UD)),
		 BLU => Corner(BRU, (:LR, :FB, :UD)),
		 BRU => Corner(FRU, (:LR, :FB, :UD)),
	),
	edge_overrides = 
	Dict(
  	    FU => Edge(LU,(:LR, :FB, :UD)),
  	    LU => Edge(BU,(:LR, :FB, :UD)),
		BU => Edge(RU,(:LR, :FB, :UD)),
		RU => Edge(FU,(:LR, :FB, :UD)),
	),
)

const F = CubeState(
	corner_overrides = 
	Dict(
		 FRU => Corner(FRD, (:FB, :UD, :LR)),
		 FRD => Corner(FLD, (:FB, :UD, :LR)),
		 FLD => Corner(FLU, (:FB, :UD, :LR)),
		 FLU => Corner(FRU, (:FB, :UD, :LR)),
	),
	edge_overrides = 
	Dict(
		 FU => Edge(FR, (:FB, :UD, :LR)),
		 FR => Edge(FD, (:FB, :UD, :LR)),
		 FD => Edge(FL, (:FB, :UD, :LR)),
		 FL => Edge(FU, (:FB, :UD, :LR)),
	),
)

Base.getindex(s::CubeState, p::CornerCubie) = s.corners[p]
Base.getindex(s::CubeState, p::EdgeCubie) = s.edges[p]
Base.setindex!(s::CubeState, p::CornerCubie, c::Corner) = s.corners[p] = c
Base.setindex!(s::CubeState, p::EdgeCubie, c::Edge) = s.edges[p] = c

function draw_triad!(lscene::LScene, world_from_frame::Transform; kwargs...)
	colors = [:red, :green, :blue]

	directions = [
		Vec3d(1.0, 0.0, 0.0),
		Vec3d(0.0, 1.0, 0.0),
		Vec3d(0.0, 0.0, 1.0)]
	directions = [world_from_frame.r * d for d in directions]
	arrows3d!(lscene,
			  fill(world_from_frame*zero(Vec3d), 3),
			  directions,
			  color = colors;
			  kwargs...)
end

function draw_faces!(lscene::LScene, cubie, shift::Int, world_from_cubie::Transform)
    vertices_in_axis = [
    	Vec3d(0.5, -0.49, -0.49),
    	Vec3d(0.5, -0.49, 0.49),
    	Vec3d(0.5, 0.49, 0.49),
    	Vec3d(0.5, 0.49, -0.49),
    ]
    mesh_faces = [
        GLTriangleFace(1, 2, 3),
        GLTriangleFace(1, 3, 4),
    ]

	faces = circshift(collect(FACES_FROM_CUBIES[cubie]), shift)
	for (i, face) in enumerate(faces)
		color = FACE_COLORS[face]
		cubie_from_axis = Transform(circshift(one(Mat3d), (0, 1-i)))
		vertices_in_world = [world_from_cubie * cubie_from_axis * v for v in vertices_in_axis]
		mesh!(lscene, vertices_in_world, mesh_faces, color = color, shading=NoShading)
		linesegments!(lscene, 
					  [vertices_in_world..., vertices_in_world[1]],
					  color=:black, linewidth=2)
	end
end

function display!(lscene::LScene, cube::CubeState)
	# Draw a triad
	draw_triad!(lscene, Transform(), lengthscale=0.2)

	# Draw triads for each of cubie coordinate frames
	for (cubie_loc, world_from_cubie) in WORLD_FROM_CUBIES
		draw_triad!(lscene, world_from_cubie, lengthscale=0.1)
		text!(lscene, String(Symbol(cubie_loc)), position=world_from_cubie.t)
		cubie_state = cubie_loc isa Symbol ? cubie_loc : cube[cubie_loc]
		cubie = cubie_state isa Symbol ? cubie_state : cubie_state.cubie
		shift = cubie isa Symbol ? 0 : (cubie_state isa Corner ? cubie_state.twist : (cubie_state.flip ? 1 : 0))
		draw_faces!(lscene, cubie, shift, world_from_cubie)
	end
end

fig = Figure(size=(800, 600))
lscene = LScene(fig[1, 1])
identity_cube = CubeState()

display!(lscene, F)

display(fig)
wait(fig.scene)
