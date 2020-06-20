function varargout = Mcalibrator2(varargin)

  % Mcalibrator2 -- display luminance/chromaticity characterization software package.
  % function varargout = Mcalibrator2(varargin)
  %
  % MCALIBRATOR2 M-file for Mcalibrator2.fig
  %      MCALIBRATOR2, by itself, creates a new MCALIBRATOR2 or raises the existing
  %      singleton*.
  %
  %      H = MCALIBRATOR2 returns the handle to a new MCALIBRATOR2 or the handle to
  %      the existing singleton*.
  %
  %      MCALIBRATOR2('CALLBACK',hObject,eventData,handles,...) calls the local
  %      function named CALLBACK in MCALIBRATOR2.M with the given input arguments.
  %
  %      MCALIBRATOR2('Property','Value',...) creates a new MCALIBRATOR2 or raises the
  %      existing singleton*.  Starting from the left, property value pairs are
  %      applied to the GUI before Mcalibrator2_OpeningFcn gets called.  An
  %      unrecognized property name or invalid value makes property application
  %      stop.  All inputs are passed to Mcalibrator2_OpeningFcn via varargin.
  %
  %      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
  %      instance to run (singleton)".
  %
  % See also: GUIDE, GUIDATA, GUIHANDLES
  %
  % Edit the above text to modify the response to help Mcalibrator2
  %
  % Last Modified by GUIDE v2.5 03-Apr-2018 13:09:59
  %
  %
  % Created    : "2012-04-13 07:36:14 ban"
  % Last Update: "2018-04-03 13:20:50 ban"
  % <a
  % href="mailto:ban.hiroshi+mcalibrator@gmail.com">email to Hiroshi Ban</a>

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % functions for initializing Mcalibrator2 GUI
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % add path to subfunctions
  addpath(genpath(fullfile(fileparts(mfilename('fullpath')),'subfunctions')));

  % change directory to the Mcalibrator2 directory
  tgt=mfilename('fullpath'); %which('Mcalibrator2');
  cd(fileparts(tgt));

  % Begin initialization code - DO NOT EDIT
  gui_Singleton = 1;
  gui_State = struct('gui_Name',       mfilename, ...
                     'gui_Singleton',  gui_Singleton, ...
                     'gui_OpeningFcn', @Mcalibrator2_OpeningFcn, ...
                     'gui_OutputFcn',  @Mcalibrator2_OutputFcn, ...
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


% --- Executes just before Mcalibrator2 is made visible.
function Mcalibrator2_OpeningFcn(hObject, eventdata, handles, varargin)

  % This function has no output args, see OutputFcn.
  % hObject    handle to figure
  % eventdata  reserved - to be defined in a future version of MATLAB
  % handles    structure with handles and user data (see GUIDATA)
  % varargin   command line arguments to Mcalibrator2 (see VARARGIN)

  global tabhandle;

  % add path to subfunctions
  addpath(genpath(fullfile(fileparts(mfilename('fullpath')),'subfunctions')));

  % Choose default command line output for Mcalibrator2
  handles.output = hObject;

  % Update handles structure
  guidata(hObject, handles);

  % UIWAIT makes Mcalibrator2 wait for user response (see UIRESUME)
  % uiwait(handles.figure1);

  % set text message
  set(handles.information_uipanel,'Title','Welcome to Mcalibrator2');
  strings=load_information_strings;
  set(handles.information_text,'FontAngle','normal','FontName','Tahoma','FontSize',10.0,'FontUnits','pixels','String',[{'This is Mcalibrator2 config panel.',''},strings{1}]);

  % disable some tabs when opening Mcalibrator2
  tver=version('-release'); if str2double(tver(1:4))<2012, tabselectionfcn(hObject,'McalibratorTab',2:4,'off'); end; clear tver;
  tabhandle=hObject;


% --- Outputs from this function are returned to the command line.
function varargout = Mcalibrator2_OutputFcn(hObject, eventdata, handles)

  % Get default command line output from handles structure
  varargout{1} = handles.output;


% --- Outputs from this function are returned to the command line.
function varargout = Mcalibrator2_DeleteFcn(hObject, eventdata, handles)

  global colorimeterhandler; %#ok
  global displayhandler; %#ok

  % remove path
  rmpath(genpath(fullfile(fileparts(mfilename('fullpath')),'subfunctions')));

  % delete object
  %if ~isempty(colorimeterhandler), delete colorimeterhandler; end
  %if ~isempty(displayhandler), delete displayhandler; end

  % clear global variables
  clear global all;
  clear persistent all;
  clear all;
  close all;
  clear mex;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions for config tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% these are empty, just required to handle GUI
function save_dir_edit_Callback(hObject, eventdata, handles)
function date_edit_Callback(hObject, eventdata, handles)
function repetition_edit_Callback(hObject, eventdata, handles)
function use_localM_radiobutton_Callback(hObject, eventdata, handles)
function range_min_edit_Callback(hObject, eventdata, handles)
function range_max_edit_Callback(hObject, eventdata, handles)
function red_radiobutton_Callback(hObject, eventdata, handles)
function green_radiobutton_Callback(hObject, eventdata, handles)
function blue_radiobutton_Callback(hObject, eventdata, handles)
function gray_radiobutton_Callback(hObject, eventdata, handles)
function magenda_radiobutton_Callback(hObject, eventdata, handles)
function yellow_radiobutton_Callback(hObject, eventdata, handles)
function cyan_radiobutton_Callback(hObject, eventdata, handles)
function flare_correction_radiobutton_Callback(hObject, eventdata, handles)


% these are a kind of dummy functions, just required to handle GUI
function apparatus_popupmenu_Callback(hObject, eventdata, handles)
function apparatus_popupmenu_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
  % set colorimeter names to GUI
  colorimeters=colorimeter_list();
  str_colorimeter=[];
  for ii=1:1:length(colorimeters), str_colorimeter=[str_colorimeter,colorimeters{ii}(1)]; end %#ok
  set(hObject,'String',str_colorimeter);
  set(hObject,'Value',1);


function display_routine_popupmenu_Callback(hObject, eventdata, handles)
function display_routine_popupmenu_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
  % set display subroutine names to GUI
  displayroutines=displayroutine_list();
  str_displayroutine=[];
  for ii=1:1:length(displayroutines), str_displayroutine=[str_displayroutine,displayroutines{ii}(1)]; end %#ok
  set(hObject,'String',str_displayroutine);
  set(hObject,'Value',1);


function sampling_popupmenu_Callback(hObject, eventdata, handles)
function sampling_popupmenu_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


function interval_popupmenu_Callback(hObject, eventdata, handles)
function interval_popupmenu_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


function lutoutbit_popupmenu_Callback(hObject, eventdata, handles)
function lutoutbit_popupmenu_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


function gathermethod_popupmenu_Callback(hObject, eventdata, handles)
function gathermethod_popupmenu_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

function save_dir_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


function date_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


function range_min_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


function range_max_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


function repetition_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

% main procedures
function manageConfigTab(handles,state)

  % state : 'on' or 'off'
  set(handles.save_dir_edit,'Enable',state);
  set(handles.select_dir_pushbutton,'Enable',state);
  set(handles.date_edit,'Enable',state);
  set(handles.apparatus_popupmenu,'Enable',state);
  set(handles.display_routine_popupmenu,'Enable',state);
  set(handles.sampling_popupmenu,'Enable',state);
  set(handles.use_localM_radiobutton,'Enable',state);
  set(handles.range_min_edit,'Enable',state);
  set(handles.range_max_edit,'Enable',state);
  set(handles.interval_popupmenu,'Enable',state);
  set(handles.lutoutbit_popupmenu,'Enable',state);
  set(handles.repetition_edit,'Enable',state);
  set(handles.gathermethod_popupmenu,'Enable',state);
  set(handles.red_radiobutton,'Enable',state);
  set(handles.green_radiobutton,'Enable',state);
  set(handles.blue_radiobutton,'Enable',state);
  set(handles.gray_radiobutton,'Enable',state);
  set(handles.magenda_radiobutton,'Enable',state);
  set(handles.yellow_radiobutton,'Enable',state);
  set(handles.cyan_radiobutton,'Enable',state);
  set(handles.flare_correction_radiobutton,'Enable',state);


function manageMeasureTab(handles,state)

  % state : 'on' or 'off'
  set(handles.scr_num_edit,'Enable',state);
  set(handles.com_num_edit,'Enable',state);
  set(handles.pos_adjust_pushbutton,'Enable',state);
  set(handles.create_serial_pushbutton,'Enable',state);
  set(handles.reset_serial_pushbutton,'Enable',state);
  set(handles.initialize_pushbutton,'Enable',state);
  set(handles.measure_pushbutton,'Enable',state);


function manageLUTTab(handles,state)

  % state : 'on' or 'off'
  set(handles.curvefitting_pushbutton,'Enable',state);
  set(handles.fitting_popupmenu,'Enable',state);
  set(handles.create_lut_pushbutton,'Enable',state);
  set(handles.check_lut_pushbutton,'Enable',state);
  set(handles.easycheck_togglebutton,'Enable',state);


function manageColorTab(handles,state)

  % state : 'on' or 'off'
  set(handles.load_phosphor_pushbutton,'Enable',state);
  set(handles.use_LUT_radiobutton,'Enable',state);
  set(handles.use_RGB_radiobutton,'Enable',state);
  set(handles.xyY_edit,'Enable',state);
  set(handles.RGB_edit,'Enable',state);
  set(handles.xyY_RGB_convert_pushbutton,'Enable',state);
  set(handles.load_text_pushbutton,'Enable',state);
  set(handles.calculator_method_popupmenu,'Enable',state);
  set(handles.calculator_measure_pushbutton,'Enable',state);
  set(handles.results_xyY_edit,'Enable',state);
  set(handles.results_RGB_edit,'Enable',state);
  set(handles.calculator_view_pushbutton,'Enable',state);
  set(handles.calculator_save_pushbutton,'Enable',state);


function param=setparam(handleobject)

  tmp=get(handleobject,'String');
  id=get(handleobject,'value');
  param.name=tmp{id};
  param.id=id;


function select_dir_pushbutton_Callback(hObject, eventdata, handles)

  dir_name=uigetdir(fileparts(mfilename('fullpath')));
  if dir_name~=0
    set(handles.save_dir_edit,'String',dir_name);
  end


function config_ok_togglebutton_Callback(hObject, eventdata, handles)

  global tabhandle;
  global config;
  global colorimeterhandler;
  global displayhandler;

  if get(handles.config_ok_togglebutton,'Value')

    % enable some tabs
    tver=version('-release'); if str2double(tver(1:4))<2012, tabselectionfcn(tabhandle,'McalibratorTab',2:4,'on'); end; clear tver;
    manageConfigTab(handles,'off');
    manageMeasureTab(handles,'on');
    manageLUTTab(handles,'on');
    manageColorTab(handles,'on');

    % store the current configurations and save them to a file
    config.save_dir=get(handles.save_dir_edit,'String');
    if ~exist(config.save_dir,'dir'), mkdir(config.save_dir); end
    config.date=get(handles.date_edit,'String');

    config.apparatus=setparam(handles.apparatus_popupmenu);
    config.display_routine=setparam(handles.display_routine_popupmenu);
    config.sampling=setparam(handles.sampling_popupmenu);
    config.use_localM=get(handles.use_localM_radiobutton,'Value');

    % get measurement ranges
    tmp_min=str2double(get(handles.range_min_edit,'String'));
    if size(tmp_min,1)==1, tmp_min=tmp_min'; end
    tmp_max=str2double(get(handles.range_max_edit,'String'));
    if size(tmp_max,1)==1, tmp_max=tmp_max'; end
    if numel(tmp_min)~=numel(tmp_max) || ~isempty(find(tmp_min<0.0,1)) || ~isempty(find(1.0<tmp_max,1)) || ~isempty(find(tmp_min(:)>tmp_max(:),1))
      PlaySound(0);
      set(handles.information_text,'String','Measuring range should be within 0.0<=min<=max<=1.0. Check your setting.');
      % disable some tabs
      tver=version('-release'); if str2num(tver(1:4))<2012, tabselectionfcn(tabhandle,'McalibratorTab',2:4,'off'); end; clear tver; %#ok
      manageConfigTab(handles,'on');
      manageMeasureTab(handles,'off');
      manageLUTTab(handles,'off');
      manageColorTab(handles,'off');
      set(handles.config_ok_togglebutton,'Value',0);
      return
    end
    if numel(tmp_min)<7 % 7 = red, green, blue, gray, magenda, yellow, cyan
      tmp_min(end:7)=tmp_min(end); if size(tmp_min,1)==1, tmp_min=tmp_min'; end
      tmp_max(end:7)=tmp_max(end); if size(tmp_max,1)==1, tmp_max=tmp_max'; end
    end
    config.meas_range=[tmp_min,tmp_max];

    config.interval=setparam(handles.interval_popupmenu);
    config.lutoutbit=setparam(handles.lutoutbit_popupmenu);
    config.repetition=setparam(handles.gathermethod_popupmenu);
    config.repetition.num=get(handles.repetition_edit,'String');

    config.usered=get(handles.red_radiobutton,'Value');
    config.usegreen=get(handles.green_radiobutton,'Value');
    config.useblue=get(handles.blue_radiobutton,'Value');
    config.usegray=get(handles.gray_radiobutton,'Value');
    config.usemagenda=get(handles.magenda_radiobutton,'Value');
    config.useyellow=get(handles.yellow_radiobutton,'Value');
    config.usecyan=get(handles.cyan_radiobutton,'Value');
    config.flare_correction=get(handles.flare_correction_radiobutton,'Value');

    % set object/function handler
    colorimeters=colorimeter_list();
    if isempty(colorimeterhandler)
      colorimeterhandler=eval(sprintf('%s;',colorimeters{config.apparatus.id}{2}));
    elseif isstructmember(colorimeterhandler,'init_flg')
      if colorimeterhandler.init_flg==0
        colorimeterhandler=eval(sprintf('%s;',colorimeters{config.apparatus.id}{2}));
      else
        colorimeterhandler.reset_port();
        if exist('colorimeterhandler','var')==1, delete colorimeterhandler; end
        colorimeterhandler=eval(sprintf('%s;',colorimeters{config.apparatus.id}{2}));
      end
    else
      colorimeterhandler=eval(sprintf('%s;',colorimeters{config.apparatus.id}{2}));
    end
    if colorimeters{config.apparatus.id}{3}==0 % serial connection
      set(handles.com_text,'String','Serial');
      set(handles.com_num_edit,'String','COM1');
      %set(handles.com_num_edit,'Enable','on');
      %set(handles.create_serial_pushbutton,'Enable','on');
      %set(handles.reset_serial_pushbutton,'Enable','on');
    elseif colorimeters{config.apparatus.id}{3}==1 % USB connection
      set(handles.com_text,'String','USB');
      set(handles.com_num_edit,'String','USB port');
      set(handles.com_num_edit,'Enable','off');
      %set(handles.create_serial_pushbutton,'Enable','off');
      %set(handles.reset_serial_pushbutton,'Enable','off');
    else
      set(handles.information_text,'String',...
          'Currently, only [0(SERIAL)|1(USB)] can be accepted as the third variable of colorimeter_list. Check the list file.');
      set(handles.config_ok_togglebutton,'Value',0);
      return
    end

    % set a display routine
    displayroutines=displayroutine_list();
    displayhandler=eval(sprintf('@%s;',displayroutines{config.display_routine.id}{2}));

    % check whether Psychtoolbox is installed
    if strcmp(config.display_routine.name,'Psychtoolbox') || ...
       strcmp(config.display_routine.name,'BITS++ with Psychtoolbox') || ...
       strcmp(config.display_routine.name,'Psychtoolbox (10bit depth)')
      if exist('Screen','file')~=3 % does not exist mex file named 'Screen' = Psychtoolbox is not installed
        PlaySound(0);
        set(handles.information_text,'String','Psychtoolbox is not installed on this computer. Install it first.');

        % disable some tabs
        tver=version('-release'); if str2double(tver(1:4))<2012, tabselectionfcn(tabhandle,'McalibratorTab',2:4,'off'); end; clear tver;
        manageConfigTab(handles,'on');
        manageMeasureTab(handles,'off');
        manageLUTTab(handles,'off');
        manageColorTab(handles,'off');
        set(handles.config_ok_togglebutton,'Value',0);

        return;
      end
    end

    % save the configurations
    save_dir=fullfile(config.save_dir,config.date);
    if ~exist(save_dir,'dir'), mkdir(save_dir); end
    save_fname=fullfile(save_dir,sprintf('mcalibrator2_results_%s.mat',config.date));
    if ~exist(save_fname,'file')
      save(save_fname,'config');
    else
      save(save_fname,'-append','config');
    end

    PlaySound(1);

  else

    % disable some tabs
    tver=version('-release'); if str2double(tver(1:4))<2012, tabselectionfcn(tabhandle,'McalibratorTab',2:4,'off'); end; clear tver;
    manageConfigTab(handles,'on');
    manageMeasureTab(handles,'off');
    manageLUTTab(handles,'off');
    manageColorTab(handles,'off');

  end


function load_pushbutton_Callback(hObject, eventdata, handles)

  global config;

  [filename,filepath]=uigetfile({'config_*.mat','config file (config_*.mat)';'*.*','All Files (*.*)'},'select a config file');
  if ~filename, PlaySound(0); return; end
  load(fullfile(filepath,filename));
  set(handles.save_dir_edit,'String',config.save_dir);
  set(handles.date_edit,'String',datestr(now,'yymmdd'));
  set(handles.apparatus_popupmenu,'Value',config.apparatus.id);
  set(handles.display_routine_popupmenu,'Value',config.display_routine.id);
  set(handles.sampling_popupmenu,'Value',config.sampling.id);
  set(handles.use_localM_radiobutton,'Value',config.use_localM);
  if unique(config.meas_range(:,1))==1
    set(handles.range_min_edit,'String',num2str(config.meas_range(1,1)));
  else
    tmp_min=num2str(config.meas_range(:,1));
    min_str=deblank(tmp_min(1,:));
    for ii=2:1:size(tmp_min,1), min_str=strcat(min_str,',',deblank(tmp_min(ii,:))); end
    set(handles.range_min_edit,'String',min_str);
    clear tmp_min min_str;
  end
  if unique(config.meas_range(:,2))==1
    set(handles.range_max_edit,'String',num2str(config.meas_range(1,2)));
  else
    tmp_max=num2str(config.meas_range(:,2));
    max_str=deblank(tmp_max(1,:));
    for ii=2:1:size(tmp_max,1), max_str=strcat(max_str,',',deblank(tmp_max(ii,:))); end
    set(handles.range_max_edit,'String',max_str);
    clear tmp_max max_str;
  end
  set(handles.interval_popupmenu,'Value',config.interval.id);
  set(handles.lutoutbit_popupmenu,'Value',config.lutoutbit.id);
  set(handles.repetition_edit,'String',config.repetition.num);
  set(handles.gathermethod_popupmenu,'Value',config.repetition.id);
  set(handles.red_radiobutton,'Value',config.usered);
  set(handles.green_radiobutton,'Value',config.usegreen);
  set(handles.blue_radiobutton,'Value',config.useblue);
  set(handles.gray_radiobutton,'Value',config.usegray);
  set(handles.magenda_radiobutton,'Value',config.usemagenda);
  set(handles.yellow_radiobutton,'Value',config.useyellow);
  set(handles.cyan_radiobutton,'Value',config.usecyan);
  set(handles.flare_correction_radiobutton,'Value',config.flare_correction);

  PlaySound(1);


function save_pushbutton_Callback(hObject, eventdata, handles)

  global config;

  config.save_dir=get(handles.save_dir_edit,'String');
  config.date=get(handles.date_edit,'String');

  config.apparatus=setparam(handles.apparatus_popupmenu);
  config.display_routine=setparam(handles.display_routine_popupmenu);
  config.sampling=setparam(handles.sampling_popupmenu);
  config.use_localM=get(handles.use_localM_radiobutton,'value');

  tmp_min=str2double(get(handles.range_min_edit,'String'));
  if size(tmp_min,1)==1, tmp_min=tmp_min'; end
  tmp_max=str2double(get(handles.range_max_edit,'String'));
  if size(tmp_max,1)==1, tmp_max=tmp_max'; end
  if numel(tmp_min)~=numel(tmp_max) || ~isempty(find(tmp_min<0.0,1)) || ~isempty(find(1.0<tmp_max,1)) || ~isempty(find(tmp_min(:)>tmp_max(:),1))
    PlaySound(0);
    set(handles.information_text,'String','Measuring range should be within 0.0<=min<=max<=1.0. Check your setting.');
    return
  end
  if numel(tmp_min)<7 % 7 = red, green, blue, gray, magenda, yellow, cyan
    tmp_min(end:7)=tmp_min(end); if size(tmp_min,1)==1, tmp_min=tmp_min'; end
    tmp_max(end:7)=tmp_max(end); if size(tmp_max,1)==1, tmp_max=tmp_max'; end
  end
  config.meas_range=[tmp_min,tmp_max];

  config.interval=setparam(handles.interval_popupmenu);
  config.lutoutbit=setparam(handles.lutoutbit_popupmenu);
  config.repetition=setparam(handles.gathermethod_popupmenu);
  config.repetition.num=get(handles.repetition_edit,'String');

  config.usered=get(handles.red_radiobutton,'value');
  config.usegreen=get(handles.green_radiobutton,'value');
  config.useblue=get(handles.blue_radiobutton,'value');
  config.usegray=get(handles.gray_radiobutton,'value');
  config.usemagenda=get(handles.magenda_radiobutton,'value');
  config.useyellow=get(handles.yellow_radiobutton,'value');
  config.usecyan=get(handles.cyan_radiobutton,'value');
  config.flare_correction=get(handles.flare_correction_radiobutton,'value');

  save_dir=fullfile(config.save_dir,'config');
  if ~exist(save_dir,'dir'), mkdir(save_dir); end
  save(fullfile(save_dir,sprintf('config_%s.mat',config.date)),'config');

  PlaySound(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions for measure tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% these are a kind of dummy functions, just required to handle GUI
function scr_num_edit_Callback(hObject, eventdata, handles)
function scr_num_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

function com_num_edit_Callback(hObject, eventdata, handles)
function com_num_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


% main procedures
function pos_adjust_pushbutton_Callback(hObject, eventdata, handles)

  global displayhandler;

  set(handles.information_uipanel,'Title','information');
  scr_num=str2num(get(handles.scr_num_edit,'String')); %#ok
  displayhandler(999,1,[],scr_num);
  set(handles.information_text,'String',{'adjust the position and focus of the colorimeter and press Adjust OK button.',...
                                         '','then, press F5 on MATLAB console to proceed.'});


function create_serial_pushbutton_Callback(hObject, eventdata, handles)

  global colorimeterhandler;

  set(handles.information_uipanel,'Title','information');

  set(handles.information_text,'String','Creating a communication port to colorimeter.....');
  port_name=get(handles.com_num_edit,'String');
  colorimeterhandler=colorimeterhandler.gen_port(port_name);
  set(handles.information_text,'String','A communication port to colorimeter is properly created.');

  PlaySound(1);


function reset_serial_pushbutton_Callback(hObject, eventdata, handles)

  global colorimeterhandler;

  set(handles.information_uipanel,'Title','information');

  set(handles.information_text,'String','Resetting a communication port.....');
  colorimeterhandler=colorimeterhandler.reset_port();
  set(handles.information_text,'String','A communication port is properly reset.');

  PlaySound(1);


function initialize_pushbutton_Callback(hObject, eventdata, handles)

  global colorimeterhandler;

  set(handles.information_uipanel,'Title','information');

  set(handles.information_text,'String','Initializing the colorimeter.....');
  check=1; count=1;
  while check~=0 && count<=5 % try to do at most 5 times
    [colorimeterhandler,check]=colorimeterhandler.initialize();
    count=count+1;
    set(handles.information_text,'String','Initializing Error...Re-Initializing');
  end
  if count==6
    set(handles.information_text,'String','You couldn''t initialize the apparatus.');
    PlaySound(0);
    return;
  end
  set(handles.information_text,'String','Initializing the colorimeter.....Done');

  PlaySound(1);


function measure_pushbutton_Callback(hObject, eventdata, handles)

  global config;
  global colorimeterhandler;
  global displayhandler;
  global phosphors;
  global flares;

  set(handles.information_uipanel,'Title','information');

  % create luminance file format
  save_dir=fullfile(config.save_dir,config.date);
  save_fname=fullfile(save_dir,sprintf('mcalibrator2_results_%s.mat',config.date));

  % constant variables to display information or plot result
  color_str={'red','green','blue','gray','magenda','yellow','cyan'};
  colors={[1,0,0],[0,1,0],[0,0,1],[0.3,0.3,0.3],[1,0,1],[1,1,0],[0,1,1]};

  % constant variables to display color window
  color_msk={[1,0,0],[0,1,0],[0,0,1],[1,1,1],[1,0,1],[1,1,0],[0,1,1]};
  measure_flg=[config.usered,config.usegreen,config.useblue,config.usegray,config.usemagenda,config.useyellow,config.usecyan];

  % set the sampling interval (config.meas_range(xx,1) - config.meas_range(xx,2)) --- (0.0-1.0) by default.
  sampnum=str2num(config.sampling.name); %#ok
  mRGBs=cell(length(color_str),1);
  lum=cell(length(color_str),1);
  for ii=1:1:length(color_str)
    if ~measure_flg(ii)
      mRGBs{ii}=NaN;
      lum{ii}=zeros(4,sampnum); % 4 = sampling-point, x, y, Y
    else
      if strcmp(config.interval.name,'equally spaced')
        samppoints=config.meas_range(ii,1):diff(config.meas_range(ii,:))/(sampnum-1):config.meas_range(ii,2);
      elseif strcmp(config.interval.name,'low-biased')
        samppoints=(config.meas_range(ii,1):diff(config.meas_range(ii,:))/(sampnum-1):config.meas_range(ii,2)).^2;
      elseif strcmp(config.interval.name,'high-biased')
        samppoints=sqrt(config.meas_range(ii,1):diff(config.meas_range(ii,:))/(sampnum-1):config.meas_range(ii,2));
      end

      % add 0/1 video input values for measuring flare/phosphor xyY
      if ~config.use_localM
        if config.meas_range(ii,1)~=0
          samppoints=[0.0,samppoints]; %#ok
        end
        if config.meas_range(ii,2)~=1
          samppoints=[samppoints,1.0]; %#ok
        end
      end

      % set RGB video input values
      mRGBs{ii}=repmat(samppoints,3,1).*repmat((color_msk{ii})',1,numel(samppoints));
      lum{ii}=zeros(4,numel(samppoints)); % 4 = sampling-point, x, y, Y
      lum{ii}(1,:)=samppoints;
    end
  end

  % initialize color window
  scr_num=str2num(get(handles.scr_num_edit,'String')); %#ok
  fig_id=displayhandler([255,255,255],1,[],scr_num); pause(0.2);

  % measure CIE1931 xyY values
  [Ys,xs,ys,displayhandler,colorimeterhandler]=...
    MeasureCIE1931xyYs(displayhandler,colorimeterhandler,mRGBs,1,fig_id,str2num(config.repetition.num),config.repetition.name); %#ok
  for ii=1:1:length(color_str)
    if ~measure_flg(ii), continue; end;
    lum{ii}(4,:)=Ys{ii}; lum{ii}(2,:)=xs{ii}; lum{ii}(3,:)=ys{ii};
  end
  displayhandler(-999,1,fig_id);

  % save the phosphor xyY matrix and flare xyY as text files when red, green, and blue phosphor luminance values were obtained.
  if sum(lum{1}(1,:))~=0 && sum(lum{2}(1,:))~=0 && sum(lum{3}(1,:))~=0
    fid=fopen(fullfile(save_dir,'phosphors.txt'),'w');
    if fid==-1, PlaySound(0); error('can not open phoshors.txt to write.'); end
    if lum{1}(1,end)==1.0 && ~config.use_localM % when the luminance values for the maximum video inputs were measured
      phosphors=zeros(3,3); % phosphors = [rx,gx,bx;ry,gy,by;rY,gY,bY];
      phosphors(:,1)=[lum{1}(2,end);lum{1}(3,end);lum{1}(4,end)];
      phosphors(:,2)=[lum{2}(2,end);lum{2}(3,end);lum{2}(4,end)];
      phosphors(:,3)=[lum{3}(2,end);lum{3}(3,end);lum{3}(4,end)];
      fprintf(fid,'%.8f %.8f %.8f\n',phosphors(1,1),phosphors(1,2),phosphors(1,3));
      fprintf(fid,'%.8f %.8f %.8f\n',phosphors(2,1),phosphors(2,2),phosphors(2,3));
      fprintf(fid,'%.8f %.8f %.8f\n',phosphors(3,1),phosphors(3,2),phosphors(3,3));
    else
      fprintf(fid,'!!NOTICE!!\npartial measurements are under going.\nphosphor xyY will be obtained later.\n');
    end
    fclose(fid);

    fid=fopen(fullfile(save_dir,'flare.txt'),'w');
    if fid==-1, PlaySound(0); error('can not open flares.txt to write.'); end
    if lum{1}(1,1)==0.0 && ~config.use_localM % when the luminance values for the minimum (flare) video inputs were measured
      flares=[mean([lum{1}(2,1),lum{2}(2,1),lum{3}(2,1)]);
              mean([lum{1}(3,1),lum{2}(3,1),lum{3}(3,1)]);
              mean([lum{1}(4,1),lum{2}(4,1),lum{3}(4,1)])]; % flares = [gx;gy;gY];
      fprintf(fid,'%.8f\n',flares(1));
      fprintf(fid,'%.8f\n',flares(2));
      fprintf(fid,'%.8f\n',flares(3));
    else
      fprintf(fid,'!!NOTICE!!\npartial measurements are under going.\nflare xyY will be obtained later.\n');
    end
    fclose(fid);
  % when gray-scale luminance values were obtained, generate flares.txt
  elseif sum(lum{4}(1,:))~=0 % gray-scale
    fid=fopen(fullfile(save_dir,'flare.txt'),'w');
    if fid==-1, PlaySound(0); error('can not open flares.txt to write.'); end
    if lum{1}(1,1)==0.0 && ~config.use_localM % when the luminance values for the minimum (flare) video inputs were measured
      flares=[lum{4}(2,1),lum{4}(3,1),lum{4}(4,1)];
      fprintf(fid,'%.8f\n%.8f\n%.8f\n',flares(1),flares(2),flares(3));
    else
      fprintf(fid,'!!NOTICE!!\npartial measurements are under going.\nflare xyY will be obtained later.\n');
    end
    fclose(fid);
  end

  % remove xyY for 0/1 video input values used in measuring flare/phosphor xyY
  for ii=1:1:length(color_str)
    if measure_flg(ii) && ~config.use_localM
      if config.meas_range(ii,1)~=0, lum{ii}=lum{ii}(:,2:end); end
      if config.meas_range(ii,2)~=1, lum{ii}=lum{ii}(:,1:end-1); end
    end
  end

  % plotting
  axes(handles.lum_figure);
  hold on;
  for ii=1:1:length(color_str)
    if ~measure_flg(ii), continue; end;
    plot(lum{ii}(1,:),lum{ii}(4,:),'Marker','o','MarkerSize',3,'MarkerFaceColor',colors{ii},'MarkerEdgeColor',colors{ii});
  end
  set(gca,'XLim',[0,1]);
  set(gca,'XTick',0:0.2:1.0);
  xlabel('video input (0.0-1.0)');
  ylabel('luminance (cd/m^2)');
  title('measured luminance');

  % save the results
  save(save_fname,'-append','lum');
  if ~isempty('phosphors'), save(save_fname,'-append','phosphors'); end
  if ~isempty('flares'), save(save_fname,'-append','flares'); end

  PlaySound(1);


function clear_lum_pushbutton_Callback(hObject, eventdata, handles)

  axes(handles.lum_figure);
  cla;

  PlaySound(1);


function measure_separate_pushbutton_Callback(hObject, eventdata, handles)

  figure; c=gca;

  % copy objects
  axes(c);
  set(c,'Position',[0.13,0.11,0.7750,0.8150]);
  copyobj(get(handles.lum_figure,'Children'),c);
  title(get(get(handles.lum_figure,'Title'),'String'));
  xlabel(get(get(handles.lum_figure,'XLabel'),'String'));
  ylabel(get(get(handles.lum_figure,'YLabel'),'String'));
  set(gca,'XLim',get(handles.lum_figure,'XLim'));
  set(gca,'YLim',get(handles.lum_figure,'YLim'));
  set(gcf,'Name','Mcalibrator2: measured luminance','NumberTitle','off');

  PlaySound(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions for LUT tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% these are empty, just required to handle GUI
function fitting_popupmenu_Callback(hObject, eventdata, handles)
function fitting_popupmenu_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

function easycheck_togglebutton_Callback(hObject, eventdata, handles)
function easycheck_togglebutton_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

% main procedures
function fitmethod=getfitmethod(fitting_method)

  if strcmp(fitting_method,'Gain-offset-gamma')
    fitmethod='gog';
  elseif strcmp(fitting_method,'cubic spline')
    fitmethod='cbs';
  elseif strcmp(fitting_method,'robust cubic spline')
    fitmethod='rcbs';
  elseif strcmp(fitting_method,'power function')
    fitmethod='pow';
  elseif strcmp(fitting_method,'diff of 2 power function')
    fitmethod='pow2';
  elseif strcmp(fitting_method,'log space')
    fitmethod='log';
  elseif strcmp(fitting_method,'linear')
    fitmethod='lin';
  elseif strcmp(fitting_method,'5th order polynomial')
    fitmethod='poly';
  elseif strcmp(fitting_method,'sigmoid')
    fitmethod='sig';
  elseif strcmp(fitting_method,'Weibull function')
    fitmethod='wbl';
  elseif strcmp(fitting_method,'grid search with robust spline')
    fitmethod='gs';
  end


function curvefitting_pushbutton_Callback(hObject, eventdata, handles)

  global config;

  set(handles.information_uipanel,'Title','information');

  % create luminance file format
  save_dir=fullfile(config.save_dir,config.date);
  save_fname=fullfile(save_dir,sprintf('mcalibrator2_results_%s.mat',config.date));

  load(save_fname); % load measured luminance data
  if ~exist('lum','var')
    set(handles.information_text,'String','no luminance data. measure luminance first.');
    return;
  end

  % initialize variables
  measure_flg=[config.usered,config.usegreen,config.useblue,config.usegray,config.usemagenda,config.useyellow,config.usecyan];
  color_str={'red','green','blue','gray','magenda','yellow','cyan'};
  colors={[1,0,0],[0,1,0],[0,0,1],[0.3,0.3,0.3],[1,0,1],[1,1,0],[0,1,1]};
  fitlum=cell(length(color_str),1);
  for ii=1:1:length(color_str)
    if ~measure_flg(ii), continue; end;
    fitlum{ii}=zeros(2,size(lum{ii},2)); %#ok % lum is already loaded on memory
    fitlum{ii}(1,:)=lum{ii}(1,:);
  end

  % set fitting parameters
  tmp=get(handles.fitting_popupmenu,'String');
  id=get(handles.fitting_popupmenu,'Value');
  fitting_method=tmp{id};
  fitmethod=getfitmethod(fitting_method);

  flare_correction_flg=config.flare_correction;
  display_flg=0;
  save_flg=0;

  monotonic_flg=1;
  lowpass_flg=0;
  options.lowpass_cutoff=0.085;
  options.epsilon=0.01;
  options.breaks=8;

  % overwrite parameters when they are set in the parameter file.
  tmp=getGammaCorrectionParams();
  if isstructmember(tmp,'monotonic_flg'), monotonic_flg=tmp.monotonic_flg; end
  if isstructmember(tmp,'lowpass_flg'), lowpass_flg=tmp.lowpass_flg; end
  if isstructmember(tmp,'lowpass_cutoff'), options.lowpass_cutoff=tmp.lowpass_cutoff; end
  if isstructmember(tmp,'epsilon'), options.epsilon=tmp.epsilon; end
  if isstructmember(tmp,'breasks'), options.breaks=tmp.breaks; end
  clear tmp;

  % fitting
  for ii=1:1:length(color_str)
    if ~measure_flg(ii), continue; end;
    set(handles.information_text,'String',sprintf('fitting a model to the measured %s phosphor...',color_str{ii}));
    fitlum{ii}(2,:)=ApplyCurveFitting(lum{ii}([1,4],:),fitmethod,monotonic_flg,lowpass_flg,flare_correction_flg,display_flg,save_flg,options);
    set(handles.information_text,'String',sprintf('fitting a model to the measured %s phosphor...Done.',color_str{ii}));
  end

  axes(handles.lum_figure); cla;

  for ii=1:1:length(color_str)
    if ~measure_flg(ii), continue; end;
    axes(handles.lum_figure); %#ok
    hold on;
    plot(lum{ii}(1,:),lum{ii}(4,:),'o','MarkerSize',3,'MarkerFaceColor',colors{ii},'MarkerEdgeColor','none');
    plot(fitlum{ii}(1,:),fitlum{ii}(2,:),'-','Color',colors{ii},'LineWidth',2);
    set(gca,'XLim',[0,1]);
    set(gca,'XTick',0:0.2:1.0);
    xlabel('video input (0.0-1.0)');
    ylabel('luminance (cd/m^2)');
    title(sprintf('fitting result, method: %s',fitmethod));
  end

  axes(handles.lum_figure);
  hold off;

  % create luminance file format
  save(save_fname,'-append','fitting_method','fitlum');

  PlaySound(1);


function create_lut_pushbutton_Callback(hObject, eventdata, handles)

  global config;

  % create luminance file format
  save_dir=fullfile(config.save_dir,config.date);
  save_fname=fullfile(save_dir,sprintf('mcalibrator2_results_%s.mat',config.date));

  load(save_fname); % load measured luminance data
  if ~exist('lum','var')
    set(handles.information_text,'String','no luminance data. measure luminance first.');
    return;
  end

  % initialize variables

  measure_flg=[config.usered,config.usegreen,config.useblue,config.usegray,config.usemagenda,config.useyellow,config.usecyan];
  color_str={'red','green','blue','gray','magenda','yellow','cyan'};
  colors={[1,0,0],[0,1,0],[0,0,1],[0.3,0.3,0.3],[1,0,1],[1,1,0],[0,1,1]};
  lutoutbit=str2double(config.lutoutbit.name);
  lut=cell(length(color_str),1);
  for ii=1:1:length(color_str), lut{ii}=zeros(2,lutoutbit); end

  % initialize an object to communicate with Microsoft Powerpoint
  windows_flg=0;
  if strcmp(mexext,'mexw32') || strcmp(mexext,'mexw64') % OS = Windows
    windows_flg=1;
    ppt=AddSlide2PPT;
    if ~isempty(ppt.app_handle)
      ppt=ppt.addTitleSlide(sprintf('Mcalibrator2%sDisplay Calibration Results',ppt.newline()),datestr(now,'yymmdd'));

      % add config information to PPT slide
      config_info=sprintf('colorimeter     : %s\r\n',config.apparatus.name);
      config_info=[config_info,sprintf('Sampling        : %s\r\n',config.sampling.name)];
      config_info=[config_info,sprintf('Interval        : %s\r\n',config.interval.name)];
      config_info=[config_info,sprintf('Repetition      : %s (%s)\r\n',config.repetition.num,config.repetition.name)];
      config_info=[config_info,sprintf('Flare Correction: %d\r\n',config.flare_correction)];
      tmp=get(handles.fitting_popupmenu,'String');
      id=get(handles.fitting_popupmenu,'Value');
      fitting_method=tmp{id};
      config_info=[config_info,sprintf('Fitting Model   : %s\r\n',fitting_method)];
      ppt=ppt.addTextSlide('Parameters',config_info);
    else
      windows_flg=0;
    end
  end

  % set fitting parameters
  tmp=get(handles.fitting_popupmenu,'String');
  id=get(handles.fitting_popupmenu,'Value');
  fitting_method=tmp{id};
  fitmethod=getfitmethod(fitting_method);

  flare_correction_flg=config.flare_correction;
  display_flg=1;
  save_flg=0;

  monotonic_flg=1;
  lowpass_flg=0;
  options.lowpass_cutoff=0.085;
  options.epsilon=0.01;
  options.breaks=8;

  % overwrite parameters when they are set in the parameter file.
  tmp=getGammaCorrectionParams();
  if isstructmember(tmp,'monotonic_flg'), monotonic_flg=tmp.monotonic_flg; end
  if isstructmember(tmp,'lowpass_flg'), lowpass_flg=tmp.lowpass_flg; end
  if isstructmember(tmp,'lowpass_cutoff'), options.lowpass_cutoff=tmp.lowpass_cutoff; end
  if isstructmember(tmp,'epsilon'), options.epsilon=tmp.epsilon; end
  if isstructmember(tmp,'breasks'), options.breaks=tmp.breaks; end
  clear tmp;

  % generate Color Lookup Tables
  axes(handles.lut_figure); cla;
  for ii=1:1:length(color_str)
    if ~measure_flg(ii), continue; end;

    set(handles.information_text,'String',sprintf('Generating LUT for %s phosphor...',color_str{ii}));
    lut{ii}=ApplyGammaCorrection(lum{ii}([1,4],:),fitmethod,lutoutbit,monotonic_flg,lowpass_flg,...
                                 flare_correction_flg,display_flg,save_flg,options); %#ok % lum is already loaded on memory

    % get the figure id to focus on the latest gamma correction result figure in taking a snapshot.
    % to do it, the last gamma correction plot figure id is stored in figaxis before the matlab
    % focus is back on the main Mcalibrator2 window
    try
      figall=get(groot);
    catch
      figall=get(0); % old style to get the graphic root object;
    end
    figall=figall.Children;
    figaxis=gcf;
    %for ff=1:1:size(figall,1)
    %  if ~isempty(strmatch(figall(ff).Name,sprintf('Mcalibrator2 Gamma Correction Result: %s',fitmethod)))
    %    figure(figall(ff)); % set the last gamma correction plot as the current figure. note: the Mcalibrator root figure is 0.
    %    figaxis=gcf;
    %  end
    %end
    %set(figaxis,'Name',[get(figaxis,'Name'),sprintf(' %s',color_str{ii})]);
    drawnow;

    % save images as a PPT slide
    if windows_flg
      tmpimgfile=fullfile(save_dir,'gamma_result.png');
      set(figaxis,'PaperPositionMode','auto');
      print(figaxis,tmpimgfile,'-dpng','-r0');
      %saveas(gcf,tmpimgfile,'bmp');
      ppt=ppt.addImageSlide(color_str{ii},tmpimgfile);
      delete(tmpimgfile);
      %close(figaxis);
    end
    if exist(fullfile(pwd,sprintf('gamma_corr_result_%s.png',fitmethod)),'file')
      delete(fullfile(pwd,sprintf('gamma_corr_result_%s.png',fitmethod)));
    end

    % plotting
    axes(handles.lut_figure); %#ok
    hold on;
    plot(1:1:size(lut{ii},2),lut{ii}(1,:),'-','Marker','o','MarkerSize',3,'MarkerFaceColor',colors{ii},'Color',colors{ii});
    xlabel('LUT ID');
    set(gca,'XLim',[0,size(lut{ii},2)]);
    ylabel('video input (0.0-1.0)');
    title('generated LUTs');

    % save the generated LUTs to text files
    fid=fopen(fullfile(save_dir,sprintf('%s.lut',color_str{ii})),'w');
    if fid==-1, PlaySound(0); error('can not open a %s LUT file to write.',color_str{ii}); end
    for mm=1:1:size(lut{ii},2), fprintf(fid,'% 4d %.8f\n',mm,lut{ii}(1,mm)); end
    fclose(fid);

    set(handles.information_text,'String',sprintf('Generating LUT for %s phosphor...Done.',color_str{ii}));
  end
  hold off;

  % save the generated PPT slides
  if windows_flg, ppt.saveAs(fullfile(save_dir,'display_calibration_result.ppt')); ppt.close(0); end

  % save the results
  save(save_fname,'-append','fitting_method','lut');

  % save a combined RGB LUT to a text file
  if measure_flg(1) && measure_flg(2) && measure_flg(3)
    fid=fopen(fullfile(save_dir,'rgb_gamma.lut'),'w');
    if fid==-1, PlaySound(0); error('can not open rgb_gamma.lut to write.'); end
    for mm=1:1:size(lut{1},2), fprintf(fid,'%.8f %.8f %.8f\n',lut{1}(1,mm),lut{2}(1,mm),lut{3}(1,mm)); end
    fclose(fid);
  end

  % save the generaged LUT(s) for PTB3
  if lutoutbit==256
    if measure_flg(1) && measure_flg(2) && measure_flg(3)
      gammatable=[lut{1}(1,:);lut{2}(1,:);lut{3}(1,:)]'; %#ok
      save(fullfile(save_dir,'gammatablePTB.mat'),'gammatable');
    elseif measure_flg(4)
      gammatable=(lut{4}(1,:))'; %#ok
      save(fullfile(save_dir,'gammatablePTB.mat'),'gammatable');
    end
  end

  PlaySound(1);


function check_lut_pushbutton_Callback(hObject, eventdata, handles)

  global config;
  global colorimeterhandler;
  global displayhandler;

  set(handles.information_uipanel,'Title','information');

  % create luminance file format
  save_dir=fullfile(config.save_dir,config.date);
  save_fname=fullfile(save_dir,sprintf('mcalibrator2_results_%s.mat',config.date));

  load(save_fname); % load measured luminance data
  if ~exist('lut','var')
    set(handles.information_text,'String','no LUT data. generate LUT first.');
    return;
  end

  % initialize variables
  measure_flg=[config.usered,config.usegreen,config.useblue,config.usegray,config.usemagenda,config.useyellow,config.usecyan];
  color_str={'red','green','blue','gray','magenda','yellow','cyan'};
  colors={[1,0,0],[0,1,0],[0,0,1],[0.3,0.3,0.3],[1,0,1],[1,1,0],[0,1,1]};
  color_msk={[1,0,0],[0,1,0],[0,0,1],[1,1,1],[1,0,1],[1,1,0],[0,1,1]};

  % check linearity of the generated LUTs
  if get(handles.easycheck_togglebutton,'Value') % easy mode

    axes(handles.lut_figure); cla;

    for ii=1:1:length(color_str)
      if ~measure_flg(ii), continue; end;

      set(handles.information_text,'String',sprintf('checking linearity of %s LUT...',color_str{ii}));
      axes(handles.lut_figure); %#ok
      hold on;
      plot(linspace(config.meas_range(ii,1),config.meas_range(ii,2),size(lut{ii},2)),lut{ii}(2,:),'-','Marker','o','MarkerSize',3,'MarkerFaceColor',colors{ii},...
           'Color',colors{ii}); %#ok % lut is already loaded on memory
      set(gca,'XLim',[0,1]);
      set(gca,'XTick',0:0.2:1.0);
      set(gca,'XLim',[0,1]);
      xlabel('LUT ID');
      ylabel('luminance (cd/m^2)');
      title('linearity of LUTs');
      set(handles.information_text,'String',sprintf('checking linearity of %s LUT...Done.',color_str{ii}));
    end
    hold off;

  else % measure luminance again and check linearity

    % initialize seed of random sequence
    InitializeRandomSeed();

    % get/set 20 points for re-measure the luminance
    checklumval=cell(length(color_str),1);
    for ii=1:1:length(color_str)
      if ~measure_flg(ii), continue; end;
      checklumval{ii}=lut{ii}(1,floor(linspace(1,str2num(config.lutoutbit.name),20)),1); %#ok
    end

    % set luminance values
    checklum=cell(length(color_str),1);
    for ii=1:1:length(color_str)
      if ~measure_flg(ii), continue; end;
      checklum{ii}=zeros(5,20); % 4 = measured_val, x, y, Y
      checklum{ii}(1,:)=linspace(config.meas_range(ii,1),config.meas_range(ii,2),20);%checklumval;
      checklum{ii}(2,:)=checklumval{ii};
    end

    % initialize color window
    scr_num=str2num(get(handles.scr_num_edit,'String')); %#ok
    fig_id=displayhandler([255,255,255],1,[],scr_num); pause(0.2);

    % measure CIE1931 xyY
    for ii=1:1:length(color_str)
      if ~measure_flg(ii), continue; end;

      set(handles.information_text,'String',sprintf('Measuring CIE 1931 xyY of %s...',color_str{ii}));
      mesorder=shuffle(1:1:numel(checklumval{ii}));%1:1:numel(checklumval)
      for mm=mesorder
        [checklum{ii}(5,mm),checklum{ii}(3,mm),checklum{ii}(4,mm),displayhandler,colorimeterhandler]=...
          MeasureCIE1931xyY(displayhandler,colorimeterhandler,repmat(checklumval{ii}(mm),1,3).*color_msk{ii},1,fig_id);
      end
      set(handles.information_text,'String',sprintf('Measuring CIE 1931 xyY of %s...Done',color_str{ii}));
      hold off;
    end
    displayhandler(-999,1,fig_id);

    axes(handles.lut_figure); cla

    % plotting
    rho=zeros(length(color_str),1);
    pval=zeros(length(color_str),1);
    rms=zeros(length(color_str),1);
    for ii=1:1:length(color_str)
      if ~measure_flg(ii), continue; end;

      set(handles.information_text,'String',sprintf('checking linearity of %s LUT...',color_str{ii}));
      axes(handles.lut_figure); %#ok
      hold on;
      plot(checklum{ii}(1,:),checklum{ii}(5,:),'Marker','o','MarkerSize',3,'MarkerFaceColor',colors{ii},'Color',colors{ii});

      % linear fitting
      p=polyfit(checklum{ii}(1,:),checklum{ii}(5,:),1);
      linfit=p(1)*checklum{ii}(1,:)+p(2);
      plot(checklum{ii}(1,:),linfit,'-','Color',colors{ii},'LineWidth',2);

      % RMSE
      e=(checklum{ii}(5,:)-linfit)./linfit*100;
      rms(ii)=sqrt(e*e')./sqrt(size(checklum{ii}(5,:),2));

      % goodness of linearity by correlation-coefficient & its p-value
      [rho(ii),pval(ii)]=corr(checklum{ii}(1,:)',(checklum{ii}(5,:))');

      set(gca,'XLim',[0,1]);
      set(gca,'XTick',0:0.2:1.0);
      xlabel('LUT ID');
      ylabel('luminance (cd/m^2)');
      title('linearity of LUTs');
      set(handles.information_text,'String',sprintf('checking linearity of %s LUT...Done.',color_str{ii}));
    end % for ii=1:1:length(color_str)

    % display the goodness of linearity on the information window
    fit_str={'Linearity check, results',''};
    for ii=1:1:length(color_str)
      if ~measure_flg(ii), continue; end;
      fit_str=[fit_str,{sprintf('%s: rmse=%.2f, corr=%.2f, p-value=%.2f',color_str{ii},rms(ii),rho(ii),pval(ii)),''}]; %#ok
    end
    set(handles.information_text,'String',fit_str);

    axes(handles.lut_figure);
    hold off;

    % create luminance file format
    save(save_fname,'-append','checklum');

  end % if handles.easycheck_togglebutton % easy mode

  PlaySound(1);


function clear_lut_pushbutton_Callback(hObject, eventdata, handles)

  axes(handles.lut_figure);
  cla;

  PlaySound(1);


function LUT_separate_pushbutton_Callback(hObject, eventdata, handles)

  figure; c=gca;

  % copy objects
  axes(c);
  set(c,'Position',[0.13,0.11,0.7750,0.8150]);
  copyobj(get(handles.lut_figure,'Children'),c);
  title(get(get(handles.lut_figure,'Title'),'String'));
  xlabel(get(get(handles.lut_figure,'XLabel'),'String'));
  ylabel(get(get(handles.lut_figure,'YLabel'),'String'));
  set(gca,'XLim',get(handles.lut_figure,'XLim'));
  set(gca,'YLim',get(handles.lut_figure,'YLim'));
  set(gcf,'Name','Mcalibrator2: generated LUTs','NumberTitle','off');

  PlaySound(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions for Color Calculator tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% these are a kind of dummy functions, just required to handle GUI
function xyY_edit_Callback(hObject, eventdata, handles)
function xyY_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end


function RGB_edit_Callback(hObject, eventdata, handles)
function RGB_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

function calculator_method_popupmenu_Callback(hObject, eventdata, handles)
function calculator_method_popupmenu_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end
  % set measurement method to GUI
  meas_methods=measurement_method_list();
  str_meas_method=[];
  for ii=1:1:length(meas_methods), str_meas_method=[str_meas_method,meas_methods{ii}(1)]; end %#ok
  set(hObject,'String',str_meas_method);
  set(hObject,'Value',1);


function results_xyY_edit_Callback(hObject, eventdata, handles)
function results_xyY_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

function results_RGB_edit_Callback(hObject, eventdata, handles)
function results_RGB_edit_CreateFcn(hObject, eventdata, handles)
  if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
  end

function color_figure_CreateFcn(hObject, eventdata, handles)

  PlotCIE1931xy([],[],-1,0,1);


% fucntions to handle GUI
function use_LUT_radiobutton_Callback(hObject, eventdata, handles)

  if get(handles.use_LUT_radiobutton,'Value')
    set(handles.use_RGB_radiobutton,'Value',0);
    set(handles.use_LUT_radiobutton,'Value',1);
    set(handles.RGB_text,'String','LUT');
    set(handles.measured_RGB_text,'String','LUT');
  else
    set(handles.use_RGB_radiobutton,'Value',1);
    set(handles.use_LUT_radiobutton,'Value',0);
    set(handles.RGB_text,'String','R,G,B');
    set(handles.measured_RGB_text,'String','R,G,B');
  end


function use_RGB_radiobutton_Callback(hObject, eventdata, handles)

  if get(handles.use_RGB_radiobutton,'Value')
    set(handles.use_RGB_radiobutton,'Value',1);
    set(handles.use_LUT_radiobutton,'Value',0);
    set(handles.RGB_text,'String','R,G,B');
    set(handles.measured_RGB_text,'String','R,G,B')
  else
    set(handles.use_RGB_radiobutton,'Value',0);
    set(handles.use_LUT_radiobutton,'Value',1);
    set(handles.RGB_text,'String','LUT');
    set(handles.measured_RGB_text,'String','LUT');
  end


% main procedures
function load_phosphor_pushbutton_Callback(hObject, eventdata, handles)

  global config;
  global colorimeterhandler;
  global displayhandler;
  global phosphors;
  global flares;

  set(handles.information_uipanel,'Title','information');

  % create luminance file format
  save_dir=fullfile(config.save_dir,config.date);
  save_fname=fullfile(save_dir,sprintf('mcalibrator2_results_%s.mat',config.date));

  % get/set phosphor CIE1931 xyY
  load(save_fname); % load measured luminance data

  % when phosphors and flares are already obtained.
  if ~isempty(phosphors) && ~isempty(flares)

    % empty, use already acquired phosphors and flares values

  % when RGB measurements were done but they were conducted in partial RGB video input space, create a local phosphor matrix
  elseif config.use_localM && exist('lum','var') && sum(lum{1}(1,:))~=0 && sum(lum{2}(1,:))~=0 && sum(lum{3}(1,:))~=0 %#ok

    set(handles.information_text,'String',{'RGB phosphor chromaticities have not been acquired yet.',...
        'starting to measure CIE1931 xyY for RGB phosphors in a local space....'});

    % initialize color window
    scr_num=str2num(get(handles.scr_num_edit,'String')); %#ok
    fig_id=displayhandler([255,255,255],1,[],scr_num); pause(0.2);

    % create a local color transformation matrix = (local) phosphor xyY matrix
    % for details, see AutoColorEstimateLinear.m function

    % get random video input values in a local space
    sRGB=unifrnd(repmat(config.meas_range(1:3,1),1,18),repmat(config.meas_range(1:3,2),1,18));
    %sRGB=unifrnd(0,1,3,18);

    % set RGB or LUT values
    mRGB=sRGB;
    if get(handles.use_LUT_radiobutton,'Value')
      lut=LoadLUTs();
      if isempty(lut), set(handles.information_text,'String','can not load RGB LUTs. Generate them first.'); PlaySound(0); return; end

      % get lut ID corresponding to the target rgb
      [dummy,mRGB]=getLUTidx(lut,sRGB); %#ok
      clear lut;
    end

    % measure CIE 1931 xyY values in a local space and estimate the transformation matrix
    msxyY=zeros(3,size(mRGB,2));
    set(handles.information_text,'String','Measuring CIE 1931 xyY in a local space...');
    for ii=1:1:size(sRGB,2)
      [msxyY(3,ii),msxyY(1,ii),msxyY(2,ii),displayhandler,colorimeterhandler]=...
          MeasureCIE1931xyY(displayhandler,colorimeterhandler,mRGB(:,ii),1,fig_id);
    end
    set(handles.information_text,'String','Measuring CIE 1931 xyY in a local space...Done');
    msXYZ=xyY2XYZ(msxyY);
    T0=(msXYZ*msXYZ')\msXYZ*sRGB';
    T0=T0';
    phosphors=XYZ2xyY(inv(T0));
    clear msXYZ msxyY sRGB mRGB T0;

    % measure leaked light (zero-level) luminance
    if config.flare_correction
      flares=zeros(3,3); % zero-level light
      set(handles.information_text,'String','Measuring CIE 1931 xyY of flare...');
      for ii=1:1:3
        [flares(3,ii),flares(1,ii),flares(2,ii),displayhandler,colorimeterhandler]=...
            MeasureCIE1931xyY(displayhandler,colorimeterhandler,zeros(3,1),1,fig_id);
      end
      set(handles.information_text,'String','Measuring CIE 1931 xyY of flare...Done');
      flares=mean(flares,2);
    else
      flares=[]; % empty if partial measurements are done.
    end
    displayhandler(-999,1,fig_id);

  % when nothing has been measured, measure phosphors and get a global transformation matrix
  else

    phosphors=zeros(3,3); % phosphors = [rx,gx,bx; ry,gy,by; rY,gY,bY];
    flares=zeros(3,3); % leaked (zero-level) light

    set(handles.information_text,'String',{'RGB phosphor chromaticities have not been acquired yet.',...
                        'starting to measure CIE1931 xyY for RGB phosphors....'});

    % initialize color window
    scr_num=str2num(get(handles.scr_num_edit,'String')); %#ok
    fig_id=displayhandler([255,255,255],1,[],scr_num); pause(0.2);

    % measure CIE1931 xyY for RGB phosphors
    color_str={'red','green','blue'};
    colors={[1,0,0],[0,1,0],[0,0,1]};
    for ii=1:1:length(color_str)
      set(handles.information_text,'String',sprintf('Measuring CIE 1931 xyY of %s...',color_str{ii}));
      [phosphors(3,ii),phosphors(1,ii),phosphors(2,ii),displayhandler,colorimeterhandler]=...
          MeasureCIE1931xyY(displayhandler,colorimeterhandler,colors{ii},1,fig_id);
      set(handles.information_text,'String',sprintf('Measuring CIE 1931 xyY of %s...Done',color_str{ii}));
    end

    % measure leaked light (zero-level) luminance
    set(handles.information_text,'String','Measuring CIE 1931 xyY of flare...');
    for ii=1:1:3
      [flares(3,ii),flares(1,ii),flares(2,ii),displayhandler,colorimeterhandler]=...
          MeasureCIE1931xyY(displayhandler,colorimeterhandler,zeros(3,1),1,fig_id);
    end
    set(handles.information_text,'String','Measuring CIE 1931 xyY of flare...Done');
    flares=mean(flares,2);
    displayhandler(-999,1,fig_id);

  end
  set(handles.information_text,'String',{'RGB phosphor chromaticities have not been acquired yet.','starting to measure CIE1931 xyY for RGB phosphors....Done.'});

  % plotting phosphor CIE1931 xy
  axes(handles.color_figure);
  hold off;
  PlotCIE1931xy([],phosphors,-1,1,1);
  hold off;

  % save the results
  save(save_fname,'-append','phosphors','flares');

  PlaySound(1);


function xyY_RGB_convert_pushbutton_Callback(hObject, eventdata, handles)

  global config;
  global phosphors;
  global flares;

  set(handles.information_uipanel,'Title','information');

  if isempty(phosphors) || sum(phosphors(:))==0
    set(handles.information_text,'String','RGB phosphor chromaticities have not been acquired yet. Measure them first.');
    PlaySound(0);
    return
  else
    % convert chromaticities from xyY to RGB
    myxyY=(getDataFromStr(get(handles.xyY_edit,'String')))';

    % flare correction
    if config.flare_correction
      flare_xyY=flares;%repmat(flares,1,size(myxyY,2));
    else
      flare_xyY=[];
    end
    rgbdata=xyY2RGB(myxyY,phosphors,flare_xyY);
    rgbdata(rgbdata<0)=0;
    rgbdata(rgbdata>1)=1.0;

    % set RGB or LUT values
    if get(handles.use_LUT_radiobutton,'Value')
      lut=LoadLUTs();
      if isempty(lut), set(handles.information_text,'String','can not load RGB LUTs. Generate them first.'); PlaySound(0); return; end

      % get lut ID corresponding to the target rgb
      lutdata=getLUTidx(lut,rgbdata);

      % set lut ID to RGB_edit
      str_lut=[];
      for ii=1:1:size(lutdata,1)
        str_lut=[str_lut,num2str(lutdata(ii,1)),',',num2str(lutdata(ii,2)),',',num2str(lutdata(ii,3)),';']; %#ok
      end
      set(handles.RGB_edit,'String',str_lut);
      clear lut;
    else
      % set rgb values to RGB_edit
      str_rgb=[];
      for ii=1:1:size(rgbdata,2)
        str_rgb=[str_rgb,num2str(rgbdata(1,ii)),',',num2str(rgbdata(2,ii)),',',num2str(rgbdata(3,ii)),';']; %#ok
      end
      set(handles.RGB_edit,'String',str_rgb);
    end
  end % if ~exist(phosphors,'var') || sum(phosphors(:))==0

  if get(handles.use_LUT_radiobutton,'Value')
    set(handles.information_text,'String','xyY values were converted to RGB values.');
  else
    set(handles.information_text,'String','xyY values were converted to LUT IDs.');
  end

  PlaySound(1);


function load_text_pushbutton_Callback(hObject, eventdata, handles)

  set(handles.information_uipanel,'Title','information');

  [filename,filepath]=uigetfile({'*.txt','xyY file (*.txt)';'*.*','All Files (*.*)'},'select a text file (x1,y1,Y1;(enter)x2,y2,Y2;(enter)x3,y3,...)');
  if ~filename, PlaySound(0); return; end
  xyYdata=load(fullfile(filepath,filename));
  if size(xyYdata,2)~=3
    set(handles.information_text,'String',{'text file format error','xyY text file should be organized as x1,y1,Y1;[ENTER]y1,y2,Y2;[ENTER]x3,y3,Y3;. check the file again'});
    clear filename filepath;
    return
  else
    str_xyY=[];
    for ii=1:1:size(xyYdata,1)
      str_xyY=[str_xyY,num2str(xyYdata(ii,1)),',',num2str(xyYdata(ii,2)),',',num2str(xyYdata(ii,3)),';']; %#ok
    end
  end
  set(handles.xyY_edit,'String',str_xyY);

  PlaySound(1);


function calculator_measure_pushbutton_Callback(hObject, eventdata, handles)

  % set a function to measure/estimate CIE1931 xyY and run it
  meas_methods=measurement_method_list();
  eval(sprintf('%s(hObject,eventdata,handles);',meas_methods{get(handles.calculator_method_popupmenu,'Value')}{2}));

  PlaySound(1);


function calculator_view_pushbutton_Callback(hObject, eventdata, handles)

  set(handles.information_uipanel,'Title','information');

  if isempty(get(handles.xyY_edit,'String')) || isempty(get(handles.RGB_edit,'String')) || ...
     isempty(get(handles.results_xyY_edit,'String')) || isempty(get(handles.results_RGB_edit,'String'))
    set(handles.information_text,'String','Data has not acquired. Measure xyY values you want first.');
    PlaySound(0);
    return
  end

  set(handles.information_text,'String','Loading CIE1931 xyY data...');

  % gather data: 1. xyY you want, 2. RGB you want, 3. xyY measured, 4. RGB measured
  my_xyY=getDataFromStr(get(handles.xyY_edit,'String'));
  my_RGB=getDataFromStr(get(handles.RGB_edit,'String'));
  results_xyY=getDataFromStr(get(handles.results_xyY_edit,'String'));
  results_RGB=getDataFromStr(get(handles.results_RGB_edit,'String'));

  % display on the measured results on command window
  if get(handles.use_LUT_radiobutton,'Value')
    fprintf('\n***** wanted/measured xyY and the corresponding LUT values *****\n\n');
    for ii=1:1:size(my_xyY,1)
      fprintf('color [%03d] : xyY[%.3f, %.3f, %.3f], LUT[%03d, %03d, %03d]\n',...
              ii,my_xyY(ii,1),my_xyY(ii,2),my_xyY(ii,3),my_RGB(ii,1),my_RGB(ii,2),my_RGB(ii,3));
      fprintf(' --measured : xyY[%.3f, %.3f, %.3f], LUT[%03d, %03d, %03d]\n\n',...
              results_xyY(ii,1),results_xyY(ii,2),results_xyY(ii,3),results_RGB(ii,1),results_RGB(ii,2),results_RGB(ii,3));
    end
  else
    fprintf('\n***** wanted/measured xyY and the corresponding RGB values *****\n\n');
    for ii=1:1:size(my_xyY,1)
      fprintf('color [%03d] : xyY[%.3f, %.3f, %.3f], RGB[%.3f, %.3f, %.3f]\n',...
              ii,my_xyY(ii,1),my_xyY(ii,2),my_xyY(ii,3),my_RGB(ii,1),my_RGB(ii,2),my_RGB(ii,3));
      fprintf(' --measured : xyY[%.3f, %.3f, %.3f], RGB[%.3f, %.3f, %.3f]\n\n',...
              results_xyY(ii,1),results_xyY(ii,2),results_xyY(ii,3),results_RGB(ii,1),results_RGB(ii,2),results_RGB(ii,3));
    end
  end

  set(handles.information_text,'String','Loading CIE1931 xyY data...Done.');

  PlaySound(1);


function calculator_save_pushbutton_Callback(hObject, eventdata, handles)

  global config;

  set(handles.information_uipanel,'Title','information');

  % create luminance file format
  save_dir=fullfile(config.save_dir,config.date);
  save_fname=fullfile(save_dir,sprintf('mcalibrator2_results_%s.mat',config.date));

  if isempty(get(handles.xyY_edit,'String')) || isempty(get(handles.RGB_edit,'String')) || ...
     isempty(get(handles.results_xyY_edit,'String')) || isempty(get(handles.results_RGB_edit,'String'))
    set(handles.information_text,'String','Data has not acquired. Measure xyY values you want first.');
    PlaySound(0);
    return
  end

  % store data as matlab variable

  set(handles.information_text,'String','Saving CIE1931 xyY data...');

  % estimation method
  if get(handles.use_LUT_radiobutton,'Value')
    estimate.method='LUT';
  else
    estimate.method='RGB';
  end

  % gather data: 1. xyY you want, 2. RGB you want, 3. xyY measured, 4. RGB measured
  estimate.my_xyY=getDataFromStr(get(handles.xyY_edit,'String'));
  estimate.my_RGB=getDataFromStr(get(handles.RGB_edit,'String'));
  estimate.results_xyY=getDataFromStr(get(handles.results_xyY_edit,'String'));
  estimate.results_RGB=getDataFromStr(get(handles.results_RGB_edit,'String'));

  % save the results
  save(save_fname,'-append','estimate');

  % save the results to a text file
  estimate_files=wildcardsearch(save_dir,'estimate_*.txt');
  if isempty(estimate_files)
    estimate_file='estimate_files_001.txt';
  else
    idx=length(estimate_files)+1;
    estimate_file=sprintf('estimate_files_%03d.txt',idx);
  end

  fid=fopen(fullfile(save_dir,estimate_file),'w');
  if fid==-1, PlaySound(0); warning('can not open a file to save the estimated xyY & RGB.'); return; end
  fprintf(fid,'***********************************************\n');
  fprintf(fid,'Mcalibrator2, chromaticity estimation results\n');
  fprintf(fid,'date: %s\n',datestr(now,'mmmm dd YYYY, HH:MM:SS'));
  fprintf(fid,'***********************************************');
  fprintf(fid,'\n');
  fprintf(fid,['colorID x_you_want y_you_want Y_you_want R_you_want G_you_want B_you_want ',...
               'x_estimated y_estimated Y_estimated R_estimated G_estimated B_estimated ',...
               'percentage_error_x percentage_error_y percentage_error_Y\n']);
  for nn=1:1:size(estimate.my_xyY,1)
    prc_error=(estimate.my_xyY(nn,:)-estimate.results_xyY(nn,:))./estimate.my_xyY(nn,:).*100;
    fprintf(fid,'color_%04d %.8f %.8f %.8f %.8f %.8f %.8f %.8f %.8f %.8f %.8f %.8f %.8f %.8f %.8f %.8f\n',...
            nn,estimate.my_xyY(nn,1),estimate.my_xyY(nn,2),estimate.my_xyY(nn,3),...
               estimate.my_RGB(nn,1),estimate.my_RGB(nn,2),estimate.my_RGB(nn,3),...
               estimate.results_xyY(nn,1),estimate.results_xyY(nn,2),estimate.results_xyY(nn,3),...
               estimate.results_RGB(nn,1),estimate.results_RGB(nn,2),estimate.results_RGB(nn,3),...
               prc_error(1),prc_error(2),prc_error(3));
  end
  fclose(fid);

  set(handles.information_text,'String','Saving CIE1931 xyY data...Done.');

  PlaySound(1);


function plot_color_pushbutton_Callback(hObject, eventdata, handles)

  global phosphors;

  rawxyY=getDataFromStr(get(handles.xyY_edit,'String'));
  mesxyY=getDataFromStr(get(handles.results_xyY_edit,'String'));
  set(handles.information_text,'String','Plotting measured data on the CIE1931 diagram...');
  if isempty(phosphors)
    tri_flg=0;
    disp('WARNING: phosphor tristimulus values have not been measured yet. using dummy values...');
  else
    tri_flg=1;
  end
  if isempty(rawxyY), disp('WARNING: xyY values you want have not been set yet...'); end
  if isempty(mesxyY), disp('WARNING: actual xyY values have not been measured yet...'); end
  axes(handles.color_figure);
  hold off;
  PlotCIE1931xy((rawxyY(:,1:2))',phosphors,-1,tri_flg,1,1);
  PlotCIE1931xy((mesxyY(:,1:2))',phosphors,0,tri_flg,1,0);
  hold off;

  set(handles.information_text,'String','Plotting measured data on the CIE1931 diagram...Done.');

  PlaySound(1);


function clear_color_pushbutton_Callback(hObject, eventdata, handles)

  axes(handles.color_figure);
  PlotCIE1931xy([],[],-1,0,1);

  PlaySound(1);


function color_separate_pushbutton_Callback(hObject, eventdata, handles)

  figure; c=gca;

  % copy objects
  axes(c);
  set(c,'Position',[0.13,0.11,0.7750,0.8150]);
  copyobj(get(handles.color_figure,'Children'),c);
  title(get(get(handles.color_figure,'Title'),'String'));
  xlabel(get(get(handles.color_figure,'XLabel'),'String'));
  ylabel(get(get(handles.color_figure,'YLabel'),'String'));
  set(gca,'XLim',get(handles.color_figure,'XLim'));
  set(gca,'YLim',get(handles.color_figure,'YLim'));
  set(gcf,'Name','Mcalibrator2: CIE1931 chromaticity diagram','NumberTitle','off');
  axis square;
  grid on;

  PlaySound(1);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions for about tab
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function display_test_pushbutton_Callback(hObject, eventdata, handles)

  display_test();


function parameters_pushbutton_Callback(hObject, eventdata, handles)

  persistent strings;

  % load strings to be displayed in Information window
  if isempty(strings), strings=load_information_strings; end

  ans_str=questdlg(strings{6},'Warning: Mcalibrator2 paramter settings','gamma-correction','auto color optimization','Cancel','Cancel');
  if strcmp(ans_str,'gamma-correction')
    clear getGammaCorrectionParams; % to release the cash of this function from memory.
    edit('getGammaCorrectionParams.m');
    PlaySound(1);
  elseif strcmp(ans_str,'auto color optimization')
    clear getOptimizationParams; % to release the cash of this function from memory.
    edit('getOptimizationParams.m');
    PlaySound(1);
  else
    PlaySound(0);
  end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% functions to handle information_text according to TAB change
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function McalibratorTab_TabSelectionChange_Callback(hObject, eventdata, handles)

  persistent strings;

  % load strings to be displayed in Information window
  if isempty(strings), strings=load_information_strings; end

  tabid=get(handles.McalibratorTab,'Value');
  if tabid(1)==1
    set(handles.information_uipanel,'Title','config tab: setup Mcalibrator2');
    set(handles.information_text,'FontAngle','normal','FontName','Tahoma','FontSize',10.0,'FontUnits','pixels','String',strings{1});
  elseif tabid(2)==1
    set(handles.information_uipanel,'Title','measure tab: measure CIE1931 xyY');
    set(handles.information_text,'FontAngle','normal','FontName','Tahoma','FontSize',11.0,'FontUnits','pixels','String',strings{2});
  elseif tabid(3)==1
    set(handles.information_uipanel,'Title','LUT tab: generate Color Lookup Table(s)');
    set(handles.information_text,'FontAngle','normal','FontName','Tahoma','FontSize',11.0,'FontUnits','pixels','String',strings{3});
  elseif tabid(4)==1
    set(handles.information_uipanel,'Title','Color Calculator tab: get colors you want');
    set(handles.information_text,'FontAngle','normal','FontName','Tahoma','FontSize',10.0,'FontUnits','pixels','String',strings{4});
  elseif tabid(5)==1
    set(handles.information_uipanel,'Title','about Mcalibrator2');
    set(handles.information_text,'FontAngle','normal','FontName','Tahoma','FontSize',10.0,'FontUnits','pixels','String',strings{5});
  end