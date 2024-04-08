function [A] = bvpSolver(H,a1,a2)
% bvpSolver  Solve a boundary value problem (BVP) and plot the result
%
% Y0 = BVPSOLVER(HDESIRED,A1,A2) finds the necessary final altitude A
% required for an apoapsis of 1200km from the input apoapsis HDESIRED
% and initial altitude inputs of A1 and A2.
% The two altitude guesses A1 and A2 set the altitude boundaries.
% HDESIRED is the necessary apoapsis of 1200km

% Set initial conditions in seconds
t0 = 0;
dt = 1;
tend = 40000;
a = [a1,a2];
errors=[];
R=6051800;
Hdesired=H+R;

% Sets up input in correct order for ivpSolver
inputs =[t0,dt,tend,0,0,10000000,-11000];

% Inputs the initial conditions and altitude A into IVPSOLVER for A1
% and then A2 to find an apoapsis of H1 and then H2.

% Sets up an anonymous function to return the apoapsis of any z data set
h_max = @(z) max(hypot(z(1,840/dt:end),z(3,840/dt:end)));

inputs(4)=a1;
[~,z] = ivpSolver(inputs);

% ERROR1 computs the error of the output apoapsis compared to
% HDESIRED.
error1 = (h_max(z) - Hdesired)/Hdesired;
errors=[errors,error1];

inputs(4)=a2;
[~,z] = ivpSolver(inputs);

% ERROR2 computs the error of the output apoapsis compared to
% HDESIRED.
error2 = (h_max(z) - Hdesired)/Hdesired;
errors=[errors,error2];

% Tolerances for HFINAL to equal HDESIRED
Upperbound = 1.00000001*Hdesired;
Lowerbound = 0.99999999*Hdesired;

% While loop reduces ERORROR3 in H3 by using STEPRK4 and IVPSOLVER
% until final apoapsis HFINAL is within the tolerances for HDESIRED
m=3;
H=h_max(z);
% Iterates until the H value is between the desired limits
while H > Upperbound || H < Lowerbound
    % Extrapolates a new altitude value from previous values
    a(m) = a(m-1) - ((a(m-1)-a(m-2))/(errors(m-1)-errors(m-2)))*errors(m-1);
    inputs(4) = a(m);
    [~,z] = ivpSolver(inputs);
    
    % Calculates apoapsis and error for the altitude value
    H = h_max(z);
    error = ((H-Hdesired)/Hdesired);
    errors = [errors,error];
    m = m + 1;
end
% Returns final altitude value 
A = (a(end)-R);

