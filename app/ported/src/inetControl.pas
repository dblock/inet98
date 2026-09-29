unit inetControl;

interface

uses Classes, Forms, Windows, Dialogs, SysUtils, SpriteReact;

type

  TAction = (Reboot, Poweroff);
  TInterfaceControl = class(TThread)
  private
    TempStorageStr: string;
    TempStorageModal: boolean;
    Target : TForm;
    FTerminating : boolean;
    FAction: TAction;
  protected
    procedure Execute; override;
  public
    constructor Create(Form: TForm);
    procedure Stop;
    procedure ShutdownSync;
    procedure Shutdown;
    procedure ShutdownNowSync;
    procedure ShutdownNow;
    procedure Resume;
    procedure ShowFusion;
    procedure HideFusion;
    procedure ExitWindows;
    procedure Terminate;
    procedure ExitInet;
    procedure ExitWindowsSync;
    procedure ExitWindowsNowSync;
    procedure ExitWindowsNow;
    procedure ShowMessage(Modal: boolean; Msg: string);
    procedure ShowMessageSync;
    procedure ShowScreenSaver;
    procedure HideScreenSaver;
  published
    property Terminating: boolean read FTerminating;
    property Action: TAction read FAction;
  end;

implementation

uses inetMain, inetExit, inetTimer, ScreenSaver;

procedure TInterfaceControl.ShutdownSync;
begin
     Synchronize(Shutdown);
     end;

procedure TInterfaceControl.Shutdown;
begin
     FAction := Poweroff;
     inetExit.ExitWindows.ShowModal;
     end;

procedure TInterfaceControl.ShutdownNowSync;
begin
     Synchronize(ShutdownNow);
     end;

procedure TInterfaceControl.ShutdownNow;
begin
     FAction := Poweroff;
     inetExit.ExitWindows.PowerOff;
     end;

procedure tInterfaceControl.ExitWindowsNowSync;
begin
     Synchronize(ExitWindowsNow);
     end;

procedure tInterfaceControl.ExitWindowsNow;
begin
     FAction := Reboot;
     inetExit.ExitWindows.WinExit;
     end;

procedure tInterfaceControl.ExitWindowsSync;
begin
     Synchronize(ExitWindows);
     end;

procedure tInterfaceControl.ExitWindows;
begin
     FAction := Reboot;
     inetExit.ExitWindows.ShowModal;
     end;

procedure TInterfaceControl.Stop;
begin
     Suspended := True;
     end;

procedure TInterfaceControl.Resume;
begin
     Suspended := False;
     end;

constructor TInterfaceControl.Create(Form: TForm);
begin
     FTerminating := False;
     Target := Form;
     inherited Create(False);
     end;

procedure TInterfaceControl.Showfusion;
begin
     while Target.Left < 0 do Target.Left := Target.Left + 4;
     ReactManager.Resume;
     end;

procedure TInterfaceControl.HideFusion;
begin
     ReactManager.Pause;
     while Target.Left + Target.Width > 8 do Target.Left := Target.Left - 4;
     end;

procedure TInterfaceControl.Execute;
var
   aPoint: TPoint;
begin
  Priority:=tpLowest;
  while not Application.Terminated do begin
        Sleep(500);
        GetcursorPos(aPoint);
        if (Target.Left < 0) then begin
          if (aPoint.x < 10) then Synchronize(ShowFusion);
          end else begin
          if (aPoint.x > Target.Width) then Synchronize(HideFusion);
          end;
        end;
  end;

procedure TInterfaceControl.Terminate;
begin
     FTerminating := True;
     Synchronize(ExitInet);
     end;

procedure TInterfaceControl.ExitInet;
begin
     Application.Terminate;
     end;

procedure TInterfaceControl.ShowMessageSync;
begin
     TInetMsg.NormalShow(TempStorageModal, TempStorageStr);
     end;

procedure TInterfaceControl.ShowMessage(Modal: boolean; Msg: string);
begin
     TempStorageStr := Msg;
     TempStorageModal := Modal;
     Synchronize(ShowMessageSync);
     end;

procedure TInterfaceControl.ShowScreenSaver;
begin
     ShowCursor(False);
     sSaver.Show;
     end;


procedure TInterfaceControl.HideScreenSaver;
begin
     ShowCursor(True);
     sSaver.Hide;
     end;
     
end.
