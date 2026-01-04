# This algorithm proceeds by defining the following subgroups chain:
# - Cross on top
# - Top face solved
# - Middle Layer Solved
# - Orient bottom cross
# - Orient bottom fase
# - Permute bottom cross
# - Permute bottom layer

function compute_action_costs(g, hom)
    action_costs = Dict()
    generators = GAP.Globals.GeneratorsOfGroup(g)
    for gen in generators
        factored = GAP.Globals.PreImagesRepresentative(hom, gen)
        action_costs[gen] = GAP.Globals.Length(factored)
        println("$gen -> $factored $(GAP.Globals.Length(factored))")
    end
    return action_costs
end

function build_lookup(g, action_costs, new_facelets_ids, op)
    println("$g -> $h")
    # Since we are stabilizing facelets, computing the orbit
    # of these facelets is sufficient to build our lookup table
    orbit = GAP.Globals.Orb(
        g,
        new_facelets_ids,
        op,
        GAP.GapObj(Dict(:schreier => true)))
    GAP.Globals.Enumerate(orbit)

    lookup_table = Dict()
    for i in 1:GAP.Globals.Length(orbit)
        point = orbit[i]

        print(point)
    end
end

function build_beginner_lookups()
    move_names = keys(RUBIKS_MOVES)
    rubiks_perms = Dict(k => GAP.Globals.PermList(GAP.GapObj(to_perm(RUBIKS_MOVES[k])))
        for k in move_names)
    cube_group = GAP.Globals.Group(values(rubiks_perms)...)

    free = GAP.Globals.FreeGroup(
        [GAP.GapObj(String(k)) for k in move_names]...)

    println(move_names)
    println(GAP.Globals.GeneratorsOfGroup(free))
    println(GAP.Globals.GeneratorsOfGroup(cube_group))

    hom = GAP.Globals.GroupHomomorphismByImages(free, cube_group,
        GAP.Globals.GeneratorsOfGroup(free),
        GAP.GapObj([rubiks_perms[k] for k in move_names]))

    u_cross_facelets = [(FU, :up), (LU, :up), (BU, :up), (RU, :up)]
    u_corner_facelets = [(FRU, :up), (FLU, :up), (BLU, :up), (BRU, :up)]
    middle_facelets = [(FL, :front), (FR, :front), (BL, :back), (BR, :back)]
    d_cross_facelets = [(FD, :down), (LD, :down), (BD, :down), (RD, :down)]
    d_corner_facelets = [(FRD, :down), (FLD, :down), (BLD, :down), (BRD, :down)]

    facelet_chain = [
        (u_cross_facelets, GAP.Globals.OnTuples),
        (u_corner_facelets, GAP.Globals.OnTuples),
        (middle_facelets, GAP.Globals.OnTuples),
        (d_cross_facelets, GAP.Globals.OnSets),
        (d_corner_facelets, GAP.Globals.OnSets),
        (d_cross_facelets, GAP.Globals.OnTuples),
        (d_corner_facelets, GAP.Globals.OnTuples),
    ]
    group_chain = [(cube_group, [])]
    for (facelets, kind) in facelet_chain
        prev_group = last(group_chain)
        facelet_ids = [FACELET_ID_FROM_FACELET[f] for f in facelets]
        facelet_ids = GAP.GapObj(facelet_ids)
        facelet_ids = kind == GAP.Globals.OnSets ? GAP.Globals.Set(facelet_ids) : facelet_ids
        new_group = GAP.Globals.Stabilizer(prev_group, facelet_ids, kind)
        push!(group_chain, (new_group, facelet_ids, kind))
    end

    GAP.Globals.LoadPackage(GAP.GapObj("orb"))
    for ((g, _, _), (h, new_facelets, kind)) in zip(group_chain[1:end-1], group_chain[2:end])
        action_costs = compute_action_costs(g, hom)
        build_lookup(g, action_costs, new_facelets, kind)
        break
    end

    println(Int128(GAP.Globals.Size(cube_group)))
end