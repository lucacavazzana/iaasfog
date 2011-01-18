function [] = popup2(string)

f = figure('Visible','off','Position',[360,500,400,85]);

hLabel = uicontrol('Style','text',...
                   'String',string,...
                   'Position',[5,35,390,40]);

hButt = uicontrol('Style','pushbutton',...
                  'String','close',...
                  'Position',[30,5,100,25],...
                  'Callback',@ok_Call);

align([hLabel,hButt],'Center','None');
% Assign the GUI a name to appear in the window title.
set(f,'Name','Error','Menubar','None')
% Move the GUI to the center of the screen.
movegui(f,'center')
% Make the GUI visible.
set(f,'Visible','on');

    function ok_Call(source,eventdata)
        close(f);
    end

end