unit SpriteReact;

interface

uses SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls, Dialogs;

type

  TReactThreadManager = class (TThread)
     private
           Reactable: boolean;
           Idle: boolean;
           Launched : boolean;
           Killed: boolean;
           aControl: TControl;
           aPoint: TPoint;
           ReactThreads : TList;
           FOnIdle: TNotifyEvent;
           procedure Execute; override;
           procedure SyncReact;
           procedure Reaction;
           procedure SetFOnIdle(aEvent: TNotifyEvent);
           procedure SyncIdle;
     public
           procedure Pause;
           procedure Resume;
           procedure Kill;
           procedure Launch;
           constructor Create;
           procedure RegisterControl(aControl: TControl);
           procedure UnregisterControl(aControl: Tcontrol);
           function Running: boolean;
     protected
     published
           property OnIdle: TNotifyEvent read FOnIdle write SetFOnIdle;
     end;

var
    ReactManager: TReactThreadManager = nil;

implementation

uses SpriteClass;

procedure TReactThreadManager.SetFOnIdle(aEvent: TNotifyEvent);
begin
     FOnIdle := aEvent;
     end;

constructor TReactThreadManager.Create;
begin
     ReactThreads := Tlist.Create;
     FreeOnTerminate:=True;
     Killed := False;
     Launched:=False;
     inherited Create(True);
     end;

function TReactThreadManager.Running: boolean;
begin
     Result := Suspended;
     end;

procedure TReactThreadManager.SyncReact;
begin
     try
     TSprite(aControl).React(aPoint);
     except
     end;
     end;

procedure TReactThreadManager.Reaction;
begin
     try
     Reactable := TSprite(aControl).Reacting(aPoint, idle)
     except
     end;
     end;

procedure TReactThreadManager.Execute;
var
   i: integer;
   hadReaction: boolean;
begin
     try
     while not Killed do begin
              hadReaction := False;
              for i:=0 to ReactThreads.Count - 1 do begin
                  try
                  GetCursorPos(aPoint);
                  if not Killed then aControl := ReactThreads[i];
                  if aControl.Visible and Application.Active and (not Killed) then begin
                     Synchronize(Reaction);
                     if not idle then begin
                        hadReaction := True;
                        //Screen.Cursor := (aControl as TSprite).Cursor;
                        end;
                     if Reactable and (not Killed) then Synchronize(SyncReact);
                     end;
                  except
                  end;
                  //Application.ProcessMessages;            {Enable under D2}
                  end;
              Sleep(200);
              if not hadReaction then begin
                 if Assigned(OnIdle) then Synchronize(SyncIdle);
                 Application.ProcessMessages;
                 //Screen.Cursor := crDefault;
                 end;
              end;
     except
     end;
     end;

procedure TReactThreadManager.SyncIdle;
begin
     OnIdle(Self);
     end;

procedure TReactThreadManager.RegisterControl(aControl: TControl);
begin
     try
     ReactThreads.Add(aControl);
     if Launched then Suspended := False;
     except
     end;
     end;

procedure TReactThreadManager.UnRegisterControl(aControl: TControl);
var
   i: integer;
begin
     try
     if (not Killed) and (not Application.Terminated) then begin
        i := ReactThreads.IndexOf(aControl);
        if (i <> -1) and (not Killed) and (not Application.Terminated) then begin
           ReactThreads.Remove(aControl);
           if ReactThreads.Count = 0 then Suspended := True;
           end;
        end;
     except
     end;
     end;

procedure TReactThreadManager.Kill;
begin
     try
     Killed := True;
     Suspended := False;
     except
     end;
     end;

procedure TReactThreadManager.Launch;
begin
     try
     Suspended:=False;
     Launched := True;
     except
     end;
     end;

procedure TReactThreadManager.Pause;
begin
     Suspended:=True;
     end;

procedure TReactThreadManager.Resume;
begin
     Suspended:=False;
     end;


begin
     //ReactManager := TReactThreadManager.Create;
     //ReactManager.Launch;
     end.
