%% Generate trajectory animation of 3DOF flight model

clear;
close all;

%% 1. Select the filename of the output animation (excluding file extension)
filename = 'myflight';

%% 2. Load the .mat file containing the trajectory history
load 'trajectory.mat';

%% 3. Select output animation file type:
% 0 : generate animation but don't save it
% 1 for gif (for gif, you can stop the animator at any point by closing the
% window or force stopping the script (ctrl+c))
% 2 for avi (for avi format, you must wait until the animator finishes
% before closing the window. Otherwise, the avi file will not play.
filetype = 0; % 1 for gif, 2 for avi

%% 3.1 If output filetype is gif, set the delay in seconds before the gif loops
loopdelay = 3;

%% 4. Set zoom factor (larger value = smaller plane)
boxsize = 24;

%% 5. Interpolate the flight trajectory (for higher frame rates)
% For example, an interp_factor of 1.5 would linearly interpolate the
% trajectory so that the number of frames would be increased by 1.5
% (assuming the framerate is kept constant).

interp_factor = 1.5;
ilen = length(t_list)*interp_factor; % Interpolated vector length

t_list      = interpolate(t_list,ilen);
h_list      = interpolate(h_list,ilen);
x_list      = interpolate(x_list,ilen);
y_list      = interpolate(y_list,ilen);
gamma_list  = interpolate(gamma_list,ilen);
psi_list    = interpolate(psi_list,ilen);
mu_list     = interpolate(mu_list,ilen);
Wx_list     = interpolate(Wx_list,ilen);
Wy_list     = interpolate(Wy_list,ilen);
V_list      = interpolate(V_list,ilen);

%% Gif creation
% Load STL file for 3D aircraft model
uav = stlread('glider.stl');

%% 5. Colour the aircraft for visibility and orientation
num_vert = length(uav.vertices);
cmap = zeros(num_vert,3);

% Select colour of aircraft model
colour1 = [1 0 0]; % RGB array ([1 0 0] would be the colour red)

% Paint the aircraft model (the different parts were determined through
% trial and error). Add more colours as desired.
for i = 1:num_vert
    if i > 15*num_vert/100 & i < 28.57*num_vert/100 %top left wing
        for j = 1:3
            cmap(i,j) = colour1(j);
        end
    end
    if i > 28.6*num_vert/100 & i < 38*num_vert/100 %left body
        for j = 1:3
            cmap(i,j) = colour1(j);
        end
    end
    if i > 43*num_vert/100 & i < 50*num_vert/100 %right body
        for j = 1:3
            cmap(i,j) = colour1(j);
        end
    end
    if i > 69.3*num_vert/100 & i < 70.57*num_vert/100 %right elevator top
        for j = 1:3
            cmap(i,j) = colour1(j);
        end
    end
    if i > 71.73*num_vert/100 & i < 72.9*num_vert/100 %left elevator top
        for j = 1:3
            cmap(i,j) = colour1(j);
        end
    end
    if i > 90*num_vert/100 & i < 100*num_vert/100 %top right wing
        for j = 1:3
            cmap(i,j) = colour1(j);
        end
    end
end

% Initialize video file
if filetype == 2
    v = VideoWriter([filename,'.avi']);
    v.FrameRate = interp_factor/dt;
    open(v);
end

%% 6. Begin animation loop
for k = 1:length(t_list)
    fig = figure(1); clf;
    set(gcf,'Position',[0 0 1920 1080],'color','w');
    ax = axes('XLim',[min(x_list) max(x_list)+100],'YLim',[min(y_list) max(y_list)],'ZLim',[min(h_list) max(h_list)]);
    plot3(x_list(1:k),y_list(1:k),h_list(1:k),'b');
    xlim([x_list(k)-boxsize, x_list(k)+boxsize])
    ylim([y_list(k)-boxsize, y_list(k)+boxsize])
    zlim([h_list(k)-boxsize, h_list(k)+boxsize])
    daspect([1 1 1])
    grid on;
    hold on;
    
    %% Set view angle as required
    view(-25,25); % (azimuth, elevation) in degrees

    % Generate ground at z=0 (flat mesh)
    if h_list(k)-boxsize <= 0
        x = [x_list(k)-boxsize, x_list(k)+boxsize];
        y = [y_list(k)-boxsize, y_list(k)+boxsize];
        Z = zeros(length(x),length(y));

        [X,Y] = meshgrid(x,y);
        color = 0.5*ones(length(x),length(y),3);

        surf(X,Y,Z,color,'FaceColor','flat','LineStyle','none');
    end
    
    % Plot start and end markers of the trajectory
    plot3(x_list(1),y_list(1),h_list(1),'color',[0 0.75 0],'marker','.');
    plot3(x_list(end),y_list(end),h_list(end),'.r');
    
    % Main plot axis labels
    xlabel('x [ft]');
    ylabel('y [ft]');
    zlabel('height [ft]');
    
    %% Miniplot - trajectory overview
    axes('Position',[.72 .72 .15 .22]); % Set the plot's position (x coord, y coord, width, height)
    plot3(x_list,y_list,h_list,'b'); % Draw the trajectory
    hold on;
    plot3(x_list(k),y_list(k),h_list(k),'color','r','markersize',15,'marker','.'); % Draw the marker representing the aircraft
    grid on;
    view(10,10); % Change viewing angle
    axis equal;
    hold off;
    title('Trajectory Overview');
    
    %% Miniplot - attitude indicator
    axes('Position',[.7 .44 .2 .2]) % Set the plot's position (x coord, y coord, width, height)
    radius = rad2deg(gamma_max)*1.1;
    angle = -mu_list(k);
    gamma = gamma_list(k);
    
    if gamma >= 0
        pitch = atan(mod(rad2deg(gamma),360)/radius);
    else
        pitch = atan(mod(rad2deg(gamma),-360)/radius);
    end
    
    if abs(angle) >= mu_max || abs(gamma) >= gamma_max
        polarplot([angle+pitch pi+angle-pitch],sqrt(((radius)^2)+(gamma)^2)*[1 1],'linewidth',2,'color','r');
    else
        polarplot([angle+pitch pi+angle-pitch],sqrt(((radius)^2)+(gamma)^2)*[1 1],'linewidth',2,'color','b');
    end
    hold on;
    polarplot([0 pi],radius*[1,1],'linewidth',1,'color','k');
    polarhistogram('BinEdges',[mu_max pi-mu_max pi+mu_max 2*pi-mu_max],'BinCounts',radius*[2 0 2],'FaceColor','r','FaceAlpha',0.1,'EdgeAlpha',0)
    rlim([0 radius]);
    box on
    title(['Attitude (',char(176),')']);
    
    %% Miniplot - heading and wind indicator
    axes('Position',[.7 .15 .2 .2]) % Set the plot's position (x coord, y coord, width, height)
    max_radius = max(V_list);
    radius = V_list(k);
    heading = psi_list(k);
    polarplot([0 heading],[0 radius],'linewidth',2,'color','b'); % Plot heading angle
    hold on;
    polarplot([0 pi/2+atan(Wy_list(k)/Wx_list(k))],[0 sqrt(Wx_list(k)^2+Wy_list(k)^2)],'linewidth',2,'color',0.75*[0 1 0]); % Plot wind profile direction
    rlim([0 max_radius])
    box on
    title(['Heading and Wind Velocities (',char(176),', ft/s)']);
    ttl = {'N (+y)';'30';'60';'E (+x)';'120';'150';'S';'210';'240';'W';'300';'330'}; % Theta axis labels
    set(gca,'ThetaZeroLocation','top','ThetaDir','clockwise','thetaticklabels',ttl)
        
    %% Initialize 3D UAV Object
    % Note: the main plot must be drawn after the miniplots (do not move
    % this section up higher)
    figure('visible','off');clf;
    model = patch('Faces',uav.faces,'Vertices',uav.vertices,'FaceVertexCData',cmap,'EdgeColor', 'none');
    model.FaceColor = 'flat';
    t = hgtransform('Parent',ax);
    set(model,'Parent',t);

    % Transform UAV Object
    trans = makehgtform('translate',[x_list(k) y_list(k) h_list(k)]);
    rotz = makehgtform('zrotate',-psi_list(k)-pi);
    rotx = makehgtform('xrotate',-gamma_list(k));
    roty = makehgtform('yrotate',-mu_list(k));
    set(t,'Matrix',trans*rotz*rotx*roty);
    
    %% Draw entire frame and save frame
    frame = getframe(fig);
    
    if filetype == 1
        gifname = [filename,'.gif']; % Save directory
        im = frame2im(frame);
        [imind,cm] = rgb2ind(im,256);
        if k == 1
            imwrite(imind,cm,gifname,'gif','DelayTime',dt/interp_factor,'Loopcount',inf);
        elseif k == length(t_list)
            imwrite(imind,cm,gifname,'gif','DelayTime',loopdelay,'WriteMode','append');
        else
            imwrite(imind,cm,gifname,'gif','DelayTime',dt/interp_factor,'WriteMode','append');
        end
    elseif filetype == 2
        writeVideo(v,frame);
    end
end

% Close video file
if filetype == 2
    close(v);
end
