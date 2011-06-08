function [fol, img, nImg] = iaasGui()

%   Copyright 2011 Stefano Cadario, Luca Cavazzana.
%   $Revision: xxxxx $  $Date: 2011/05/07 $

f = figure('Visible','off','Position',[360,500,400,120]);

hFolderLabel = uicontrol('Style','text','String','image folder',...
    'Position',[15,90,100,25]);

hFolder = uicontrol('Style','edit','String',pwd,...
    'Position',[115,90,200,25]);

hFolderButt = uicontrol('Style','pushbutton','String','select',...
    'Position',[315,90,70,25],...
    'Callback',@folder_Call);

hNameLabel = uicontrol('Style','text','String','first image',...
    'Position',[15,60,100,25]);

hName = uicontrol('Style','edit',...
    'Position',[115,60,200,25]);

hNameButt = uicontrol('Style','pushbutton','String','select',...
    'Position',[315,60,70,25],...
    'Callback',@file_Call);

hNumLabel = uicontrol('Style','text','String','images number',...
    'Position',[15,30,100,25]);

hNum = uicontrol('Style','edit',...get
    'Position',[115,30,200,25]);

hConfirmButt = uicontrol('Style','pushbutton','String','confirm',...
    'Position',[315,5,70,25],...
    'Callback',@confirm_Call);

% Assign the GUI a name to appear in the window title.
set(f,'Name','iaasFog','Menubar','None');
% Move the GUI to the center of the screen.
movegui(f,'center');
% Make the GUI visible.
set(f,'Visible','on');
drawnow;
uiwait;
close(f);

    function folder_Call(source,eventdata)
        set(hFolder,'String',uigetdir(get(hFolder,'String')));
    end

    function file_Call(source, eventdata)
        set(hName, 'String', uigetfile({'*.jpg;*.tif;*.png;*.gif','All Image Files';...
            '*.*','All Files'}, 'Select the first file',get(hFolder,'String')));
    end

    function confirm_Call(source, eventdata)
        if (exist(get(hFolder,'String'),'dir')~=7)
            popup('Folder doesn''t exist');
        elseif (exist([get(hFolder,'String'),'/',get(hName,'String')],'file')~=2)
            popup('Missing file');
        elseif (mod(str2double(get(hNum,'String')),1)~=0 || str2double(get(hNum,'String')) <= 0)
            popup('Not a positive integer');
        else
            fol = get(hFolder,'String');
            img = get(hName,'String');
            nImg = str2double(get(hNum,'String'));
            uiresume;
        end
    end

end