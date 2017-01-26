object fmCustomForm: TfmCustomForm
  Left = 0
  Top = 0
  BorderStyle = bsDialog
  Caption = #1054#1089#1086#1073#1099#1081' '#1074#1099#1073#1086#1088
  ClientHeight = 105
  ClientWidth = 225
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poMainFormCenter
  PixelsPerInch = 96
  TextHeight = 13
  object Label1: TLabel
    Left = 11
    Top = 19
    Width = 55
    Height = 13
    Caption = #1063#1080#1089#1083#1086' '#1084#1080#1085':'
  end
  object Label2: TLabel
    Left = 11
    Top = 46
    Width = 41
    Height = 13
    Caption = #1042#1099#1089#1086#1090#1072':'
  end
  object Label3: TLabel
    Left = 11
    Top = 73
    Width = 44
    Height = 13
    Caption = #1064#1080#1088#1080#1085#1072':'
  end
  object edMines: TEdit
    Left = 72
    Top = 16
    Width = 33
    Height = 21
    TabOrder = 0
    Text = '40'
  end
  object edHeight: TEdit
    Left = 72
    Top = 43
    Width = 33
    Height = 21
    TabOrder = 1
    Text = '16'
  end
  object edWidth: TEdit
    Left = 72
    Top = 70
    Width = 33
    Height = 21
    TabOrder = 2
    Text = '16'
  end
  object btnOk: TButton
    Left = 136
    Top = 14
    Width = 75
    Height = 25
    Caption = 'OK'
    Default = True
    ModalResult = 1
    TabOrder = 3
  end
  object btnCancel: TButton
    Left = 136
    Top = 45
    Width = 75
    Height = 25
    Caption = #1054#1090#1084#1077#1085#1072
    ModalResult = 2
    TabOrder = 4
  end
end
