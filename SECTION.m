classdef SECTION < handle
  %------------------------------------------------------------------------
  properties
    A;    %area
    I11;  %inerzia dir 11
    I22;  %inerzia dir 22
    J;    %inerzia torsionale
  end
  %------------------------------------------------------------------------
  methods
    %----------------------------------------------------------------------
    function this=SECTION(varargin)
      sec_name = "";
      if (nargin == 2)
        sec_name = varargin{1};
        parameters = varargin{2};
      elseif (nargin == 4) %assegnamo direttamente i valori
        this.A = varargin{1};
        this.I11 = varargin{2};
        this.I22 = varargin{3};
        this.J = varargin{4};
      end
      if (sec_name ~= "")
        this.initialize_section(sec_name, parameters);
      end
    end
    %----------------------------------------------------------------------
    function initialize_section(this, sec_name, parameters)
      switch sec_name
        case "rec"
          B = parameters(1);
          H = parameters(2);
          area = B * H;
          inertia11 = (B * H^3) / 12;
          inertia22 = (H * B^3) / 12;
          a = min(B, H);
          b = max(B, H);
          k = 0.208 + (1 - a/b) * 0.125; %un po' approssimata
          torsion = k * (a * b ^3);
        case "circle"
          d = parameters(1);
          area = pi * d^2 / 4;
          inertia11 = pi * (0.5 * d)^4 / 64;
          inertia22 = pi * (0.5 * d)^4 / 64;
          torsion = pi * (0.5 * d)^4 / 2;
      end
      this.A = area;
      this.I11 = inertia11;
      this.I22 = inertia22;
      this.J = torsion;
    end
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    %----------------------------------------------------------------------
    function write(this)
      fprintf("--Section\n");
      fprintf("   A: %f; ",this.A);
      fprintf("I11: %f; ",this.I11);
      fprintf("I22: %f; ",this.I22);
      fprintf("J: %f;\n",this.J);
      fprintf("--\n");
    end
    %----------------------------------------------------------------------
  end
  %------------------------------------------------------------------------
end