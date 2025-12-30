
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
	:front => :green,
	:right => :red,
	:back => :blue,
	:left => :orange,
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

const AXIS_PERM_FROM_DIR = Dict(
	:FB => (FB = :FB, RL = :UD, UD = :RL),
	:RL => (FB = :UD, RL = :RL, UD = :FB),
	:UD => (FB = :RL, RL = :FB, UD = :UD),
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

struct CubeState 
	data::Dict{Cubie, CubieState}	
	inv_data::Dict{Cubie, CubieState}
end

function CubeState(data::Dict{Cubie, CubieState})
	inv_data = Dict{Cubie, CubieState}()
	for (cubie, cubie_state) in data
		d = Dict(v => k for (k, v) in pairs(cubie_state.axis_perm))
		inv_data[cubie_state.cubie] = CubieState(
			cubie, (FB = d[:FB], RL = d[:RL], UD = d[:UD]))
	end
	CubeState(data, inv_data)
end

function CubeState(; piece_swaps=Dict(), axis_perm=DEFAULT_PERM)
	data = Dict{Cubie, CubieState}(c => CubieState(c, DEFAULT_PERM)
				   for c in instances(Cubie))
	for (k, v) in piece_swaps
		data[k] = CubieState(v, axis_perm)
	end
	CubeState(data)
end


Base.getindex(s::CubeState, p::Cubie) = s.data[p]
Base.inv(s::CubeState) = CubeState(s.inv_data, s.data)
Base.adjoint(s::CubeState) = inv(s)

function Base.:*(a::CubeState, b::CubeState)
	# To compute a * b, we iterate over the cubie locations.
	# For each location, we find which piece is there in b
	# We then look up the location of that piece in A
	out = Dict{Cubie, CubieState}()
	for c in instances(Cubie)
		# look through a
		a_state = a[c]
		# look through b
		b_state = b[a_state.cubie]

		axis_perm = AxisPerm(
			a_state.axis_perm[b_state.axis_perm[d]]
			for d in fieldnames(AxisPerm)
		)
		out[c] = CubieState(b_state.cubie, axis_perm)
	end
	CubeState(out)
end

const DEFAULT_PERM = (FB= :FB, RL = :RL, UD = :UD)

function FaceRotation(corner_cycle, edge_cycle)
	piece_swaps = Dict()
	for (src, dst) in zip(corner_cycle, circshift(corner_cycle, -1)) 
		piece_swaps[dst] = src
	end
	for (src, dst) in zip(edge_cycle, circshift(edge_cycle, -1)) 
		piece_swaps[dst] = src
	end

	all_pieces = [corner_cycle..., edge_cycle...]
	common_face = only(intersect([FACES_FROM_CUBIES[c] for c in all_pieces]...))
	common_dir = AXIS_FROM_FACE[common_face]

	return CubeState(piece_swaps=piece_swaps, axis_perm = AXIS_PERM_FROM_DIR[common_dir])
end

const U = FaceRotation([FRU, BRU, BLU, FLU], [FU, RU, BU, LU])
const D = FaceRotation([FRD, FLD, BLD, BRD], [FD, LD, BD, RD])
const F = FaceRotation([FRU, FLU, FLD, FRD], [FU, FL, FD, FR])
const B = FaceRotation([BRU, BRD, BLD, BLU], [BU, BR, BD, BL])
const R = FaceRotation([FRU, FRD, BRD, BRU], [FR, RD, BR, RU])
const L = FaceRotation([FLU, BLU, BLD, FLD], [FL, LU, BL, LD])

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

display!(lscene, D' * L' * B' * U' * R' * F' * F * R * U * B * L * D)

display(fig)
wait(fig.scene)
