unit SpriteTimer;

interface

uses Classes, WinTypes, Controls, Forms, MmSystem;

type

  PThreadControl = ^TThreadControl;
  TThreadControl = record
       Control: TControl;
       Interval: dword;
       Enabled: boolean;
       OnTimer: TNotifyEvent;
       TickRun: dword;
       end;

  TSpriteTimer = class(TThread)
       private
          Killed: boolean;
          CurrentControl: PThreadControl;
          ControlsList: TList;
          procedure Execute; override;
          procedure ExecuteControl;
       public
          procedure Kill;
          constructor Create;
          //destructor Destroy; override;
          procedure RegisterControl(_Control: TControl; _Interval: dword; _Enabled: boolean; _OnTimer: TNotifyEvent);
          procedure UnregisterControl(_Control: TControl);
       protected
       published
       end;

var
   AnimateTimer: TSpriteTimer = nil;

implementation

constructor TSpriteTimer.Create;
begin
     Killed := False;
     ControlsList := TList.Create;
     FreeOnTerminate := True;
     inherited Create(True);
     end;

{destructor TSpriteTimer.Destroy;
var
   i: integer;
begin
     for i:=ControlsList.Count - 1 downto 0 do begin
         dispose(PThreadControl(ControlsList[i]));
         end;
     ControlsList.Free;
     inherited Destroy;
     end;}

procedure TSpriteTimer.RegisterControl(_Control: TControl; _Interval: dword; _Enabled: boolean; _OnTimer: TNotifyEvent);
var
   ThreadControl: PThreadControl;
begin
     try
     new(ThreadControl);
     with ThreadControl^ do begin
          Control := _Control;
          Interval := _Interval;
          Enabled := _Enabled;
          OnTimer := _OnTimer;
          TickRun := TimeGetTime;
          end;
     ControlsList.Add(ThreadControl);
     Suspended := False;
     except
     end;
     end;

procedure TSpriteTimer.UnregisterControl(_Control: TControl);
var
   ThreadControl: PThreadControl;
   i: integer;
begin
     try
     for i:=0 to ControlsList.Count - 1 do
         if PThreadControl(ControlsList.Items[i])^.Control = _Control then begin
            ThreadControl := PThreadControl(ControlsList.Items[i]);
            ControlsList.Remove(ThreadControl);
            dispose(ThreadControl);
            if ControlsList.Count = 0 then Suspended:=True;
            exit;
            end;
     except
     end;
     end;


procedure TSpriteTimer.ExecuteControl;
begin
     try
     CurrentControl^.OnTimer(Self);
     CurrentControl^.TickRun := TimeGetTime;
     except
     end;
     end;

procedure TSpriteTimer.Kill;
begin
     Killed := True;
     Suspended := False;
     end;

procedure TSpriteTimer.Execute;
var
   i: integer;
begin
     while not Killed do begin
           try
              for i:=0 to ControlsList.Count - 1 do begin
                  CurrentControl:=PThreadControl(ControlsList.Items[i]);
                  if CurrentControl^.Enabled then
                     if (TimeGetTime - CurrentControl^.TickRun) > CurrentControl^.Interval then
                        Synchronize(ExecuteControl);
                     Application.ProcessMessages;
                  end;
           except
           end;
           end;
     end;

end.
