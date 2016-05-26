close all
clear all
addpath ('osmFunctions');
addpath(genpath('dependencies'));

%% test scenario
%1=reach maximum capacity of road (fundamentaldiagramm)
%2=panne (raum-zeit)
settings.testScenario = 0;
%%
settings.spawnVehicles = true;
settings.despawnVehicles = true;
%2 lanes are recommended
settings.minimumLanes = 2;
settings.maximumLanes = 2;

settings.minimumVehicleSpeed = 3;
settings.maximumVehicleSpeed = 5;

%vehicle spawn probability per iteration
%must be in [0,1]
settings.vehicleSpawnProbability = 0.3;

settings.cellLengthInMeters = 5;

settings.maximumRoadSpeed = 5;

%tröden probability
settings.p=0.2;
%barlovic model trödel probability
settings.p0=0.4;

%run delay
settings.delay=1/20;

%analysis settings
settings.analysisRoadID = 2;
settings.analysisRoadLane = 2;

settings.fundamentaldiagramm = true;
settings.raumzeitdiagramm = true;