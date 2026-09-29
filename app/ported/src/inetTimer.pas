unit inetTimer;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, ExtCtrls, StdCtrls, Buttons;

type
  TinetMsg = class(TForm)
    Image1: TImage;
    StatLabel: TLabel;
    cmdClose: TBitBtn;
    MsgTimer: TTimer;
    procedure FormCreate(Sender: TObject);
    procedure cmdCloseClick(Sender: TObject);
    procedure MsgTimerTimer(Sender: TObject);
  private
    //procedure HideTitlebar;
  public
    class procedure NormalShow(Modal: boolean; Msg: string);
  end;

implementation

uses inetMain;

{$R *.lfm}

{procedure TInetMsg.HideTitlebar;
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
   end;}

class procedure TInetMsg.NormalShow(Modal: boolean; Msg: string);
var
   inetMsg: TInetMsg;
begin
     Application.CreateForm(TinetMsg, inetMsg);
     inetMsg.StatLabel.Caption := Msg;
     inetMsg.MsgTimer.Enabled := True;
     inetMsg.MsgTimer.Interval := inetMain.MsgMax;
     if Modal then begin
        inetMsg.ShowModal;
        inetMsg.Destroy;
        end else inetMsg.Show;
     end;

procedure TinetMsg.FormCreate(Sender: TObject);
begin
     //HideTitleBar;
     end;

procedure TinetMsg.cmdCloseClick(Sender: TObject);
begin
     Close;
     end;

procedure TinetMsg.MsgTimerTimer(Sender: TObject);
begin
     Close;
     end;

     end.
