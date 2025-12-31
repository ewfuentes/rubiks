
const FACE_ORDER = [:front, :back, :right, :left, :up, :down]
const FACELETS_FROM_FACE = Dict(
    :front => [FLU, FU, FRU, 
               FL,      FR, 
               FLD, FD, FRD],
    :back => [BRU, BU, BLU, 
              BR,      BL,
              BRD, BD, BLD],
    :right => [FRU, RU, BRU, 
               FR,      BR,
               FRD, RD, BRD],
    :left => [BLU, LU, FLU,
              BL,      FL,
              BLD, LD, FLD],
    :up => [BLU, BU, BRU,
            LU,      RU,
            FLU, FU, FRU],
    :down => [FLD, FD, FRD,
              LD,      RD,
              BLD, BD, BRD],
)

FACELET_ID_FROM_FACELET = let
    idx = 1
    out = Dict{Tuple{Cubie, Symbol}, Int64}()
    for face in FACE_ORDER
        for cubie in FACELETS_FROM_FACE[face]
            out[(cubie, face)] = idx
            idx += 1
        end
    end
    out
end

function to_perm(s::CubeState)
    out = fill(-1, 48)
    for (facelet, facelet_id) in FACELET_ID_FROM_FACELET 
        # Find out where the cubie ends up
        new_facelet = s * facelet
        new_facelet_id = FACELET_ID_FROM_FACELET[new_facelet]
        out[facelet_id] = new_facelet_id
    end
    return out
end