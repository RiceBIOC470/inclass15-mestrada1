% Gb comments
Step1 0 No code or files of separately saved images
Step2 50 no probability files saved
Step3 50 Need to use cat function to overlay images correctly 
Step4 100
Step5 100 Can’t grade easily because you don’t provide the correct files
Step6 100 
Step7 100 
Step8 100
Overall 75

%% step 1: write a few lines of code or use FIJI to separately save the
% nuclear channel of the image Colony1.tif for segmentation in Ilastik

file = '48hColony1_DAPI.tif';
reader1 = bfGetReader(file);
iplane1 = reader1.getIndex(0,0,0)+1;
img = bfGetPlane(reader1, iplane1);
imshow(img, []);

%% step 2: train a classifier on the nuclei
% try to get the get nuclei completely but separe them where you can
% save as both simple segmentation and probabilities

% This step was performed using Ilastik

%% step 3: use h5read to read your Ilastik simple segmentation
% and display the binary masks produced by Ilastik 

simple_seg = h5read('48hColony1_DAPI_Simple Segmentation.h5', '/exported_data');
simple_seg = squeeze(simple_seg)';
imshow(simple_seg, []);

% use h5read

% (datasetname = '/exported_data')
% Ilastik has the image transposed relative to matlab
% values are integers corresponding to segmentation classes you defined,
% figure out which value corresponds to nuclei

% Value of 1 corresponds to nuclei

%% step 3.1: show segmentation as overlay on raw data

imshow(img,[]);
hold on;
imshow(simple_seg,[]);

%% step 4: visualize the connected components using label2rgb
% probably a lot of nuclei will be connected into large objects

RGB = label2rgb(simple_seg);
imshow(RGB, []);

%% step 5: use h5read to read your Ilastik probabilities and visualize

prob_img = h5read('48hColony1_DAPI_Probabilities.h5', '/exported_data');
prob_img = squeeze(prob_img(2,:,:))';
imshow(prob_img, []);

% it will have a channel for each segmentation class you defined

%% step 6: threshold probabilities to separate nuclei better

prob_thresh = prob_img > 0.99;
imshow(prob_thresh, []);


%% step 7: watershed to fill in the original segmentation (~hysteresis threshold)

conn_comp = bwconncomp(prob_thresh);
data = regionprops(conn_comp, 'Area');
area = [data.Area];
s = round(1.2*sqrt(mean(area))/pi);
nucmin = imerode(prob_thresh, strel('disk', s));
outside = ~imdilate(prob_thresh, strel('disk', 1));
basin = imcomplement(bwdist(outside));
basin = imimposemin(basin, nucmin | outside);
ws = watershed(basin);
imshow(ws, []);


%% step 8: perform hysteresis thresholding in Ilastik and compare the results
% explain the differences

% Ilastik (hysteresis method) seems to better separate cell nuclei as opposed to the MATLAB
% method of erosion watershed. Additionally, Ilastik shows better edge
% detection. 

%hysteresis thresholding thresholds at a high threshold (expansion, look
%this up)

%% step 9: clean up the results more if you have time 
% using bwmorph, imopen, imclose etc
