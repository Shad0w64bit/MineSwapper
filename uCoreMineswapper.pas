unit uCoreMineswapper;

interface

uses
  Vcl.Graphics, Vcl.Controls, System.Classes, Vcl.ImgList, System.Types, System.SysUtils;

type
  TCellType = (cFirstClick=-2, cOpen=-1, cClose=0, cFlag=1, cMine=2, c0,c1,c2,c3,c4,c5,c6,c7,c8);
  PCanvas = ^TCanvas;

   TGameStateProc = procedure(const Win: boolean);
   TFlagsStateProc = procedure(const Flags: integer);


  TCoreMineSwapper = class
  private
    mPCanvas: PCanvas;
    mSpriteList: TImageList;

    // Field Params
    mInitField: boolean;
    mEndGame: boolean;

    mFieldHeight: Word;
    mFieldWidth:  Word;
    mMineCount: Word;
    mFieldUp: array of array of TCellType; // [Открыто, закрыто, флажок]
    mFieldDown: array of array of TCellType; // генерируемое поле, цифры, мины

    function IsOpen(X, Y: integer): boolean;
    function IsEmpty(X, Y: integer): boolean;
    function IsFirstClick(X, Y: integer): boolean;
    function IsFlag(X, Y: integer): boolean;
    function IsMine(X, Y: integer): boolean;
    function IsNumber(X, Y: integer): boolean;
    function IsRange(X, Y: integer): boolean;
    procedure OpenEmpty(X, Y: integer);
    procedure GenerateMines(X, Y: integer);
    function aroundMineCount(X, Y: integer): integer;
    function CountFlagMine: integer;
//    function CountMine: integer;
    function FinishGame: boolean;
    function CountOpenCells: integer;
    procedure Boom;
    function getSpriteWidth: integer;
    procedure setSpriteWidth(const Value: integer);
    function getSpriteHeight: integer;
    procedure setSpriteHeight(const Value: integer);
    function getFieldHeightPixel: integer;
    function getFieldWidthPixel: integer;
  public
    constructor Create(AOwner: TComponent);
    destructor Destroy; override;
  protected
    SetGameState: TGameStateProc;
    SetFlagsState: TFlagsStateProc;
  public
    procedure Repaint;
    procedure LoadSprite(const Height, Width: integer; Images: TCustomImageList);
    procedure OpenCell(X,Y: integer);
    procedure SetFlag(X,Y: integer);
    procedure ResizeField(NewHeight, NewWidth: Word);
    procedure InitField;

    property Canvas: PCanvas read mPCanvas write mPCanvas;
    property Height: Word read mFieldHeight;
    property GameState: TGameStateProc write SetGameState;
    property FlagsState: TFlagsStateProc write SetFlagsState;
    property Width: Word read mFieldWidth;
    property MineCount: Word read mMineCount write mMineCount;
    property SpriteWidth: integer read getSpriteWidth write setSpriteWidth;
    property SpriteHeight: integer read getSpriteHeight write setSpriteHeight;
    property FieldHeightPixel: integer  read getFieldHeightPixel;
    property FieldWidthPixel: integer  read getFieldWidthPixel;
    property EndGame: boolean read mEndGame;
  end;


implementation

{ TCoreMineSwapper }

function TCoreMineSwapper.getFieldHeightPixel: integer;
begin
  Result := Height * SpriteHeight;
end;

function TCoreMineSwapper.getFieldWidthPixel: integer;
begin
  Result := Width * SpriteWidth;
end;

function TCoreMineSwapper.getSpriteHeight: integer;
begin
  result := mSpriteList.Height;
end;

function TCoreMineSwapper.getSpriteWidth: Integer;
begin
  result := mSpriteList.Width;
end;

{$REGION 'MineFunc'}
function TCoreMineSwapper.IsFlag(X,Y: integer): boolean;
begin
  result := (mFieldUp[X,Y] = cFlag);
end;

function TCoreMineSwapper.IsFirstClick(X,Y: integer): boolean;
begin
  result := (mFieldUp[X,Y] = cFirstClick);
end;

function TCoreMineSwapper.IsEmpty(X,Y: integer): boolean;
begin
  result := (mFieldDown[X,Y] = c0);
end;

function TCoreMineSwapper.IsNumber(X,Y: integer): boolean;
begin
  result := (mFieldDown[X,Y] > c0);
end;

function TCoreMineSwapper.IsOpen(X,Y: integer): boolean;
begin
  result := (mFieldUp[X,Y] = cOpen);
end;

function TCoreMineSwapper.IsMine(X,Y: integer): boolean;
begin
  result := (mFieldDown[X,Y] = cMine);
end;

function TCoreMineSwapper.IsRange(X,Y: integer): boolean;
begin
  if (X<0) or (Y<0) or (X>=mFieldWidth) or (Y>=mFieldHeight) then
    result := false
  else
    result := true;
end;

function TCoreMineSwapper.CountOpenCells: integer;
var
  X,Y: integer;
begin
  result:=0;
  for X := Low(mFieldUp) to High(mFieldUp) do
    for Y := Low(mFieldUp) to High(mFieldUp) do
      if IsOpen(X,Y) then
        Result:=Result+1;
end;

function TCoreMineSwapper.CountFlagMine: integer;
var
  X,Y: integer;
begin
  result:=0;
  for X := Low(mFieldUp) to High(mFieldUp) do
    for Y := Low(mFieldUp) to High(mFieldUp) do
      if IsFlag(X,Y) then
        Result:=Result+1;
end;

{
function TCoreMineSwapper.CountMine: integer;
var
  X,Y: integer;
begin
  result:=0;
  for X := Low(mFieldUp) to High(mFieldUp) do
    for Y := Low(mFieldUp) to High(mFieldUp) do
      if IsMine(X,Y) then
        Result:=Result+1;
end;
}

function TCoreMineSwapper.FinishGame: boolean;
begin
  result := (mFieldHeight*mFieldWidth - CountOpenCells = mMineCount);
end;

{$ENDREGION 'MineFunc'}

constructor TCoreMineSwapper.Create(AOwner: TComponent);
begin
  inherited Create;
  mSpriteList := TImageList.Create(AOwner);
  mInitField:=false;
  mMineCount:=4;
  ResizeField(16,16);
end;

destructor TCoreMineSwapper.Destroy;
begin
  ResizeField(0,0);
  mSpriteList.Destroy;
  inherited Destroy;
end;

procedure TCoreMineSwapper.LoadSprite(const Height, Width: integer; Images: TCustomImageList);
begin
  mSpriteList.Height := Height;
  mSpriteList.Width := Width;

  mSpriteList.BeginUpdate;
  mSpriteList.AddImages(Images);
  mSpriteList.EndUpdate;
end;

function TCoreMineSwapper.aroundMineCount(X,Y:integer):integer;
var
  I,J: integer;
begin
  result:=0;
  for I := X-1 to X+1 do
    for J := Y-1 to Y+1 do
      if IsRange(I,J) and IsMine(I,J) then
        Result:=Result+1;
end;

procedure TCoreMineSwapper.GenerateMines(X, Y: integer);

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
      mFieldDown[mX,mY] := cMine;
      for I := -1 to 1 do
        for J := -1 to 1 do
        begin
          fX := mX+I;
          fY := mY+J;
          if IsRange(fX,fY) then
          if not IsMine(fX,fY) then
            mFieldDown[fX,fY] := TCellType(ord(mFieldDown[fX,fY]) + 1);
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
//  InitField;
  Mines := mMineCount;
  mFieldUp[X,Y] := cFirstClick;

  // Sets mine in game field
  while (Mines<>0) do
  begin
    if Mines < (mMineCount-10) then
    begin

      for I := Low(m) to High(m) do
      begin
        M[I].coord := Point(Random(mFieldWidth), Random(mFieldHeight));
        while IsMine(M[I].coord.X,M[I].coord.Y) or
          IsFirstClick(M[I].coord.X,M[I].coord.Y) do
            M[I].coord := Point(Random(mFieldWidth), Random(mFieldHeight));

        M[I].Priority := (ABS(M[I].coord.X-X)+abs(M[I].coord.Y-Y))*
        (Random(aroundMineCount(M[I].coord.X,M[I].coord.Y)));
      end;

      p:=Low(m);
      for I := Low(m) to High(m) do
        if M[p].Priority<M[I].Priority then
          p:=i;

      if SetMine(M[p].coord.X, M[p].coord.Y) then
        Mines := Mines -1;
    end else if SetMine(Random(mFieldWidth), Random(mFieldHeight)) then
      Mines := Mines -1;
  end;
  mFieldUp[X,Y] := cClose;
end;

procedure TCoreMineSwapper.Boom;
var
  X,Y: integer;
begin
  for X := Low(mFieldUp) to High(mFieldUp) do
    for Y := Low(mFieldUp) to High(mFieldUp) do
      if IsMine(X,Y) then
        mFieldUp[X,Y] := cOpen;
end;

procedure TCoreMineSwapper.OpenCell(X, Y: integer);
begin
  if mEndGame then exit;
  if IsFlag(X,Y) then exit;

 if (not mInitField) then
  begin
    GenerateMines(X,Y);
    mInitField:=true;
  end;

  if (not IsOpen(X, Y)) then
  begin
    if IsEmpty(X,Y) then
      OpenEmpty(x,Y)
    else if IsMine(X,Y) then
    begin
      mFieldUp[X,Y] := cOpen;
      Boom;
      Repaint;
      SetGameState(false); // BOOM !
      SetFlagsState(0);
      mEndGame := true;
      Repaint;
      Exit;
    end;

    mFieldUp[X,Y] := cOpen;
    Repaint;

    if FinishGame then
    begin
      SetGameState(true);
      SetFlagsState(0);
      mEndGame := true;
      Repaint;
      Exit;
    end;
  end;
end;

procedure TCoreMineSwapper.OpenEmpty(X,Y: integer);
var
  I,J: integer;
begin
// Добавить проверку на флаг
    if IsFlag(X,Y) then exit;

    if IsEmpty(X,Y) and (not IsOpen(X,Y)) then
    begin
      mFieldUp[X,Y] := cOpen;
      for I := -1 to 1 do
      for J := -1 to 1 do
        if IsRange(X+I,Y+J) then
            OpenEmpty(X+I,Y+J);
    end
      else
    if IsNumber(X,Y) then
      mFieldUp[X,Y] := cOpen;
end;

procedure TCoreMineSwapper.Repaint;
var
  X,Y: integer;
begin
  for X := Low(mFieldUp) to High(mFieldUp) do
    for Y := Low(mFieldUp) to High(mFieldUp) do
      if IsOpen(X,Y) then
        mSpriteList.Draw(mPCanvas^,
          X * mSpriteList.Height,
          Y * mSpriteList.Width,
          ord(mFieldDown[X,Y]))
      else
        mSpriteList.Draw(mPCanvas^,
          X*mSpriteList.Height,
          Y*mSpriteList.Width,
          ord(mFieldUp[X,Y]));
end;

procedure TCoreMineSwapper.ResizeField(NewHeight, NewWidth: Word);
begin
  mFieldHeight := NewHeight;
  mFieldWidth  := NewWidth;
  SetLength(mFieldUp, mFieldHeight, mFieldWidth);
  SetLength(mFieldDown, mFieldHeight, mFieldWidth);
end;

procedure TCoreMineSwapper.InitField;
var
  X,Y: integer;
begin
  // Close all cell
  for X := Low(mFieldUp) to High(mFieldUp) do
    for Y := Low(mFieldUp) to High(mFieldUp) do
      mFieldUp[X,Y] := cClose;

  // Sets empty cell on all field
  for X := Low(mFieldDown) to High(mFieldDown) do
    for Y := Low(mFieldDown) to High(mFieldDown) do
      mFieldDown[X,Y] := c0;

  mInitField:=false;
  mEndGame:=false;
end;

procedure TCoreMineSwapper.SetFlag(X, Y: integer);
begin
  if mEndGame then exit;
  
  if (not IsOpen(X,Y)) then
  begin
    if IsFlag(X,Y) then
      mFieldUp[X,Y] := cClose
    else
      mFieldUp[X,Y] := cFlag;
    Repaint;

    SetFlagsState(CountFlagMine);
  end;
end;

procedure TCoreMineSwapper.setSpriteHeight(const Value: integer);
begin
  mSpriteList.Height := Value;
end;

procedure TCoreMineSwapper.setSpriteWidth(const Value: integer);
begin
  mSpriteList.Width := Value;
end;

end.
