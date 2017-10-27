classdef city < handle % allows for modification
    properties % variables
        name; % city name
        grid; % grid overlay
        BOM; % bill of materials
        dbase; % database
    end
    properties(Constant) % constants
        dimBox = 35; % dimension of each box (ft)
        dimMap = [50 50]; % dimension of map (squares)
        mph2Kw = 500; % Kw generated per mph of wind
    end
    
    methods
        function obj = city(dbases, name) % constructor
            obj.dbase = dbases; % database instance
            if (nargin == 2) % if name of city supplied
                obj.name = name;
                t_name = regexprep(obj.name, {' ', '\.'}, '');
                obj.grid = returnGrid(obj.dbase, t_name);
            end
        end
        
        
        function [ret ret2] = returnDimMap(obj) % returns dimensions of map
            ret = obj.dimMap(1);
            ret2 = obj.dimMap(2);
        end
        
        function ret = returnName(obj) % return name of city
           ret = obj.name; 
        end
        
        function ret = returnMap(obj) % returns city map
           t_name = regexprep(obj.name, {' ', '\.'}, '');
           ret =  returnMap(obj.dbase, t_name);
        end
        
        function createBOM(obj) % create BOM
            total = 0;
            model = returnModel(obj.dbase); % cannot reference temp cell
            index = obj.grid(obj.grid > 0); % cannot reference temp matrix; finds the index of the grid that the user chose 
            uniqueindex = unique(index);
            obj.BOM = sprintf('---------------------------------------------------------------------\n');
           	obj.BOM = sprintf('%s|\tModel\t|\t\tType\t\t|\t#\t|\t Price\t  |\t   Total \t|\n', obj.BOM);
            obj.BOM = sprintf('%s---------------------------------------------------------------------\n', obj.BOM);
            for i = 1:size(uniqueindex, 1)
                t_model = model(uniqueindex(i)); % cannot reference temp cell
                t_type = returnType(obj.dbase, model(uniqueindex(i))); % cannot reference temp cell;
                t_count = sum(index == uniqueindex(i));
                t_price = returnPrice(obj.dbase, model(uniqueindex(i)));
                t_total = t_price * t_count;
                total = total + t_total;
                obj.BOM = sprintf('%s| %-10s| %-18s|  %-5d|   $%-9.2f|\t $%-10.2f|\n', obj.BOM, t_model{1, :}, t_type{1, :}, t_count, t_price, t_total);
                obj.BOM = sprintf('%s---------------------------------------------------------------------\n', obj.BOM);
            end
            obj.BOM = sprintf('%s\t\t\t\t\t\t\t\t\t\t| Grand Total =\t $%-10.2f|\n', obj.BOM, total);
            obj.BOM = sprintf('%s\t\t\t\t\t\t\t\t\t\t|---------------------------|\n', obj.BOM);
        end
        function ret = returnBOM(obj) % return BOM
            ret = obj.BOM;
        end
        function ret = estimateSolar(obj) % solar energy estimate using average solar data
            t_name = regexprep(obj.name, {' ', '\.'}, '');
            ret = sum(sum(obj.grid <= returnNumber(obj.dbase) & obj.grid > 0)) * obj.dimBox^2 * returnSolar(obj.dbase, t_name);
        end
        function ret = estimateWind(obj) % wind energy estimate using average wind data
            t_name = regexprep(obj.name, {' ', '\.'}, '');
            ret = sum(sum(obj.grid > returnNumber(obj.dbase))) * obj.mph2Kw * returnWind(obj.dbase, t_name);
        end
        function outputGrid(obj) % output grid into database
            setGrid(obj.dbase, obj.grid, obj.name);
        end
        function updateGrid(obj, x, y, model) % updates grid
            if (nargin == 4) % sets value of grid at (x,y) to model index
                index = strcmp(returnModel(obj.dbase), model);
                obj.grid(x, y) = find(index);
            else % sets value of grid at (x,y) to 0
                obj.grid(x, y) = 0;
            end
        end
        function ret = returnGrid(obj) % returns grid
            ret = obj.grid;
        end
        function loadGrid(obj, grid) % loads grid and updates grid in database
            obj.grid = grid;
            outputGrid(obj);
        end
    end
end