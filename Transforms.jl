struct Transform
	r::Mat3d
	t::Vec3d
end

Transform() = Transform(one(Mat3d), zero(Vec3d)) 
Transform(r::StaticMatrix{3, 3}) = Transform(Mat3d(r), zero(Vec3d)) 
Transform(t::Vec3d) = Transform(one(Mat3d), t) 

function Base.:*(a_from_b::Transform, b_from_c::Transform)
	Transform(a_from_b.r * b_from_c.r, a_from_b * b_from_c.t)
end

function Base.:*(a_from_b::Transform, p_in_b::Vec3d)
	a_from_b.r * p_in_b + a_from_b.t
end