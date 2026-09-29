unit SpriteClass;

interface

uses SysUtils, Windows, Messages, Classes, Graphics, Controls, Forms, StdCtrls, ExtCtrls, Dialogs, SpriteAnimate, SpriteReact;

type

  TDCEvent = procedure (aDC: HDC) of object;
  TReactEvent = procedure (Sender: TObject; var Reactable: boolean) of object;

var
  SpritePainting: boolean = True;

type

  TSprite = class(TGraphicControl)
     private
          //FDevelopControl : TSpriteDevelop;
          //FLayer: integer;
          WentDown: boolean;
          FKeepDown: boolean;
          FDown: boolean;
          FOnReact: TReactEvent;
          CWidth, CHeight: integer;
          {$ifndef SpriteRegistered}
          bmUnReg, bmUnRegOld: HBitmap;
          UnRegDC: HDC;
          {$endif}
          {DisabledDC : HDC;
          DisabledBmp, DisabledBmpOld : HBITMAP;}
          bmAndBack, bmAndObject, bmAndMem, bmBackOld, bmObjectOld, bmMemOld: HBitmap;
          lastDC, hdcMem, hdcBack, hdcObject, hdcTemp: HDC;
          FDrawDisabled: boolean;
          FOnStepForward: TDCEvent;
          FOnStart: TNotifyEvent;
          FOnEnd: TNotifyEvent;
          Finished: boolean;
          FRemove: boolean;
          FPaused: boolean;
          BmSaveGeneral: HBitmap;
          BmSaveGeneralOld: HBitmap;
          HdcSaveGeneral: HDC;
          FAutoSize: boolean;
          FTransparentColor : TColor;
          FBitmapLow: TBitmap;
          FBitmapHigh: TBitmap;
          FBitmapCurrent: TBitmap;
          FImageList: TImageList;
          FMoveVertical: integer;
          FMoveHorizontal: integer;
          FMoveSteps : integer;
          FStartX : integer;
          FStartY : integer;
          CurrentX: integer;
          CurrentY: integer;
          FCycle: boolean;
          FReverse: boolean;
          FReactable: boolean;
          FAnimator: TSpriteAnimate;
          FEntireReact: boolean;
          FEnter: TNotifyEvent;
          FExit: TNotifyEvent;
          FOver : Boolean;
          FShow: TNotifyEvent;
          CurrentBitmap: integer;
          dX, dY : double;
          FTransparent: boolean;
          FdX, FdY : double;
          FMaskX: integer;
          FMaskY: integer;
          FCursor: TCursor;
          FBorderStyle : TPenStyle;
          FShowBorder: boolean;
          FBorderWidth: integer;
          FBorderColor: TColor;
          Inside: boolean;
          Showing: boolean;
          procedure DoRefresh;
          procedure DrawCurrentBitmap(adc: HDC);
          procedure DrawTransparentBitmap(adc: HDC; Image: TBitmap; TransparentColor: TColor);
          procedure Paint; override;
          procedure CreateSaveDC;
          procedure DisposeSaveDC;
          procedure SetBitmapHigh(Value: tBitmap);
          procedure SetBitmapLow(Value: tBitmap);
          procedure SetTransparentColor(Value: TColor);
          procedure SetReactable(Value: boolean);
          function  OnGlyphP(X, Y: integer): boolean;
          procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
          procedure Click; override;
          procedure SelfEnter(Sender: TObject);
          procedure SelfExit(Sender: TObject);
          procedure ExecOnExit;
          procedure ExecOnEnter;
          procedure Show(Sender: TObject);
          procedure SetAnimator(Value: TSpriteAnimate);
          procedure SetMoveHorizontal(Value: integer);
          procedure SetMoveVertical(Value: integer);
          procedure SetMoveSteps(Value: integer);
          procedure SetImageList(Value: TImageList);
          procedure SetStartX(Value: integer);
          procedure SetStartY(Value: integer);
          procedure SetMaskX(Value: integer);
          procedure SetMaskY(Value: integer);
          procedure SetCursor(Value: TCursor);
          procedure SetEntireReact(Value: boolean);
          procedure SetShow(Value: TNotifyEvent);
          procedure SetReverse(Value: boolean);
          procedure SetCycle(Value: boolean);
          procedure SetAutosize(Value: boolean);
          procedure SetShowBorder(Value: boolean);
          procedure SetBorderStyle(Value: TPenStyle);
          procedure SetBorderWidth(Value: integer);
          procedure SetBorderColor(Value: TColor);
          procedure SetRemove(Value: boolean);
          procedure SetOnStart(Value: TNotifyEvent);
          procedure SetOnEnd(Value: TNotifyEvent);
          procedure SetOnStepForward(Value: TDCEvent);
          procedure Loaded; override;
          procedure SetFDrawDisabled(Value: boolean);
          //procedure SetFLayer(Value: integer);
          //procedure SetDevelopControl(Value: TSpriteDevelop);
          procedure SetTransparent(Value: boolean);
          procedure SetOnReact(Value: TReactEvent);
          procedure WMMouseDown(var T: TMsg); message WM_LBUTTONDOWN;
          procedure WMMouseUp(var T: TMsg); message WM_LBUTTONUP;
     public
          procedure Restart;
          procedure Pause;
          procedure Resume;
          procedure StepForward(adc: HDC);
          procedure React(aPoint: TPoint);
          constructor Create(AOwner: TComponent); override;
          destructor Destroy; override;
          procedure PrepareDCs(adc: hdc);
          procedure DisposeDCs(adc: hdc);
          function Reacting(aPoint: TPoint; var isIdle: boolean): boolean;
          procedure FlickBitmap(ABitmap: TBitmap);
          procedure SetFDown(Value: boolean);
          procedure SetFKeepDown(Value: boolean);
     published
          property OnReact: TreactEvent read FOnReact write SetOnReact;
          property Transparent: boolean read FTransparent write SetTransparent;
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
          property Visible;
          property Cursor: TCursor read FCursor write SetCursor default crDefault;
          property OnEnter: TNotifyEvent read FEnter write FEnter;
          property OnExit: TNotifyEvent read FExit write FExit;
          property CursorOverImage: Boolean read FOver;
          property TransparentColor: TColor read FTransparentColor write SetTransparentColor default clBlack;
          property MoveVertical: integer read FMoveVertical write SetMoveVertical;
          property MoveHorizontal: integer read FMoveHorizontal write SetMoveHorizontal;
          property MoveSteps: integer read FMoveSteps write SetMoveSteps;
          property StartLeft: integer read FStartX write SetStartX;
          property StartTop: integer read FStartY write SetStartY;
          property SpriteAnimator: TSpriteAnimate read FAnimator write SetAnimator;
          property BitmapLow: TBitmap read FBitmapLow write SetBitmapLow;
          property BitmapHigh: TBitmap read FBitmapHigh write SetBitmapHigh;
          property ImageList: TImageList read FImageList write SetImageList;
          property Reactable : boolean read FReactable write SetReactable;
          property EntireReact: boolean read FEntireReact write SetEntireReact;
          property OnShow: TNotifyEvent read FShow write SetShow;
          property Reverse : boolean read FReverse write SetReverse;
          property Cycle: boolean read FCycle write SetCycle;
          property MaskX: integer read FMaskX write SetMaskX;
          property MaskY: integer read FMaskY write SetMaskY;
          property AutoSize: boolean read FAutoSize write SetAutoSize;
          property ShowBorder: boolean read FShowBorder write SetShowBorder;
          property BorderStype: TPenStyle read FBorderStyle write SetBorderStyle;
          property BorderColor: TColor read FBorderColor write SetBorderColor;
          property BorderWidth: integer read FBorderWidth write SetBorderWidth;
          property Paused: boolean read FPaused;
          property Remove: boolean read FRemove write SetRemove;
          property OnStart: TNotifyEvent read FOnStart write SetOnStart;
          property OnEnd: TNotifyEvent read FOnEnd write SetOnEnd;
          property OnStepForward: TDcEvent read FOnStepForward write SetOnStepForward;
          property Down: boolean read FDown write SetFDown;
          property KeepDown: boolean read FKeepDown write SetFKeepDown;
          //property DrawDisabled: boolean read FDrawDisabled write SetFDrawDisabled;
          //property Layer: integer read FLayer write SetFLayer;
          //property DevelopControl: TSpriteDevelop read FDevelopControl write SetDevelopControl;
          end;

	procedure Register;

implementation

constructor TSprite.Create(AOwner: TComponent);
begin
     inherited Create(AOwner);
     //DevelopControl := nil;
     FDrawDisabled:= False;
     WentDown:=False;
     FDown := False;
     FKeepDown := False;
     FTransparent := True;
     Finished := False;
     hdcMem := 0;
     FRemove := False;
     FCycle := True;
     FPaused:=False;
     CurrentBitmap := 0;
     Inside := False;
     Showing:=True;
     OnShow := Show;
     FBitmapLow := TBitmap.Create;
     FBitmapHigh := TBitmap.Create;
     CurrentX := 0;
     CurrentY := 0;
     Width:=50;
     Height:=50;
     Reactable := False;
     HDcSaveGeneral := 0;
     FBorderStyle := psDot;
     FBorderColor := clBlack;
     FBorderWidth := 1;
     FShowBorder := False;
     FBitmapCurrent := nil;
     end;

destructor TSprite.Destroy;
begin
     try if FReactable then ReactManager.UnRegisterControl(Self); except end;
     try FBitmapLow.Free; except end;
     try FBitmapHigh.Free; except end;
     try if Assigned(FAnimator) then FAnimator.UnRegisterControl(Self); except end;
     try if Assigned(FImageList) then
         if FImageList.Count > 0 then FBitmapCurrent.Free; except end;
     DisposeDCs(lastDC);
     DisposeSaveDC;
     inherited Destroy;
     end;

procedure TSprite.SetAnimator(Value: TSpriteAnimate);
begin
     if Value <> FAnimator then begin
        FAnimator := Value;
        try if Assigned(FAnimator) then FAnimator.RegisterControl(Self); except FAnimator := nil; end;
        Visible := False;
        DoRefresh;
        end;
     end;

procedure TSprite.SetTransparentColor(Value: TColor);
begin
     if FTransparentColor <> Value then begin
        FTransparentColor := Value;
        DoRefresh;
        end;
     end;

procedure TSprite.SetBitmapLow(Value: TBitmap);
begin
     FBitmapLow.Assign(Value);
     try
     if Assigned(FImageList) then begin
        if FImageList.Count = 0 then FBitmapCurrent := FBitmapLow;
        end else FBitmapCurrent := FBitmapLow;
     except
     FImageList := nil;
     FBitmapCurrent := FBitmapLow;
     end;
     Height := FBitmapLow.Height;
     Width := FBitmapLow.Width;
     if Height = 0 then Height := 50;
     if Width = 0 then Width := 50;
     if (FBitmapLow.Height > 0) and
        (csDesigning in ComponentState) and
        not (csLoading in ComponentState) then
        FTransparentColor := FBitmapLow.Canvas.Pixels[0, FBitmapLow.Height - 1];
     DoRefresh;
     end;

procedure TSprite.SetMoveVertical(Value: integer);
begin
     if Value <> FMoveVertical then begin
        FMoveVertical := Value;
        if FMoveSteps <> 0 then dy := FMoveVertical / FMoveSteps else dy := 0;
        end;
     end;

procedure TSprite.SetMoveSteps(Value: integer);
begin
     if (Value >=0) and (Value <> FMoveSteps) then begin
        FMoveSteps:=Value;
        if FMoveSteps <> 0 then dy := FMoveVertical / FMoveSteps else dy := 0;
        if FMoveSteps <> 0 then dx := FMoveHorizontal / FMoveSteps else dx :=0;
        end;
     end;

procedure TSprite.SetMoveHorizontal(Value: integer);
begin
     FMoveHorizontal := Value;
     if FMoveSteps <> 0 then dx := FMoveHorizontal / FMoveSteps else dx :=0;
     end;

procedure TSprite.SetBitmapHigh(Value: TBitmap);
begin
     FBitmapHigh.Assign(Value);
     if (FBitmapCurrent = nil) then begin
        try
        if Assigned(FImageList) then begin
           if FImageList.Count = 0 then FBitmapCurrent := FBitmapHigh;
           end else FBitmapCurrent := FBitmapHigh;
        except
        FImageList := nil;
        FBitmapCurrent := FBitmapHigh;
        end;
        end;
     if (csDesigning in ComponentState) and
        not(csLoading in ComponentState) and
        Assigned(FBitmapLow) then FReactable := True;
     DoRefresh;
     end;

procedure TSprite.SetMaskX(Value: integer);
begin
     if (Value >= 0) and (Value <> FMaskX) then begin
        FMaskX := Value;
        DoRefresh;
        end;
     end;

procedure TSprite.SetMaskY(Value: integer);
begin
     if (Value >= 0) and (Value <> FMaskY) then begin
        FMaskY := Value;
        DoRefresh;
        end;
     end;

procedure TSprite.SetStartX(Value: integer);
begin
     if Value >= 0 then begin
        FStartX := Value;
        CurrentX := Value;
        fdY := CurrentX;
        DoRefresh;
        end;
     end;

procedure TSprite.SetStartY(Value: integer);
begin
     if Value >= 0 then begin
        FStartY := Value;
        CurrentY := Value;
        fdY := CurrentY;
        DoRefresh;
        end;
     end;

procedure TSprite.StepForward(adc: hdc);
begin
     if FAnimator = nil then begin
        MessageDlg('StepForward:: this procedure can only be used internally by a TSpriteAnimator!', mtError, [mbOk],0);
        Application.Terminate;
     end else if csDesigning in ComponentState then begin
        DrawCurrentBitmap(adc);
     end else if Assigned(FImageList) and (FImageList.Count > 0) then begin
        if not FPaused then
        if FReverse then begin
           CurrentBitmap := (CurrentBitmap - 1) mod FImageList.Count;
           if CurrentBitmap < 0 then CurrentBitmap := FImagelist.Count - 1;
           end else CurrentBitmap := (CurrentBitmap + 1) mod FImageList.Count;
        FImageList.GetBitmap(CurrentBitmap, FBitmapCurrent);
     end;

     if not (csDesigning in ComponentState) and Assigned(FOnStepForward)
        then FOnStepForward(adc);

     if Showing then begin
        OnShow(Self);
        if FBitmapCurrent.Height > 0 then DrawCurrentBitmap(adc);
        end;

     if not FPaused and not Finished then begin
        if FReverse then begin
           FdX := FdX - dx;
           FdY := FdY - dy;
           end else begin
           FdX := FdX + dx;
           FdY := FdY + dy;
           end;

        CurrentX := trunc(FdX);
        CurrentY := trunc(FdY);

        if ((CurrentX > FMoveHorizontal + FBitmapCurrent.Width + FStartX) or (CurrentX < 0) or
           (CurrentY > FMoveVertical + FBitmapCurrent.Height + FStartY) or (CurrentY < 0)) then begin
              if Assigned(FOnEnd) then FOnEnd(Self);
              if FCycle then Restart
                 else begin
                 Finished := True;
                 try
                 if FRemove then if Assigned(FAnimator) then FAnimator.UnregisterControl(Self);
                 except
                 FAnimator := nil;
                 end;
                 end;
           end else if FBitmapCurrent.Height > 0 then DrawCurrentBitmap(adc);
        end;
     end;

procedure TSprite.Paint;
begin
    if (not SpritePainting) then exit;
    {if Assigned(DevelopControl) then
       if DevelopControl.GetCurrentLayer <> FLayer then exit;}
    if not (csDesigning in ComponentState) and (not Visible) then exit;
    if FBitmapCurrent <> nil then
    if FAutoSize and (FBitmapCurrent.Height > 0) then begin
       if Height <> FBitmapCurrent.Height then Height := FBitmapCurrent.Height;
       if Width <> FBitmapCurrent.Width then Width := FBitmapCurrent.Width;
       end;
    if (csDesigning in ComponentState) or (FShowBorder) then begin
       Canvas.Pen.Style := FBorderStyle;
       Canvas.Brush.Style := bsClear;
       Canvas.Pen.Color := FBorderColor;
       Canvas.Pen.Width := FBorderWidth;
       Canvas.Rectangle(0, 0, Width, Height);
       end;
    //if FOver then if Screen.Cursor <> FCursor then Screen.Cursor := FCursor;
    if (csDesigning in ComponentState) then begin
       if Assigned(FImageList) then begin
          if FImageList.Count = 0 then FBitmapCurrent := FBitmapLow;
          end else FBitmapCurrent := FBitmapLow;
       if Assigned(FAnimator) or (FBitmapCurrent.Height = 0) then begin
          Canvas.MoveTo(Width, 0);
          Canvas.LineTo(0, Height);
          Canvas.MoveTo(0, 0);
          Canvas.LineTo(Width, Height);
          end;
       end;
    if Showing then OnShow(Self) else CreateSaveDC;
    if (not (csLoading in ComponentState)) and (FBitmapCurrent.Height > 0) then DrawCurrentBitmap(Canvas.Handle);
    end;

procedure TSprite.DrawCurrentBitmap(adc: hdc);
var
  ARect : TRect;
  Tmp : TBitMap;
begin
     ARect := Rect(0, 0, Width,Height);
     if (not Ftransparent) or (FTransparentColor >= 0) and (FTransparentColor <= $7FFFFFFF) then begin
        Tmp := TBitmap.Create;
        Tmp.Height := FBitmapCurrent.Height;
        Tmp.Width :=  FBitmapCurrent.Width;
        Tmp.Canvas.CopyRect(ARect, FBitmapCurrent.Canvas, ARect);
        DrawTransparentBitmap(adc, Tmp, FTransparentColor);
        Tmp.Free;
        end else Canvas.CopyRect(ARect, FBitmapCurrent.Canvas, ARect);
     end;

procedure TSprite.SetReactable(Value: boolean);
begin
     FReactable := Value;
     end;

procedure TSprite.PrepareDCs(adc: HDC);
{$ifndef SpriteRegistered}
var
   i, j: integer;
{$endif}
begin
     if hdcMem = 0 then begin
     if Assigned(FAnimator) then begin
        try
        CWidth := FAnimator.Width;
        CHeight := FAnimator.Height;
        except
        Cwidth := Width;
        CHeight := Height;
        FAnimator := nil;
        end;
        end else begin
        CWidth := Width;
        CHeight := Height;
        end;

     lastDC := adc;
     if not (csDesigning in ComponentState) and Assigned(FAnimator) then hdcMem := aDc;
     hdcBack   := CreateCompatibleDC(adc);                                       { create some DCs to hold temporary data }
     hdcObject := CreateCompatibleDC(adc);
     if hdcMem = 0 then begin
        hdcMem    := CreateCompatibleDC(adc);
        bmAndMem    := CreateCompatibleBitmap (adc, CWidth, CHeight);
        bmMemOld    := SelectObject (hdcMem, bmAndMem);
        end;

     {DisabledDC := CreateCompatibleDC(adc);
     DisabledBmp := CreateCompatibleBitmap(adc, CWidth, CHeight);
     DisabledBmpOld := SelectObject(DisabledDC, DisabledBMP);


     for j:=0 to CWidth do
          for i:=0 to CHeight do
              SetPixel(DisabledDC, j, i, clWhite);}

     {$ifndef SpriteRegistered}
     UnRegDC := CreateCompatibleDC(adc);
     bmUnReg := CreateCompatibleBitmap(adc, CWidth, CHeight);
     bmUnRegOld := SelectObject(UnRegDC, bmUnReg);
     for j:=0 to CWidth do
          for i:=0 to CHeight do
             if Odd(i) and Odd(j) then begin
                SetPixel(UnRegDC, j, i, clWhite);
                end;
     {$endif}
     bmAndBack   := CreateBitmap (CWidth, CHeight, 1, 1, nil);                 { monochrome DC }
     bmAndObject := CreateBitmap (CWidth, CHeight, 1, 1, nil);
     bmBackOld   := SelectObject (hdcBack, bmAndBack);
     bmObjectOld := SelectObject (hdcObject, bmAndObject);
     end;
     end;

procedure TSprite.DrawTransparentBitmap (adc: HDC; Image: TBitmap; TransparentColor: TColor);
var
  cColor          : TColorRef;
  ptSize          : TPoint;
  tx, ty, ix, iy: integer;
begin
     try
     if not SpritePainting then exit;
     if not (csDesigning in ComponentState) then begin
        tX := CurrentX - FMaskX;
        if tX < 0 then begin
           tX := abs(tX);
           ix := 0;
           end else begin
           tX := 0;
           ix := CurrentX - FMaskX;
           end;
        tY := CurrentY - FMaskY;
        if tY < 0 then begin
           tY := abs(tY);
           iy := 0;
           end else begin
           tY := 0;
           iy := CurrentY - FMaskY;
           end;
        end else begin
        tX := 0;
        tY := 0;
        if Canvas.Handle = adc then begin
           CurrentX := 0;
           CurrentY := 0;
           end else begin
           CurrentX := FStartX;
           CurrentY := FStartY;
           end;
        ix := CurrentX;
        iy := CurrentY;
        end;

     if FDown then begin
        tX := tX - 1;
        tY := tY - 1;
        end;

     PrepareDCs(adc);

     TransparentColor := TransparentColor or $02000000;
     hdcTemp := Image.Canvas.Handle; { port: LCL keeps the bitmap selected in its canvas DC }

     ptSize.x := Image.Width;                                                    { convert bitmap dimensions from device to logical points }
     ptSize.y := Image.Height;
     DPtoLP (hdcTemp, ptSize, 1);                                                  { convert from device logical points }

     if not FTransparent then begin
        //BitBlt (adc, 0, 0, CWidth, CHeight, hdcTemp, 0, 0, SRCCOPY);                    { place the original bitmap back into the bitmap sent here }
        BitBlt (adc, ix, iy, ptSize.x - tx, ptSize.y - ty, hdcTemp, tx, ty, SRCCOPY);                    { place the original bitmap back into the bitmap sent here }
        end else begin
        SetMapMode (hdcTemp, GetMapMode (adc));
        cColor := SetBkColor (hdcTemp, TransparentColor);                            { set the background color of the source DC to the color contained in the parts of the bitmap that should be transparent }
        BitBlt (hdcObject, tx, ty, ptSize.x - tx, ptSize.y - ty, hdcTemp, tx, ty, SRCCOPY);        { create the object mask for the bitmap by performing a BitBlt() from the source bitmap to a monochrome bitmap }
        SetBkColor (hdcTemp, cColor);                                               { set the background color of the source DC back to the original color }
        BitBlt (hdcBack, tx, ty, ptSize.x - tx, ptSize.y - ty, hdcObject, tx, ty, NOTSRCCOPY);    { create the inverse of the object mask }

        if FReactable and
           Assigned(FBitmapHigh) and
           not Assigned(FAnimator) and
           not (csDesigning in ComponentState) then
             BitBlt (hdcMem, 0, 0, CWidth, CHeight, hdcSaveGeneral, 0, 0, SRCCOPY)     { copy the background of the main DC to the destination }
             else BitBlt (hdcMem, 0, 0, CWidth, CHeight, adc, 0, 0, SRCCOPY);     { copy the background of the main DC to the destination }

        if (csDesigning in ComponentState) or (Self.Enabled) or (FDrawDisabled) then begin
           BitBlt (hdcMem, ix, iy, ptSize.x - tx, ptSize.y - ty, hdcObject, tx, ty, SRCAND); { mask out the places where the bitmap will be placed }
           BitBlt (hdcTemp, tx, ty, ptSize.x - tx, ptSize.y - ty, hdcBack, tx, ty, SRCAND);            { mask out the transparent colored pixels on the bitmap }
           BitBlt (hdcMem, ix, iy, ptSize.x - tx, ptSize.y - ty, hdcTemp, tx, ty, SRCPAINT); { XOR the bitmap with the background on the destination DC }
           //if not Self.Enabled then BitBlt(hdcMem, ix, iy, ptSize.x, ptSize.y, DisabledDC, 0, 0, SRCPAINT);
           end;
        {$ifndef SpriteRegistered}
        if not(csDesigning in ComponentState) then BitBlt(hdcMem, ix, iy, ptSize.x, ptSize.y, UnRegDC, 0, 0, SRCPAINT);
        {$endif}

        if (hdcmem <> adc) then BitBlt (adc, 0, 0, CWidth, CHeight, hdcMem, 0, 0, SRCCOPY);
        end;
     except
     end;
     end;

procedure TSprite.DisposeDCs(adc: hdc);
begin
     (*try
     {$ifndef SpriteRegistered}
     DeleteObject(SelectObject(UnRegDC, bmUnRegOld));
     DeleteDC(UnRegDC);
     {$endif}
     DeleteObject (SelectObject (hdcBack, bmBackOld));
     DeleteObject (SelectObject (hdcObject, bmObjectOld));
     if (hdcMem <> adc) then begin
        DeleteObject (SelectObject (hdcMem, bmMemOld));
        DeleteDC (hdcMem);
        end;
     DeleteDC (hdcBack);
     DeleteDC (hdcObject);
     DeleteDC (hdcTemp);
     except
     end;*)
     end;

procedure TSprite.React(aPoint: TPOint);
begin
{     if (not PtInRect(Rect(ClientOrigin.X, ClientOrigin.Y, ClientOrigin.X + Width, ClientOrigin.Y + Height), aPoint))
        or (not FEntireReact and not FOver) then begin
             if Inside then begin
                Screen.Cursor := crDefault;
                if FReactable then ExecOnExit;
                end;
             end else
     if (FEntireReact or FOver) then begin
        if not Inside then begin
           Screen.Cursor := FCursor;
           if FReactable then ExecOnEnter;
           end;
        end;   }
     if Inside then begin
        //if Screen.Cursor <> crDefault then Screen.Cursor := crDefault;
        if FReactable then ExecOnExit;
        end else begin
        //if Screen.Cursor <> FCursor then Screen.Cursor := FCursor;
        if FReactable then ExecOnEnter;
        end;
     end;

procedure TSprite.Click;
begin
     if FOver or FEntireReact then inherited;
     end;

procedure TSprite.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
     if Application.Active then begin
        FOver := OnGlyphP(X, Y);
        if (FOver or FEntireReact) then begin
           if Screen.Cursor <> FCursor then Screen.Cursor := FCursor;
           if (FReactable) then begin
            if not FKeepDown then
            if not FDown and (ssLeft in Shift) then begin
              FDown := True;
              DrawCurrentBitmap(Canvas.Handle);
              end;
           inherited MouseMove(Shift, X, Y);
           end;
        end else Screen.Cursor := crDefault;
        end;
     end;

function TSprite.OnGlyphP(X, Y: integer): boolean;
begin
     if FBitmapCurrent <> nil then
        Result := PtInRect(ClientRect, Point(X, Y)) and (FBitmapCurrent.Canvas.Pixels[X, Y] <> FTransparentColor) or (not FTransparent)
        else Result:=True;
     end;

procedure TSprite.SelfEnter(Sender: TObject);
begin
     if not Self.Enabled then exit;
     if Assigned(FBitmapHigh) then begin
        if Assigned(FImageList) then begin
           if (FImageList.Count = 0)  then begin
              FBitmapCurrent := FBitmapHigh;
              Self.Paint
              end;
           end else begin
           FBitmapCurrent := FBitmapHigh;
           Self.Paint
           end;
        end;
     end;

procedure TSprite.SelfExit(Sender: TObject);
begin
     if not FKeepDown then
     if FReactable and FDown then begin
        FDown := False;
        DrawCurrentBitmap(Canvas.Handle);
        end;
     if not Self.Enabled then exit;
     if Assigned(FBitmapHigh) then begin
        if Assigned(FImageList) then begin
           if (FImageList.Count = 0)  then begin
              FBitmapCurrent := FBitmapLow;
              Self.Paint
              end;
           end else begin
           FBitmapCurrent := FBitmapLow;
           Self.Paint
           end;
        end;
     end;

procedure TSprite.ExecOnExit;
begin
     if not Self.Enabled then exit;
     if Inside then begin
         if Assigned(OnExit) then OnExit(Self);
         SelfExit(Self);
         Inside := False;
         end;
     end;

procedure TSprite.ExecOnEnter;
begin
     if not Self.Enabled then exit;
     if not Inside then begin
        if Assigned(OnEnter) then OnEnter(Self);
        SelfEnter(Self);
        Inside := True;
        end;
     end;

procedure TSprite.Show(Sender: TObject);
begin
     Restart;
     Showing:=False;
     if Assigned(FImageList) then begin
        if FImageList.Count = 0 then FBitmapCurrent := FBitmapLow;
        end else FBitmapCurrent := FBitmapLow;
     end;

procedure TSprite.SetImageList(Value: TImageList);
begin
     FImageList := Value;
     if Assigned(FImageList) and (FImageList.Count > 0) then begin
        FBitmapCurrent := TBitmap.Create;
        FImageList.GetBitmap(0, FBitmapCurrent);
        DoRefresh;
        end;
     end;

procedure TSprite.SetCursor(Value: TCursor);
begin
     FCursor := Value;
     end;

procedure TSprite.SetEntireReact(Value: boolean);
begin
     FEntireReact := Value;
     end;

procedure TSprite.SetShow(Value: TNotifyEvent);
begin
     FShow := Value;
     end;

procedure TSprite.SetReverse(Value: boolean);
begin
     FReverse := Value;
     end;

procedure TSprite.SetCycle(Value: boolean);
begin
     FCycle := Value;
     end;

procedure TSprite.SetAutosize(Value: boolean);
begin
     FAutosize := Value;
     DoRefresh;
     end;

procedure TSprite.CreateSaveDC;
begin
     if not (csLoading in ComponentState) and
        FReactable and Assigned(FBitmapHigh) and (HdcSaveGeneral = 0) and
        not Assigned(Fanimator) then begin
           hdcSaveGeneral := CreateCompatibleDC(Canvas.Handle);
           BmSaveGeneral := CreateCompatibleBitmap (Canvas.Handle, Width, Height);
           BmSaveGeneralOld := SelectObject (hdcSaveGeneral, bmSaveGeneral);
           BitBlt (hdcSaveGeneral, 0, 0, Width, Height, Canvas.Handle, 0, 0, SRCCOPY);
           end;
     end;

procedure TSprite.DisposeSaveDC;
begin
     if HdcSaveGeneral <> 0 then begin
        DeleteObject (SelectObject (bmSaveGeneral, bmSaveGeneralOld));
        DeleteDC (hdcSaveGeneral);
        end;
     end;

procedure TSprite.SetBorderStyle(Value: TPenStyle);
begin
     if FBorderStyle <> Value then begin
        FBorderStyle := Value;
        if (csDesigning in ComponentState) and
           not(csLoading in ComponentState) then FShowBorder := True;
        DoRefresh;
        end;
     end;

procedure TSprite.SetShowBorder(Value: boolean);
begin
     if FShowBorder <> Value then begin
        FShowBorder := Value;
        DoRefresh;
        end;
     end;

procedure TSprite.SetBorderWidth(Value: integer);
begin
     if Value > 0 then begin
        FBorderWidth:=Value;
        if (csDesigning in ComponentState) and
           not(csLoading in ComponentState) then FShowBorder := True;
        DoRefresh;
        end;
     end;

procedure TSprite.SetBorderColor(Value: TColor);
begin
     if FBorderColor <> Value then begin
        FBorderColor := Value;
        if (csDesigning in ComponentState) and
           not(csLoading in ComponentState) then FShowBorder := True;
        DoRefresh;
        end;
     end;

procedure TSprite.DoRefresh;
begin
     if not Self.Enabled then exit;
     if csDesigning in ComponentState then begin
        Invalidate;
        try
        if Assigned(FAnimator) then Fanimator.Invalidate;
        except
        FAnimator := nil;
        end;
        end;

     Paint;
     
     try
     if Assigned(Fanimator) then FAnimator.Repaint;
     except
     FAnimator := nil;
     end;

     end;

procedure TSprite.Pause;
begin
     FPaused := True;
     end;

procedure TSprite.Resume;
begin
     FPaused := False;
     end;

procedure TSprite.Restart;
begin
     Finished := False;
     if Assigned(FOnStart) then FOnStart(Self);
     if FReverse then begin
        FdX := FMoveHorizontal + FStartX;
        FdY := FMoveVertical + FStartY;
        end else begin
        FdX := FStartX;
        FdY := FStartY;
        end;
     CurrentX := trunc(FdX);
     CurrentY := trunc(FdY);
     try
     if Assigned(FAnimator) then
        if not FAnimator.IsRegisteredControl(Self) then
           FAnimator.RegisterControl(Self);
     except
     FAnimator := nil;
     end;
     end;

procedure TSprite.SetRemove(Value: boolean);
begin
     FRemove := Value;
     end;

procedure TSprite.SetOnStart(Value: TNotifyEvent);
begin
     FOnStart := Value;
     end;

procedure TSprite.SetOnEnd(Value: TNotifyEvent);
begin
     FOnEnd := Value;
     end;

procedure TSprite.SetOnStepForward(Value: TDCEvent);
begin
     FOnStepForward := Value;
     end;

{procedure TSprite.SetFLayer(Value: integer);
begin
     if Value <> FLayer then begin
        Flayer:=Value;
        Repaint;
        end;
     end;}

procedure TSprite.Loaded;
begin
     inherited Loaded;
     if not (csDesigning in ComponentState) then begin
        if (ReactManager = nil) then begin
           ReactManager := TReactThreadManager.Create;
           ReactManager.Launch;
           end;
        if FReactable then ReactManager.RegisterControl(Self)
           else ReactManager.UnRegisterControl(Self);
        end;
     end;

function TSprite.Reacting(aPoint: TPoint; var isIdle: boolean): boolean;
begin
     Result := False;
     isIdle := True;
     if not Visible then exit;
     {if Assigned(DevelopControl) then
       if DevelopControl.GetCurrentLayer <> FLayer then exit;}
     if (not PtInRect(Rect(ClientOrigin.X, ClientOrigin.Y, ClientOrigin.X + Width, ClientOrigin.Y + Height), aPoint))
        or (not FEntireReact and not FOver) then begin
             isIdle := False;
             if Inside then Result := True else Result := False;
             end else
     if (FEntireReact or FOver) then begin
        isIdle := False;
        if not Inside then Result := True else Result := False;
        end;
     if Assigned(FOnReact) then FOnReact(Self, Result);
     end;

{procedure TSprite.SetDevelopControl(Value: TSpriteDevelop);
begin
     FDevelopControl := Value;
     Repaint;
     end;}

procedure TSprite.SetTransparent(Value: boolean);
begin
     FTransparent := Value;
     end;

procedure TSprite.FlickBitmap(ABitmap: TBitmap);
begin
     FBitmapCurrent := ABitmap;
     FTransparentColor := FBitmapCurrent.Canvas.Pixels[0, FBitmapCurrent.Height - 1];
     DrawCurrentBitmap(Canvas.Handle);
     end;

procedure TSprite.SetOnReact(Value: TReactEvent);
begin
     FOnReact := Value;
     end;

procedure TSprite.WMMouseDown(var T: TMsg);
begin
     if FReactable and (FOver or FEntireReact) then begin
        if not FDown then begin
           WentDown := True;
           FDown := True;
           DrawCurrentBitmap(Canvas.Handle);
           end;
        inherited;
        end;
     end;


procedure TSprite.WMMouseUp(var T: TMsg);
begin
     if FReactable and (FOver or FEntireReact) then begin
        if FDown then
        if (not FKeepDown) or (not WentDown) then begin
           FDown := False;
           DrawCurrentBitmap(Canvas.Handle);
           end;
        WentDown := False;
        inherited;
        end;
     end;

procedure TSprite.SetFDown(Value: boolean);
begin
     if fDown <> Value then begin
        FDown := Value;
        DrawCurrentBitmap(Canvas.Handle);
        if (csDesigning in ComponentState) then FKeepDown := True;
        end;
     end;

procedure TSprite.SetFKeepDown(Value: boolean);
begin
     if Value <> FKeepDown then begin
        FKeepDown := Value;
        DrawCurrentBitmap(Canvas.Handle);
        end;
     end;

procedure TSprite.SetFDrawDisabled(Value: boolean);
begin
     if Value <> FDrawDisabled then begin
        FDrawDisabled := Value;
        DrawCurrentBitmap(Canvas.Handle);
        end;
     end;

procedure Register;
begin
  RegisterComponents('Sprites', [TSprite, TSpriteAnimate]);
  end;


begin

     end.
