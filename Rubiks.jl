# precedence: F/B, R/L, U/D
@enum Cubie FRU FRD FLU FLD BRU BRD BLU BLD FR FL FU FD BR BL BU BD LU LD RU RD
const AxisPerm = NamedTuple{(:FB, :RL, :UD), NTuple{3, Symbol}}
const Facelet = Tuple{Cubie, Symbol}


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

function Base.:*(a::CubeState, b::Facelet)
    query_cubie, query_face = b
    new_cubie_state = a[query_cubie]
    new_cubie = new_cubie_state.cubie
    face_dir = AXIS_FROM_FACE[query_face]
    new_face_dir = new_cubie_state.axis_perm[face_dir]
    new_face = only(filter(f-> new_face_dir == AXIS_FROM_FACE[f],
                           FACES_FROM_CUBIES[new_cubie]))
    (new_cubie, new_face)
end

function Base.:*(a::CubeState, b::CubeState)
	# To compute a * b, we iterate over the cubie locations.
	# For each location, we find which piece is there in b
	# We then look up the location of that piece in A
	out = Dict{Cubie, CubieState}()
	for c in instances(Cubie)
		# look through a
		b_state = b[c]
		# look through b
		a_state = a[b_state.cubie]
		axis_perm = AxisPerm(
			a_state.axis_perm[b_state.axis_perm[d]]
			for d in fieldnames(AxisPerm)
		)
		out[c] = CubieState(a_state.cubie, axis_perm)
	end
	CubeState(out)
end

const DEFAULT_PERM = (FB= :FB, RL = :RL, UD = :UD)

function FaceRotation(corner_cycle, edge_cycle)
	piece_swaps = Dict()
	for (src, dst) in zip(corner_cycle, circshift(corner_cycle, -1)) 
		piece_swaps[src] = dst
	end
	for (src, dst) in zip(edge_cycle, circshift(edge_cycle, -1)) 
		piece_swaps[src] = dst
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

const RUBIKS_MOVES = Dict(
	:F => F,
	:B => B,
	:R => R,
	:L => L,
	:U => U,
	:D => D,
)