unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.UIConsts, System.Classes, System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs,
  FMX.Controls.Presentation, FMX.StdCtrls, Net.Socket, FMX.ScrollBox, FMX.Memo,
  System.Hash, Net.StreamSocket, UCustomMemoryStream, FMX.Objects, FMX.Edit;

type
  TForm1 = class(TForm)
    Button1: TButton;
    Timer1: TTimer;
    Memo1: TMemo;
    Button2: TButton;
    Timer2: TTimer;
    Circle1: TCircle;
    Edit1: TEdit;
    procedure Button1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
  private
    S,SC,C: TTCPSocket;
    C2: TStreamSocket;
    procedure OnCConnect(Sender: TObject);
    procedure OnAccept(Sender: TObject);
    procedure OnReceived(Sender: TObject);
    procedure OnC2Connect(Sender: TObject);
    procedure OnC2Received(Sender: TObject);
    procedure OnC2Close(Sender: TObject);
  public
    { Public declarations }
  end;

var
  Form1: TForm1;

implementation

{$R *.fmx}

procedure TForm1.FormCreate(Sender: TObject);
begin

  S:=TTCPSocket.Create;
  S.OnAccept:=OnAccept;
  //S.Start(5556);

  C:=TTCPSocket.Create;
  C.OnConnect:=OnCConnect;

  C2:=TStreamSocket.Create;
  C2.OnConnect:=OnC2Connect;
  C2.OnReceived:=OnC2Received;
  C2.OnClose:=OnC2Close;

end;

procedure TForm1.FormDestroy(Sender: TObject);
begin

  S.Terminate;
  C.Terminate;
  C2.Terminate;
  if Assigned(SC) then SC.Terminate;

  S.Free;
  C.Free;
  C2.Free;
  SC.Free;

end;

procedure TForm1.OnAccept(Sender: TObject);
begin
  if not Assigned(SC) then
  begin
    SC:=TTCPSocket.Create(S.GetAcceptSocket);
    SC.OnReceived:=OnReceived;
    SC.Connect;
  end;
end;

procedure TForm1.Timer1Timer(Sender: TObject);
var B: TBytes;
begin
  B:=TEncoding.ANSI.GetBytes(THash.GetRandomString(10));
  if Assigned(C) then C.Send(B[0],Length(B));
end;

procedure TForm1.OnReceived(Sender: TObject);
begin
  if Memo1.Lines.Count>30 then
    Memo1.Text:=TTCPSocket(Sender).ReceiveString
  else
    Memo1.Lines.Add(TTCPSocket(Sender).ReceiveString);
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  //C.Connect(S.HostAddress,5555);
  C.Connect('190.2.146.26',5555);
end;

procedure TForm1.OnCConnect(Sender: TObject);
begin
  C.Disconnect;
  C.Connect('190.2.146.26',5555);
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  if C2.Connected then
  begin
    C2.Disconnect;
    Timer2.Enabled:=False;
    Circle1.Fill.Color:=claRed;
  end else
    C2.Connect(Edit1.Text,5555);
end;

procedure TForm1.OnC2Connect(Sender: TObject);
begin
  Timer2.Enabled:=True;
  Circle1.Fill.Color:=claGreen;
end;

procedure TForm1.OnC2Close(Sender: TObject);
begin
  Timer2.Enabled:=False;
  Circle1.Fill.Color:=claRed;
  C2.Connect(Edit1.Text,5555);
end;

procedure TForm1.Timer2Timer(Sender: TObject);
var B: TBytes;
begin
  B:=TEncoding.ANSI.GetBytes(THash.GetRandomString(10));
  C2.SendPackage(B[0],Length(B),702);
  C2.SendPackage(B[0],Length(B),702);
  C2.SendPackage(B[0],Length(B),702);
  C2.SendPackage(B[0],Length(B),702);
end;

procedure TForm1.OnC2Received(Sender: TObject);
var
  Packages: TPackagesList;
  Package: TPackage;
begin

  Packages:=TPackagesList.Create;
  try

    TStreamSocket(Sender).DataStream.StreamToList(Packages);

    for Package in Packages do
    case Package.typ of
    702:

    if Memo1.Lines.Count>30 then
      Memo1.Text:=TEncoding.ANSI.GetString(TBytes(Package.obj))
    else
      Memo1.Lines.Add(TEncoding.ANSI.GetString(TBytes(Package.obj)));

    end;

  finally
    Packages.Free;
  end;

end;

end.
