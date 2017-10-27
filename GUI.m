function varargout = GUI(varargin)
% GUI MATLAB code for GUI.fig
%      GUI, by itself, creates a new GUI or raises the existing
%      singleton*.
%
%      H = GUI returns the handle to a new GUI or the handle to
%      the existing singleton*.
%
%      GUI('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in GUI.M with the given input arguments.
%
%      GUI('Property','Value',...) creates a new GUI or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before GUI_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to GUI_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above saveText to modify the response to help GUI

% Last Modified by GUIDE v2.5 12-Mar-2013 11:11:29

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @GUI_OpeningFcn, ...
                   'gui_OutputFcn',  @GUI_OutputFcn, ...
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
% End initialization code - DO NOT EDIT

% called at GUI creation
function GUI_OpeningFcn(hObject, eventdata, handles, varargin)
handles.output = hObject; % choose default command line output for GUI

handles.dbase = database; % instance of database created
handles.model = get(handles.modelselect, 'String'); % gets list of models
contents = cellstr(get(handles.citymenu, 'String')); % gets city names
for i = 1:size(contents,1) % creates struct of cities
   handles.arr{i,1} = city(handles.dbase, contents{i});
end
citymenu_Callback(handles.citymenu, eventdata, handles); % loads city data at GUI initiation
handles = guidata(hObject);
modelselect_Callback(handles.modelselect, eventdata, handles); % loads model data at GUI initiation
handles = guidata(hObject);
[X Y] = returnDimMap(handles.selectedcity); % gets bounds of grid
set(handles.map, 'XLim', [0 X], 'YLim', [0 Y]); % sets bounds of axes

guidata(hObject, handles); % update handles structure



% called when GUI is closed
function figure1_DeleteFcn(hObject, eventdata, handles)
if (isfield(handles, 'selectedcity')) % checks if grid of selected city exists
    outputGrid(handles.selectedcity); % updated grid of selected city
end

% outputs from this function are returned to the command line.
function varargout = GUI_OutputFcn(hObject, eventdata, handles) 
varargout{1} = handles.output; % get default command line output from handles structure



% Callbacks

% called when city selection is created
function citymenu_CreateFcn(hObject, eventdata, handles)
str = {'Las Vegas'; 'Los Angeles'; 'San Francisco'};
set(hObject, 'String', str);

% called when different city is selected
function citymenu_Callback(hObject, eventdata, handles)
if (isfield(handles, 'selectedcity')) % checks if grid of selected city exists
    outputGrid(handles.selectedcity); % updates grid of selected city
end
contents = cellstr(get(hObject, 'String'));
handles.selectedcity = findCity(handles, contents{get(hObject,'Value')}); % sets current city
guidata(hObject,handles);
[X Y] = returnDimMap(handles.selectedcity);
image([0 X], [0 Y], flipdim(handles.selectedcity.returnMap,1), 'HitTest', 'off'); % draws map of city onto grid with appropriate dimensions
% Draws lines of grid
for i = 0:Y
    x = [0 X];
    y = [i i];
    plot(x,y,'Color','black', 'HitTest', 'off');
end
for i = 0:X
    x = [i i];
    y = [0 Y];
    plot(x,y,'Color','black', 'HitTest', 'off');
end
% Fills rectangles on grid with appropriate colors
grid = handles.selectedcity.returnGrid;
for i = 1:size(grid, 1)
    for j = 1:size(grid, 2)
       if (grid(i, j) ~= 0)
        t_model = handles.model(grid(i, j));
        t_color = returnColor(handles.dbase, t_model);
        rectangle('Position',[j - 1, Y - i, 1, 1], 'HitTest', 'off', 'FaceColor', [t_color(1)/255 t_color(2)/255 t_color(3)/255]);
       end
    end
end
updateEstimate(handles); % displays energy estimate data



% called when map is clicked
function map_ButtonDownFcn(hObject, eventdata, handles)
[X Y] = returnDimMap(handles.selectedcity);
pos=get(gca, 'CurrentPoint'); % Gets position of mouse click
mouse = get(gcbf, 'SelectionType'); % gets type of click, normal = m1, alt = m2, extend = m3
grid = handles.selectedcity.returnGrid;
x = floor(pos(1, 1)); % horizontal location of click
y = floor(pos(1, 2)); % vertical location of click
if (x < X && x >= 0 && y < Y && y >= 0) % checks if click is out of bounds
    if (strcmp(mouse, 'normal')) % if left mouse
        t_color = returnColor(handles.dbase, handles.selectedmodel); % color of selected model
        rectangle('Position', [x, y, 1, 1], 'HitTest', 'off', 'FaceColor', [t_color(1)/255 t_color(2)/255 t_color(3)/255]); % fills rectangle
        handles.selectedcity.updateGrid(Y - y, x + 1, handles.selectedmodel); % updates grid
        updateEstimate(handles); % displays energy estimate data
    elseif (strcmp(mouse, 'alt')) % if right mouse
        handles.selectedcity.updateGrid(Y - y, x + 1); % updates grid
        delete(findall(gca, 'Position',[x, y, 1, 1])); % delete rectangle
        updateEstimate(handles); % displays energy estimate data
    elseif (strcmp(mouse, 'extend')) % if middle mouse
        if (grid(Y - y, x + 1) ~= 0) % checks if model info is available
            set(handles.modelselect, 'value', grid(Y - y, x + 1)); % changes selected model
            modelselect_Callback(handles.modelselect, eventdata, handles); % calls callback for change in model selected
        end
    end
end


% create when model selection is created
function modelselect_CreateFcn(hObject, eventdata, handles)
set(hObject, 'String', returnModel(database)); % imports list of model to model selection

 % called when different model is selected
function modelselect_Callback(hObject, eventdata, handles)
handles.selectedmodel = handles.model(get(hObject, 'value')); % sets selected model
guidata(hObject, handles);
% gets data for model
t_brand = returnBrand(handles.dbase, handles.selectedmodel); 
t_dimension = returnDimension(handles.dbase, handles.selectedmodel);
t_price = returnPrice(handles.dbase, handles.selectedmodel);
t_type = returnType(handles.dbase, handles.selectedmodel);
t_color = returnColor(handles.dbase, handles.selectedmodel);
% displays data for model
str = sprintf('Model Info\n');
str = sprintf('%sBrand: %s\n', str, t_brand{1});
str = sprintf('%sModel: %s\n', str, handles.selectedmodel{1});
if (t_dimension(2) == 0) % if turbine/generator
    str = sprintf('%sDiameter: %d\n', str, t_dimension(1));
else % if solar panel
    str = sprintf('%sDimension: %.2f x %.2f x %.2f\n', str, t_dimension(1), t_dimension(2), t_dimension(3));
end
str = sprintf('%sPrice: $%.2f\n', str, t_price);
str = sprintf('%sType: %s\n', str, t_type{1});
str = sprintf('%sColor: [%d %d %d]', str, t_color(1), t_color(2), t_color(3));
set(handles.modelinfo, 'BackgroundColor', [t_color(1)/255 t_color(2)/255 t_color(3)/255]); % sets background color of info box to that of model color
set(handles.modelinfo, 'String', str); 



% called if saveBOM button is pressed, saves BOM as text file
function saveBOM_Callback(hObject, eventdata, handles)
[file, path] = uiputfile('*.txt', 'Save BOM'); % asks for file name and location input
if (~isequal(file, 0) && ~isequal(path, 0)) % if selection is made
    handles.selectedcity.createBOM; % creates BOM of selected city
    str = sprintf('%s%s', path,file);
    fp = fopen(str, 'w');
    fprintf(fp, '%s', handles.selectedcity.returnBOM); % outputs BOM to file
    fclose(fp);
end



% called if savePicture button is clicked, saves picture as PNG file
function savePicture_Callback(hObject, eventdata, handles)
[file, path] = uiputfile('*.png', 'Save Picture'); % asks for file name and location input
if (~isequal(file, 0) && ~isequal(path, 0)) % if selection is made
    pic = getframe(gca); % takes picture of current grid with the city image in the background
    str = sprintf('%s%s', path, file);
    imwrite(pic.cdata, str, 'png'); % outputs picture to file
end



% called if the button is clicked, saves saveText file
function saveText_Callback(hObject, eventdata, handles)
[file, path] = uiputfile('*.txt', 'Save Text'); % asks for file name and location input
if (~isequal(file, 0) && ~isequal(path, 0)) % if selection is made
    str = sprintf('%s%s', path, file);
    dlmwrite(str,returnGrid(handles.selectedcity), '\t');
end



% called if the button is clicked, loads saveText file
function loadText_Callback(hObject, eventdata, handles)
[file, path] = uigetfile('*.txt','Load Text'); % asks for file name and location output
if (~isequal(file,0) && ~isequal(path,0)) % if selection is made
    str = sprintf('%s%s', path, file);
    handles.selectedcity.loadGrid(dlmread(str, '\t'));
    citymenu_Callback(handles.citymenu, eventdata, handles);
end



% called if reset button is pressed, clears all the grid
function reset_Callback(hObject, eventdata, handles)
[X Y] = returnDimMap(handles.selectedcity);
grid = handles.selectedcity.returnGrid;
for i = 1:size(grid, 1)
    for j = 1:size(grid, 2)
       if (grid(i, j) ~= 0)
        t_model = handles.model(grid(i, j));
        t_color = returnColor(handles.dbase, t_model);
        delete(findall(gca,'Position',[j - 1, Y - i, 1, 1])); % deletes rectangles
        handles.selectedcity.updateGrid(i, j); % updates grid
       end
    end
end

citymenu_Callback(handles.citymenu, eventdata, handles);



% called when help button is pressed
function help_Callback(hObject, eventdata, handles)
str = sprintf('Fill a square by left clicking.\nEmpty a square by right clicking.');
str = sprintf('%s\nCopy the model information of a square by clicking the middle button on the mouse.',str);
str = sprintf('%s\nClick Save Text to save grid in text format.',str);
str = sprintf('%s\nClick Load Text to load grid in text format.',str);
str = sprintf('%s\nClick Save Bills of Materials to save receipt of material costs of grid',str);
str = sprintf('%s\nClick Save Picture to save screenshot of grid.',str);
str = sprintf('%s\nClick Reset to reset grid.',str);
msgbox(str); % displays messagebox


% called when help button is created
function help_CreateFcn(hObject, eventdata, handles)
[x ,~] = imread('icon.jpg'); % reads help button image
img = imresize(x, [20 20]); % resizes image
set(hObject, 'cdata', img); % displays image on button

% user defined functions

function ret = findCity(handles, name) % finds city in struct of cities
for i = 1:size(handles.arr, 1)
    if (strcmp(name, handles.arr{i}.returnName) == 1)
        ret = handles.arr{i};
    end
end

function updateEstimate(handles) % updates energy estimate data
str = sprintf('Energy Estimate\n');
str = sprintf('%sSolar Energy: %.2f\n', str, handles.selectedcity.estimateSolar);
str = sprintf('%sWind Energy: %.2f\n', str, handles.selectedcity.estimateWind);
set(handles.energyestimate, 'String', str);
