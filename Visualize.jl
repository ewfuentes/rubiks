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

function draw_faces!(lscene::LScene, cube::CubeState, cubie_loc)
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

	world_from_cubie = WORLD_FROM_CUBIES[cubie_loc]
	for (i, face) in enumerate(FACES_FROM_CUBIES[cubie_loc])
        if cubie_loc isa Symbol
            src_face = face
        else
            _, src_face = cube' * (cubie_loc, face)
        end
		color = FACE_COLORS[src_face]
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
		draw_faces!(lscene, cube, cubie_loc)
	end
end