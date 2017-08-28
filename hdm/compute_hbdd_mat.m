function [HBDDMat, HBDM] = compute_hbdd_mat( U, lambda, sqrtInvD, vIdxCumSum )
% COMPUTE_HBDD - Calculate the Horizontal Base Diffusion Distance
%                The output is a distance matrix where the (i,j)-th entry
%                is the Horizontal Base Diffusion Distance between the i-th
%                mesh and the j-th mesh. In particular, HBDDMat should be a
%                symmetric matrix with all entries nonnegative.

GroupSize = length(vIdxCumSum);
sqrtInvD(isinf(sqrtInvD)) = 0;
BundleHDM = sqrtInvD*U(:,2:end);
HBDM = zeros(GroupSize, nchoosek(size(BundleHDM,2),2));
for j=1:GroupSize
    BundleHDM_Block = normc(BundleHDM(vIdxCumSum(j,1):vIdxCumSum(j,2),:));
    BundleHDM_Block = BundleHDM_Block*sparse(1:(size(U,2)-1), 1:(size(U,2)-1), sqrt(lambda(2:end)));
    HBDM(j,:) = pdist(BundleHDM_Block', @(x,y) y*x');
end
HBDDMat = pdist(HBDM);

end

