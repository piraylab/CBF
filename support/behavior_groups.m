function groups = behavior_groups(lr)
%BEHAVIOR_GROUPS Figure 3 classification from human block learning rates.
% Same sample-mean thresholds described in Section 4.2 of the manuscript.
bv=lr*[-1;1;-1;1]/2;
bs=lr*[-1;-1;1;1]/2;
vol_blind=(bv<mean(bs)) & (bs<mean(bs));
sto_blind=(bs>mean(bv)) & (bv>mean(bv));
groups=table(vol_blind,sto_blind,bv,bs);
end
