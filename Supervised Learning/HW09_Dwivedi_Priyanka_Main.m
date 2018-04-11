% HW09-main
%Author : Priyanka Dwivedi(pd6741@g.rit.edu)
%The following is main program for calling function for images.

function HW09_Dwivedi_Priyanka_Main

rasp_img = 'IMG_0190__RASPBERRIES__smr.jpg';
golf_img = {'IMG_0828__COLOR_GOLFBALLS__smr.jpg','IMG_0842__WHITE_GOLFBALLS__smr.jpg'};
%find raspberry 
%@param1 : image
%@param2 : interactive(if 0 load and if 1 ask for points from user)
HW09_pd6741_FIND_RASPBERRIES(rasp_img,0);
%find golf balls
%@param1 : image
%@param2 : interactive(if 0 load and if 1 ask for points from user)
HW09_pd6741_FIND_GOLF_BALLS(golf_img{1},0);
HW09_pd6741_FIND_GOLF_BALLS(golf_img{2},0);

end