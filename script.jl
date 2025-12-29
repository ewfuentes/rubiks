
using GeometryBasics
using GLMakie
using Rotations
using CoordinateTransformations
using StaticArrays

# precedence: F/B, R/L, U/D
@enum Cubie FRU FRD FLU FLD BRU BRD BLU BLD FR FL FU FD BR BL BU BD LU LD RU RD

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

const AxisPerm = NamedTuple{(:FB, :RL, :UD), NTuple{3, Symbol}}

struct CubieState 
	cubie::Cubie
	axis_perm::AxisPerm
end

mutable struct CubeState 
	data::Dict{Cubie, CubieState}	
end

Base.getindex(s::CubeState, p::Cubie) = s.data[p]
Base.setindex!(s::CubeState, c::CubieState, p::Cubie) = s.data[p] = c

const DEFAULT_PERM = (FB= :FB, RL = :RL, UD = :UD)

function CubeState(; piece_swaps=Dict(), axis_perm=DEFAULT_PERM)
	out = CubeState(Dict(c => CubieState(c, DEFAULT_PERM)
				   for c in instances(Cubie)))
	for (k, v) in piece_swaps
		out[k] = CubieState(v, axis_perm)
	end
	return out
end

const U = CubeState(
	piece_swaps = Dict(
		FRU => FLU,
		FLU => BLU,
		BLU => BRU,
		BRU => FRU,
  	    FU => LU,
  	    LU => BU,
		BU => RU,
		RU => FU,
	),
	axis_perm = (FB = :RL, RL = :FB, UD = :UD),
)

const D = CubeState(
	piece_swaps = Dict(
		FRD => BRD,
		BRD => BLD,
		BLD => FLD,
		FLD => FRD,
  	    FD => RD,
		RD => BD,
		BD => LD,
  	    LD => FD,
	),
	axis_perm = (FB = :RL, RL = :FB, UD = :UD),
)

const F = CubeState(
	piece_swaps = Dict(
		 FRU => FRD,
		 FRD => FLD,
		 FLD => FLU,
		 FLU => FRU,
		 FU => FR,
		 FR => FD,
		 FD => FL,
		 FL => FU,
	),
	axis_perm = (FB = :FB, RL = :UD, UD = :RL)
)

const B = CubeState(
	piece_swaps = Dict(
		 BRU => BLU,
		 BLU => BLD,
		 BLD => BRD,
		 BRD => BRU,
		 BU => BL,
		 BL => BD,
		 BD => BR,
		 BR => BU,
	),
	axis_perm = (FB = :FB, RL = :UD, UD = :RL)
)

const R = CubeState(
	piece_swaps = Dict(
		 FRU => BRU,
		 BRU => BRD,
		 BRD => FRD,
		 FRD => FRU,

		 FR => RU,
		 RU => BR,
		 BR => RD,
		 RD => FR,

	),
	axis_perm = (FB = :UD, RL = :RL, UD = :FB)
)

const L = CubeState(
	piece_swaps = Dict(
		 FLU => FLD,
		 FLD => BLD,
		 BLD => BLU,
		 BLU => FLU,
		 FL => LD,
		 LD => BL,
		 BL => LU,
		 LU => FL,
	),
	axis_perm = (FB = :UD, RL = :RL, UD = :FB)
)


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

function draw_faces!(lscene::LScene, cubie, axis_perm, cubie_loc)
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

	# want a map that goes from original faces to new face ordering
	faces = FACES_FROM_CUBIES[cubie]
	face_from_dir = Dict(AXIS_FROM_FACE[f] => f for f in faces)
	face_from_permuted_dir = Dict(axis_perm[d] => f for (d, f) in face_from_dir)
	cubie_loc_dirs = [AXIS_FROM_FACE[f] for f in FACES_FROM_CUBIES[cubie_loc]]
	permuted_faces = [face_from_permuted_dir[d] for d in cubie_loc_dirs]

	world_from_cubie = WORLD_FROM_CUBIES[cubie_loc]
	for (i, face) in enumerate(permuted_faces)
		color = FACE_COLORS[face]
		cubie_from_axis = Transform(circshift(one(Mat3d), (0, 1-i)))
		vertices_in_world = [world_from_cubie * cubie_from_axis * v for v in vertices_in_axis]
		mesh!(lscene, vertices_in_world, mesh_faces, color = color, shading=NoShading)
		lines!(lscene, [vertices_in_world..., vertices_in_world[1]],
					  color=:black, linewidth=3)
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
		axis_perm = cubie isa Symbol ? DEFAULT_PERM : cubie_state.axis_perm
		draw_faces!(lscene, cubie, axis_perm, cubie_loc)
	end
end

fig = Figure(size=(800, 600))
lscene = LScene(fig[1, 1])
identity_cube = CubeState()

display!(lscene, L)

display(fig)
wait(fig.scene)
