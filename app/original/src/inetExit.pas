unit inetExit;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, Buttons, ExtCtrls, ShellApi, d32errors, WinProcs;

type
  TExitWindows = class(TForm)
    StatLabel: TLabel;
    CancelCommand: TBitBtn;
    TerminateTimer: TTimer;
    Image1: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure TerminateTimerTimer(Sender: TObject);
    procedure CancelCommandClick(Sender: TObject);
  private
    CountDown : integer;
    procedure HideTitlebar;
    procedure StatUpdate;
  public
    procedure WinExit;
    procedure Poweroff;
  end;

var
  ExitWindows: TExitWindows;

implementation

uses inetControl, inetMain;

{$R *.DFM}

procedure TExitWindows.HideTitlebar;
Var
   Save : LongInt;
Begin
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


procedure TExitWindows.FormCreate(Sender: TObject);
begin
     HideTitleBar;
     end;

procedure TExitWindows.FormShow(Sender: TObject);
begin
     CountDown := 10;
     TerminateTimer.Enabled := True;
     StatUpdate;
     end;

procedure TExitWindows.WinExit;
begin
    WinProcs.ExitWindowsEx(EW_REBOOTSYSTEM, -1);
    end;

procedure TExitWindows.StatUpdate;
begin
     if (inetMainForm.InterfaceControl.Action = inetControl.Poweroff) then begin
        StatLabel.Caption := 'Poweroff in ' + IntToStr(CountDown) + ' seconds ...';
        end else if (inetMainForm.InterfaceControl.Action = inetControl.Reboot) then begin
        StatLabel.Caption := 'Windows shall restart in ' + IntToStr(CountDown) + ' seconds ...';
        end;
     end;


procedure TExitWindows.TerminateTimerTimer(Sender: TObject);
begin
     dec(CountDown);
     StatUpdate;
     if CountDown = 0 then begin
        TerminateTimer.Enabled := False;
        CancelCommand.Visible := False;
        if (inetMainForm.InterfaceControl.Action = inetControl.Poweroff) then PowerOff else WinExit;
        end;
     end;

procedure TExitWindows.CancelCommandClick(Sender: TObject);
begin
     TErminateTimer.Enabled := False;
     Close;
     end;

procedure TExitWindows.Poweroff;
begin
    asm
        mov ax,5307h
        mov bx,1
        mov cx,3
        int 15h
        end;
     end;

end.
