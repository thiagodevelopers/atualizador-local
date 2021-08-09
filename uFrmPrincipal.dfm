object FrmAtualizacaoLocal: TFrmAtualizacaoLocal
  Left = 447
  Top = 269
  BorderIcons = []
  BorderStyle = bsDialog
  ClientHeight = 27
  ClientWidth = 162
  Color = clBtnFace
  Font.Charset = DEFAULT_CHARSET
  Font.Color = clWindowText
  Font.Height = -11
  Font.Name = 'Tahoma'
  Font.Style = []
  OldCreateOrder = False
  Position = poDesktopCenter
  OnCloseQuery = FormCloseQuery
  OnCreate = FormCreate
  PixelsPerInch = 96
  TextHeight = 13
  object LbVerificandoAtualizacoes: TLabel
    Left = 8
    Top = 8
    Width = 128
    Height = 13
    Caption = 'Verificando Atualiza'#231#245'es...'
  end
  object TmAtualizacao: TTimer
    Interval = 5000
    OnTimer = TmAtualizacaoTimer
    Left = 56
  end
end
