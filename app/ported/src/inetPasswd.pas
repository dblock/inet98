unit inetPasswd;

interface

uses Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs, StdCtrls, Buttons, ExtCtrls, MaskEdit;

type
  TPasswdForm = class(TForm)
    Passwd: TEdit;
    Image1: TImage;
    Label1: TLabel;
    BitBtn1: TBitBtn;
    BitBtn2: TBitBtn;
  private
    { Private declarations }
  public
    function InputQuery: string;
  end;

var
  PasswdForm: TPasswdForm;

implementation

uses inetMain;

{$R *.lfm}

function TPasswdForm.InputQuery: string;
begin
     Passwd.Text := '';
     ShowModal;
     if ModalResult = mrOk then begin
        Result := Passwd.Text;
        if Result = SecondPassword then Result:=inetMain.Password;
        end else Result := '';
     end;

end.
