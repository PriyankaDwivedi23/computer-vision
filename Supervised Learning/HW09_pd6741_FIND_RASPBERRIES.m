% HW09-raspberry
%Author : Priyanka Dwivedi(pd6741@g.rit.edu)
%The following program performs classification for raspberry and 
function HW09_pd6741_FIND_RASPBERRIES(fn,interactive)
addpath('../TEST_IMAGES');
addpath('../../TEST_IMAGES');
addpath('./TEST_IMAGES/');
if nargin < 2 
    fn = 'IMG_0190__RASPBERRIES__smr.jpg';
    interactive  = 0;
end

%read the image
im = im2double(imread(fn));
if interactive
    %select the foreground points using ginput
    figure,imshow( im ),title('Select Foregrounds objects and hit return to end');
    [x_fg, y_fg] = ginput();
    %select backgrounf points using ginput
    figure, imshow( im ),title('Select Background objects and hit return to end ');
    [x_bg, y_bg] = ginput();
    %save points in user_data
    save raspberry_data
else
    load raspberry_data
end
%Use lab color channel 
im_lab      = rgb2lab( im );
im_a        = im_lab(:,:,2);
im_b        = im_lab(:,:,3);
%get fg indices
fg_indices  = sub2ind( size(im_lab), round(y_fg), round(x_fg) );
%get bg indices
bg_indices  = sub2ind( size(im_lab), round(y_bg), round(x_bg) );
fg_a        = im_a( fg_indices );
fg_b        = im_b( fg_indices );
bg_a        = im_a( bg_indices );
bg_b        = im_b( bg_indices );
%compute mean and covariance for foreground object
fg_ab       = [ fg_a fg_b ];  % This forms a matrix of the two features of the foreground object.
%compute the mean
mean_fg     = mean( fg_ab ); 
%compute covariance
cov_fg      = cov( fg_ab );
%compute mean and covariance for background object
bg_ab       = [ bg_a bg_b ]; % This forms a matrix of the two features of the background object.
%compute the mean
mean_bg     = mean( bg_ab ); 
%compute covariance
cov_bg      = cov( bg_ab );             
%Form matrix of two channel a and b
im_ab       = [ im_a(:) im_b(:) ];
%Now Use Mahalanobis function 
mahal_fg    = ( mahal( im_ab, fg_ab ) ) .^ (1/2);
mahal_bg    = ( mahal( im_ab, bg_ab ) ) .^ (1/2);
%classify as Class A for foreground object 
%if distance to FG is < distance to BG then it is class A
class_0     = mahal_fg < mahal_bg;
class_im    = reshape( class_0, size(im_a,1), size(im_a,2) );
figure('Position',[10 10 1024 768]);
subplot(2,2,1);
imagesc(im);
axis image;
title('Original Image ', 'FontSize', 20, 'FontWeight', 'bold' );
%classified image 
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
title('Histogram ', 'FontSize', 20, 'FontWeight', 'bold' );
%form model for mahalanobis distance
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
threshold       = dist_mean;
guess_cls0      = fg_dists < threshold;
% Change the shape of the classification to look like an image:
class_im        = reshape( guess_cls0, size(im_a,1), size(im_a,2) );
%get rid of small dot which is noise
disk = strel('disk',4);
class_im = imopen(class_im,disk);
subplot(2,2,4);
imagesc( class_im );
title('Classified Image', 'FontSize', 20, 'FontWeight', 'bold' );
    

end

