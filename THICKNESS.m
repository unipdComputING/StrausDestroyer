classdef THICKNESS < handle
    %CLASSE per definire lo spessore degli elementi plate
    
    %...........................PROPRIETA'.................................
    properties
        thickness;   %spessore dell'elemento plate
    end
    %......................................................................
    
    %............................METODI....................................
    methods
        %----------------------COSTRUTTORE---------------------------------
        function this = THICKNESS(h)
            this.thickness=h;
        end
        %------------------------------------------------------------------
    end
    %......................................................................
end

