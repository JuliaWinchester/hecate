function [pmV ] = CORR_map_mesh_to_plane_nonconforming(V,F,mF,seed_face,M,E2V,numE, reflect_mesh)
% map the mesh V,F to plane using the non-conforming method of polthier
% use the seed face to cut the mesh open
% output: the midpoint mesh and its embedding to plane

oF = F; %rememeber the face list for later

disp(size(V));
disp(size(F));

%cut out the seed face
ioutf = seed_face; % Index of face to remove because it is the cut face
outf = F(ioutf,:); % Actual vertices to remove from faces to remove
outf=sort(outf); 
disp(size(outf));
disp(outf);
F(ioutf,:)=[]; % Removes cut face from F, vertices still in V tho

[L] = CORR_compute_laplacian_tension(V,F); % V x V matrix of laplacian tensions? tension field?
L1 = L;
save('~/L1_working.mat', 'L1');
disp(cond(L1));
outf = sort(outf);
L1(outf(1),:) = []; % Removes all values in row corresponding to first removed vertex in L
L1(outf(2)-1,:) = []; % Removes all values in row corresponding to second removed vertex - 1 in L
L1rows = size(L1,1); % Number of rows in L1 (number of verts)

L1(L1rows+1,outf(1)) = 1; % Adds two new rows to L1
L1(L1rows+2,outf(2)) = 1;

b = zeros(L1rows,1);
b(L1rows+1) = -1;
b(L1rows+2) = 1;
u = L1\b;
disp(cond(L1))

disp('Just after warning')
% %with linear system
% [e_u_star] = CORR_calculate_conjugate_harmonic(F,V,u,M,E2V,numE);
%withOUT linear system
imissing_f = seed_face;
[e_u_star] = CORR_calculate_conjugate_harmonic_faster(oF,V,mF,u,M,E2V,numE,imissing_f);
disp('After conjugate harmonic')
[mu] = CORR_get_midpoint_values_of_function(oF,u, M, E2V, numE);
disp('After get midpoint values')
if(reflect_mesh==0)
    pmV = [mu e_u_star]; 
else
    pmV = [mu -e_u_star]; 
end
disp('After if statement')
