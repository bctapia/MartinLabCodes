%% Rough Draft Space
            % Running blank
 %           initTime=clock;
 %           newTime=initTime;
 %           initS = initTime(5)*60 + initTime(6);
 %           newS = newTime(5)*60+initTime(6);
 %           blankS = 1; % CHANGE THIS BACK TO 120 ---------------------
 %           while newS-initS < blankS      
 %               newTime=clock;
 %               newS = newTime(5)*60+newTime(6);
 %           end
%% Initialization of Nidaq Parameters

%{                             
                  ORGANIZATION OF NIDAQ CHANNELS
------------Dev 1----------------| ------------Dev 2------------------| 
0 : N2flowOut : output : voltage | 0 : TempOut : output : voltage     |
1 : CO2flowOut : output: voltage | 0 : N2valveOut : output : digital  |
2 : N2flowIn : input : voltage   | 1 : CO2valveOut : output : digital |                      
3 : CO2flowIn : input : voltage  | 
4 : CO2readIn : input : voltage  |
5 : HumidityIn : input : voltage | 
6 : PressureIn : input : voltage |
7 : TempIn : input: voltage      |  
------------------------------------------------------------------------
%}

clear; clc; close all; tic;

%create data acquisition object
Dev1 = daq("ni");
Dev2 = daq("ni");

% Dev 1
N2flowOut = addoutput(Dev1,"Dev1",0,"Voltage");
CO2flowOut = addoutput(Dev1,"Dev1",1,"Voltage");
N2flowIn = addinput(Dev1,"Dev1",2,"Voltage");
CO2flowIn = addinput(Dev1,"Dev1",3,"Voltage");
CO2ReadIn = addinput(Dev1,"Dev1",4,"Voltage");
HumidityIn = addinput(Dev1,"Dev1",5,"Voltage");
PressureIn = addinput(Dev1,"Dev1",6,"Voltage");
TempIn = addinput(tempv,"Dev1",3,"Current"); % THIS IS CORRECT

% Dev 2
TempOut = addoutput(Dev2,"Dev2",0,"Voltage"); % THIS IS CORRECT
N2ValveOut = addoutput(Dev2,"Dev2",0,"Digital");
CO2ValveOut = addoutput(Dev2,"Dev2",1,"Digital");

% Read Parameters
N2flowIn.Name = "N2Flow";
N2flowIn.TerminalConfig = "SingleEnded";
CO2flowIn.Name = "CO2Flow";
CO2flowIn.TerminalConfig = "SingleEnded";
TempIn.Name = "ColumnTemp";
TempIn.TerminalConfig = "SingleEnded";
CO2ReadIn.Name = "CO2 PPM";
CO2ReadIn.TerminalConfig = "SingleEnded";
HumidityIn.Name = "Humidity";
HumidityIn.TerminalConfig = "SingleEnded";
PressureIn.Name = "Pressure";
PressureIn.TerminalConfig = "SingleEnded";

Dev1.Rate = 40; % scan/s

%% INPUTS

numrun = input('Number of runs: ');
numblanks = 2; % CHANGE THIS BACK TO 10 RUNS ---------------------
% numblanks = input('number of blanks: ') uncomment if you want to control
blanktime = 2; % min
% blanktime = input('time of blank run (min): ') uncomment if you want to control
adstime = input("Time of adsorption run (min): ");
adstemp=input('Temperature of adsorption run (C): ');
destime = input('Time of desorption period (min): ');
destemp=input('Temperature of desorption period (C): ');
N2f=input("N2 flow [sccm](range: 0 - 300): ");
O2f=input("O2 flow [sccm]: ");
outO2=O2f*0.01412;
CO2f=input("Air flow [sccm] (range: 0 - 1000): ");
blanks = input("Do you want to run blanks? (1/0): ");
cont = input('Ready? (1/0): ');

%% GENERAL SETUP 

% Temp -> Voltage [Optimized for -30 C - 212 C]
adstempvoltage = (adstemp-152.14)/303.4;
destempvoltage = (destemp-152.14)/303.4;
% Flow -> Voltage
outN2 = N2f; % *0.01480;
outCO2 = CO2f; % *0.005;

% min -> sec
blanktimesec = blanktime*60;
adstimesec = adstemp*60;
destimesec = destemp*60;

% opening N2, closing air
outN2valve = 1;
outCO2valve = 0;
%write(N2valve,outN2valve);
%write(CO2valve,outCO2valve);

fprintf('pausing for 60 seconds\n')
pause(2) % CHANGE THIS BACK TO 60 ---------------------
fprintf('continuing!\n')
%% BLANKS
while cont==1
    if blanks==1
        fprintf('Running %d blanks\n', numblanks)
        for i=1:numblanks
            fprintf('Starting Blank %d\n', i)
            blank_1 = read(Dev1, seconds(blanktimesec)); % UPDATE NAMING CONVENTIONS
            fprintf('COMPLETE: Blank %d\n', i)
            
            % Allowing humidity & CO2 to return to normal levels by pausing
            % for 3 min
            fprintf('Pausing for 3 minutes\n')
            pause(10) % CHANGE THIS BACK TO 180 ---------------------
        end

        fprintf('BLANKS COMPLETE\n')
        break
    else
        fprintf('SKIPPING BLANKS')
        break
    end
end
%% RUN LOOP
while cont==1

    % write(d1,outCO2);
    % write(d2,outN2);
    for i=1:numrun
        
        
    % DESOPRTION

        % opening N2, closing air
        outN2valve = 1;
        outCO2valve = 0;
 %       write(N2valve,outN2valve);
 %       write(CO2valve,outCO2valve);

        % getting to correct desorption temperature
        fprintf('Equilibrating to %f C\n', destemp)
 %       acttempv = read(tempv,1);
 %       while acttempv(-1) < destempvoltage
 %           acttempv = read(tempv,1);
 %       end
        fprintf('COMPLETE: Equilibration to %f C\n', destemp)
        fprintf('Desorbing for Run %d for %f minutes\n',i,destime)
        % actual desorption period
        Dev1_1_des = read(Dev1,seconds(destimesec));
        fprintf('COMPLETE: Desorption for run %d\n', i)

    % ADSORPTION
       fprintf('Equilibrating to %f C\n', adstemp)
        % getting to correct desorption temperature
  %      acttempv = read(tempv,1);
  %      while acttempv(-1) > adstempvoltage
  %          acttempv = read(tempv,1);
  %      end
        fprintf('COMPLETE: Equilibration to %f C\n', adstemp)
        fprintf('Adsorption for Run %d for %f minutes\n',i,adstime)
         % opening air, closing N2
        outN2valve = 0;
        outCO2valve = 1;
 %      write(N2valve,outN2valve);
 %      pause(2)
 %      write(CO2valve,outCO2valve);
        % actual adsorption period
        Dev1_1_ads = read(Dev1,seconds(adstimesec));

        fprintf('COMPLETE: adsorption for run %d\n',i)
    end
fprintf('All adsorption runs complete\n!')
break
end
fprintf('Program shutting off\n')
fprintf('No errors generated\n')
toc;