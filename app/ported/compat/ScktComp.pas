unit ScktComp;

{ Minimal replacement for Delphi 3's ScktComp.TServerSocket, enough for inet98.
  For safety the server only listens on 127.0.0.1. }

{$mode delphi}

interface

uses
  Classes, SysUtils, ssockets, WinSock2;

type
  TServerType = (stNonBlocking, stThreadBlocking);

  TCustomWinSocket = class
  private
    FStream: TSocketStream;
    function GetRemoteAddress: string;
    function GetRemotePort: integer;
  public
    constructor Create(AStream: TSocketStream);
    destructor Destroy; override;
    function ReceiveText: string;
    function SendText(const S: string): integer;
    procedure Close;
    property RemoteAddress: string read GetRemoteAddress;
    property RemoteHost: string read GetRemoteAddress;
    property RemotePort: integer read GetRemotePort;
  end;

  TSocketNotifyEvent = procedure(Sender: TObject; Socket: TCustomWinSocket) of object;

  TServerSocket = class;

  TAcceptThread = class(TThread)
  private
    FOwner: TServerSocket;
    FServer: TInetServer;
    procedure DoConnect(Sender: TObject; Data: TSocketStream);
  protected
    procedure Execute; override;
  public
    constructor Create(AOwner: TServerSocket);
    procedure Stop;
  end;

  TServerSocket = class(TComponent)
  private
    FActive: boolean;
    FPort: integer;
    FServerType: TServerType;
    FOnAccept: TSocketNotifyEvent;
    FThread: TAcceptThread;
    procedure SetActive(Value: boolean);
  protected
    procedure Loaded; override;
  public
    destructor Destroy; override;
  published
    property Active: boolean read FActive write SetActive;
    property Port: integer read FPort write FPort;
    property ServerType: TServerType read FServerType write FServerType;
    property OnAccept: TSocketNotifyEvent read FOnAccept write FOnAccept;
  end;

implementation

constructor TCustomWinSocket.Create(AStream: TSocketStream);
begin
  FStream := AStream;
end;

destructor TCustomWinSocket.Destroy;
begin
  Close;
  inherited;
end;

function TCustomWinSocket.GetRemoteAddress: string;
begin
  Result := '127.0.0.1';
end;

function TCustomWinSocket.GetRemotePort: integer;
begin
  Result := 0;
end;

function TCustomWinSocket.ReceiveText: string;
var
  n: u_long;
  got: integer;
begin
  Result := '';
  if FStream = nil then begin
    Sleep(50);
    Exit;
  end;
  n := 0;
  if (ioctlsocket(FStream.Handle, FIONREAD, n) <> 0) or (n = 0) then begin
    Sleep(50);
    Exit;
  end;
  SetLength(Result, n);
  got := FStream.Read(Result[1], n);
  if got <= 0 then Result := '' else SetLength(Result, got);
end;

function TCustomWinSocket.SendText(const S: string): integer;
begin
  Result := 0;
  if (FStream <> nil) and (Length(S) > 0) then Result := FStream.Write(S[1], Length(S));
end;

procedure TCustomWinSocket.Close;
begin
  FreeAndNil(FStream);
end;

constructor TAcceptThread.Create(AOwner: TServerSocket);
begin
  FOwner := AOwner;
  FreeOnTerminate := False;
  inherited Create(False);
end;

procedure TAcceptThread.DoConnect(Sender: TObject; Data: TSocketStream);
begin
  if Assigned(FOwner.FOnAccept) then
    FOwner.FOnAccept(FOwner, TCustomWinSocket.Create(Data))
  else
    Data.Free;
end;

procedure TAcceptThread.Execute;
var
  i, Port: integer;
begin
  { macOS only lets root bind ports below 1024 on 127.0.0.1, so fall back to Port + 10000 }
  for i := 0 to 1 do
  try
    Port := FOwner.FPort + i * 10000;
    FreeAndNil(FServer);
    FServer := TInetServer.Create('127.0.0.1', Port);
    FServer.OnConnect := DoConnect;
    FServer.StartAccepting;
    Exit;
  except
    on E: Exception do if IsConsole then WriteLn(StdErr, 'ScktComp: ', E.Message);
  end;
end;

procedure TAcceptThread.Stop;
begin
  if FServer <> nil then FServer.StopAccepting(True);
end;

procedure TServerSocket.SetActive(Value: boolean);
begin
  FActive := Value;
  if csLoading in ComponentState then Exit;
  if FActive and (FThread = nil) then
    FThread := TAcceptThread.Create(Self)
  else if not FActive and (FThread <> nil) then begin
    FThread.Stop;
    FThread := nil;
  end;
end;

procedure TServerSocket.Loaded;
begin
  inherited;
  SetActive(FActive);
end;

destructor TServerSocket.Destroy;
begin
  if FThread <> nil then FThread.Stop;
  inherited;
end;

end.
