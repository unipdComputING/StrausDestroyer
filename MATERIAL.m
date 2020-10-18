classdef MATERIAL < handle
  %------------------------------------------------------------------------
  properties
    E;
    nu;
    density;
    thexpansion;
  end
  %------------------------------------------------------------------------
  methods
    %----------------------------------------------------------------------
    function this=MATERIAL(varargin)
      this.E = 0;
      this.nu = 0;
      this.density = 0;
      this.thexpansion = 0;
      if nargin ~= 0
        cont = 1;
        while cont <= nargin
          switch varargin{cont}
            case "E"
              cont = cont + 1;
              this.E = varargin{cont};
            case "nu"
              cont = cont + 1;
              this.nu = varargin{cont};
            case "density"
              cont = cont + 1;
              this.density = varargin{cont};
            case "thexpansion"
              cont = cont + 1;
              this.thexpansion = varargin{cont};
          end
          cont = cont + 1;
        end
      end
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    function write(this)
      fprintf("--Material\n");
      fprintf("   Young Mod: %f ", this.E);
      fprintf("Poisson: %f\n", this.nu);
      fprintf("   Density: %e\n", this.density);
      fprintf("   Thermal Expansion: %f\n", this.thexpansion);
      fprintf("--\n");
    end
    %----------------------------------------------------------------------
  end
  %------------------------------------------------------------------------
end