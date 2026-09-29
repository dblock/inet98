unit SpriteDevelop;

interface

uses Classes, Controls;

type
  TSpriteDevelop = class;
  TStageNotifier = procedure(StageManager: TSpriteDevelop; Previous, Current: integer) of object;

  TSpriteDevelop = class(TComponent)
     private
          FCurrentLayer : integer;
          FOnLayerChange: TStageNotifier;
          procedure SetCurrentLayer(Value: integer);
     public
          function GetcurrentLayeR: integer;
          procedure Refresh;
          constructor Create(AOwner: TComponent); override;
          procedure SetFOnLayerChange(Value: TStageNotifier);
     published
          property CurrentLayer: integer read FCurrentLayer write SetCurrentLayer;
          property OnLayerChange: TStageNotifier read FOnLayerChange write SetFOnLayerChange;
     end;

implementation

constructor TSpriteDevelop.Create(AOwner: TComponent);
begin
     FCurrentLayer := 0;
     FOnLayerChange:=nil;
     inherited Create(AOwner);
     end;

procedure TSpriteDevelop.SetCurrentLayer(Value: integer);
begin
     if not (csDesigning in ComponentState) then if Assigned(FOnLayerChange) then FOnLayerChange(Self, FCurrentLayer, Value);
     FCurrentLayer := Value;
     Refresh;
     end;

function TSpriteDevelop.GetCurrentLayer: integer;
begin
     Result := FCurrentLayer;
     end;

procedure TSpriteDevelop.Refresh;
var
   i: integer;
begin
     for i:=0 to Self.Owner.ComponentCount - 1 do
         if Owner.Components[i] is TGraphicControl then
            (Owner.Components[i] as TGraphicControl).Invalidate;
     end;

procedure TSpriteDevelop.SetFOnLayerChange(Value: TStageNotifier);
begin
     FOnLayerChange := Value;
     end;

end.
