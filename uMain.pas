unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ExtCtrls, WinApi.CommCtrl, System.Types;

const
  SpriteHeight  = 26; //px
  SpriteWidth   = 26;

  MineCount = 40;
  FieldHeight = 16;
  FieldWidth = 16;

  IndentField = 20; // px

  FieldHeightPixel = FieldHeight * SpriteHeight;
  FieldWidthPixel  = FieldWidth  * SpriteWidth;

  //Определения клеточки
  cFirstClick = -2;
  cOpen = -1;
  cClose = 0;
  cFlag = 1;
  cMine = 2;
  c0 = 3;
  c1 = 4;
  c2 = 5;
  c3 = 6;
  c4 = 7;
  c5 = 8;
  c6 = 9;
  c7 = 10;
  c8 = 11;

type
  TfmMain = class(TForm)
    SpriteList: TImageList;
    pbField: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure pbFieldPaint(Sender: TObject);
    procedure pbFieldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
  private
    { Private declarations }
    mInitField: boolean;
    FieldUp: array [0..FieldHeight-1, 0..FieldWidth-1] of Integer; // Открыто, закрыто, флажок
    FieldDown: array [0..FieldHeight-1, 0..FieldWidth-1] of Integer; // генерируемое поле, цифры, мины

    procedure InitField;
    procedure GenerateMines(X,Y: integer); // First Click
    procedure RepaintField;

  public
    { Public declarations }
  end;

  {
    Взрыв мин от точки взрыва
  }


var
  fmMain: TfmMain;
  cheat: boolean;

implementation

{$R *.dfm}

{$REGION 'FuncMinesField'}
function IsFlag(X,Y: integer): boolean;
begin
  result := (fmMain.FieldUp[X,Y] = cFlag);
end;

function IsFirstClick(X,Y: integer): boolean;
begin
  result := (fmMain.FieldUp[X,Y] = cFirstClick);
end;

function IsEmpty(X,Y: integer): boolean;
begin
  result := (fmMain.FieldDown[X,Y] = c0);
end;

function IsNumber(X,Y: integer): boolean;
begin
  result := (fmMain.FieldDown[X,Y] > c0);
end;

function IsOpen(X,Y: integer): boolean;
begin
  result := (fmMain.FieldUp[X,Y] = cOpen);
end;

function IsMine(X,Y: integer): boolean;
begin
  result := (fmMain.FieldDown[X,Y] = cMine);
end;

function IsRange(X,Y: integer): boolean;
begin
  if (X<0) or (Y<0) or (X>=FieldWidth) or (Y>=FieldHeight) then
    result := false
  else
    result := true;
end;

procedure Boom;
var
  X,Y: integer;
begin
with fmMain do
  for X := Low(FieldUp) to High(FieldUp) do
    for Y := Low(FieldUp) to High(FieldUp) do
      if IsMine(X,Y) then
        FieldUp[X,Y] := cOpen;
end;

procedure OpenEmpty(X,Y: integer);
var
  I,J: integer;
begin
  with fmMain do
  begin
    if IsFlag(X,Y) then exit;

    if IsEmpty(X,Y) and (not IsOpen(X,Y)) then
    begin
      FieldUp[X,Y] := cOpen;
      for I := -1 to 1 do
      for J := -1 to 1 do
        if IsRange(X+I,Y+J) then
          OpenEmpty(X+I,Y+J);
    end
      else
    if IsNumber(X,Y) then
      FieldUp[X,Y] := cOpen;
    end;
end;

function aroundMineCount(X,Y:integer):integer;
var
  I,J: integer;
begin
result:=0;
with fmMain do
  for I := X-1 to X+1 do
  for J := Y-1 to Y+1 do
    if IsRange(I,J) and IsMine(I,J) then
      Result:=Result+1;
end;
function CountOpenCells: integer;
var
  X,Y: integer;
begin
result:=0;
with fmMain do
  for X := Low(FieldUp) to High(FieldUp) do
    for Y := Low(FieldUp) to High(FieldUp) do
      if IsOpen(X,Y) then
        Result:=Result+1;
end;

function CountFlagMine: integer;
var
  X,Y: integer;
begin
result:=0;
with fmMain do
  for X := Low(FieldUp) to High(FieldUp) do
    for Y := Low(FieldUp) to High(FieldUp) do
      if IsFlag(X,Y) then
        Result:=Result+1;
end;

function CountMine: integer;
var
  X,Y: integer;
begin
result:=0;
with fmMain do
  for X := Low(FieldUp) to High(FieldUp) do
    for Y := Low(FieldUp) to High(FieldUp) do
      if IsMine(X,Y) then
        Result:=Result+1;
end;

function FinishGame: boolean;
begin
  result := (FieldHeight*FieldWidth - CountOpenCells = MineCount);
end;

{$ENDREGION 'FuncMinesField'}

procedure TfmMain.FormCreate(Sender: TObject);
begin
  cheat:=false;
  Randomize;
  ClientHeight := FieldHeightPixel + IndentField * 2;
  ClientWidth  := FieldWidthPixel  + IndentField * 2;

  pbField.Height := FieldHeightPixel;
  pbField.Width  := FieldWidthPixel;
  pbField.Top  := IndentField;
  pbField.Left := IndentField;

  InitField;
end;

procedure TfmMain.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if (ssCtrl in Shift) and (Key = Ord('H')) then
    cheat:= not cheat;
  RepaintField;
end;

procedure TfmMain.GenerateMines(X, Y: integer);

  {
    function SetMine(X,Y: integer): boolean;
  Description
    Set mine in game field.
  Params
    X,Y Coordinate where set mine
  Result
    TRUE - Mine Is set
    FALSE - Mine is not set. (Mine is already set)
  }

  function SetMine(mX,mY: integer): boolean;
  var
    I,J,fX,fY: integer;
  begin
    result := true; // установлена
    if not IsMine(mX,mY) then
    begin
      FieldDown[mX,mY] := cMine;
      for I := -1 to 1 do
        for J := -1 to 1 do
        begin
          fX := mX+I;
          fY := mY+J;
          if IsRange(fX,fY) then
          if not IsMine(fX,fY) then
            FieldDown[fX,fY] := FieldDown[fX,fY] + 1;
        end;
    end else
      result := false;
  end;

type
  TMineNew = record
    coord: TPoint;
    Priority: integer;
  end;

var
  Mines,i,p: integer;
  m: array [0..2] of TMineNew;
begin
  Mines := MineCount;
  FieldUp[X,Y] := cFirstClick;

  // Sets mine in game field
  while (Mines<>0) do
  begin
    if Mines < (MineCount-10) then
    begin

      for I := Low(m) to High(m) do
      begin
        M[I].coord := Point(Random(FieldWidth), Random(FieldHeight));
        while IsMine(M[I].coord.X,M[I].coord.Y) or
          IsFirstClick(M[I].coord.X,M[I].coord.Y) do
            M[I].coord := Point(Random(FieldWidth), Random(FieldHeight));

        M[I].Priority := (ABS(M[I].coord.X-X)+abs(M[I].coord.Y-Y))*
        (Random(aroundMineCount(M[I].coord.X,M[I].coord.Y)));
      end;

      p:=Low(m);
      for I := Low(m) to High(m) do
        if M[p].Priority<M[I].Priority then
          p:=i;

      if SetMine(M[p].coord.X, M[p].coord.Y) then
        Mines := Mines -1;
    end else if SetMine(Random(FieldWidth), Random(FieldHeight)) then
      Mines := Mines -1;
  end;
  FieldUp[X,Y] := cClose;
end;

procedure TfmMain.InitField;
var
  X,Y: integer;
begin
  // Close all cell
  for X := Low(FieldUp) to High(FieldUp) do
    for Y := Low(FieldUp) to High(FieldUp) do
      FieldUp[X,Y] := cClose;

  // Sets empty cell on all field
  for X := Low(FieldDown) to High(FieldDown) do
    for Y := Low(FieldDown) to High(FieldDown) do
      FieldDown[X,Y] := c0;

  fmMain.Caption:=inttostr(CountFlagMine)+' / '+ inttostr(MineCount);
//  GenerateMines(Random(FieldHeight),Random(FieldWidth));
end;

procedure TfmMain.pbFieldMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  fX,fY: integer;
  flag: boolean;
begin
  fX := X div SpriteWidth;
  fY := Y div SpriteHeight;

  if (not IsRange(fX,fY)) then Exit;
  flag := IsFlag(fX,fY);

  if (mbLeft = Button) and flag then exit;
  if (mbRight = Button) then
  begin
    if (not IsOpen(fX,fY)) then
    begin
      if flag then
        FieldUp[fX,fY] := cClose
      else
        FieldUp[fX,fY] := cFlag;
      RepaintField;
      fmMain.Caption:=inttostr(CountFlagMine)+' / '+ inttostr(MineCount);
    end;
    exit;
  end;

  if (not mInitField) then
  begin
    GenerateMines(fX,fY);
    mInitField:=true;
  end;

  if (not IsOpen(fX, fY)) then
  begin
    if IsEmpty(fX,fY) then
      OpenEmpty(fx,fY)
    else if IsMine(fX,fY) then
    begin
//      FieldUp[fX,fY] := cOpen;
      Boom;
      RepaintField;
      ShowMessage('BOOM!');
      InitField;
      mInitField:=false;
      RepaintField;
      Exit;
    end;

    FieldUp[fX,fY] := cOpen;
    RepaintField;

    if FinishGame then
    begin
//      FieldUp[fX,fY] := cOpen;
//      RepaintField;
      ShowMessage('Win!');
      InitField;
      mInitField:=false;
      RepaintField;
      Exit;
    end;

  end;
end;

procedure TfmMain.pbFieldPaint(Sender: TObject);
begin
  RepaintField;
end;

procedure TfmMain.RepaintField;
var
  X,Y: integer;
begin
  for X := Low(FieldUp) to High(FieldUp) do
    for Y := Low(FieldUp) to High(FieldUp) do
      if IsOpen(X,Y) or cheat then
        SpriteList.Draw(pbField.Canvas,
          X*SpriteHeight,
          Y*SpriteWidth,
          FieldDown[X,Y])
      else
        SpriteList.Draw(pbField.Canvas,
          X*SpriteHeight,
          Y*SpriteWidth,
          FieldUp[X,Y]);
end;

end.
