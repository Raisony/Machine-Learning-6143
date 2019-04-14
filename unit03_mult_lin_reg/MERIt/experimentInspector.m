function experimentInspector


%  Create and then hide the GUI as it is being constructed.
hMain = figure('Visible','off','Position',[400,500,300,300],...
    'NumberTitle','off',...
    'Toolbar','none',...
    'MenuBar','none');
initData.('experimentData') = struct;
initData.('InHandles') = [];
initData.('OutHandles') = [];
initData.('PlotHandles') = [];
initData.('hTxtRep') = [];
initData.('hLbhRep') = [];
initData.('repIdx') = 1;


set(hMain,'UserData',initData);

hetSelectFile = uicontrol(hMain,'Style','edit',...
    'String','experiment file ...',...
    'Position',[10 270 200 20],...
    'Callback',{@hetSelectFile_Callback});
set(hetSelectFile,'UserData',['.',filesep]);

hpbSelectFile = uicontrol('Style','pushbutton','String','file...',...
    'Position',[220 270 50 20],...
    'Callback',{@hpbSelectFile_Callback});


% Initialize the GUI.
% Change units to normalized so components resize
% automatically.
set([hMain,hetSelectFile, hpbSelectFile],...
    'Units','normalized');

align([hetSelectFile, hpbSelectFile],'fixed',10,'middle')

% Assign the GUI a name to appear in the window title.
set(hMain,'Name','TUDOR experiment inspector')
% Move the GUI to the center of the screen.
movegui(hMain,'center')

% Make the GUI visible.
set(hMain,'Visible','on');


    function hpbSelectFile_Callback(source,eventdata)
        
        % Open file selection dialog
        DialogTitle = 'Select experiment data:';
        [FileName,PathName] = uigetfile('./*.mat',DialogTitle, get(hetSelectFile,'UserData'));
        
        
        if ~(FileName == 0)
            % Update edit text
            set(hetSelectFile,'String',fullfile(PathName,FileName));
            hetSelectFile_Callback(hetSelectFile);
        end
        
    end

    function hetSelectFile_Callback(source,eventdata)
        
        FullFileName = get(source,'String');
        [filePath] = fileparts(FullFileName);
        
        set(hetSelectFile,'UserData',filePath);
        
        UserData = get(hMain,'UserData');
        tmp = load(FullFileName);
        UserData.('experimentData') = tmp.('experimentData');
        
        set(hMain,'UserData',UserData);
        hMainUpdateControls_Callback(hMain);
        
    end

    function hMainUpdateControls_Callback(source,eventdata)
        
        UserData = get(hMain,'UserData');
        
        %% Delete existing checkboxes
        nIn = numel(UserData.('InHandles'));
        nOut = numel(UserData.('OutHandles'));
        
        for iIn = 1:nIn
            delete(UserData.('InHandles')(iIn));
        end
        for iOut = 1:nOut
            delete(UserData.('OutHandles')(iOut));
        end
        
        % also delete repetion uicontrols
        delete(UserData.('hLbhRep'))
        delete(UserData.('hTxtRep'))
        
        %% Create new checkboxes
        inNames = UserData.('experimentData').InputName;
        outNames = UserData.('experimentData').OutputName;
        
        nIn = size(inNames,1);
        nOut = size(outNames,1);
        
        UserData.('InHandles') = [];
        UserData.('OutHandles') = [];
        
        % Input checkboxes
        for iIn = 1:ceil(nIn/2) % left column
            if iIn == ceil(nIn/2)
                UserData.('InHandles')(iIn) = uicontrol(hMain,'Style','checkbox',...
                    'String',inNames(iIn,:),'Units','Normalized',...
                    'Value',0,'Position',[0.05 0.75 0.4 0.05],...
                    'Callback',{@chkboxUpdate_Callback});
            else
                UserData.('InHandles')(iIn) = uicontrol(hMain,'Style','checkbox',...
                    'String',inNames(iIn,:),'Units','Normalized',...
                    'Value',0,'Position',[0.05 0.8 0.4 0.05],...
                    'Callback',{@chkboxUpdate_Callback});
            end
        end
        for iIn = ceil(nIn/2)+1:nIn % right column
            UserData.('InHandles')(iIn) = uicontrol(hMain,'Style','checkbox',...
                'String',inNames(iIn,:),'Units','Normalized',...
                'Value',0,'Position',[0.55 0.8 0.4 0.05],...
                'Callback',{@chkboxUpdate_Callback});
        end
        
        % Output checkboxes
        for iOut = 1:ceil(nOut/2) % left column
            if iOut == ceil(nOut/2)
                UserData.('OutHandles')(iOut) = uicontrol(hMain,'Style','checkbox',...
                    'String',outNames(iOut,:),'Units','Normalized',...
                    'Value',0,'Position',[0.05 0.2 0.4 0.05],...
                    'Callback',{@chkboxUpdate_Callback});
            else
                UserData.('OutHandles')(iOut) = uicontrol(hMain,'Style','checkbox',...
                    'String',outNames(iOut,:),'Units','Normalized',...
                    'Value',0,'Position',[0.05 0.65-0.0001*iOut 0.4 0.05],...
                    'Callback',{@chkboxUpdate_Callback});
            end
        end
        for iOut = ceil(nOut/2)+1:nOut % right column
            UserData.('OutHandles')(iOut) = uicontrol(hMain,'Style','checkbox',...
                'String',outNames(iOut,:),'Units','Normalized',...
                'Value',0,'Position',[0.55 0.65-0.0001*iOut 0.4 0.05],...
                'Callback',{@chkboxUpdate_Callback});
        end
        
        
        % Distribute and align
        align([UserData.('InHandles')(1:ceil(nIn/2))],...
            'none','distribute')
        align([UserData.('InHandles')(ceil(nIn/2):nIn)],...
            'none','distribute')
        align([UserData.('OutHandles')(1:ceil(nOut/2))],...
            'none','distribute')
        align([UserData.('OutHandles')(ceil(nOut/2):nOut)],...
            'none','distribute')
        
        
        % Listbox for repetition selection
        UserData.('hTxtRep') = uicontrol(hMain,'Style','text',...
            'String','Repetition:','Units','Normalized',...
            'Position',[0.05 0.08 0.4 0.08]);
        
        UserData.('hLbhRep') = uicontrol(hMain,'Style','listbox',...
            'String',UserData.('experimentData').ExperimentName,'Units','Normalized',...
            'Value',1,'Position',[0.45 0.08 0.4 0.08],...
            'Callback',{@lstboxUpdate_Callback});
        
        align( UserData.('hTxtRep'),'left','none')
        align( UserData.('hLbhRep'),'left','none')
               
        set(hMain,'UserData',UserData);
        
        lstboxUpdate_Callback(UserData.('hLbhRep'));
        
    end

    function lstboxUpdate_Callback(source,eventdata)
        UserData = get(hMain,'UserData');
        
        lstVal = get(source,'Value');
        lstStr = get(source,'String');
        
        selStr = lstStr{lstVal};
        
        UserData.RepIdx = str2num(selStr(end-2:end));
        
        set(hMain,'UserData', UserData);
        
        nIn = numel(UserData.('InHandles'));
        for iIn = 1:nIn
            chkboxUpdate_Callback(UserData.('InHandles')(iIn));
        end
        
        nOut = numel(UserData.('OutHandles'));
        for iOut = 1:nOut
            chkboxUpdate_Callback(UserData.('OutHandles')(iOut));
        end
        
    end

    function chkboxUpdate_Callback(source,eventdata)
        
        chkString = get(source,'String');
        chkVal = get(source,'Value');
        
        UserData = get(hMain,'UserData');
        
        if chkVal == 1 % make a new plot
            
            figHandle = findobj(UserData.('PlotHandles'),'Type','Figure','-and','Name',chkString{1});
            if isempty(figHandle)
                figHandle = figure('Name', chkString{1},'NumberTitle','off', 'DeleteFcn',{@plotfigCloseFcn} );
                set(figHandle,'UserData',hMain);
                UserData.('PlotHandles')(end+1) = figHandle;
            else
                figure(figHandle);
            end

            % Plot the data according to it's type
            switch chkString{1}
                case {'commanded joint Angle q1';...
                        'commanded joint Angle q2';...
                        'commanded joint Angle q3'}
                    
                    % limits
                    q1Lim = 180/pi*[-2.9671;    3.1416];
                    q2Lim = 180/pi*[ -0.2443;    3.3510];
                    q3Lim = 180/pi*[-1.7802;    1.7802];
                    
                    
                    switch chkString{1}(end)
                        case '1'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').InputData{UserData.RepIdx}(:,1)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q1Lim(1),q1Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q1Lim(2),q1Lim(2)] ,'r')
                            hold off;
                            ylabel('com. \itq_1 \rm[deg]')
                        case '2'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').InputData{UserData.RepIdx}(:,2)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q2Lim(1),q2Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q2Lim(2),q2Lim(2)] ,'r')
                            hold off;
                            ylabel('com. \itq_2 \rm[deg]')

                        case '3'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').InputData{UserData.RepIdx}(:,3)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q3Lim(1),q3Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q3Lim(2),q3Lim(2)] ,'r')
                            hold off;
                            ylabel('com. \itq_3 \rm[deg]')

                    end
                    
                    
                    
                case {'joint angle q1';...
                        'joint angle q2';...
                        'joint angle q3'}
                    
                    % limits
                    q1Lim = 180/pi*[-2.9671;    3.1416];
                    q2Lim = 180/pi*[ -0.2443;    3.3510];
                    q3Lim = 180/pi*[-1.7802;    1.7802];
                                      
                    
                    switch chkString{1}(end)
                        case '1'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,1)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q1Lim(1),q1Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q1Lim(2),q1Lim(2)] ,'r')
                            hold off;
                            ylabel('\itq_1 \rm[deg]')
                       case '2'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,2)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q2Lim(1),q2Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q2Lim(2),q2Lim(2)] ,'r')
                            hold off;
                            ylabel('\itq_2 \rm[deg]')
                        case '3'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,3)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q3Lim(1),q3Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[q3Lim(2),q3Lim(2)] ,'r')
                            hold off;
                            ylabel('\itq_3 \rm[deg]')
                    end
                    
                    
                case {'joint angular velocity dq1';...
                        'joint angular velocity dq2';...
                        'joint angular velocity dq3'}
                    
                    % limits
                    qDot1Lim = 180/pi*[-3.2221;    3.2221];
                    qDot2Lim = 180/pi*[ -2.1855;    2.1855];
                    qDot3Lim = 180/pi*[-2.5541;    2.5541];
                                      
                    switch chkString{1}(end)
                        case '1'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,4)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[qDot1Lim(1),qDot1Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[qDot1Lim(2),qDot1Lim(2)] ,'r')
                            hold off;
                            ylabel('\itqDot_1 \rm[deg/s]')
                        case '2'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,5)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[qDot2Lim(1),qDot2Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[qDot2Lim(2),qDot2Lim(2)] ,'r')
                            hold off;
                            ylabel('\itqDot_2 \rm[deg/s]')
                        case '3'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,6)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[qDot3Lim(1),qDot3Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[qDot3Lim(2),qDot3Lim(2)] ,'r')
                            hold off;
                            ylabel('\itqDot_3 \rm[deg/s]')
                    end
                    
                case {'joint current I1';...
                        'joint current I2';...
                        'joint current I3'}
                    
                    % limits
                    i1Lim = [-3.9500;    3.9500];
                    i2Lim =[ -3.9500;    3.9500];
                    i3Lim = [-2.8500;    2.8500];
        
                    
                    switch chkString{1}(end)
                        case '1'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                UserData.('experimentData').OutputData{UserData.RepIdx}(:,7)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[i1Lim(1),i1Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[i1Lim(2),i1Lim(2)] ,'r')
                            ylabel('\iti_1 \rm[A]')
                            hold off;
                        case '2'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                UserData.('experimentData').OutputData{UserData.RepIdx}(:,8)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[i2Lim(1),i2Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[i2Lim(2),i2Lim(2)] ,'r')
                            hold off;
                            ylabel('\iti_2 \rm[A]')
                        case '3'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                UserData.('experimentData').OutputData{UserData.RepIdx}(:,9)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[i3Lim(1),i3Lim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[i3Lim(2),i3Lim(2)] ,'r')
                            hold off;
                            ylabel('\iti_3 \rm[A]')

                    end
                    hold off;
                    
                case {'strain measured on 2nd link eps21';...
                        'strain measured on 2nd link eps22';...
                        'strain measured on 3rd link eps31';...
                        'strain measured on 3rd link eps32'}
                    
                    % limits
                    epsLim = [-1500, 1500];

                    
                    switch chkString{1}(end-1:end)
                        case '21'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                UserData.('experimentData').OutputData{UserData.RepIdx}(:,10)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[epsLim(1),epsLim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[epsLim(2),epsLim(2)] ,'r')
                            ylabel('\it\epsilon_{21} \rm[\mum/m]')
                            hold off;
                        case '22'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                UserData.('experimentData').OutputData{UserData.RepIdx}(:,11)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[epsLim(1),epsLim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[epsLim(2),epsLim(2)] ,'r')
                            ylabel('\it\epsilon_{22} \rm[\mum/m]')
                            hold off;
                        case '31'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                UserData.('experimentData').OutputData{UserData.RepIdx}(:,12)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[epsLim(1),epsLim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[epsLim(2),epsLim(2)] ,'r')
                            ylabel('\it\epsilon_{31} \rm[\mum/m]')
                            hold off;
                        case '32'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                UserData.('experimentData').OutputData{UserData.RepIdx}(:,13)...
                                ,'b');
                            hold on
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[epsLim(1),epsLim(1)] ,'r')
                            plot([UserData.('experimentData').samplingInstants{UserData.RepIdx}(1);UserData.('experimentData').samplingInstants{UserData.RepIdx}(end)],[epsLim(2),epsLim(2)] ,'r')
                            ylabel('\it\epsilon_{32} \rm[\mum/m]')
                            hold off;
                    end
                    hold off;
                    
                case  {'joint angular acceleration ddq1 (noisy)';...
                        'joint angular acceleration ddq2 (noisy)';...
                        'joint angular acceleration ddq3 (noisy)'}

                    
                    switch chkString{1}(end-8)
                        case '1'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,14)...
                                ,'b');
                            ylabel('\itqDotDot_1 \rm[deg/s^2]')
                        case '2'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,15)...
                                ,'b');
                            ylabel('\itqDotDot_2 \rm[deg/s^2]')
                        case '3'
                            plot(UserData.('experimentData').samplingInstants{UserData.RepIdx},...
                                180/pi*UserData.('experimentData').OutputData{UserData.RepIdx}(:,16)...
                                ,'b');
                            ylabel('\itqDotDot_3 \rm[deg/s^2]')
                    end
                    hold off;
                    
                otherwise
            end
            xlabel('\itt \rm[s]');
            title(['Rep. ', num2str(UserData.RepIdx)]);
            set(hMain,'UserData',UserData);
            
        else % close a possibly open plot figure
            partFigure = findobj(UserData.('PlotHandles'),'Type','Figure','-and','Name',chkString{1});
            close(partFigure);
        end
        
    end

    function plotfigCloseFcn(source, eventdata)
        mainHandle = get(source,'UserData');
        
        if ishandle(mainHandle)
            UserData = get(mainHandle,'UserData');
            
            sourceName = get(source,'Name');
            
            partCheckBox = findobj(get(mainHandle,'children'),'Style','Checkbox','-and','String',{sourceName});
            
            set(partCheckBox,'Value',0);
            
            UserData.('PlotHandles')(UserData.('PlotHandles') == source) = [];
            
            set(mainHandle,'UserData',UserData);
        end
        
        
    end
end

