% HW09-golf
%Author : Priyanka Dwivedi(pd6741@g.rit.edu)
%The following program perform classification for golf balls and grass.
function HW09_pd6741_FIND_GOLF_BALLS(fn,interactive)
addpath('../TEST_IMAGES');
addpath('../../TEST_IMAGES');
addpath('./TEST_IMAGES/');
if nargin < 1
    fn = 'IMG_0842__WHITE_GOLFBALLS__smr.jpg';
    interactive = 0;
end
%read the image
im_rgb = im2double(imread( fn ));
if (interactive )
    figure('Position',[10 10 1024 768]);
    imshow( im_rgb ),title('SELECT FOREGROUND OBJECT and hit return to continue ');
    [x_fg, y_fg] = ginput();
    imshow( im_rgb ),title('SELECT BACKGROUND OBJECT and hit return to continue ... ');
    [x_bg, y_bg] = ginput();
    if (strcmp(fn , 'IMG_0828__COLOR_GOLFBALLS__smr.jpg'))
        save IMG_0828__COLOR_GOLFBALLS__smr
    else
        if (strcmp(fn , 'IMG_0842__WHITE_GOLFBALLS__smr.jpg'))
            save IMG_0842__WHITE_GOLFBALLS__smr
        end
    end
else
    if (strcmp(fn , 'IMG_0828__COLOR_GOLFBALLS__smr.jpg'))
        load IMG_0828__COLOR_GOLFBALLS__smr
    else
        if (strcmp(fn , 'IMG_0842__WHITE_GOLFBALLS__smr.jpg'))
            load IMG_0842__WHITE_GOLFBALLS__smr
        end
    end
    
end
%blur image
filter = fspecial('gaussian',[15 15],8);
im_rgb        = imfilter( im_rgb, filter , 'same', 'repl' );
%use disk filter
filter = fspecial( 'disk', 6 );
im_rgb = imfilter( im_rgb, filter, 'same', 'repl' );
%use hsv color space
im_hsv      = rgb2hsv( im_rgb );
%get indices of foreground and background
fg_indices  = sub2ind( size(im_hsv), round(y_fg), round(x_fg) );
bg_indices  = sub2ind( size(im_hsv), round(y_bg), round(x_bg) );
%get saturation channel
im_saturation       = im_hsv(:,:,2);
%get value channel
im_value       = im_hsv(:,:,3);
%get edge strength
Gmag = edge(im_saturation,'Sobel');
%add edge strength to image
im_rgb = im_rgb + Gmag;
figure,imshow(im_rgb),title('With filter and edge strength');
fg_sat        = im_saturation( fg_indices );
fg_value        = im_value( fg_indices );
bg_sat        = im_saturation( bg_indices );
bg_value       = im_value( bg_indices );
% COMPUTE COVARIANCE FOR FG POINTS IN ab SPACE:
fg_sv       = [ fg_sat fg_value ];                    % This forms a matrix of the two features of the
% foreground object.
%compute mean
mean_fg     = mean( fg_sv );
%compute covariance
cov_fg      = cov( fg_sv );
bg_sv       = [ bg_sat bg_value ];            % This forms a matrix of the two features of the
% foreground object
mean_bg     = mean( bg_sv );            % Compute mean
cov_bg      = cov( bg_sv );             %compute covariance

im_sv       = [ im_saturation(:) im_value(:) ];
%compute mahalanobis distance
mahal_fg    = ( mahal( im_sv, fg_sv ) ) .^ (1/2);
mahal_bg    = ( mahal( im_sv, bg_sv ) ) .^ (1/2);
%  Classify as Class 0 (golf) if distance to FG is < distance to BG.
class_0     = mahal_fg < mahal_bg;
class_im    = reshape( class_0, size(im_saturation,1), size(im_saturation,2) );
figure('Position',[10 10 1024 768]);
subplot(2,2,1);
original_image = im2double(imread(fn));
imagesc(original_image);
axis image;
title('Original Image', 'FontSize', 20, 'FontWeight', 'bold' );
%temporary classified image
subplot(2,2,2);
imagesc( class_im );
axis image;
colormap(gray);
title('TEMP Image of Classification ', 'FontSize', 20, 'FontWeight', 'bold' );
%histogram
subplot(2,2,3);
fg_dists        = mahal_fg;
fg_dists_cls0   = fg_dists( class_0 );
mmax            = max( fg_dists_cls0 );
mmin            = min( fg_dists_cls0 );
edges           = mmin : (mmax-mmin)/100 : mmax;
[freqs bins]    = histc( fg_dists, edges );
bar( edges, freqs );
aa = axis();
title('Histogram', 'FontSize', 20, 'FontWeight', 'bold' );
%  Form a model of the foreground Mahalanobis distance:
fg_dists        = mahal_fg;
fg_dists_cls0   = fg_dists(class_0);
dist_mean       = mean( fg_dists_cls0 );
dist_std_01     = std(  fg_dists_cls0 );
% Toss everything outside of one standard deviation, and re-adjust the mean value:
b_inliers       = ( fg_dists_cls0 <= (dist_mean + dist_std_01) ) & ( fg_dists_cls0 >= (dist_mean - dist_std_01));
the_inliers     = fg_dists_cls0( b_inliers );
dist_mean       = mean( the_inliers );

%  Use a distance to target variable as rules for inclusion:
%  We could do better than this by adding some additional tolerance.
%
threshold       = dist_mean ;
guess_cls0      = fg_dists < threshold;
% Change the shape of the classification to look like an image:
class_im        = reshape( guess_cls0, size(im_saturation,1), size(im_saturation,2) );

subplot(2,2,4);
imagesc( class_im );
title('Classified Image', 'FontSize', 20, 'FontWeight', 'bold' );



end



