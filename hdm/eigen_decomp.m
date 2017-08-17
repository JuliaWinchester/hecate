function [U, lambda, sqrtInvD] = eigen_decomp(H, diffMatrixSize, eigCols)
% EIGEN_DECOMP - Eigenvector and eigenvalue decomposition

% sqrtD = sparse(1:diffMatrixSize,1:diffMatrixSize,sqrt(sum(H)));
% invD = sparse(1:diffMatrixSize,1:diffMatrixSize,1./sum(H));
sqrtInvD = sparse(1:diffMatrixSize,1:diffMatrixSize,1./sqrt(sum(H)));
H = sqrtInvD*H*sqrtInvD;
H = (H+H')/2;

eigopt = struct('isreal',1,'issym',1,'maxit',5000,'disp',0);
tic;
[U, lambda] = eigs(H, eigCols+1, 'LM', eigopt);
lambda = diag(lambda);
disp(['Eigen-decomp completed in ' num2str(toc) ' seconds']);

end