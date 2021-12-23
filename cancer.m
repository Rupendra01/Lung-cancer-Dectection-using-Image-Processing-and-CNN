function varargout = cancer(varargin)
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @cancer_OpeningFcn, ...
                   'gui_OutputFcn',  @cancer_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
function cancer_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject;
guidata(hObject, handles);
% create an axes that spans the whole gui
ah = axes('unit', 'normalized', 'position', [0 0 1 1]); 
% import the background image and show it on the axes
bg = imread('project_image1.jpg');
imagesc(bg);
% prevent plotting over the background and turn the axis off
set(ah,'handlevisibility','off','visible','off')
% making sure the background is behind all the other uicontrols
uistack(ah, 'bottom');


function varargout = cancer_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output;

function pushbutton1_Callback(hObject, eventdata, handles)
global I
clc
[filename, pathname] = uigetfile('*.jpg', 'Pick an Image');
     if isequal(filename,0) | isequal(pathname,0)
      
   warndlg('File is not selected');
           else
              I=imread(filename);
      axes(handles.axes1)
      imshow(I);
      title 'Input Image'     
    end
title 'Input Lung Image'

function pushbutton2_Callback(hObject, eventdata, handles)
global I
t=rgb2gray(I);
he=histeq(t);

axes(handles.axes2);
imshow(he);
title 'Histogram Equalization'
function pushbutton3_Callback(hObject, eventdata, handles)
global I
t=rgb2gray(I);
he=histeq(t);
threshold = graythresh(he);
bw = im2bw(he,threshold);

axes(handles.axes3);
imshow(bw)
title 'Segmentation by Thresholding'

function pushbutton4_Callback(hObject, eventdata, handles)
global I
t=rgb2gray(I);
he=histeq(t);
threshold = graythresh(he);
bw = im2bw(he,threshold);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(bw), hy, 'replicate');
axes(handles.axes4);
imshow(Iy,[]),

title('Filtered Image')

function pushbutton5_Callback(hObject, eventdata, handles)
global I
t=rgb2gray(I);
he=histeq(t);
threshold = graythresh(he);
bw = im2bw(he,threshold);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(bw), hy, 'replicate');
se = strel('line',11,90);
bw2 = imdilate(Iy,se);
axes(handles.axes5);
imshow(bw2), 
title('Dilated')

function pushbutton6_Callback(hObject, eventdata, handles)

global I
t=rgb2gray(I);
he=histeq(t);
threshold = graythresh(he);
bw = im2bw(he,threshold);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(bw), hy, 'replicate');
se = strel('line',11,90);
bw2 = imdilate(Iy,se);

BW5 = imfill(bw2,'holes');
  axes(handles.axes6);
  imshow(BW5)
 
 title 'Image Filling'
function pushbutton7_Callback(hObject, eventdata, handles)
global I
t=rgb2gray(I);
he=histeq(t);
threshold = graythresh(he);
bw = im2bw(he,threshold);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(bw), hy, 'replicate');
se = strel('line',11,90);
bw2 = imdilate(Iy,se);
BW5 = imfill(bw2,'holes');
  disp ('Contrast Value');
  cmap = contrast(BW5);

 disp ('Entropy Value');
 E = entropy(BW5)
 set(handles.edit2,'string',num2str(E));

 glcm = graycomatrix(BW5,'Offset',[2 0]);

function pushbutton8_Callback(hObject, eventdata, handles)
global I
t=rgb2gray(I);
he=histeq(t);
threshold = graythresh(he);
bw = im2bw(he,threshold);
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(bw), hy, 'replicate');
se = strel('line',11,90);
bw2 = imdilate(Iy,se);
BW5 = imfill(bw2,'holes');
C=BW5;
c1=mean(C);
c2=var(double(C));
d=C;

GLCM2 = graycomatrix(d,'Offset',[2 0;0 2]);
c4 = graycoprops(GLCM2,{'contrast','homogeneity','Energy'});
set(handles.edit4,'string',num2str(min(c4.Energy)));
c24= graycoprops(GLCM2,'contrast');
set(handles.edit3,'string',num2str(min(c24.Contrast)));
c5=corr(double(d));
c6=c5(1,:);
c7=c1;
c8=c2;

c9=[c6 c7 c8];
load OvarianCancerQAQCdataset
[feat,stat] = rankfeatures(Y,grp,'CRITERION','ttest','NUMBER',100);
P = double(Y(feat, :));      % Inputs
Cidx = strcmp('Cancer',grp); % Logical index vector for Cancer samples
T = double(Cidx)';           % Targets
rand('seed', 672880951)
net = newff(P,T,5);                        % create neural network
[net,tr] = train(net,P,T); % train network
testInputs = P(:,tr.testInd);
testTargets = T(:,tr.testInd);

out = round(sim(net,testInputs));           % Get response of trained network
diff = [testTargets - 2*out];

detections = length(find(diff==-1));        % cancer samples classified as cancerous
false_positives = length(find(diff==1));    % cancer samples classified as normal
true_positives = length(find(diff==0));     % normal samples classified as normal
false_alarms = length(find(diff==-2));      % normal samples classified as cancerous

Nt = size(testInputs,2);                    % Number of testing samples
fprintf('Total testing samples: %d\n', Nt);

%classification matrix
cm = [detections false_positives; false_alarms true_positives]
cm_p = (cm ./ Nt) .* 100   
fprintf('Percentage Correct classification   : %f%%\n', 100*(cm(1,1)+cm(2,2))/Nt);
fprintf('Percentage Incorrect classification : %f%%\n', 100*(cm(1,2)+cm(2,1))/Nt);

if ((max(c24.Contrast))>2)
    set(handles.edit1,'string','Lung Cancer Affected Image');
else
    set(handles.edit1,'string','Normal Image');
end




function edit1_Callback(hObject, eventdata, handles)
function edit1_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit2_Callback(hObject, eventdata, handles)

function edit2_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit3_Callback(hObject, eventdata, handles)

function edit3_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit4_Callback(hObject, eventdata, handles)

function edit4_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)

function edit5_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit6_Callback(hObject, eventdata, handles)
function edit6_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit7_Callback(hObject, eventdata, handles)

function edit7_CreateFcn(hObject, eventdata, handles)
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end






function edit9_Callback(hObject, eventdata, handles)

function edit9_CreateFcn(hObject, eventdata, handles)

if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
