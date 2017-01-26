unit uCustomForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, System.Classes, Vcl.Graphics,
  Vcl.Controls, Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls;

type
  TfmCustomForm = class(TForm)
    edMines: TEdit;
    edHeight: TEdit;
    edWidth: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    btnOk: TButton;
    btnCancel: TButton;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

var
  fmCustomForm: TfmCustomForm;

implementation

{$R *.dfm}

end.
