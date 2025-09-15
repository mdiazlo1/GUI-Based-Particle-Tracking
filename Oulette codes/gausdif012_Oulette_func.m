function vtracks = gausdif012_Oulette_func( tracks,T )
%GAUSDIF012_Oulette_FUNC Gaussian smoothing using 0th, 1st and 2nd
%derivative of Gaussian to obtain smoothed trajectories, velocities and
%acceleration
%version using trajectories computed by Oulette, x and y seperately.
% tracks	x OR y data
% T         filter width, filter will be on the domain [-T,T] and have a
%           standard-deviation of T/1.5

sig = T/1.5;
%% Define Kernels
% Discrete Gaussian:
G = 1/(sig*sqrt(2*pi)) .* exp(-(-T:T).^2/(2*sig^2));
% normalize:
G = G/sum(G);

% first order derivative of Gaussian:
dG = - (-T:T)/(sig^3*sqrt(2*pi)) .* exp(-(-T:T).^2/(2*sig^2));
% normalize as A*dG+B
% using the conditions sum(A*dG+B) = 0, sum((-T:T)*(A*dG+B)) = 1
B = 0;
A = -1/sum((-T:T).*dG);
dG = A*dG+B;
ntracks = numel(tracks);
%Initialize vtracks structure
vtracks = repmat(struct('len',[],'X',[],'Y',[],'T',[],'U',[], ...
     'V',[]),ntracks,1);

%% Position
for TrackNum = 1:numel(tracks)
    % convolution:
    x = conv(tracks(TrackNum).X,G); y = conv(tracks(TrackNum).Y,G);

    % extract unbiased (i.e. not at the edge) points and change shape:
    x = x(2*T+1:end-2*T); y = y(2*T+1:end-2*T);

    %% velocity
    % convolution:
    u = conv(tracks(TrackNum).X,dG); v = conv(tracks(TrackNum).Y,dG);

    % extract unbiased (i.e. not at the edge) points and change shape:
    u = u(2*T+1:end-2*T); v = v(2*T+1:end-2*T);
    t = tracks(TrackNum).T;
    t = t(T+1:end-T);

    vtracks(TrackNum) = struct('len',numel(x), ...
        'X',x, ...
        'Y',y, ...
        'T',t, ...
        'U',u, ...
        'V',v);
end
% %% acceleration
% % second order derivative of Gaussian:
% ddG = - (sig^2-(-T:T).^2)/(sig^5*sqrt(2*pi)) .* exp(-(-T:T).^2/(2*sig^2));
% % normalize as A*ddG+B:
% % using the conditions sum(A*ddG+B) = 0, sum((-T:T)^2/2*(A*ddg+B)) = 1
% A = 2/(sum((-T:T).^2.*ddG) - 1/numel(-T:T) * sum(ddG) * sum((-T:T).^2));
% B = -A/numel(-T:T) * sum(ddG);
% ddG = A*ddG+B;
%
% % convolution:
% a = conv(tracks',ddG);
%
% % extract unbiased (i.e. not at the edge) points and change shape:
% a = a(2*T+1:end-2*T)';
%
% % I need this part for concatenation:
% if isempty(a)
%     a = [];
% end

end

