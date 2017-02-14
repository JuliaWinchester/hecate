function chunk = chunk_idx(x, y, n, chunkSize)
% CHUNK_IDX - Returns group number for xy comparison of n entities by chunkSize

chunk = ceil(((x-1)*n+y)/chunkSize);

end