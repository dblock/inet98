unit screenSaver;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls;

type
  TsSaver = class(TForm)
    ScreenImage: TImage;
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    procedure HideTitleBar;
  public
  end;

var
  sSaver: TsSaver;

implementation

{$R *.lfm}

uses d32gen;

procedure TsSaver.FormCreate(Sender: TObject);
var
   ScreenBmp: string;
begin
     HideTitleBar;
     ScreenBmp := bs(ExtractFileDir(Application.ExeName)) + 'bar\screen.bmp';
     if FileExists(ScreenBmp) then ScreenImage.Picture.LoadFromFile(ScreenBmp);
     end;

procedure TsSaver.HideTitlebar;
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

procedure TsSaver.FormShow(Sender: TObject);
begin
     Left := 0;
     Top := 0;
     Width := Screen.Width;
     Height := Screen.Height;
     ScreenImage.Left := (Screen.Width - ScreenImage.Width) div 2;
     ScreenImage.Top := (Screen.Height - ScreenImage.Height) div 2;
     BringToFront;     
     end;

end.
