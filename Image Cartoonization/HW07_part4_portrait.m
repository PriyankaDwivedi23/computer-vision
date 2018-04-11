%HW07_part_4
%Author : Priyanka Dwivedi(pd6741@g.rit.edu)
%The following program own portrait and cartoonise it.

function HW07_part4_portrait(color_space)

% Cluster image to see if number of objects is identifyable...

addpath( './TEST_IMAGES'     );
addpath( '../TEST_IMAGES'    );
addpath( '../../TEST_IMAGES' );

target_max_dimension = 420;     
variable_needs_a_better_name_ford = [1/10 ] ;     
   
%default image if not passed
    if ( nargin < 1 )
        fn_in = 'IMG_1379.jpg';
        color_space = 'ycbcr';
    end
   
    %read the Image
    im_orig         = imread( fn_in );
    dims            = size( im_orig );
    
    % Because kMeans takes a long time to run, resample the image so it is smaller:
    var_name_rvec   = ([1 1] * target_max_dimension) ./ dims(1:2);
    var_name_rfr    = min( var_name_rvec );
    
    %Resize image 
    im              = imresize( im_orig, var_name_rfr );    
    dims            = size( im );
    
    %To compute edge strength
    image_gray = rgb2gray(im);
    Gmag = edge(image_gray,'Sobel');

    % Note: % Some amount of smear here.  
    % This is a hidden parameter for your clustering algorithm.
    fltr        = fspecial( 'gauss', [15 15], 1);         
    im          = imfilter( im, fltr, 'same', 'repl' );
    
    %To check various Colorspace
    if (strcmp(color_space,'ycbcr'))
        im_ycc      = rgb2ycbcr( im );   
        [xs, ys]     = meshgrid( 1:dims(2), 1:dims(1) );
        %Only Y channel
        im_ch1     = im_ycc(:,:,1);
        %Only Cb channel
        im_ch2        = im_ycc(:,:,2);
        %Only Cr channel
        im_ch3        = im_ycc(:,:,3);
   elseif (strcmp(color_space,'hsv'))
        %convert rgb to hsv
        im_hsv = rgb2hsv(im);
        [xs, ys]     = meshgrid( 1:dims(2), 1:dims(1) );
        %only H channel
        im_ch1 = im_hsv(:,:,1);
        %only S channel
        im_ch2 = im_hsv(:,:,2);
        %only V channel
        im_ch3 = im_hsv(:,:,3);
    elseif (strcmp(color_space,'lab'))
        %convert rgb to lab
        im_lab = rgb2lab(im);
        [xs, ys]     = meshgrid( 1:dims(2), 1:dims(1) );
        %only L channel
        im_ch1 = im_lab(:,:,1);
        %only a channel
        im_ch2 = im_lab(:,:,2);
        %only b channel
        im_ch3 = im_lab(:,:,3);
    else
        [xs, ys]     = meshgrid( 1:dims(2), 1:dims(1) );
        %only R channel
        im_ch1 = im(:,:,1);
        %only G channel
        im_ch2 = im(:,:,2);
        %only B channel
        im_ch3 = im(:,:,3);
 
        
    end
    
    %dist measures
    dist_names = {'SqEuclid' };

    %k = 128
    n_clusters = 6;
        
        % What is this for?
        %weights to multiplied to change values in row and col
        for wt = variable_needs_a_better_name_ford
            
            %To use different distance measure
            for dist_idx = 1:length(dist_names)
                
                % What happens with the curly braces here??
                %It takes element from cell array i.e distance measure
                %that will be used to calculate distance between object and 
                %its cluster centroid using different formula i.e Cityblock,
                %SqEuclid given in the cell array.
                dist_name = dist_names{ dist_idx };
                

                % What is happening here?? in detail... 
                %change the attribute along row,col,red,green,blue               
                attributes  = [ xs(:)*wt, ys(:)*wt, double(im_ch1(:)), double(im_ch2(:)), double(im_ch3(:)),double(Gmag(:))];

                % What makes this take longer??
                %It depends on the number of clusters and # iteration
                %performed until no change in values of clusters 
                tic;
                [cluster_id, cluster_centers] = kmeans( attributes, n_clusters, 'Dist', dist_name, 'Replicate', 3, 'MaxIter', 250 );
                toc
                %reshape the cluster
                im_new     = reshape( cluster_id, dims(1), dims(2) );
                
                %3:5 means RGB values should be considered as attributes
                %may have other values in the set
                if (strcmp(color_space,'ycbcr'))
                    quest= uint8( cluster_centers( :, 3:5 ) ); 
                    zebra = ycbcr2rgb( quest );
                elseif (strcmp(color_space,'hsv'))
                    quest= cluster_centers( :, 3:5 ) ; 
                    zebra = hsv2rgb(quest);
                elseif (strcmp(color_space,'lab'))
                    quest = cluster_centers( :, 3:5 );
                    zebra = lab2rgb(quest);
                else
                    quest= uint8( cluster_centers( :, 3:5 ) ); 
                    zebra = quest;
                end 
                % Convert to double to increase precision
                willow      = im2double(zebra);                      
                x_over = round( rand(1,1)*400 + 100 );
                y_up   = round( rand(1,1)*100 + 10 );
                figure('Position', [x_over, y_up, 600, 600] );
                %display image
                imagesc( im_new );
                axis image;
                ttl_test = sprintf('k = %d,  distance wt = %8.5f,  dist name = %s , colorspace=%s', n_clusters, wt, dist_name,color_space);
                title( ttl_test, 'FontSize', 14 );
                colorbar
                colormap( willow );
                axis image;
                drawnow;

                % How to save a colormapped image:
                imwrite( im_new, willow, 'TEMP_IMAGE_FILENAME.png' );

                % What are the relative file sizes of the images??
                ls -l 'TEMP_IMAGE_FILENAME.png';

            end
        end
   fprintf('done\n');
end


