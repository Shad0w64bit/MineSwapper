unit uCoreMineswapper;

interface

uses
  Vcl.Graphics, Vcl.Controls;

type
  TCellType = (cOpen=-1, cClose, cFlag, cMine, c0,c1,c2,c3,c4,c5,c6,c7,c8);
  PCanvas = ^TCanvas;


  TCoreMineSwapper = class
  private
    mPCanvas: PCanvas;

    // Field Params
    mInitField: boolean;
    mFieldHeight: Word;
    mFieldWidth:  Word;
    mFieldUp: array of array of TCellType; // [Открыто, закрыто, флажок]
    mFieldDown: array of array of TCellType; // генерируемое поле, цифры, мины

    procedure ResizeField(NewHeight, NewWidth: Word);
  public
    constructor Create;
    destructor Destroy; override;
  protected
    procedure GenerateField;

    property Canvas: PCanvas read mPCanvas write mPCanvas;
    property Height: Word read mFieldHeight;
    property Width: Word read mFieldWidth;
  end;


implementation

{ TCoreMineSwapper }

constructor TCoreMineSwapper.Create;
begin
  inherited Create(Self);
  mInitField:=false;
  ResizeField(16,16);
end;

destructor TCoreMineSwapper.Destroy;
begin
  ResizeField(0,0);
  inherited Destroy;
end;

procedure TCoreMineSwapper.GenerateField;
begin
//
end;

procedure TCoreMineSwapper.ResizeField(NewHeight, NewWidth: Word);
begin
  mFieldHeight := NewHeight;
  mFieldWidth  := NewWidth;
  SetLength(mFieldUp, mFieldHeight, mFieldWidth);
  SetLength(mFieldDown, mFieldHeight, mFieldWidth);
end;

end.
