DefineConstant[ Lf = {0.54, Min 0, Max 10, Name "Fault resolution" } ];
DefineConstant[ Ls = {0.54, Min 0, Max 10, Name "Resolution near free surface" } ];
DefineConstant[ Lf_ns = {0.285, Min 0, Max 10, Name "low normal stress Fault resolution" } ];
DefineConstant[ dip = {10, Min 0, Max 90, Name "Dipping angle" } ];
DefineConstant[ start_ns = {135, Min 0, Max 280, Name "Start of low normal stress region" } ];
DefineConstant[ end_ns = {260, Min 0, Max 280, Name "End of low normal stress region" } ];

dip_rad = dip * Pi / 180.0;

h = 40;
d = 400;
/*d = 180;*/
w = d * Cos(dip_rad) / Sin(dip_rad);
w = w < d ? d : w;
d1 = 200;
d2 = 280;
Point(1) = {-w, 0, 0, h};
Point(2) = {w, 0, 0, h};
Point(3) = {w + d * Cos(dip_rad) / Sin(dip_rad), -d, 0, h};
Point(4) = {-w + d * Cos(dip_rad) / Sin(dip_rad), -d, 0, h};
Point(5) = {d * Cos(dip_rad) / Sin(dip_rad), -d, 0, h};
Point(6) = {0, 0, 0, h};
// Point(7) = {d4 * Cos(dip_rad), -d4 * Sin(dip_rad), 0, h};
// Point(8) = {d3 * Cos(dip_rad), -d3 * Sin(dip_rad), 0, h};
Point(7) = {d2 * Cos(dip_rad), -d2 * Sin(dip_rad), 0, h};
Point(8) = {d1 * Cos(dip_rad), -d1 * Sin(dip_rad), 0, h};
Line(1) = {1, 6};
Line(2) = {6, 2};
Line(3) = {2, 3};
Line(4) = {3, 5};
Line(5) = {5, 4};
Line(6) = {4, 1};
Line(7) = {7, 5};
Line(8) = {8, 7};
// Line(9) = {9, 8};
// Line(10) = {10, 9};
Line(9) = {6, 8};
Curve Loop(1) = {9, 8, 7, -4, -3, -2};
Curve Loop(2) = {9, 8, 7, 5, 6, 1};
Plane Surface(1) = {1};
Plane Surface(2) = {2};
Physical Curve(3) = {8, 9};
Physical Curve(1) = {1, 2, 4, 5};
Physical Curve(5) = {3, 6, 7};
Physical Surface(1) = {1};
Physical Surface(2) = {2};
Field[1] = MathEval;
Field[1].F = Sprintf("%g + 3e-2*(x + y*%g)^2 + 2e-3*(min(0, y/%g+280))^2", Lf, Cos(dip_rad)/Sin(dip_rad), Sin(dip_rad));
Field[2] = MathEval;
Field[2].F = Sprintf("%g + 3e-2*(x + y*%g)^2 + 2e-3*(min(0 , y/%g+%g))^2 + 2e-3*(min(0 , -1*(y/%g+%g)))^2", Lf_ns, Cos(dip_rad)/Sin(dip_rad), Sin(dip_rad), end_ns, Sin(dip_rad), start_ns);
Field[3] = MathEval;
Field[3].F = Sprintf("%g + 0.1 * sqrt(x^2 + y^2)", Ls);
Field[4] = Min;
Field[4].FieldsList = {1, 2, 3};
Background Field = 4;
Mesh.MshFileVersion = 2.2;
