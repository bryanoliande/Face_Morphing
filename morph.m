  %
  % morphing script
  %

  % load in two images...
  I1 = im2double(imread('equilateral.jpg'));
  %make 2nd one same size as first
  I2 = im2double( imresize( imread('scalene.jpg'), [size(I1,1) size(I1,2)]) );

  % get user clicks on keypoints using either ginput or cpselect tool
   [pts_img1, pts_img2] = cpselect(I1, I2, 'wait', true);

  % the more pairs of corresponding points the better... ideally for 
  % faces ~20 point pairs is good include several points around the
  % outside contour of the head and hair.
 
  % you may want to save pts_img1 and pts_img2 out to a .mat file at
  % this point so you can easily reload it without having to click
  % again. 
  
  save hw5pts.mat pts_img1 pts_img2
  load hw5pts.mat


  % append the corners of the image to your list of points
  % this assumes both images are the same size and that your
  % points are in a 2xN array
  size(I1)
  size(I2)
  pts_img1 = pts_img1' %20x2 to 2x20
  pts_img2 = pts_img2' %20x2 to 2x20
  [h,w,~] = size(I1);
  pts_img1 = [pts_img1 [0 0]' [w 0]' [0 h]' [w h]'];
  pts_img2 = [pts_img2 [0 0]' [w 0]' [0 h]' [w h]'];

  % generate triangulation 
  pts_halfway = 0.5*pts_img1 + 0.5*pts_img2;
  
  dim1 = pts_halfway(1,:)';
  dim2 = pts_halfway(2,:)';
  
  tri = delaunay(dim1, dim2);

  % now produce the frames of the morph sequence
  for fnum = 1:61
    t = (fnum-1)/60;

    % intermediate key-point locations
    pts_target = (1-t)*pts_img1 + t*pts_img2;                

    %warp both images towards target
    I1_warp = warp(I1,pts_img1,pts_target,tri);              

    I2_warp = warp(I2,pts_img2,pts_target,tri);              % warp image 2
    Iresult = (1-t)*I1_warp + t*I2_warp;                     % blend the two warped images
    % blend the two warped images
    Iresult = (1-t)*I1_warp + t*I2_warp;                     

    % display frames
    figure(1); clf; imagesc(Iresult); axis image; drawnow;   

    % alternately save them to a file to put in your writeup
    imwrite(Iresult,sprintf('frame_%2.2d.jpg',fnum),'jpg');   
  end
