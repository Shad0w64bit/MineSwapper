unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ExtCtrls, WinApi.CommCtrl, System.Types, ucoremineswapper;

type
  TfmMain = class(TForm)
    SpriteList: TImageList;
    MineField: TPaintBox;
    procedure FormCreate(Sender: TObject);
    procedure MineFieldPaint(Sender: TObject);
    procedure MineFieldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
  private
    { Private declarations }
  public
    { Public declarations }
    CoreMineSwapper: TCoreMineSwapper;
  end;

var
  fmMain: TfmMain;

implementation

{$R *.dfm}

procedure getGameState(const Win: boolean);
begin
  if Win then
    ShowMessage('Win')
  else
    ShowMessage('Boom')
end;

procedure getFlagsState(const Flags: integer);
begin
  fmMain.Caption:=inttostr(Flags)+' / '+ inttostr(fmMain.CoreMineSwapper.MineCount);
end;

procedure TfmMain.FormCreate(Sender: TObject);
const
  IndentField = 20;
begin
  Randomize;

  CoreMineSwapper := TCoreMineSwapper.Create(Self);
  CoreMineSwapper.Canvas := @MineField.Canvas;
  CoreMineSwapper.LoadSprite(SpriteList.Height, SpriteList.Width, SpriteList);

  CoreMineSwapper.GameState := @getGameState;
  CoreMineSwapper.FlagsState := @getFlagsState;

  CoreMineSwapper.MineCount := 40;
  CoreMineSwapper.ResizeField(16,16);
  CoreMineSwapper.InitField;


  MineField.Top  := IndentField;
  MineField.Left := IndentField;
  MineField.Height := CoreMineSwapper.FieldHeightPixel;
  MineField.Width  := CoreMineSwapper.FieldWidthPixel;

  ClientHeight := MineField.Height + IndentField * 2;
  ClientWidth  := MineField.Width  + IndentField * 2;
end;

procedure TfmMain.MineFieldMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
  fX, fY: integer;
begin
  if CoreMineSwapper.EndGame then
  begin
    CoreMineSwapper.InitField;  // Заполняем поле пустыми значениями
    CoreMineSwapper.Repaint;    // Отрисовывем
    exit;                       // И ждем первого нажатия
  end;

  fX := X div CoreMineSwapper.SpriteWidth;
  fY := Y div CoreMineSwapper.SpriteHeight;

  if (Button = mbLeft) then CoreMineSwapper.OpenCell(fX, fY);
  if (Button = mbRight) then CoreMineSwapper.SetFlag(fX, fY);
end;

procedure TfmMain.MineFieldPaint(Sender: TObject);
begin
  CoreMineSwapper.Repaint;
end;

end.
