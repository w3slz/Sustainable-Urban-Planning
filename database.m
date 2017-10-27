classdef database < handle % allows for pass by reference
    properties % variables
        city; % city data
        solar; % solar data
        wind; % wind data
        map; % map data
        brand; % brand data
        dimension; % dimension data
        model; % model data
        price; % price data
        type; % type data
        color; % color data
        grid; % grid data
    end
    methods
        function obj = database() % constructor; loads data from mat-files
            obj.city = cell2mat(struct2cell(load('weather.mat', 'city'))); %data are saved as matrices
            obj.solar = cell2mat(struct2cell(load('weather.mat', 'solar')));
            obj.wind = cell2mat(struct2cell(load('weather.mat', 'wind')));
            obj.map = load('map.mat'); %load the map data
            if(exist('grid.mat', 'file')) % creates empty grid.mat if not found
               obj.grid = load('grid.mat');
            else
               obj.grid = struct; 
            end
            obj.brand = cell2mat(struct2cell(load('pricing.mat', 'brand')));
            obj.dimension = cell2mat(struct2cell(load('pricing.mat', 'dimension')));
            obj.model = cell2mat(struct2cell(load('pricing.mat', 'model')));
            obj.price = cell2mat(struct2cell(load('pricing.mat', 'price')));
            obj.type = cell2mat(struct2cell(load('pricing.mat', 'type')));
            obj.color = cell2mat(struct2cell(load('pricing.mat', 'color')));
        end
        
        
        % Functions related to weather.mat data
        function ret = returnCity(obj) % returns list of cities
            ret = cellstr(obj.city);
        end
        
        function ret = returnSolar(obj, city) % returns average solar data of city over 12 months
            t_city = regexprep(cellstr(obj.city), {' ', '\.'}, '');
            ret = sum(obj.solar(strcmp(city, t_city), :))/12;
        end
        
        function ret = returnWind(obj, city) % returns average wind data of city over 12 months
            t_city = regexprep(cellstr(obj.city), {' ', '\.'}, '');
            ret = sum(obj.wind(strcmp(city, t_city), :))/12; 
        end
        
        function ret = returnMap(obj, city) % returns map of city
            t_map = regexprep(cellstr(fieldnames(obj.map)), {' ', '\.'}, '');
            mapcell = struct2cell(obj.map); % cannot reference temp cell
            if (sum(strcmp(city, t_map)) == 1) % checks if map exists
                ret = mapcell{strcmp(city, t_map)};
            else % returns test map if map does not exist
                ret = mapcell{strcmp('test', t_map)};
            end
        end
        
        
        % Functions related to pricing.mat data 
        %(for the panels and turbines)
        function ret = returnModel(obj) % returns the list of models
           ret = cellstr(obj.model); 
        end
        
        function ret = returnNumber(obj) % returns number of solar panels. uses 'Wind' as delimeter.
           ret = size(obj.model, 1) - sum(cell2mat(strfind(cellstr(obj.type), 'Wind')));
        end
        
        function ret = returnBrand(obj, model) % returns brand of the specified model
            brandstr = cellstr(obj.brand); % cannot reference temp str
            ret = brandstr(strcmp(model, cellstr(obj.model)), :);
        end
        
        function ret = returnDimension(obj, model) % returns dimensions of the specified model
            ret = obj.dimension(strcmp(model, cellstr(obj.model)), :);
        end
        
        function ret = returnPrice(obj, model) % returns price of the specified model
           ret = obj.price(strcmp(model, cellstr(obj.model)), :);    
        end
        
        function ret = returnType(obj, model) % returns type of specified model
            typestr = cellstr(obj.type); % cannot reference temp str
            ret = typestr(strcmp(model, cellstr(obj.model)), :);
        end
        
        function ret = returnColor(obj, model) % returns color of specified model
             ret = obj.color(strcmp(model, cellstr(obj.model)), :);           
        end
        
        
        % Functions related to grid.mat data
        function ret = returnGrid(obj, name) % returns grid of city "name"
            t_grid = regexprep(cellstr(fieldnames(obj.grid)), {' ', '\.'}, '');
            gridcell = struct2cell(obj.grid); % cannot reference temp cell
            if (sum(strcmp(name, t_grid)) > 0) % returns grid if found
                ret = gridcell{strcmp(name, t_grid)};
            else % creates empty grid and returns it
                [X Y] = returnDimMap(city(obj));
                setGrid(obj, zeros(Y, X), name);
                ret = returnGrid(obj, name);
            end
        end
        
        function setGrid(obj, grid, city) % outputs grid of city into grid.mat
            t_city = regexprep(city, {' ', '\.'}, '');
            obj.grid.(t_city) = grid;
            t_grid = obj.grid; % 'obj.grid' not allowed as parameter in save funcion
            save('grid.mat', '-struct', 't_grid');
            obj.grid = load('grid.mat');
        end
    end
end