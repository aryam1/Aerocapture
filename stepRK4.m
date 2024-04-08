function znext = stepRK4(z,dt)
% stepRungeKutta    Compute one step using the RungeKutta method
% 
%     ZNEXT = stepRungeKutta(T,Z,DT) computes the state vector ZNEXT at the next
%     time step T+DT

% Calculate the state derivative from the current state
dz = stateDeriv(z);

% Calculate A, B,C and D for dz

A = dt * dz;

B = dt * stateDeriv(z + A/2);

C = dt * stateDeriv(z + B/2);

D = dt * stateDeriv(z + C);

% Calculate the next state vector from the previous one using Euler's
% update equation

znext = z +(A+2*B+2*C+D)/6;
end


