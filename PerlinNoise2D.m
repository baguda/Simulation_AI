classdef PerlinNoise2D
    properties
        gridX      % Width of the grid
        gridY      % Height of the grid
        scale      % Scale factor for noise frequency
        octaves    % Number of noise layers for detail
        persistence % Amplitude decay factor for each octave
        lacunarity % Frequency growth factor for each octave
        minValue   % Minimum value of the grid
        maxValue   % Maximum value of the grid
        seed       % Seed for random generation
        grid
    end
    
    methods
        % Constructor
        function obj = PerlinNoise2D(gridX, gridY, scale, octaves, persistence, lacunarity, minValue, maxValue, seed,upper,lower)
            obj.gridX = gridX;
            obj.gridY = gridY;
            obj.scale = scale;
            obj.octaves = octaves;
            obj.persistence = persistence;
            obj.lacunarity = lacunarity;
            obj.minValue = minValue;
            obj.maxValue = maxValue;
            obj.seed = seed;
            obj.grid=obj.generate();
            obj.grid(obj.grid>upper)=maxValue;
            obj.grid(obj.grid<lower)=minValue;
            
        end
        
        % Main function to generate the Perlin noise grid
        function noiseGrid = generate(obj)
            rng(obj.seed); % Seed the random number generator
            
            % Initialize grid
            noiseGrid = zeros(obj.gridX, obj.gridY);
            
            % Octave loop to layer Perlin noise at different frequencies
            maxAmplitude = 0;
            amplitude = 1;
            frequency = 1;
            
            for o = 1:obj.octaves
                for i = 1:obj.gridX
                    for j = 1:obj.gridY
                        x = i / obj.scale * frequency;
                        y = j / obj.scale * frequency;
                        
                        % Accumulate noise based on Perlin Noise formula
                        noiseGrid(i, j) = noiseGrid(i, j) + obj.perlin(x, y) * amplitude;
                    end
                end
                maxAmplitude = maxAmplitude + amplitude;
                amplitude = amplitude * obj.persistence;
                frequency = frequency * obj.lacunarity;
            end
            
            % Normalize the grid values
            noiseGrid = noiseGrid / maxAmplitude;
            
            % Scale to Min and Max
            noiseGrid = obj.minValue + (obj.maxValue - obj.minValue) * (noiseGrid + 1) / 2;
        end
        
        % Core Perlin noise function
        function value = perlin(obj, x, y)
        % Determine grid cell coordinates
        x0 = floor(x);
        x1 = x0 + 1;
        y0 = floor(y);
        y1 = y0 + 1;
        
        % Local coordinates within the cell
        dx = x - x0;
        dy = y - y0;
        
        % Gradient vectors at each corner of the cell
        g00 = obj.gradient(x0, y0,obj.seed);
        g10 = obj.gradient(x1, y0,obj.seed);
        g01 = obj.gradient(x0, y1,obj.seed);
        g11 = obj.gradient(x1, y1,obj.seed);
        
        % Distance vectors from point to each corner
        d00 = [dx, dy];
        d10 = [dx - 1, dy];
        d01 = [dx, dy - 1];
        d11 = [dx - 1, dy - 1];
        
        % Dot products of distance vectors with gradients
        dot00 = dot(g00, d00);
        dot10 = dot(g10, d10);
        dot01 = dot(g01, d01);
        dot11 = dot(g11, d11);
        
        % Fade the local coordinates
        u = obj.fade(dx);
        v = obj.fade(dy);
        
        % Interpolate the dot products
        nx0 = obj.lerp(dot00, dot10, u);
        nx1 = obj.lerp(dot01, dot11, u);
        value = obj.lerp(nx0, nx1, v);
    end
    
    % Helper function: Generate a pseudo-random gradient vector
    function g = gradient(~, ix, iy,seed)
        % Hash function to produce repeatable pseudorandom values based on cell coordinates
        r=ix * 49632 + iy * 504;
        rr=r + seed;
        rng(rr); % Seed based on cell coordinates
        angle = 2 * pi * rand();               % Random angle for 2D gradient
        g = [cos(angle), sin(angle)];           % Convert angle to unit vector
    end
    
    % Helper function: Fade function for smoother interpolation
    function t = fade(~, t)
        % Uses 6t^5 - 15t^4 + 10t^3, the standard Perlin fade function
        t = t * t * t * (t * (t * 6 - 15) + 10);
    end
    
    % Helper function: Linear interpolation
    function a = lerp(~, a0, a1, w)
        a = (1 - w) * a0 + w * a1;
    end
    end
end
