F := PermList([6, 4, 1, 7, 2, 8, 5, 3, 9, 10, 11, 12, 13, 14, 15, 16, 38, 18, 19, 39, 21, 40, 23, 24, 25, 26, 41, 28, 42, 30, 31, 43, 33, 34, 35, 36, 37, 32, 29, 27, 22, 20, 17, 44, 45, 46, 47, 48]);
B := PermList([1, 2, 3, 4, 5, 6, 7, 8, 14, 12, 9, 15, 10, 16, 13, 11, 17, 18, 48, 20, 47, 22, 23, 46, 35, 26, 27, 34, 29, 33, 31, 32, 19, 21, 24, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 25, 28, 30]);
R := PermList([1, 2, 43, 4, 45, 6, 7, 48, 40, 10, 11, 37, 13, 35, 15, 16, 22, 20, 17, 23, 18, 24, 21, 19, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 3, 36, 5, 38, 39, 8, 41, 42, 14, 44, 12, 46, 47, 9]);
L := PermList([33, 2, 3, 36, 5, 38, 7, 8, 9, 10, 46, 12, 44, 14, 15, 41, 17, 18, 19, 20, 21, 22, 23, 24, 30, 28, 25, 31, 26, 32, 29, 27, 16, 34, 35, 13, 37, 11, 39, 40, 1, 42, 43, 4, 45, 6, 47, 48]);
U := PermList([17, 18, 19, 4, 5, 6, 7, 8, 25, 26, 27, 12, 13, 14, 15, 16, 9, 10, 11, 20, 21, 22, 23, 24, 1, 2, 3, 28, 29, 30, 31, 32, 38, 36, 33, 39, 34, 40, 37, 35, 41, 42, 43, 44, 45, 46, 47, 48]);
D := PermList([1, 2, 3, 4, 5, 30, 31, 32, 9, 10, 11, 12, 13, 22, 23, 24, 17, 18, 19, 20, 21, 6, 7, 8, 25, 26, 27, 28, 29, 14, 15, 16, 33, 34, 35, 36, 37, 38, 39, 40, 46, 44, 41, 47, 42, 48, 45, 43]);

cube := Group(F, B, R, L, U, D);

u_cross_facelets := [34, 36, 37, 39];
u_corner_facelets := [33, 35, 38, 40];

u_cross_stab := Stabilizer(cube, u_cross_facelets, OnTuples);
u_corner_stab := Stabilizer(cube, u_corner_facelets, OnTuples);

Print("[G : u_cross_stab]: ", Index(cube, u_cross_stab), "\n");
Print("[G : u_corner_stab]: ", Index(cube, u_corner_stab), "\n");

u_face_stab := Stabilizer(u_cross_stab, u_corner_facelets, OnTuples);
Print("[u_cross_stab : u_face_stab]: ", Index(u_cross_stab, u_face_stab), "\n");
Print("[u_corner_stab : u_face_stab]: ", Index(u_corner_stab, u_face_stab), "\n");
Print("[G : u_face_stab]: ", Index(cube, u_face_stab), "\n");

middle_edges := [4, 5, 12, 13];

f2l_stab := Stabilizer(u_face_stab, middle_edges, OnTuples);
Print("[u_face_stab : f2l_stab]: ", Index(u_face_stab, f2l_stab), "\n");
Print("[G : f2l_stab]: ", Index(cube, f2l_stab), "\n");

bottom_cross_facelets := [42, 44, 45, 47];
bottom_corner_facelets := [41, 43, 46, 48];

oll_cross_stab := Stabilizer(f2l_stab, Set(bottom_cross_facelets), OnSets);
oll_corners_stab := Stabilizer(f2l_stab, Set(bottom_corner_facelets), OnSets);
oll_stab := Stabilizer(oll_cross_stab, Set(bottom_corner_facelets), OnSets);
Print("[f2l_stab : oll_cross_stab]: ", Index(f2l_stab, oll_cross_stab), "\n");
Print("[f2l_stab : oll_corners_stab]: ", Index(f2l_stab, oll_corners_stab), "\n");
Print("[f2l_stab : oll_stab]: ", Index(f2l_stab, oll_stab), "\n");

pll_cross_stab := Stabilizer(oll_stab, bottom_cross_facelets, OnTuples);
pll_corner_stab := Stabilizer(oll_stab, bottom_corner_facelets, OnTuples);
pll_stab := Stabilizer(pll_cross_stab, bottom_corner_facelets, OnTuples);

Print("[oll_stab : pll_cross_stab]: ", Index(oll_stab, pll_cross_stab), "\n");
Print("[oll_stab : pll_corner_stab]: ", Index(oll_stab, pll_corner_stab), "\n");
Print("[oll_stab : pll_stab]: ", Index(oll_stab, pll_stab), "\n");
Print("|pll_stab|: ", Size(pll_stab), "\n");
