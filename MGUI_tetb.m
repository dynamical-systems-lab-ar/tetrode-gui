function varargout = MGUI_tetb(varargin)
% MGUI_TETB MATLAB code for MGUI_tetb.fig
%      MGUI_TETB, by itself, creates a new MGUI_TETB or raises the existing
%      singleton*.
%
%      H = MGUI_TETB returns the handle to a new MGUI_TETB or the handle to
%      the existing singleton*.
%
%      MGUI_TETB('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in MGUI_TETB.M with the given input arguments.
%
%      MGUI_TETB('Property','Value',...) creates a new MGUI_TETB or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before MGUI_tetb_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to MGUI_tetb_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help MGUI_tetb

% Last Modified by GUIDE v2.5 06-Jan-2017 16:55:56

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @MGUI_tetb_OpeningFcn, ...
                   'gui_OutputFcn',  @MGUI_tetb_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before MGUI_tetb is made visible.
function MGUI_tetb_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to MGUI_tetb (see VARARGIN)

% Choose default command line output for MGUI_tetb
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes MGUI_tetb wait for user response (see UIRESUME)
% uiwait(handles.figure1);

% Crea diary
if exist('log.txt')==2
    delete('log.txt')
end
diary('log.txt')
assignin('base','hp',designfilt('highpassiir','FilterOrder',4',...
    'DesignMethod','butter','HalfPowerFrequency',300,'SampleRate',20000));
assignin('base','hps',designfilt('highpassiir','FilterOrder',4',...
    'DesignMethod','butter','HalfPowerFrequency',60,'SampleRate',20000));
assignin('base','lp',designfilt('lowpassiir','FilterOrder',4',...
    'DesignMethod','butter','HalfPowerFrequency',300,'SampleRate',20000));
handles.audiochann=0;
handles.base=pwd;
handles.currentfolder=handles.base;
handles.player=audioplayer(0,20000);
guidata(hObject,handles)

% --- Outputs from this function are returned to the command line.
function varargout = MGUI_tetb_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on selection change in listbox_dir.
function listbox_dir_Callback(hObject, eventdata, handles)
% hObject    handle to listbox_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%%%% me fijo el seleccionado
index_selected = get(hObject,'Value');
list = get(hObject,'String');
item_selected = list{index_selected}; % Convert from cell array
                                      % to string
%%% lo leo                                     
if ~strcmp(get(gcf,'SelectionType'),'open')
    %when normal click is happened, nothing to do
   return;
end
% do something when double-clicking. insert your code after this line
diary on
read_Intan_RHD2000_file([handles.currentfolder '/' item_selected])
diary off
    if(size(evalin('base','board_adc_data'),1)>1)
        do_warning(hObject, eventdata, handles)
        if(handles.audiochann==0)
            set(handles.cm_output,'String','Execution cancelled by user');
            return
        end
    else
        handles.audiochann=1;
    end
guidata(hObject,handles)
output=fileread('log.txt');
set(handles.cm_output,'String',output);
% CUANTOS TETRODOS HAY?
update_popmenu(hObject,eventdata,handles)
set(handles.popupmenu1,'Value',1)
% PLOTEO COSAS
graphics_callback(hObject, eventdata, handles)


% Hints: contents = cellstr(get(hObject,'String')) returns listbox_dir contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox_dir

% --- Executes during object creation, after setting all properties.
function listbox_dir_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox_dir (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns calle
% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function cm_output_CreateFcn(hObject, eventdata, handles)
% hObject    handle to cm_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function cm_output_Callback(hObject, eventdata, handles)
% hObject    handle to cm_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of cm_output as text
%        str2double(get(hObject,'String')) returns contents of cm_output as a double


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
tet=get(hObject,'Value');
%get current limits of spectrogram or sound
curr_x=get(handles.ax_sound,'XLim');
if tet>1
axes(handles.ax_tetrodes1)
plot(evalin('base','t_amplifier'),evalin('base',sprintf('filtfilt(hp,amplifier_data(%d,:))',4*(tet-1)-3)))
ylabel(evalin('base',sprintf('amplifier_channels(%d).native_channel_name',4*(tet-1)-3)));
axes(handles.ax_tetrodes2)
plot(evalin('base','t_amplifier'),evalin('base',sprintf('filtfilt(hp,amplifier_data(%d,:))',4*(tet-1)-2)))
ylabel(evalin('base',sprintf('amplifier_channels(%d).native_channel_name',4*(tet-1)-2)));
axes(handles.ax_tetrodes3)
plot(evalin('base','t_amplifier'),evalin('base',sprintf('filtfilt(hp,amplifier_data(%d,:))',4*(tet-1)-1)))
ylabel(evalin('base',sprintf('amplifier_channels(%d).native_channel_name',4*(tet-1)-1)));
axes(handles.ax_tetrodes4)
plot(evalin('base','t_amplifier'),evalin('base',sprintf('filtfilt(hp,amplifier_data(%d,:))',4*(tet-1))))
ylabel(evalin('base',sprintf('amplifier_channels(%d).native_channel_name',4*(tet-1))));
xlim(curr_x)
xlabel('Time (secs)')
set(gca,'XLim',curr_x)
end
linkaxes([handles.ax_tetrodes4 handles.ax_sound handles.ax_spectrogram handles.ax_tetrodes1 ...
    handles.ax_tetrodes2 handles.ax_tetrodes3],'x')

% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
set(hObject,'String','Select tetrode...')
% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes during object creation, after setting all properties.
function ax_sound_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ax_sound (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: place code in OpeningFcn to populate ax_sound

function graphics_callback(hObject, eventdata, handles)
% limpia cosas
linkaxes([handles.ax_sound handles.ax_spectrogram handles.ax_tetrodes1 ...
    handles.ax_tetrodes2 handles.ax_tetrodes3 handles.ax_tetrodes4],'off')
set(gca,'YLabel',[])
axes(handles.ax_tetrodes1)
cla 
set(gca,'YLabel',[])
axes(handles.ax_tetrodes2)
cla
set(gca,'YLabel',[])
axes(handles.ax_tetrodes3)
cla
set(gca,'YLabel',[])
axes(handles.ax_tetrodes4)
cla
%
axes(handles.ax_sound)
plot(evalin('base','t_amplifier'),evalin('base',sprintf('filtfilt(hps,board_adc_data(%d,:))',handles.audiochann)));
set(gca,'XLim',[evalin('base','t_amplifier(1)') evalin('base','t_amplifier(end)')]);
set(gca,'XTick',[])
set(gca,'Ytick',[])

axes(handles.ax_spectrogram)
% Mira la cantidad de datos
datalen=length(evalin('base',sprintf('board_adc_data(%d,:)',handles.audiochann)));
% setea el mult. de overlap inicial
[~,F,T,P] = spectrogram(evalin('base',sprintf('board_adc_data(%d,:)',handles.audiochann)),gausswin(200,5),0.75*200,[],20000,'yaxis');
%surf(T+evalin('base','t_amplifier(1)'),F,10*log10(P),'edgecolor','none');
%view(0,90)
%axis tight
a=imagesc('XData',T+evalin('base','t_amplifier(1)'),'YData',F,'CData',10*log10(P));
colormap(flipud(hot))
ylim([0 10000])
ylabel('Frequency (Hz)')
set(gca,'XTick',[])

linkaxes([handles.ax_sound handles.ax_spectrogram],'x')

function update_popmenu(hObject, eventdata, handles)
num_tet=length(evalin('base','amplifier_channels'))/4;
for k=1:num_tet
tetname{k}=sprintf('%s - %s',evalin('base',sprintf('amplifier_channels(%d).native_channel_name',4*k-3)),...
    evalin('base',sprintf('amplifier_channels(%d).native_channel_name',4*k)));
end
set(handles.popupmenu1,'String',['Select tetrode...';transpose(tetname)])

function txtfolder_Callback(hObject, eventdata, handles)
% hObject    handle to txtfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of txtfolder as text
%        str2double(get(hObject,'String')) returns contents of txtfolder as a double


% --- Executes during object creation, after setting all properties.
function txtfolder_CreateFcn(hObject, eventdata, handles)
set(hObject,'String',pwd);
% hObject    handle to txtfolder (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pbBrowse.
function pbBrowse_Callback(hObject, eventdata, handles)
indir=uigetdir;
 if indir ~= 0
    set(handles.txtfolder,'string',indir)
 else
     currentfolder=pwd;
     set(handles.txtfolder,'String',currentfolder)
 end
 handles.currentfolder=indir;
 d = dir([handles.currentfolder '/*.rhd']); %get files
 set(handles.listbox_dir,'String',{d.name}) %set string
 guidata(hObject,handles)
 
% hObject    handle to pbBrowse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% --- Executes on button press in push_playvisible.
function push_playvisible_Callback(hObject, eventdata, handles)
if(isplaying(handles.player))
stop(handles.player)
wait(0.05)
end

curr_x=get(handles.ax_sound,'XLim');
lineObjs = findobj(handles.ax_sound, 'type', 'line');
ydata = get(lineObjs, 'YData');
idx=find(evalin('base','t_amplifier')>curr_x(1) & evalin('base','t_amplifier')<curr_x(2));
handles.player=audioplayer(ydata(idx),20000);
play(handles.player)
guidata(hObject,handles);
% hObject    handle to push_playvisible (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

function do_warning(hObject, eventdata, handles)
% Construct a questdlg with three options
choice = questdlg('Warning: more than one analog channel found in the recording', ...
	'Data warning', ...
	'Load ch.1','Load ch.2','Cancel','Cancel');
% Handle response
switch choice
    case 'Load ch.1'
        handles.audiochann=1;
    case 'Load ch.2'
        handles.audiochann=2;
    case 'Cancel'
        handles.audiochann=0;
end
guidata(hObject,handles)
