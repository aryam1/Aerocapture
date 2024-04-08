function dz = stateDeriv(z)
% Calculate the state derivative for a mass-spring-damper system
% 
%     DZ = stateDeriv(T,Z) computes the derivative DZ = [V; A] of the 
%     state vector Z = [X; V], where X is displacement, V is velocity,
%     and A is acceleration.
% z =[y, dy,x, dx]

M = 4.8675e24; % Mass of Venus(kg)
m = 1500; % Mass of satellite (kg)
C = 1.25; % Drag coefficient
A = 9; 
G = 6.67408e-11;
r = hypot(z(1,end),z(3,end)); %Current distance from origin
R = 6051800; %Radius of Venus
theta = atan2d(z(1,end),z(3,end)); %Angle between spacecraft position and origin
phi = atan2d(z(2,end),z(4,end)); %Angle between spacecraft velocity and origin
z_sign = sign(z(:,end)); %Signs of current positions and velocities
rho = profileVenus(r-R); 
grav =(-G*M)/(r^2); 
drag = (((-C*A*rho)/(2*m)) * (z(2,end)^2 +z(4,end)^2));

%Imeplementation of ODEs using previously defined sign values as gravity
%acts opposite to the position and drag acts opposite to the velocity
dz1 = z(2,end);
dz2 = (z_sign(1)* grav *abs(sind(theta))) + (z_sign(2)* drag *abs(sind(phi)));
dz3 = z(4,end);
dz4 = (z_sign(3)* grav *abs(cosd(theta)))  + (z_sign(4)* drag *abs(cosd(phi)));

dz = [dz1; dz2; dz3; dz4];
end