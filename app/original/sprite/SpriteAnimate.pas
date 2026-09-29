unit SpriteAnimate;

interface

uses
    SysUtils, WinTypes, WinProcs, Messages, Classes, Graphics, Controls,
    Forms, StdCtrls, ExtCtrls, Dialogs, SpriteTimer, SpriteDevelop;

type

  TSpriteAnimate = class(TGraphicControl)
    private
       //FDevelopControl : TSpriteDevelop;
       //FLayer: integer;
       FPaused: boolean;
       BmWorking, BmSaveGeneral: HBitmap;
       BmWorkingOld, BmSaveGeneralOld: HBitmap;
       HdcWorking, HdcSaveGeneral: HDC;
       FAnimateInterval : integer;
       FEnabled: boolean;
       Controls: TList;
       procedure SetEnabled(Value: boolean);
       procedure Animate(Sender: TObject);
       procedure SetAnimateInterval(Value: integer);
       //procedure SetFLayer(Value: integer);
       //procedure SetDevelopControl(Value: TSpriteDevelop);
    protected
       procedure Loaded; override;
       procedure Paint; override;
    public
       function IsRegisteredControl(Sprite: tGraphicControl): boolean;
       procedure RegisterControl(Sprite: TGraphicControl);
       procedure UnRegisterControl(Sprite: TGraphicControl);
       procedure Pause;
       procedure Resume;
       constructor Create(AOwner: TComponent); override;
       destructor Destroy; override;
    published
       property ShowHint;
       property OnDragDrop;
       property OnDragOver;
       property OnEndDrag;
       property OnMouseDown;
       property OnMouseMove;
       property OnMouseUp;
       property OnClick;
       property OnDblClick;
       property PopupMenu;
       property AnimateInterval: integer read FAnimateInterval write SetAnimateInterval;
       property Enabled : boolean read FEnabled write SetEnabled;
       property Paused: boolean read FPaused;
       property Visible;
       //property Layer: integer read FLayer write SetFLayer;
       //property DevelopControl: TSpriteDevelop read FDevelopControl write SetDevelopControl;
  end;

  procedure Register;

implementation

uses SpriteClass;

constructor TSpriteAnimate.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     FPaused:=False;
     HdcWorking := 0;
     HdcSaveGeneral := 0;
     Controls := TList.Create;
     FAnimateInterval := 100;
     Width := 100;
     Height := 100;
     Enabled := True;
     end;

destructor TSpriteAnimate.Destroy;
begin
     if not(csDesigning in ComponentState) then AnimateTimer.UnregisterControl(Self);
     if Controls <> nil then Controls.Free;
     if HdcSaveGeneral <> 0 then begin
        DeleteObject (SelectObject (bmSaveGeneral, bmSaveGeneralOld));
        DeleteObject (SelectObject (bmWorking, bmWorkingOld));
        DeleteDC(hdcWorking);
        DeleteDC (hdcSaveGeneral);
        end;
     inherited Destroy;
     end;

procedure TSpriteAnimate.RegisterControl(Sprite: TGraphicControl);
begin
     Controls.Add(Sprite);
     if csDesigning in ComponentState then Invalidate;
     end;

procedure TSpriteAnimate.UnRegisterControl(Sprite: TGraphicControl);
begin
     Controls.Remove(Sprite);
     if csDesigning in ComponentState then Invalidate
     //else if Controls.Count = 0 then Self.Destroy;
     end;

procedure TSpriteAnimate.SetEnabled(Value: boolean);
begin
     if Value <> FEnabled then FEnabled := Value;
     end;

procedure TSpriteAnimate.Animate(Sender: TObject);
var
   k: integer;
begin
     {if Assigned(DevelopControl) then
       if DevelopControl.GetCurrentLayer <> FLayer then exit;}
     if FPaused or (not Visible) then exit;
     if (hdcWorking <> 0) then begin
        BitBlt (hdcWorking, 0, 0, Width, Height, hdcSaveGeneral, 0, 0, SRCCOPY);
        for k:=0 to Controls.Count - 1 do TSprite(Controls[k]).StepForward(hdcWorking);
        BitBlt (Canvas.Handle, 0, 0, Width, Height, hdcWorking, 0, 0, SRCCOPY);
        end;
     if csDesigning in ComponentState then begin
        for k:=0 to Controls.Count - 1 do
            TSprite(Controls[k]).StepForward(Canvas.Handle);
        end;
     end;

procedure TSpriteAnimate.Paint;
begin
     {if Assigned(DevelopControl) then
       if DevelopControl.GetCurrentLayer <> FLayer then exit;}
     if (hdcSaveGeneral = 0) or (csDesigning in ComponentState) then begin
        hdcSaveGeneral := CreateCompatibleDC(Canvas.Handle);
        BmSaveGeneral := CreateCompatibleBitmap (Canvas.Handle, Width, Height);
        BmSaveGeneralOld := SelectObject (hdcSaveGeneral, bmSaveGeneral);
        hdcWorking := CreateCompatibleDC(Canvas.Handle);
        BmWorking := CreateCompatibleBitmap (Canvas.Handle, Width, Height);
        BmWorkingOld := SelectObject (hdcWorking, BmWorking);
        BitBlt (hdcSaveGeneral, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
        end;
     if csDesigning in ComponentState then begin
        Animate(Self);
        Canvas.Pen.Style := psDot;
        Canvas.Brush.Style := bsClear;
        Canvas.Pen.Color := clBlack;
        Canvas.Rectangle(0, 0, Width, Height);
        end;
     end;

procedure TSpriteAnimate.SetAnimateInterval(Value: integer);
begin
     FAnimateInterval := Value;
     end;

function TSpriteAnimate.IsRegisteredControl(Sprite: tGraphicControl): boolean;
var
   i: integer;
begin
     i := Controls.IndexOf(Sprite);
     if i >= 0 then Result:=True else Result:=False;
     end;

procedure TSpriteAnimate.Pause;
begin
     FPaused:=True;
     end;

procedure TSpriteAnimate.Resume;
begin
     FPaused:=False;
     end;

procedure TSpriteAnimate.Loaded;
begin
     if not(csDesigning in ComponentState) then begin
        if (AnimateTimer = nil) then AnimateTimer := TSpriteTimer.Create;
        if FEnabled then begin
           AnimateTimer.RegisterControl(Self, FAnimateInterval, FEnabled, Animate);
           end else AnimateTimer.UnregisterControl(Self);
        end;
     end;

{procedure TSpriteAnimate.SetFLayer(Value: integer);
begin
     if Value <> FLayer then begin
        Flayer:=Value;
        Repaint;
        end;
     end;}

{procedure TSpriteAnimate.SetDevelopControl(Value: TSpriteDevelop);
begin
     FDevelopControl := Value;
     Repaint;
     end;}


procedure Register;
begin
  RegisterComponents('Sprites', [TSprite, TSpriteAnimate]);
  end;

end.
