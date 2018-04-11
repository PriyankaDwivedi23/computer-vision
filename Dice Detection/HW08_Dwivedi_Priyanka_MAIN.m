%HW08
%Author : Priyanka Dwivedi(pd6741@g.rit.edu)
%The following program takes image and find dots on every dice using image
%segmentation.
function HW08_Dwivedi_Priyanka_MAIN

srcFiles = dir('./TEST_IMAGES/*.jpg');
for i = 1 : length(srcFiles)
    filename = strcat('./TEST_IMAGES/',srcFiles(i).name);
    disp(filename);
    I = imread(filename);
    %read image
    im = im2double(I);
    figure, imshow(im),title('Original Image');
    %get rid of red letter on dice using red channel
    im_r  = im(:,:,1);
    figure, imshow(im_r),title('Red channel to get rid of red letter on dice');
    %to remove junk from background
    threshold = graythresh(im_r);
    disp(threshold);
    %get rid of junk and get binary image
    im_bw = bwareaopen(im_r>0.9,255 );
    %display red boundary around every dice
    figure,imshow(im_bw),title('dice');
    hold on
    [B,L,N,A] = bwboundaries(im_bw);
    for im_bound=1:length(B)
        boundary = B{im_bound};
        if(im_bound <= N)
            plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2);
        end
    end
    %determine connected components
    label = bwlabel(im_bw);
    max(max(label))
    %get the count of dice from bwconn
    count_dice = max(max(label));
    %sum will store no of 1-6 in the image
    sum = 0;
    sum1=0;
    sum2=0;
    sum3=0;
    sum4=0;
    sum5=0;
    sum6=0;
    sum_unknown = 0;
    %iterate each dice and count the number of dots on each dice
    for dice = 1 : max(max(label))
        %get each dice
        current_dice = label== dice;
        %remove dot on dice
        im_fill = imfill(current_dice,'holes');
        %invert current dice image
        current_i = ~current_dice;
        %take the dice without dot and & with negation of current dice to get
        %only dots with black background
        im_onlydots = im_fill & current_i;
        %remove white on dice and get only the dots
        dots = bwareaopen(im_onlydots>0.9, 255);
        %get the connected componnent
        dots_cc = bwconncomp(dots);
        %count the dots
        count_dots = dots_cc.NumObjects;
        %get the count of dots on each dice and sum
        sum = sum + count_dots;
        %display the dice with number of dot counts
        figure, imshow(current_dice),title(sprintf('Dice %d has %d dots',dice,count_dots))
        hold on
        [B,L,N,A] = bwboundaries(current_dice);
        for im_bound=1:length(B)
            boundary = B{im_bound};
            if(im_bound <= N)
                plot(boundary(:,2), boundary(:,1), 'r','LineWidth',2);
            end
        end
        %get the count of 1-6 from the dice
        switch(count_dots)
            case 1
                sum1 = sum1 + 1;
                
            case 2
                sum2 = sum2 + 1;
                
            case 3
                sum3 = sum3 + 1;
                
            case 4
                sum4 = sum4  + 1;
                
            case 5
                sum5 = sum5 + 1;
                
            case 6
                sum6 = sum6 + 1;
                
            otherwise
                sum_unknown = sum_unknown+1;
        end
        
    end
    %display the dice
    fprintf('Input File Name : %s\n', filename);
    fprintf('Number of dice  : %i\n',count_dice);
    fprintf('Number of 1''s  : %i\n',sum1);
    fprintf('Number of 2''s  : %i\n',sum2);
    fprintf('Number of 3''s  : %i\n',sum3);
    fprintf('Number of 4''s  : %i\n',sum4);
    fprintf('Number of 5''s  : %i\n',sum5);
    fprintf('Number of 6''s  : %i\n',sum6);
    fprintf('Number of unknown : %i\n',sum_unknown);
    fprintf('Total of all dots :  %i\n',sum)
    
    
    
    
    
end

end