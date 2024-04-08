function [t,z] = ivpSolver(inputs,varargin)
% ivpSolver    Solve an initial value problem (IVP) and plot the result
% 
%     [T,Z] = ivpSolver(T0,Z0,DT,TE) computes the IVP solution using a step 
%     size DT, beginning at time T0 and initial state Z0 and ending at time 
%     TEND. The solution is output as a time vector T and a matrix of state 
%     vectors Z.

% Set initial conditions
t(1) = inputs(1);
t0= inputs(1);
dt = inputs(2);
tend = inputs(3);
z(:,1) = inputs(4:end);

% Continue stepping until the end time is exceeded
n=1;
while t(n) <= tend
    % Apply RungeKutta's method for one time step
    new_z = stepRK4(z(:,n), dt);
    
    % Breaks the loop once stateDeriv returns a non valid results (due to
    % the spacecraft hitting the surface of Venus
    if any(isnan(new_z)|isinf(new_z))
        break
    else
        % Increment the time vector by one time step
        t(n+1) = t(n) + dt;
        z(:,n+1) = new_z;
        n=n+1;
    end
end

% Plots spacecraft path if additional argument is passed to the function
% when it's called
if isempty(varargin)
    %Caclucates an array of total displacements
    H = hypot(z(1,:),z(3,:));
    
    %Defines initial conditions of apoapsis and periapsis
    max_H=[0;0];
    min_H=[1e9;0];
    main_ax=gca;
    
    % Draws Venus
    rectangle(main_ax,'Position',[-6051800 -6051800 12103600 12103600],'Curvature',[1,1],'FaceColor', '#ae6220');
    
    % Assigns variable for animated spacecraft path plotting
    displacement = animatedline(main_ax);
    axis(main_ax,[-1e7,1e7,-1e7,1e7],'auto','equal');
    
    % Disables panning and zooming of plot
    disableDefaultInteractivity(main_ax)
    
    % Specifies the time at which the spacecraft crosses the y-axis for the
    % first time (necessary to properly calculate periapsis and apoapsis and
    % ignore intial displacement)
    start_t = 840/dt;
    
    % Defines lines for periapsis and apoapsis
    max_line=line(main_ax,0,0,'Color','red','LineStyle','--');
    min_line=line(main_ax,0,0,'Color','green','LineStyle','--');
    
    % Variable that controls the animation speed
    update_step=50;
    
    for i= t0:update_step:size(t,2)
        if i+update_step<size(z,2)
            % Adds path data points in chunks
            addpoints(displacement,z(3,i+1:i+update_step),z(1,i+1:i+update_step));
        else
            addpoints(displacement,z(3,i:end),z(1,i:end));
        end
        if i>=start_t
            % Calculates max and min displacements at current point in path
            [h_max,h1_pos]=max(H(start_t:i));
            [h_min,h2_pos]=min(H(start_t:h1_pos));
            if h_max >max_H(1)
                max_H=[h_max;h1_pos];
                 % Updates apoapsis line if new apoapsis is found
                set(max_line,'XData',[0 z(3,max_H(2)-1+start_t)],'YData',[0 z(1,max_H(2)-1+start_t)]);
            else
            end
            if h_min <min_H(1)
                min_H=[h_min;h2_pos];
                % Updates periapsis line if new periapsis is found
                set(min_line,'XData',[0 z(3,min_H(2)-1+start_t)],'YData',[0 z(1,min_H(2)-1+start_t)]);
            else
            end
        end
        drawnow;
    end
end