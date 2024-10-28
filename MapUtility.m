classdef MapUtility
    % Static class for utility functions used in map generation
    
    methods(Static)
        % Generate Perlin noise terrain grid
        % Generate Perlin noise terrain grid
        function terrain_map = generateTerrain(X, Y, scale, seed)
            % Inputs:
            % X, Y are dimensions of the grid
            % scale is the level of detail of noise (smaller = larger features)
            % seed is the random seed to generate different noise patterns
            
            % Set the random seed for reproducibility
            rng(seed);
            
            % Frequency and amplitude for Perlin noise
            freq = 1 / scale;
            amp = 1;
            
            % Initialize terrain grid
            terrain_map = zeros(X, Y);
            
            % Generate Perlin noise over the grid
            for i = 1:X
                for j = 1:Y
                    terrain_map(i, j) = MapUtility.perlin(i * freq, j * freq,seed) * amp;
                end
            end
        end
        % Generate complex terrain with octaves for more detail
        function terrain_map = generateTerrainWithOctaves(X, Y, baseScale, seed, octaves, persistence, lacunarity)
            % Inputs:
            % X, Y: dimensions of the grid
            % baseScale: base scale for noise
            % seed: random seed
            % octaves: number of noise layers (octaves)
            % persistence: how much each octave contributes
            % lacunarity: controls frequency increase for each octave
            
            % Initialize terrain grid
            terrain_map = zeros(X, Y);
            
            % Initial amplitude and frequency
            amplitude = 1;
            totalAmplitude = 0;
            
            % Set the initial seed
            rng(seed);  % This ensures that every call can be different
            
            for octave = 1:octaves
                % Adjust frequency and amplitude for each octave
                freq = baseScale * lacunarity^(octave - 1);
                currentAmplitude = amplitude * persistence^(octave - 1);
                totalAmplitude = totalAmplitude + currentAmplitude;
                
                % Generate Perlin noise for this octave with a randomized seed
                octave_seed = seed + octave * 100;  % Ensure a new seed for each octave
                noise_layer = MapUtility.generateTerrain(X, Y, freq, octave_seed);
                
                % Add the noise layer to the terrain map, scaled by current amplitude
                terrain_map = terrain_map + noise_layer * currentAmplitude;
            end
            
            % Normalize terrain map to range 0 to 10
            terrain_map = MapUtility.CustomRescale(terrain_map, 0, 10);
        end
        % Generate Perlin noise temperature grid (optional)
        function temperature_map = generateTemperature(X, Y, scale, seed)
            % Similar to generateTerrain but for temperature, using a seed
            rng(seed);
            freq = 1 / scale;
            amp = 1;
            temperature_map = zeros(X, Y);
            
            for i = 1:X
                for j = 1:Y
                    temperature_map(i, j) = MapUtility.perlin(i * freq, j * freq) * amp;
                end
            end
            
            % Normalize temperature between chosen range (e.g., -10 to 40 degrees Celsius)
            temperature_map = MapUtility.CustomRescale(temperature_map, -10, 40);  % Adjust range as needed
        end

        % Perlin noise function (2D)
        function n = perlinX(x, y)
            xi = floor(x) & 255;
            yi = floor(y) & 255;
            xf = x - floor(x);
            yf = y - floor(y);

            u = MapUtility.fade(xf);
            v = MapUtility.fade(yf);

            % Hashing corners
            aa = MapUtility.hash(xi + MapUtility.hash(yi));
            ab = MapUtility.hash(xi + MapUtility.hash(yi + 1));
            ba = MapUtility.hash(xi + 1 + MapUtility.hash(yi));
            bb = MapUtility.hash(xi + 1 + MapUtility.hash(yi + 1));

            % Interpolation
            x1 = MapUtility.lerp(u, MapUtility.grad(aa, xf, yf), MapUtility.grad(ba, xf - 1, yf));
            x2 = MapUtility.lerp(u, MapUtility.grad(ab, xf, yf - 1), MapUtility.grad(bb, xf - 1, yf - 1));
            n = MapUtility.lerp(v, x1, x2);  % Final noise value
        end  
        function n = perlin(x, y, seed)
            % Hash based on the random seed to ensure randomness
            rng(seed);
            xi = floor(x) & 255;
            yi = floor(y) & 255;
            xf = x - floor(x);
            yf = y - floor(y);

            u = MapUtility.fade(xf);
            v = MapUtility.fade(yf);

            % Use the seed to create random gradients
            aa = MapUtility.hash(xi + MapUtility.hash(yi, seed), seed);
            ab = MapUtility.hash(xi + MapUtility.hash(yi + 1, seed), seed);
            ba = MapUtility.hash(xi + 1 + MapUtility.hash(yi, seed), seed);
            bb = MapUtility.hash(xi + 1 + MapUtility.hash(yi + 1, seed), seed);

            % Interpolation
            x1 = MapUtility.lerp(u, MapUtility.grad(aa, xf, yf), MapUtility.grad(ba, xf - 1, yf));
            x2 = MapUtility.lerp(u, MapUtility.grad(ab, xf, yf - 1), MapUtility.grad(bb, xf - 1, yf - 1));
            n = MapUtility.lerp(v, x1, x2);  % Final noise value
        end        
        % Fade function to smooth transitions
        function t = fade(t)
            t = t * t * t * (t * (t * 6 - 15) + 10);
        end
        
        % Linear interpolation function
        function a = lerp(t, a1, a2)
            a = a1 + t * (a2 - a1);
        end
        
        % Gradient function for noise direction
        function g = grad(hash, x, y)
            g = ((hash & 1) * 2 - 1) * x + ((hash & 2) * 2 - 1) * y;
        end
        
        % Hash function for Perlin noise
        function h = hashX(x)
            h = bitxor(x, bitxor(16, 255));  % Simple bitwise operation
        end
         function h = hash(x, seed)
            rng(seed);  % Use the random seed to generate the hash
            h = bitxor(x, bitxor(seed, 255));  % Simple bitwise operation to randomize with seed
        end       
        % Generate the terrain (edifice grid) with clusters of impassable terrain
        function edificeGrid = generateEdificeGrid(mapSize, clusterCount, clusterRange)
            edificeGrid = zeros(mapSize);  % Start with zeros for all terrain values
            impassableLocations = [];
            
            % Place clusters of impassable terrain
            for i = 1:clusterCount
                clusterSize = randi(clusterRange);  % Random size for clusters
                x = randi([1, mapSize(1)]);
                y = randi([1, mapSize(2)]);
                
                for j = -clusterSize:clusterSize
                    for k = -clusterSize:clusterSize
                        % Ensure we don't go out of the grid's bounds
                        if (x+j > 0 && x+j <= mapSize(1)) && (y+k > 0 && y+k <= mapSize(2))
                            edificeGrid(x+j, y+k) = 10;  % Set impassable terrain
                            impassableLocations = [impassableLocations; x+j, y+k];  % Track impassable locations
                        end
                    end
                end
            end
            
            % Calculate terrain difficulty based on distance from impassable areas
            for x = 1:mapSize(1)
                for y = 1:mapSize(2)
                    if edificeGrid(x, y) ~= 10
                        distances = sqrt(sum((impassableLocations - [x, y]).^2, 2));
                        minDistance = min(distances);
                        edificeGrid(x, y) = min(max(9 - round(minDistance), 0), 9);  % Clamp between 0 and 9
                    end
                end
            end
        end
        
        % Function to calculate terrain value based on distance from impassable areas
        function terrainValue = calculateTerrainValue(edificeGrid, x, y, maxDistance)
            minTerrainValue = 0;  % Easiest terrain value
            terrainValue = 9;  % Default to the hardest terrain except impassable
            
            for i = max(-maxDistance, 1-x):min(maxDistance, size(edificeGrid, 1)-x)
                for j = max(-maxDistance, 1-y):min(maxDistance, size(edificeGrid, 2)-y)
                    if edificeGrid(x+i, y+j) == 10
                        distance = sqrt(i^2 + j^2);
                        terrainValue = min(terrainValue, round(distance));  % Round to nearest integer
                    end
                end
            end
            
            terrainValue = max(minTerrainValue, terrainValue);  % Ensure terrain value is not negative
        end        
        
        % Custom rescale function to scale the input matrix to a new range
        function output = CustomRescale(input, newMin, newMax)
            % Inputs:
            % - input: matrix to be rescaled
            % - newMin: the new minimum value after rescaling
            % - newMax: the new maximum value after rescaling
            
            % Find the min and max of the input matrix
            oldMin = min(input(:));
            oldMax = max(input(:));
            
            % Scale the input to the range [0, 1]
            scaledInput = (input - oldMin) / (oldMax - oldMin);
            
            % Scale the [0, 1] range to the new range [newMin, newMax]
            output = scaledInput * (newMax - newMin) + newMin;
        end
    end
end
