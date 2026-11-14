function block_lr = behavior_learning_rates(data)
%BEHAVIOR_LEARNING_RATES Original per-block update-on-error GLM, with intercept.
N = numel(data);
block_lr = nan(N,4);
for n = 1:N
    bucket = double(data{n}.bucket);
    bag = double(data{n}.bag);
    update = diff(bucket);
    delta = bag(1:end-1,:) - bucket(1:end-1,:);
    X = []; I = [];
    for c = 1:4
        X = blkdiag(X,delta(:,c));
        I = blkdiag(I,ones(49,1));
    end
    b = glmfit([X I],update(:),'normal','constant','off');
    block_lr(n,:) = b(1:4);
end
end
