classdef MainGUI < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        MainUI                       matlab.ui.Figure
        MainGrid                     matlab.ui.container.GridLayout
        InputGrid                    matlab.ui.container.GridLayout
        StartTimeLabel               matlab.ui.control.Label
        StartTimeEditField           matlab.ui.control.NumericEditField
        TimeStepLabel                matlab.ui.control.Label
        TimeStepEditField            matlab.ui.control.NumericEditField
        EndTimeLabel                 matlab.ui.control.Label
        EndTimeEditField             matlab.ui.control.NumericEditField
        EditFieldLabel               matlab.ui.control.Label
        AlphaEditField               matlab.ui.control.NumericEditField
        VerticalVelocityLabel        matlab.ui.control.Label
        VerticalVelocityEditField    matlab.ui.control.NumericEditField
        InitialDistancexLabel        matlab.ui.control.Label
        InitialDistancexEditField    matlab.ui.control.NumericEditField
        HorizontalVelocityLabel      matlab.ui.control.Label
        HorizontalVelocityEditField  matlab.ui.control.NumericEditField
        SimulateButton               matlab.ui.control.Button
        AnimationButton              matlab.ui.container.ButtonGroup
        ButtonOn                     matlab.ui.control.RadioButton
        ButtonOff                    matlab.ui.control.RadioButton
        TabGroup                     matlab.ui.container.TabGroup
        Path                         matlab.ui.container.Tab
        PathGrid                     matlab.ui.container.GridLayout
        HGrid                        matlab.ui.container.GridLayout
        PeriapsisLabel               matlab.ui.control.Label
        ApoapsisLabel                matlab.ui.control.Label
        Periapsis                    matlab.ui.control.Label
        Apoapsis                     matlab.ui.control.Label
        SliderGrid                   matlab.ui.container.GridLayout
        Label                        matlab.ui.control.Label
        Slider                       matlab.ui.control.Slider
        PathFigure                   matlab.ui.control.UIAxes
        Displacement                 matlab.ui.container.Tab
        DisplacementFigure           matlab.ui.control.UIAxes
        Velocity                     matlab.ui.container.Tab
        VelocityFigure               matlab.ui.control.UIAxes
        Acceleration                 matlab.ui.container.Tab
        AccelerationFigure           matlab.ui.control.UIAxes
    end

    
    methods (Access = private)
        
        function GraphDraw (app,t,z,data)
            % Clears plots on main figure
            cla(app.PathFigure);
            % Sets time variables
            t0=data(1);
            dt = data(2);
            %Caclucates an array of total displacements
            H=hypot(z(1,:),z(3,:));
            %Defines initial conditions of apoapsis and periapsis
            max_H=[0;0];
            min_H=[1e9;0];
            % Gets axis reference of main figure
            main_ax=app.PathFigure;
            % Draws Venus
            rectangle(main_ax,'Position',[-6051800 -6051800 12103600 12103600],'Curvature',[1,1],'FaceColor', '#ae6220');
            % Disables panning and zooming of plot
            disableDefaultInteractivity(main_ax)
            % Defines lines for periapsis and apoapsis
            max_line=line(main_ax,0,0,'Color','red','LineStyle','--');
            min_line=line(main_ax,0,0,'Color','green','LineStyle','--');
            % Specifies the time at which the spacecraft crosses the y-axis for the
            % first time (necessary to properly calculate periapsis and apoapsis and
            % ignore intial displacement)
            start_t = 840/dt;
            
            % Since the default method of handling concurrent callbacks in
            % MATLAB is to queue them, this try catch statement works
            % around that and discards multiple button callbacks in case
            % the user calls for too many simulations at once
            try
                % Checks if the user has selected animation to be on or off
                if app.ButtonOn.Value
                    %Animated path plot
                    displacement = animatedline(main_ax);
                    axis(main_ax,[-1e7,1e7,-1e7,1e7],'equal');
                    % Locks axis to square shape
                    pbaspect(main_ax,[1 1 1]);
                    % Gets animation speed from slider value
                    update_step=round(app.Slider.Value+1);
                    for i= t0:update_step:size(t,2)
                        % Adds path data points in chunks
                        if i+update_step<size(z,2)
                            addpoints(displacement,z(3,i+1:i+update_step),z(1,i+1:i+update_step));
                        else
                            addpoints(displacement,z(3,i:end),z(1,i:end));
                        end
                        if i>=start_t
                            [h_max,h1_pos]=max(H(start_t:i-update_step));
                            [h_min,h2_pos]=min(H(start_t:h1_pos));
                            if h_max >max_H(1)
                                max_H=[h_max;h1_pos];
                                % Updates apoapsis line if new apoapsis is found
                                set(max_line,'XData',[0 z(3,max_H(2)-1+start_t)],'YData',[0 z(1,max_H(2)-1+start_t)]);
                                % Scales axis to match size of plot whilst
                                % keeping Venus centered and axis square
                                if h_max > (1e7*sind(45))
                                    axis(main_ax,"auto","equal");
                                    x_lim=max(abs(main_ax.XLim));
                                    y_lim=max(abs(main_ax.XLim));
                                    main_ax.XLim=[-x_lim,x_lim];
                                    main_ax.YLim=[-y_lim,y_lim];
                                end
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
                else
                    % Holds axis to allow for multiple plots
                    hold(main_ax)
                    % Calculates and draws periapsis and apoapsis lines
                    [h_max,h1_pos]=max(H(start_t:end));
                    [h_min,h2_pos]=min(H(start_t:h1_pos));
                    max_H=[h_max;h1_pos];
                    set(max_line,'XData',[0 z(3,max_H(2)-1+start_t)],'YData',[0 z(1,max_H(2)-1+start_t)]);
                    min_H=[h_min;h2_pos];
                    set(min_line,'XData',[0 z(3,min_H(2)-1+start_t)],'YData',[0 z(1,min_H(2)-1+start_t)]);
                    % Plots path of spacecraft
                    plot(main_ax,z(3,:), z(1,:),'black')
                    % Scales axis to fit path
                    axis(main_ax,"auto","equal");
                    x_lim=max(abs(main_ax.XLim));
                    y_lim=max(abs(main_ax.XLim));
                    main_ax.XLim=[-x_lim,x_lim];
                    main_ax.YLim=[-y_lim,y_lim];
                    hold(main_ax,'off')
                end
            catch
                % Resets the figure if too many callbacks are enqueued
                cla(app.PathFigure)
            end
            
            % Calculates acceleration of the spacecraft
            ddz = diff(hypot(z(2,:),z(4,:))) / dt;
            
            % Plots displacement, velocity and acceleration against time on
            % other tabs of program
            plot(app.DisplacementFigure,t,((z(1,:).^2+z(3,:).^2).^0.5),'b')
            plot(app.VelocityFigure,t,((z(2,:).^2+z(4,:).^2).^0.5),'g')
            plot(app.AccelerationFigure,t(2:end),ddz,'r')
            
            % Updates text boxes with current apoapsis and periapsis values
            app.Apoapsis.Text=(sprintf('%0.2f',(max_H(1)-6051800)/1000)+" km");
            app.Periapsis.Text=(sprintf('%0.2f',(min_H(1)-6051800)/1000)+" km");
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Button pushed function: SimulateButton
        function SimulateButtonPushed(app,~)
            % Gets all child objects of the input grid layout
            kids=app.InputGrid.Children;
            
            % Gets the value of the text boxes in the second column
            data= cell2mat(get(kids(2:2:end-1),"Value"));
            
            % Validates all the inputs against criteria such as time must
            % be positive and the displacement must be greater than the
            % radius of Venus
            validate=[-data(1);(-data(2)*10)+1;data(1)+1;1;data(5);6051800;data(7)];
            validatedInputs = data-validate;
            
            errorMsg=["   ◦ Start time must be positive",...
                "   ◦ Time step must be greater than 0",...
                "   ◦ End time must be greater than start time",...
                "   ◦ α must be positive",'',...
                "   ◦ x must be greater than the radius of Venus",""];
            errorStr="Please check the following:";
            
            % Creates and displays error message for invalid inputs
            for i = 1:length(validatedInputs)
                if validatedInputs(i)<0
                    errorStr = errorStr + newline + errorMsg(i);
                end
            end
            if any(validatedInputs<0)
                msgbox(errorStr, 'Input error','error');
            else
                % Adds Venus radius to alpha to make it easier to work with
                data(4)= data(4)+6051800;
                
                % Gets simulation data for the inputs and graphs it whilst
                % passing an optional argument to ivpSolver to supress its
                % own graphing function
                [t,z]=ivpSolver(data,1);
                app.GraphDraw(t,z,data);
            end
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create MainUI and hide until all components are created
            app.MainUI = uifigure('Visible', 'off');
            app.MainUI.Color = [0.149 0.149 0.149];
            app.MainUI.Position = [640 300 640 480];
            app.MainUI.Name = 'Aerocapture Simulation';
            app.MainUI.Icon = 'VenusIcon.png';
            app.MainUI.BusyAction = 'cancel';

            % Create MainGrid
            app.MainGrid = uigridlayout(app.MainUI);
            app.MainGrid.ColumnWidth = {'1x', '1.5x'};
            app.MainGrid.RowHeight = {'1x'};
            app.MainGrid.BusyAction = 'cancel';

            % Create InputGrid
            app.InputGrid = uigridlayout(app.MainGrid);
            app.InputGrid.ColumnWidth = {'0.55x', '1x'};
            app.InputGrid.RowHeight = {'1x', '1x', '1x', '1x', '1x', '1x', '1x', '1x'};
            app.InputGrid.Layout.Row = 1;
            app.InputGrid.Layout.Column = 1;

            % Create StartTimeLabel
            app.StartTimeLabel = uilabel(app.InputGrid);
            app.StartTimeLabel.HorizontalAlignment = 'center';
            app.StartTimeLabel.FontName = 'Artifakt Element';
            app.StartTimeLabel.Layout.Row = 1;
            app.StartTimeLabel.Layout.Column = 1;
            app.StartTimeLabel.Text = 'Start Time';

            % Create StartTimeEditField
            app.StartTimeEditField = uieditfield(app.InputGrid, 'numeric');
            app.StartTimeEditField.Limits = [0 Inf];
            app.StartTimeEditField.FontName = 'Artifakt Element';
            app.StartTimeEditField.Tooltip = {'s'};
            app.StartTimeEditField.Layout.Row = 1;
            app.StartTimeEditField.Layout.Column = 2;
            app.StartTimeEditField.ValueDisplayFormat = '%lds';

            % Create TimeStepLabel
            app.TimeStepLabel = uilabel(app.InputGrid);
            app.TimeStepLabel.HorizontalAlignment = 'center';
            app.TimeStepLabel.FontName = 'Artifakt Element';
            app.TimeStepLabel.Layout.Row = 2;
            app.TimeStepLabel.Layout.Column = 1;
            app.TimeStepLabel.Text = 'Time Step';

            % Create TimeStepEditField
            app.TimeStepEditField = uieditfield(app.InputGrid, 'numeric');
            app.TimeStepEditField.Limits = [0 Inf];
            app.TimeStepEditField.FontName = 'Artifakt Element';
            app.TimeStepEditField.Tooltip = {'s'};
            app.TimeStepEditField.Layout.Row = 2;
            app.TimeStepEditField.Layout.Column = 2;
            app.TimeStepEditField.Value = 1;
            app.TimeStepEditField.ValueDisplayFormat = '%lds';

            % Create EndTimeLabel
            app.EndTimeLabel = uilabel(app.InputGrid);
            app.EndTimeLabel.HorizontalAlignment = 'center';
            app.EndTimeLabel.FontName = 'Artifakt Element';
            app.EndTimeLabel.Layout.Row = 3;
            app.EndTimeLabel.Layout.Column = 1;
            app.EndTimeLabel.Text = 'End Time';

            % Create EndTimeEditField
            app.EndTimeEditField = uieditfield(app.InputGrid, 'numeric');
            app.EndTimeEditField.Limits = [1 Inf];
            app.EndTimeEditField.FontName = 'Artifakt Element';
            app.EndTimeEditField.Tooltip = {'s'};
            app.EndTimeEditField.Layout.Row = 3;
            app.EndTimeEditField.Layout.Column = 2;
            app.EndTimeEditField.Value = 7000;
            app.EndTimeEditField.ValueDisplayFormat = '%lds';

            % Create EditFieldLabel
            app.EditFieldLabel = uilabel(app.InputGrid);
            app.EditFieldLabel.HorizontalAlignment = 'center';
            app.EditFieldLabel.FontName = 'Artifakt Element';
            app.EditFieldLabel.Layout.Row = 4;
            app.EditFieldLabel.Layout.Column = 1;
            app.EditFieldLabel.Text = 'α';

            % Create AlphaEditField
            app.AlphaEditField = uieditfield(app.InputGrid, 'numeric');
            app.AlphaEditField.Limits = [0 Inf];
            app.AlphaEditField.FontName = 'Artifakt Element';
            app.AlphaEditField.Tooltip = {'m'};
            app.AlphaEditField.Layout.Row = 4;
            app.AlphaEditField.Layout.Column = 2;
            app.AlphaEditField.Value = 1329005;
            app.AlphaEditField.ValueDisplayFormat = '%ldm';

            % Create VerticalVelocityLabel
            app.VerticalVelocityLabel = uilabel(app.InputGrid);
            app.VerticalVelocityLabel.HorizontalAlignment = 'center';
            app.VerticalVelocityLabel.FontName = 'Artifakt Element';
            app.VerticalVelocityLabel.Layout.Row = 5;
            app.VerticalVelocityLabel.Layout.Column = 1;
            app.VerticalVelocityLabel.Text = {'Vertical '; 'Velocity'};

            % Create VerticalVelocityEditField
            app.VerticalVelocityEditField = uieditfield(app.InputGrid, 'numeric');
            app.VerticalVelocityEditField.FontName = 'Artifakt Element';
            app.VerticalVelocityEditField.Tooltip = {'m/s'};
            app.VerticalVelocityEditField.Layout.Row = 5;
            app.VerticalVelocityEditField.Layout.Column = 2;
            app.VerticalVelocityEditField.ValueDisplayFormat = '%ldm/s';

            % Create InitialDistancexLabel
            app.InitialDistancexLabel = uilabel(app.InputGrid);
            app.InitialDistancexLabel.HorizontalAlignment = 'center';
            app.InitialDistancexLabel.FontName = 'Artifakt Element';
            app.InitialDistancexLabel.Layout.Row = 6;
            app.InitialDistancexLabel.Layout.Column = 1;
            app.InitialDistancexLabel.Text = {'Initial'; 'Distance (x)'; ''};

            % Create InitialDistancexEditField
            app.InitialDistancexEditField = uieditfield(app.InputGrid, 'numeric');
            app.InitialDistancexEditField.Limits = [6051800 Inf];
            app.InitialDistancexEditField.FontName = 'Artifakt Element';
            app.InitialDistancexEditField.Tooltip = {'m'};
            app.InitialDistancexEditField.Layout.Row = 6;
            app.InitialDistancexEditField.Layout.Column = 2;
            app.InitialDistancexEditField.Value = 10000000;
            app.InitialDistancexEditField.ValueDisplayFormat = '%ldm';

            % Create HorizontalVelocityLabel
            app.HorizontalVelocityLabel = uilabel(app.InputGrid);
            app.HorizontalVelocityLabel.HorizontalAlignment = 'center';
            app.HorizontalVelocityLabel.FontName = 'Artifakt Element';
            app.HorizontalVelocityLabel.Layout.Row = 7;
            app.HorizontalVelocityLabel.Layout.Column = 1;
            app.HorizontalVelocityLabel.Text = {'Horizontal '; 'Velocity'};

            % Create HorizontalVelocityEditField
            app.HorizontalVelocityEditField = uieditfield(app.InputGrid, 'numeric');
            app.HorizontalVelocityEditField.FontName = 'Artifakt Element';
            app.HorizontalVelocityEditField.Tooltip = {'ms^-1'};
            app.HorizontalVelocityEditField.Layout.Row = 7;
            app.HorizontalVelocityEditField.Layout.Column = 2;
            app.HorizontalVelocityEditField.Value = -11000;
            app.HorizontalVelocityEditField.ValueDisplayFormat = '%ldm/s';

            % Create SimulateButton
            app.SimulateButton = uibutton(app.InputGrid, 'push');
            app.SimulateButton.ButtonPushedFcn = createCallbackFcn(app, @SimulateButtonPushed, true);
            app.SimulateButton.BusyAction = 'cancel';
            app.SimulateButton.BackgroundColor = [0.902 0.6824 0.7255];
            app.SimulateButton.FontName = 'Artifakt Element';
            app.SimulateButton.Layout.Row = 8;
            app.SimulateButton.Layout.Column = 2;
            app.SimulateButton.Text = 'Simulate';

            % Create AnimationButton
            app.AnimationButton = uibuttongroup(app.InputGrid);
            app.AnimationButton.BorderType = 'none';
            app.AnimationButton.Layout.Row = 8;
            app.AnimationButton.Layout.Column = 1;

            % Create ButtonOn
            app.ButtonOn = uiradiobutton(app.AnimationButton);
            app.ButtonOn.Tooltip = {'Animation on'};
            app.ButtonOn.Text = 'On';
            app.ButtonOn.FontName = 'Artifakt Element';
            app.ButtonOn.Position = [1 25 76 22];
            app.ButtonOn.Value = true;

            % Create ButtonOff
            app.ButtonOff = uiradiobutton(app.AnimationButton);
            app.ButtonOff.Tooltip = {'Animation off'};
            app.ButtonOff.Text = 'Off';
            app.ButtonOff.FontName = 'Artifakt Element';
            app.ButtonOff.Position = [1 3 76 22];

            % Create TabGroup
            app.TabGroup = uitabgroup(app.MainGrid);
            app.TabGroup.BusyAction = 'cancel';
            app.TabGroup.Layout.Row = 1;
            app.TabGroup.Layout.Column = 2;

            % Create Path
            app.Path = uitab(app.TabGroup);
            app.Path.Title = 'Path';
            app.Path.BusyAction = 'cancel';

            % Create PathGrid
            app.PathGrid = uigridlayout(app.Path);
            app.PathGrid.ColumnWidth = {'1x'};
            app.PathGrid.RowHeight = {'1x', '0.1x', '0.1x'};
            app.PathGrid.Padding = [10 30 10 0];
            app.PathGrid.BusyAction = 'cancel';

            % Create HGrid
            app.HGrid = uigridlayout(app.PathGrid);
            app.HGrid.ColumnWidth = {'1x', '1x', '1x', '1x'};
            app.HGrid.RowHeight = {'1x'};
            app.HGrid.ColumnSpacing = 5;
            app.HGrid.RowSpacing = 5;
            app.HGrid.Padding = [5 0 5 0];
            app.HGrid.Layout.Row = 2;
            app.HGrid.Layout.Column = 1;

            % Create PeriapsisLabel
            app.PeriapsisLabel = uilabel(app.HGrid);
            app.PeriapsisLabel.HorizontalAlignment = 'center';
            app.PeriapsisLabel.FontName = 'Artifakt Element';
            app.PeriapsisLabel.FontSize = 16;
            app.PeriapsisLabel.FontColor = [0 1 0];
            app.PeriapsisLabel.Layout.Row = 1;
            app.PeriapsisLabel.Layout.Column = 1;
            app.PeriapsisLabel.Text = 'Periapsis:';

            % Create ApoapsisLabel
            app.ApoapsisLabel = uilabel(app.HGrid);
            app.ApoapsisLabel.HorizontalAlignment = 'center';
            app.ApoapsisLabel.FontName = 'Artifakt Element';
            app.ApoapsisLabel.FontSize = 16;
            app.ApoapsisLabel.FontColor = [1 0 0];
            app.ApoapsisLabel.Layout.Row = 1;
            app.ApoapsisLabel.Layout.Column = 3;
            app.ApoapsisLabel.Text = 'Apoapsis:';

            % Create Periapsis
            app.Periapsis = uilabel(app.HGrid);
            app.Periapsis.HorizontalAlignment = 'center';
            app.Periapsis.FontName = 'Artifakt Element';
            app.Periapsis.Layout.Row = 1;
            app.Periapsis.Layout.Column = 2;
            app.Periapsis.Text = '';

            % Create Apoapsis
            app.Apoapsis = uilabel(app.HGrid);
            app.Apoapsis.HorizontalAlignment = 'center';
            app.Apoapsis.FontName = 'Artifakt Element';
            app.Apoapsis.Layout.Row = 1;
            app.Apoapsis.Layout.Column = 4;
            app.Apoapsis.Text = '';

            % Create SliderGrid
            app.SliderGrid = uigridlayout(app.PathGrid);
            app.SliderGrid.ColumnWidth = {'0x', '1x'};
            app.SliderGrid.RowHeight = {'1x'};
            app.SliderGrid.Layout.Row = 3;
            app.SliderGrid.Layout.Column = 1;

            % Create Label
            app.Label = uilabel(app.SliderGrid);
            app.Label.HorizontalAlignment = 'right';
            app.Label.FontName = 'Artifakt Element';
            app.Label.Layout.Row = 1;
            app.Label.Layout.Column = 1;
            app.Label.Text = '';

            % Create Slider
            app.Slider = uislider(app.SliderGrid);
            app.Slider.Limits = [0 1000];
            app.Slider.MinorTicks = [0 100 200 300 400 500 600 700 800 900 1000];
            app.Slider.BusyAction = 'cancel';
            app.Slider.Tooltip = {'Animation Speed'};
            app.Slider.FontName = 'Artifakt Element';
            app.Slider.FontSize = 10;
            app.Slider.Layout.Row = 1;
            app.Slider.Layout.Column = 2;
            app.Slider.Value = 200;

            % Create PathFigure
            app.PathFigure = uiaxes(app.PathGrid);
            xlabel(app.PathFigure, 'X (m)')
            ylabel(app.PathFigure, 'Y (m)')
            app.PathFigure.FontName = 'Artifakt Element';
            app.PathFigure.Layout.Row = 1;
            app.PathFigure.Layout.Column = 1;
            app.PathFigure.BusyAction = 'cancel';

            % Create Displacement
            app.Displacement = uitab(app.TabGroup);
            app.Displacement.Title = 'Displacement';

            % Create DisplacementFigure
            app.DisplacementFigure = uiaxes(app.Displacement);
            xlabel(app.DisplacementFigure, 'Time(s)')
            ylabel(app.DisplacementFigure, 'Displacement, m')
            app.DisplacementFigure.FontName = 'Artifakt Element';
            app.DisplacementFigure.Position = [11 11 334 415];

            % Create Velocity
            app.Velocity = uitab(app.TabGroup);
            app.Velocity.Title = 'Velocity';

            % Create VelocityFigure
            app.VelocityFigure = uiaxes(app.Velocity);
            xlabel(app.VelocityFigure, 'Time(s)')
            ylabel(app.VelocityFigure, 'Velocity, m/s')
            app.VelocityFigure.FontName = 'Artifakt Element';
            app.VelocityFigure.Position = [11 11 334 415];

            % Create Acceleration
            app.Acceleration = uitab(app.TabGroup);
            app.Acceleration.Title = 'Acceleration';

            % Create AccelerationFigure
            app.AccelerationFigure = uiaxes(app.Acceleration);
            xlabel(app.AccelerationFigure, 'Time(s)')
            ylabel(app.AccelerationFigure, 'Acceleration, m/s^2')
            app.AccelerationFigure.FontName = 'Artifakt Element';
            app.AccelerationFigure.Position = [11 11 334 415];

            % Show the figure after all components are created
            app.MainUI.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = MainGUI

            % Create UIFigure and components
            createComponents(app)
            
            main_ax=app.PathFigure;
            % Draws Venus and set axis
            rectangle(main_ax,'Position',[-6051800 -6051800 12103600 12103600],'Curvature',[1,1],'FaceColor', '#ae6220');
            axis(main_ax,[-1e7,1e7,-1e7,1e7],'equal');
            
            % Register the app with App Designer
            registerApp(app, app.MainUI)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.MainUI)
        end
    end
end