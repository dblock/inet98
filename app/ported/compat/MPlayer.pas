unit MPlayer;

{ Minimal replacement for Delphi 3's MPlayer.TMediaPlayer, enough for inet98. }

{$mode delphi}

interface

uses
  Classes, SysUtils, Controls, MMSystem;

type
  TMPBtnType = (btPlay, btPause, btStop, btNext, btPrev, btStep, btBack, btRecord, btEject);
  TButtonSet = set of TMPBtnType;

  TMediaPlayer = class(TCustomControl)
  private
    FFileName: string;
    FVisibleButtons: TButtonSet;
    FColoredButtons: TButtonSet;
  public
    procedure Open;
    procedure Play;
  published
    property FileName: string read FFileName write FFileName;
    property VisibleButtons: TButtonSet read FVisibleButtons write FVisibleButtons;
    property ColoredButtons: TButtonSet read FColoredButtons write FColoredButtons;
    property TabOrder;
    property TabStop;
    property Visible;
  end;

implementation

procedure TMediaPlayer.Open;
begin
  mciSendString('close inet98snd', nil, 0, 0);
  mciSendString(PChar('open "' + FFileName + '" alias inet98snd'), nil, 0, 0);
end;

procedure TMediaPlayer.Play;
begin
  mciSendString('play inet98snd', nil, 0, 0);
end;

end.
