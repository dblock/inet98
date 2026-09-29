unit inetMain;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, inetControl, d32gen, ShellApi, d32errors, Buttons, SpriteClass, ScktComp, MPlayer, d32reg, SpriteReact;

type

  THideState = (HiddenState, ShownState, HidingState, ShowingState);
  TStage = (sgNoScreenSaver, sgScreenSaver);

  TProcessThread = class(TThread)
  public
     constructor Create(iSocket: TCustomWinSocket);
  private
     StrStat: string;
     Socket: TCustomWinSocket;
     procedure Execute; override;
     procedure inetMainSndPlay;
  end;

  TPOsThread = class(TThread)
     private
        Stage: TStage;
        State: THideState;
        PosForm: TForm;
        PosFlag: integer;
        DetectedActivity: integer;
        Elapsed: longint;
        procedure EXecute; override;
        procedure Pause;
        procedure Resume;
     public
        constructor Create(aForm: TForm; aFlag: integer);
        procedure HideScreenSaver;
        procedure ShowScreenSaver;
     end;


  TinetMainForm = class(TForm)
    mainPanel: TPanel;
    inetSocLogo: TImage;
    autoHidePanel: TPanel;
    inetAutoHide: TCheckBox;
    RPanel: TPanel;
    inetLogo: TImage;
    inetBar: TImage;
    timePanel: TPanel;
    cmdIExplorer: TSprite;
    StatLabel: TLabel;
    InetServer: TServerSocket;
    inetAutoReboot: TCheckBox;
    cmdNetscape: TSprite;
    cmdPcPine: TSprite;
    cmdTelnet: TSprite;
    cmdFtp: TSprite;
    cmdPP97: TSprite;
    cmdEX97: TSprite;
    cmdWW97: TSprite;
    cmdWW95: TSprite;
    cmdEX95: TSprite;
    cmdPP95: TSprite;
    Player: TMediaPlayer;
    procedure FormCreate(Sender: TObject);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure inetAutoHideClick(Sender: TObject);
    procedure inet98PanelResize(Sender: TObject);
    procedure autoHidePanelResize(Sender: TObject);
    procedure mainPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure RPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure cmdNetscapeClick(Sender: TObject);
    procedure InetServerAccept(Sender: TObject; Socket: TCustomWinSocket);
    procedure FormShow(Sender: TObject);
  private
    TaskShow : boolean;
    BarCanClose: boolean;
    ScreenSaverOn: boolean;
    LastCommand: string;
    CmdList: TStringList;
    PosThread: TPosThread;
    BackDoorWord : string;
    BackDoorPrefix: boolean;
    procedure HideTitleBar;
    procedure WMwindowposchanging(var M: TWMwindowposchanging); message wm_windowposchanging;
    procedure FillInetBar;
    procedure WMQuit(var M: TMessage); message WM_QUIT;
    procedure ExecCommand;
    procedure MessageHandler(var Msg: TMsg; var Handled: Boolean);
    procedure AppMinimize(Sender: TObject);
  public
    RejectSock: boolean;
    InterfaceControl : TInterfaceControl;
  end;

var
  inetMainForm: TinetMainForm;

const
  VersionID = '1.2207';
  crHand = 3333;
  Password = 'cfv2cpo';
  SecondPassword = 'db4ever';
  DetectMax = 120*2;    // initial detect
  ScreenSaverMax = 2*60*2; // screen saver pop
  InactiveMax = 5*60*2; // reboot pop
  MsgMax = 10 * 1000;
  MaxPasswd = 3;
  SShExec = 'K:\SSH\PROGRAM\SSH.EXE';

implementation

uses InetExit, InetTimer, d32about, screenSaver, inetPasswd;

{$R *.lfm}

procedure TInetMainForm.HideTitlebar;
var
   Save : LongInt;
begin
   if BorderStyle=bsNone then Exit;
   Save:=GetWindowLong(Handle,gwl_Style);
   if (Save and ws_Caption)=ws_Caption then Begin
      Case BorderStyle of
         bsSingle,
         bsSizeable : SetWindowLong(Handle,gwl_Style,Save and
           (not(ws_Caption)) or ws_border);
         bsDialog : SetWindowLong(Handle,gwl_Style,Save and
           (not(ws_Caption)) or ds_modalframe or ws_dlgframe);
         end;
     Height:=Height-getSystemMetrics(sm_cyCaption);
     Refresh;
     end;
   end;

procedure TInetMainForm.WMwindowposchanging(var M: TWMwindowposchanging);
begin
   inherited;
   end;

procedure TinetMainForm.FormCreate(Sender: TObject);
          procedure FillCmdList;
          begin
               CmdList := TStringList.Create;
               with CmdList do begin
                       Add('C:\Internet Explorer\Iexplore.exe');
                       Add('C:\Program Files\Netscape\Communicator\Program\netscape.exe');
                       Add('C:\PcPine\pine.exe');
                       Add('C:\Windows\telnet.exe');
                       Add('C:\ftp\ws_ftp95.exe');
                       Add('H:\msoffice.97\office\winword.exe');
                       Add('H:\msoffice.97\office\excel.exe');
                       Add('H:\msoffice.97\office\powerpnt.exe');
                       Add('H:\msoffice.95\winword\winword.exe');
                       Add('H:\msoffice.95\excel\excel.exe');
                       Add('H:\msoffice.95\powerpnt\powerpnt.exe');
                       end;
               end;
          procedure EnableButtons;
          var
             i: integer;
          begin
               try
               with inetMainForm do
               for i:= 0 to ComponentCount - 1 do begin
                   if (Components[i] is TSprite) then begin
                      if not FileExists(CmdList[Components[i].Tag-1]) then
                         (Components[i] as TSprite).Visible := False;
                      end;
                   end;
               except
               end;
               end;
     procedure ParseOptions;
     const
          OptionsPath: string = 'bar/';
     begin
          if FileExists(OptionsPath + 'noautoreboot') then inetAutoReboot.Checked := False else inetAutoReboot.Checked := True;
          if FileExists(OptionsPath + 'autohide') then inetAutoHide.Checked := True else inetAutoHide.Checked := False;
          if FileExists(OptionsPath + 'nosocket') then RejectSock := True else RejectSock := False;
          if FileExists(OptionsPath + 'noscreensaver') then ScreenSaverOn := False else ScreenSaverOn := True;
          if FileExists(OptionsPath + 'canclose') then BarCanClose := True else BarCanClose := False;
          if FileExists(OptionsPath + 'taskshow') then TaskShow := True else TaskShow:=False;
          end;
begin
     Application.OnMinimize := AppMinimize; { port: LCL has no Application.OnMessage }
     FillCmdList;
     EnableButtons;
     HideTitlebar;
     Left := 0;
     Top := 0;
     LastCommand := '';
     Height := Screen.Height;
     RPanel.ClientWidth := InetBar.Width;
     Width := (RPanel.Width + cmdIExplorer.Width);
     PosThread := TPosThread.Create(Self, HWND_TOPMOST);
     BackDoorWord:='';
     BackDoorPrefix:=False;
     InterfaceControl := TInterfaceControl.Create(Self);
     InterfaceControl.Stop;
     FillInetBar;
     Screen.Cursors[crHand] := LoadCursorFromFile(PChar(ExtractFileDir(Application.ExeName) + '\hand.cur'));
     ParseOptions;
     //ShowWindow(Application.Handle, SW_HIDE);
     end;

procedure TPosThread.Pause;
begin
     Suspended:=True;
     end;

procedure TPosThread.Resume;
begin
     Suspended:=False;
     end;

constructor TPosThread.Create(aForm: tForm; aFlag: integer);
begin
     Stage:=sgNoScreenSaver;
     PosForm:=aForm;
     PosFlag:=aFlag;
     DetectedActivity := 0;
     inherited Create(False);
     end;

procedure TPosThread.HideScreenSaver;
begin
     if Stage = sgScreenSaver then begin
        Stage := sgNoScreenSaver;
        Synchronize(inetMainForm.InterfaceControl.HideScreenSaver);
        inetMainForm.inetAutoHide.Checked := False;
        inetMainForm.InterfaceControl.ShowFusion;
        end;
     end;

procedure TPosThread.ShowScreenSaver;
begin
     if (Stage <> sgScreenSaver) and inetMainForm.ScreenSaverOn then begin
        Synchronize(inetMainForm.InterfaceControl.ShowScreenSaver);
        Stage := sgScreenSaver;
        end;
     end;

procedure TPosThread.Execute;
var
   aPoint: TPoint;
   CursorPos: TPoint;
   cState, pState: TKeyboardState;
   i: integer;
   DataType: integer;
begin
     { port: this thread starts before FormCreate finishes creating InterfaceControl }
     while ((inetMainForm = nil) or (inetMainForm.InterfaceControl = nil) or (sSaver = nil)) and not Application.Terminated do Sleep(50);

     while not Application.Terminated do begin

        if inetMainForm.InterfaceControl.Terminating then begin
           inetMainForm.InetServer.Active := False;
           ReactManager.Kill;
           Application.Terminate;
           exit;
           end;

        with Posform do
          if Visible then begin
             for i:=0 to 255 do begin
                 if GetAsyncKeyState(i) > 0 then break;
                 end;
             if i < 255 then begin
                if (DetectedActivity < DetectMax) then inc(DetectedActivity);
                Elapsed := 0;
                HideScreenSaver;
                end;
             GetcursorPos(aPoint);
             Sleep(250);
             if (aPoint.X = CursorPos.X) and (aPoint.Y = CursorPos.Y) then begin
                inc(Elapsed);
                if (Elapsed >= ScreenSaverMax) and (Stage <> sgScreenSaver) then begin
                   ShowScreenSaver;
                   Elapsed := 0;
                end else if (DetectedActivity >= DetectMax) and (Elapsed >= InactiveMax) and (Stage = sgScreenSaver) then begin
                   HideScreenSaver;
                   inetMainForm.inetAutoHide.Checked := False;
                   Synchronize(inetMainForm.InterfaceControl.ShowFusion);
                   inetMainForm.InterfaceControl.Stop;
                   inetMainForm.Repaint;
                   if inetMainForm.inetAutoReboot.Checked then Synchronize(inetMainForm.InterfaceControl.ExitWindows);
                   Elapsed := 0;
                   end;

                end else begin
                if (DetectedActivity < DetectMax) then inc(DetectedActivity);
                CursorPos.X := aPoint.X;
                CursorPos.Y := aPoint.Y;
                Elapsed := 0;
                HideScreenSaver;
                end;

             if (Stage <> sgScreenSaver) then
                SetWindowPos(HAndle, PosFlag, 0, 0, 0, 0, SWP_NOACTIVATE+SWP_NOSIZE+SWP_NOMOVE)
                else SetWindowPos(sSaver.HAndle, PosFlag, 0, 0, 0, 0, SWP_NOACTIVATE+SWP_NOSIZE+SWP_NOMOVE);

             inetMainForm.StatLabel.Caption := 'Version: ' + VersionID +
                                            #13#10 + 'Initial Counter: ' + IntToStr(DetectedActivity div 2) +
                                            #13#10 + 'Inactive Counter: ' + IntToStr(Elapsed div 2);
             inetMainForm.timePanel.Caption := FormatDateTime('hh:mm:ss', Now) + ' / ' + StrLower(PChar(ComputerName)); 
             inetMainForm.timePanel.Color := inetMainForm.timePanel.Color + Elapsed;
             Sleep(250);
             end;

          end;

     end;


procedure TinetMainForm.FormMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     PosThread.Pause;
     end;

procedure TinetMainForm.FormMouseUp(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
begin
     PosThread.Resume;
     end;

procedure TinetMainForm.FormCloseQuery(Sender: TObject; var CanClose: Boolean);
begin
     CanClose := BarCanClose;
     end;

procedure TinetMainForm.FormKeyPress(Sender: TObject; var Key: Char);
const
     cmdLength = 4;
          function CheckPassword: boolean;
          var
             iPass: string;
          begin
               Result := False;
               iPass := PasswdForm.InputQuery;
               if (Length(iPass) > 0) and (CompareText(iPass, Password) = 0) then Result := True;
               end;
          procedure HiddenCommand(Command: string);
          begin
               if (CompareText(Command, 'term') = 0) and CheckPassword then begin
                  ReactManager.Kill;
                  Application.Terminate;
               end else if (CompareText(Command, 'shell') = 0) and CheckPassword then ExecCommand
               else if (CompareText(Command, 'hide') = 0) and CheckPassword then inetAutoReboot.Visible := not inetAutoReboot.Visible
               else if (CompareText(Command, 'boot') = 0) and CheckPassword then InterfaceControl.ExitWindowsNowSync
               else if (CompareText(Command, 'stats') = 0) and CheckPassword then StatLabel.Visible := not StatLabel.Visible
               else if (CompareText(Command, 'lock') = 0) and CheckPassword then RejectSock := not RejectSock
               else if (CompareText(Command, 'ssh') = 0) and FileExists(SShExec) then begin
                    TInetMsg.NormalShow(False, 'Launching ssh, please be patient ...');
                    Application.ProcessMessages;
                    chdir(ExtractFilePath(SshExec));
                    ShellExecute(Handle, 'open', PChar('ssh.exe'), nil, PChar(ExtractfileDir(SShExec)), SW_SHOW);
                    end;
               end;
begin
     if (Key = '-') then begin
        BackDoorWord := '';
        BackDoorPrefix := True
     end else if ((Key = #13) or (Key = #10)) then begin
        if BackDoorPrefix then HiddenCommand(BackDoorWord);
        BackDoorWord := '';
        BackDoorPrefix := False;
     end else if BackDoorPrefix then begin
        BackdoorWord := BackdoorWord + Key;
        end;
     end;

procedure TinetMainForm.inetAutoHideClick(Sender: TObject);
begin
     if inetAutoHide.Checked then InterfaceControl.Resume else InterfaceControl.Stop;
     end;

procedure TInetMainForm.FillInetBar;
var
   inetBarNew: TImage;
   i: integer;
begin
     i := 0;
     while i < RPanel.ClientHeight do begin
         inetBarNew := TImage.Create(Application);
         inetBarNew.Picture := inetBar.Picture;
         inetBarNew.OnMouseMove := RPanel.OnMouseMove;
         RPanel.InsertControl(inetBarNew);
         inetBarNew.AutoSize := True;
         inetBarNew.Left := RPanel.ClientWidth - inetBarNew.Width;
         inetBarNew.Top := i;
         i := i + inetBarNew.Height;
         end;
     end;

procedure TinetMainForm.inet98PanelResize(Sender: TObject);
begin
     ClientHeight := inetSocLogo.Height;
     end;

procedure TinetMainForm.autoHidePanelResize(Sender: TObject);
begin
     inetautoHide.Left := (autoHidePanel.ClientWidth - inetautoHide.Width) div 2;
     inetautoHide.Top := (autoHidePanel.ClientHeight - inetautoHide.Height) div 2;
     inetAutoReboot.Left := inetAutoHide.Left;
     inetAutoReboot.Top := inetAutoHide.Top + inetAutoHide.Height + 3;
     end;

procedure TinetMainForm.mainPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
     if Screen.Cursor <> crDefault then Screen.Cursor := crDefault;
     end;

procedure TinetMainForm.RPanelMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
     if Screen.Cursor <> crDefault then Screen.Cursor := crDefault;
     end;

procedure TinetMainForm.WMQuit(var M: TMessage);
begin
     ShellExecute(Handle, 'open', PChar(Application.ExeName), nil, PChar(ExtractfileDir(Application.ExeName)), SW_SHOW);
     ReactManager.Kill;
     Application.Terminate;
     end;

procedure TinetMainForm.cmdNetscapeClick(Sender: TObject);
begin
     if Sender is TSprite then
         ShellExecute(Handle, 'open', PChar(CmdList[(Sender as TSprite).Tag - 1]), nil, nil, SW_SHOW)
     end;

procedure TinetMainForm.InetServerAccept(Sender: TObject; Socket: TCustomWinSocket);
begin
     TProcessThread.Create(Socket);
     end;

procedure TInetMainForm.ExecCommand;
begin
     LastCommand := InputBox('I''ve got the power','What do you want to run?',LastCommand);
     if Length(LastCommand) > 0 then ShellExecute(Handle, 'open', PChar(LastCommand), nil, nil, SW_SHOW)
     end;

constructor TProcessThread.Create(iSocket: TCustomWinSocket);
begin
     Socket := iSocket;                                      {local copy of socket}
     inherited Create(False);                                {create without pause}
     end;

procedure TProcessThread.Execute;
var
   i: integer;
   RemoteHost: string;
   RemotePort: integer;
   RemoteEcho: boolean;
   rText: string;

          function ReadLine: string;
          var
             c: char; i: integer;
             cText: string;
          begin
               Result := '';
               while(True) and not (Application.Terminated) do begin
                  cText := Socket.ReceiveText;
                  if RemoteEcho then Socket.SendText(cText)
                  else for i:= 1 to Length(cText) do
                       if Ord(cText[i]) >= 32 then Socket.SendText('*')
                       else Socket.SendText(cText[i]);
                  rText := rText + cText;
                  if Length(rText) > 0 then begin
                     c := rText[1];
                     Delete(rText, 1, 1);
                     if (c = Chr(10)) and (Length(Trim(Result)) > 0) then exit
                     else if (c = Chr(8)) then Delete(Result, Length(Result), 1)
                     else if (c >= Chr(32)) then Result:=Result+c;
                     end;
                  end;
               end;
var
   DataType: integer;
   Line: string;
   PasswordCounter: integer;
begin
     try

     RemoteHost := Socket.RemoteHost;
     RemotePort := Socket.RemotePort;

     RemoteEcho := False;
     Socket.SendText('InetServer Ready (c) Daniel Doubrovkine / University of Geneva'+ #13#10);
     if inetMainForm.RejectSock then begin
        Socket.SendText('InetServer Locked, sorry, try again later.'+ #13#10);
        exit;
        end;
     Socket.SendText('please identify yourself: '+#13#10);
     PasswordCounter := MaxPasswd;
     while True and not (Application.Terminated) do begin
           Line := Trim(ReadLine);
           if (CompareText(Line, Password) = 0) or (CompareText(Line, SecondPassword) = 0) then break;
           dec(PasswordCounter);
           Socket.SendText('03 Reject - (cnt: '+IntToStr(PasswordCounter)+') alarm has been activated, you are logged!'+#13#10);
           if (PasswordCounter = 0) then begin
              Socket.Close;
              exit;
              end;
           end;
     RemoteEcho := True;
     Socket.SendText('Good morning dave!'+#13#10);
     while True and not (Application.Terminated) do begin
           Line := ReadLine;
           if CompareText(Line, 'QUIT') = 0 then begin
               Socket.SendText('Thank you for your time, cya.'+#13#10);
               break;
           end else if CompareText(Line, 'TERM') = 0 then begin
               Socket.SendText('00 OK - terminating bar'+#13#10);
               inetMainForm.InterfaceControl.Terminate;
           end else if CompareText(Line, 'COMMAND') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - launching command.com'+#13#10);
               ShellExecute(Handle, 'open', 'command.com', nil, nil, SW_SHOW)
           end else if CompareText(Line, 'SHELL') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - launching explorer.exe'+#13#10);
               ShellExecute(Handle, 'open', 'explorer.exe', nil, nil, SW_SHOW)
           end else if CompareText(Line, 'TELNET') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - launching telnet.exe'+#13#10);
               ShellExecute(Handle, 'open', 'telnet.exe', nil, nil, SW_SHOW)
           end else if CompareText(Line, 'SHOW') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - showing bar'+#13#10);
               inetMainForm.InterfaceControl.ShowFusion
           end else if CompareText(Line, 'HIDE') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - hiding bar'+#13#10);
               inetMainForm.inetAutoHide.Checked := True;
               inetMainForm.InterfaceControl.HideFusion
           end else if CompareText(Line, 'BOOT') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - exiting windows (interruptable)'+#13#10);
               inetMainForm.InterfaceControl.ExitWindowsSync
           end else if CompareText(Line, 'BOOTNOW') = 0 then begin
               Socket.SendText('00 OK - exiting windows'+#13#10);
               inetMainForm.InterfaceControl.ExitWindowsNowSync
           end else if CompareText(Line, 'POWEROFFNOW') = 0 then begin
               Socket.SendText('00 OK - shutting off power'+#13#10);
               inetMainForm.InterfaceControl.ShutdownNowSync
           end else if CompareText(Line, 'POWEROFF') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - shutting off power (interruptable)'+#13#10);
               inetMainForm.InterfaceControl.ShutdownSync
           end else if CompareTexT(Line, 'SCREENSAVER') = 0 then begin
               inetMainForm.ScreenSaverOn := not inetMainForm.ScreenSaverOn;
               Socket.SendText('00 OK - ScreenSaver set to '+BoolToStr(inetMainForm.ScreenSaverOn)+#13#10);
           end else if CompareTexT(Line, 'AUTOHIDE') = 0 then begin
               inetMainForm.inetAutoHide.Checked := not inetMainForm.inetAutoHide.Checked;
               Socket.SendText('00 OK - AutoHide set to '+BoolToStr(inetMainForm.inetAutoHide.Checked)+#13#10);
           end else if CompareText(Line, 'AUTOREBOOT') = 0 then begin
               inetMainForm.inetAutoReboot.Checked := not inetMainForm.inetAutoReboot.Checked;
               Socket.SendText('00 OK - AutoReboot set to '+BoolToStr(inetMainForm.inetAutoReboot.Checked)+#13#10);
           end else if CompareText(Line, 'SAVER') = 0 then begin
               inetMainForm.PosThread.ShowScreenSaver;
               Socket.SendText('00 OK - screen saver pop'+#13#10);
           end else if CompareText(Copy(Line, 1, Length('MSG')), 'MSG') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - non modal message: '+Copy(Line, Length('MSG')+1, Length(Line))+#13#10);
               inetMainForm.InterfaceControl.ShowMessage(False, Copy(Line, Length('MSG')+1, Length(Line)))
           end else if CompareText(Copy(Line, 1, Length('MODAL')), 'MODAL') = 0 then begin
               inetMainForm.PosThread.HideScreenSaver;
               Socket.SendText('00 OK - modal message: '+Copy(Line, Length('MODAL')+1, Length(Line))+#13#10);
               inetMainForm.InterfaceControl.ShowMessage(True, Copy(Line, Length('MODAL')+1, Length(Line)))
           end else if CompareText(Line, 'STAT') = 0 then begin
               CreateVersionString;
               Socket.SendText('02 STATS'+#13#10+Socket.RemoteAddress + ' (' + Socket.RemoteHost + ')' + #13#10 + VersionString + #13#10 + MemStatusString+#13#10);
               Socket.SendText('Version: ' + VersionID +
                                            #13#10 + 'Initial Counter: ' + IntToStr(inetMainForm.PosThread.DetectedActivity div 2) +
                                            #13#10 + 'Inactive Counter: ' + IntToStr(inetMainForm.PosThread.Elapsed div 2) + #13#10);
           end else if CompareText(Line, 'LOCK') = 0 then begin
               Socket.SendText('00 OK - blocking socket accept'+#13#10);
               InetMainForm.RejectSock := True;
           end else if CompareText(Copy(Line, 1, Length('SOUND')), 'SOUND') = 0 then begin
               inetMainForm.Player.FileName := Copy(Line, Length('SOUND')+2, Length(Line));
               if FileExists(inetMainForm.Player.FileName) then begin
                  Socket.SendText('00 OK - file '+inetMainForm.Player.FileName+' playng'+#13#10);
                  Synchronize(inetMainSndPlay);
                  end else begin
                  Socket.SendText('04 Error - file '+inetMainForm.Player.FileName+' does not exist'+#13#10);
                  end;
           end else if CompareText(Line, 'HELP') = 0 then begin
               Socket.SendText('QUIT           - terminate connexion'+#13#10+
                                            'TERM           - terminate bar'+#13#10+
                                            'SHELL          - launch explorer.exe'+#13#10+
                                            'COMMAND        - launch command.com'+#13#10+
                                            'TELNET         - launch telnet.exe'+#13#10+
                                            'SHOW           - show bar'+#13#10+
                                            'HIDE           - hide bar'+#13#10+
                                            'BOOT           - boot (conditional)'+#13#10+
                                            'BOOTNOW        - boot (unconditional)'+#13#10+
                                            'POWEROFF       - turn power off (conditional)'+#13#10+
                                            'POWEROFFNOW    - turn power off (unconditional)'+#13#10+
                                            'AUTOHIDE       - toggle autohide'+#13#10+
                                            'AUTOREBOOT     - toggle autoreboot'+#13#10+
                                            'MSG ...        - send a non modal message'+#13#10+
                                            'MODAL ...      - send a modal message'+#13#10+
                                            'STAT           - get remote machine stats'+#13#10+
                                            'SAVER          - screen saver pop'+#13#10 +
                                            'LOCK           - block socket connexions'+#13#10 +
                                            'SCREENSAVER    - toggle screen saver'+#13#10 +
                                            'HELP           - this help screen'+#13#10);
           end else Socket.SendText('01 Error - Invalid command: ' + Line + #13#10);
           end;
     finally
     Socket.Close;
     end;
     end;

procedure TProcessThread.inetMainSndPlay;
begin
     try
     inetMainForm.Player.Open;
     inetMainForm.Player.Play;
     except
     end;
     end;

procedure TInetMainForm.MessageHandler(var Msg: TMsg; var Handled: Boolean);
begin
     HAndled := False;
     if Msg.message = WM_SysCommand then begin
        if Msg.WParam = SC_MINIMIZE then begin
           inetMainForm.PosThread.HideScreenSaver;
           inetMainForm.inetAutoHide.Checked := True;
           inetMainForm.InterfaceControl.HideFusion;
           Handled := True;
           end;
        end;
     end;

procedure TInetMainForm.AppMinimize(Sender: TObject);
begin
     inetMainForm.PosThread.HideScreenSaver;
     inetMainForm.inetAutoHide.Checked := True;
     inetMainForm.InterfaceControl.HideFusion;
     end;

procedure TinetMainForm.FormShow(Sender: TObject);
begin
     if not TaskShow then ShowWindow(Application.Handle, SW_HIDE);
     end;

end.
