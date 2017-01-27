unit uMain;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.ImgList, Vcl.ExtCtrls, WinApi.CommCtrl, System.Types, ucoremineswapper,
  Vcl.Menus;

type
  TfmMain = class(TForm)
    SpriteList: TImageList;
    MineField: TPaintBox;
    MainMenu1: TMainMenu;
    N1: TMenuItem;
    iNewGame: TMenuItem;
    N3: TMenuItem;
    iBeginner: TMenuItem;
    iFun: TMenuItem;
    iProfessional: TMenuItem;
    iCustom: TMenuItem;
    N8: TMenuItem;
    iExit: TMenuItem;
    procedure FormCreate(Sender: TObject);
    procedure MineFieldPaint(Sender: TObject);
    procedure MineFieldMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure iExitClick(Sender: TObject);
    procedure iNewGameClick(Sender: TObject);
    procedure iBeginnerClick(Sender: TObject);
    procedure iFunClick(Sender: TObject);
    procedure iProfessionalClick(Sender: TObject);
    procedure iCustomClick(Sender: TObject);
  private
    { Private declarations }
    mFieldHeight: integer;
    mFieldWidth: integer;
    mFieldMines: integer;
  public
    { Public declarations }
    CoreMineSwapper: TCoreMineSwapper;
  end;

var
  fmMain: TfmMain;

const
  IndentField = 20;

implementation

{$R *.dfm}

uses uCustomForm;

procedure getGameState(const Win: boolean);
begin
  if Win then
    MessageBox(0,PWideChar('Вы выиграли !!!'), PWideChar('Ура!'), MB_ICONINFORMATION)
  else
    MessageBox(0,PWideChar('Вы проиграли.'), PWideChar('Бум!'), MB_ICONERROR);
end;

procedure getFlagsState(const Flags: integer);
begin
  fmMain.Caption:=inttostr(Flags)+' / '+ inttostr(fmMain.CoreMineSwapper.MineCount);
end;

procedure TfmMain.FormCreate(Sender: TObject);
begin
  Randomize;

  CoreMineSwapper := TCoreMineSwapper.Create(Self);
  CoreMineSwapper.Canvas := @MineField.Canvas;
  CoreMineSwapper.LoadSprite(SpriteList.Height, SpriteList.Width, SpriteList);

  CoreMineSwapper.GameState := @getGameState;
  CoreMineSwapper.FlagsState := @getFlagsState;

  mFieldHeight := 16;
  mFieldWidth := 16;
  mFieldMines := 40;

  CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);

  MineField.Top  := IndentField;
  MineField.Left := IndentField;
  MineField.Height := CoreMineSwapper.FieldHeightPixel;
  MineField.Width  := CoreMineSwapper.FieldWidthPixel;

  ClientHeight := MineField.Height + IndentField * 2;
  ClientWidth  := MineField.Width  + IndentField * 2;
end;

procedure TfmMain.iBeginnerClick(Sender: TObject);
begin
  if not CoreMineSwapper.EndGame then
    if MessageDlg('Текущая игра будет прервана. Продолжить?',mtConfirmation, [mbYes, mbNo],0) = mrNo then exit;

  mFieldHeight := 9;
  mFieldWidth := 9;
  mFieldMines := 10;
  CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);

  MineField.Height := CoreMineSwapper.FieldHeightPixel;
  MineField.Width  := CoreMineSwapper.FieldWidthPixel;

  ClientHeight := MineField.Height + IndentField * 2;
  ClientWidth  := MineField.Width  + IndentField * 2;

  CoreMineSwapper.Repaint;
end;

procedure TfmMain.iCustomClick(Sender: TObject);
var
  frm: TfmCustomForm;
begin
  frm := TfmCustomForm.Create(self);

  frm.edHeight.Text := inttostr( CoreMineSwapper.Height );
  frm.edWidth.Text := inttostr( CoreMineSwapper.Width );
  frm.edMines.Text := inttostr( CoreMineSwapper.MineCount );

  if frm.ShowModal = mrOk then begin
    mFieldHeight := strtoint(frm.edHeight.Text);
    mFieldWidth := strtoint(frm.edWidth.Text);
    mFieldMines := strtoint(frm.edMines.Text);

    if mFieldWidth < 3 then mFieldWidth := 3;
    if mFieldHeight < 3 then mFieldHeight := 3;
    

    CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);

    MineField.Height := CoreMineSwapper.FieldHeightPixel;
    MineField.Width  := CoreMineSwapper.FieldWidthPixel;

    ClientHeight := MineField.Height + IndentField * 2;
    ClientWidth  := MineField.Width  + IndentField * 2;

    CoreMineSwapper.Repaint;
  end;

  frm.Free;
end;

procedure TfmMain.iExitClick(Sender: TObject);
begin
  close;
end;

procedure TfmMain.iFunClick(Sender: TObject);
begin
  if not CoreMineSwapper.EndGame then
    if MessageDlg('Текущая игра будет прервана. Продолжить?',mtConfirmation, [mbYes, mbNo],0) = mrNo then exit;

  mFieldHeight := 16;
  mFieldWidth := 16;
  mFieldMines := 40;
  CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);

  MineField.Height := CoreMineSwapper.FieldHeightPixel;
  MineField.Width  := CoreMineSwapper.FieldWidthPixel;

  ClientHeight := MineField.Height + IndentField * 2;
  ClientWidth  := MineField.Width  + IndentField * 2;
end;

procedure TfmMain.iNewGameClick(Sender: TObject);
begin
  if not CoreMineSwapper.EndGame then
    if MessageDlg('Текущая игра будет прервана. Продолжить?',mtConfirmation, [mbYes, mbNo],0) = mrNo then exit;

  CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);
end;

procedure TfmMain.iProfessionalClick(Sender: TObject);
begin
  if not CoreMineSwapper.EndGame then
    if MessageDlg('Текущая игра будет прервана. Продолжить?',mtConfirmation, [mbYes, mbNo],0) = mrNo then exit;

  mFieldHeight := 16;
  mFieldWidth := 30;
  mFieldMines := 99;
  CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);

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
    CoreMineSwapper.NewGame(mFieldMines, mFieldHeight, mFieldWidth);
    exit;
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
