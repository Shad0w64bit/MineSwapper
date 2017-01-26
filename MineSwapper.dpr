program MineSwapper;

uses
  Vcl.Forms,
  uMain in 'uMain.pas' {fmMain},
  uCoreMineswapper in 'uCoreMineswapper.pas',
  uCustomForm in 'uCustomForm.pas' {fmCustomForm};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
