program inet98;

uses
  Forms, WinProcs,
  inetMain in 'inetMain.pas' {inetMainForm},
  inetControl in 'inetControl.pas',
  d32errors in '..\common.d32\d32errors.pas',
  inetExit in 'inetExit.pas' {ExitWindows},
  d32about in '..\common.d32\D32about.pas',
  d32debug in '..\common.d32\D32debug.pas',
  d32reg in '..\common.d32\D32reg.pas',
  d32gen in '..\common.d32\D32gen.pas',
  inetTimer in 'inetTimer.pas' {inetMsg},
  screenSaver in 'screenSaver.pas' {sSaver},
  inetPasswd in 'inetPasswd.pas' {PasswdForm};

{$R *.RES}

begin
  Application.Initialize;
  Application.Title := 'Inet 98 Launcher';
  Application.CreateForm(TinetMainForm, inetMainForm);
  Application.CreateForm(TExitWindows, ExitWindows);
  Application.CreateForm(TsSaver, sSaver);
  Application.CreateForm(TPasswdForm, PasswdForm);
  Application.Run;
end.
