function Img = HomomorphicFilter(Img,sigma,alpha,beta,bitdepth,fig)
%https://blogs.mathworks.com/steve/2013/06/25/homomorphic-filtering-part-1/
ClassType = class(Img(:,:,1));
if nargin < 6
    fig = uifigure;
end
d = uiprogressdlg(fig,'Title','Please Wait','Message','Adjusting Image Lighting'...
    ,'Indeterminate','on');
drawnow
parfor i = 1:size(Img,3)
    %Convert image to double and then put into log domain
    I = Img(:,:,i);
    I = im2double(I);

    I = log(1+I);
    M = 2*size(I,1) + 1;
    N = 2*size(I,2) + 1;
    [X, Y] = meshgrid(1:N,1:M);
    centerX = ceil(N/2);
    centerY = ceil(M/2);
    gaussianNumerator = (X - centerX).^2 + (Y - centerY).^2;
    H = exp(-gaussianNumerator./(2*sigma.^2));
    H = 1 - H;

    H = alpha + beta*H;

    H = fftshift(H);
    %Now Pad I
    paddedI = padarray(I,ceil(size(I)/2)+1,'replicate');
    paddedI = paddedI(1:end-1,1:end-1);

    If = fft2(paddedI);
    Iout = real(ifft2(H.*If));

    Iout = Iout(ceil(M/2)-size(I,1)/2+1:ceil(M/2)+size(I,1)/2, ...
        ceil(N/2)-size(I,2)/2+1:ceil(N/2)+size(I,2)/2);

    Ihmf = exp(Iout) - 1;
    Ihmf = rescale(Ihmf,0,2^bitdepth);
    Img(:,:,i) = cast(Ihmf,ClassType);
end
close(d)
end