close all
clear all
addpath ('osmFunctions');
addpath(genpath('dependencies'));

spawnVehicles = true;
despawnVehicles = false;
%2 lanes are recommended
maximumLanes = 2;

minimumVehicleSpeed = 3;
maximumVehicleSpeed = 5;

%vehicle spawn probability per iteration
%must be in [0,1]
vehicleSpawnProbability = 0.3;

cellLengthInMeters = 5;

maximumRoadSpeed = 5;