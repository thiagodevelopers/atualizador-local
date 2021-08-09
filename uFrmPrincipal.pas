unit uFrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, IniFiles, Vcl.ExtCtrls, shellapi;

type
  TFrmAtualizacaoLocal = class(TForm)
    LbVerificandoAtualizacoes: TLabel;
    TmAtualizacao: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure TmAtualizacaoTimer(Sender: TObject);
  private
    { Private declarations }
  public
    nomeAplicacao : string;
    HoraFechar    : boolean;
    local, remoto : string;

    function verificaConfig : boolean;
    function verificaAtualizacao : boolean;
  end;

var
  FrmAtualizacaoLocal: TFrmAtualizacaoLocal;

implementation

{$R *.dfm}

procedure TFrmAtualizacaoLocal.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := HoraFechar;
end;

procedure TFrmAtualizacaoLocal.FormCreate(Sender: TObject);
begin
  HoraFechar := false;
end;

procedure TFrmAtualizacaoLocal.TmAtualizacaoTimer(Sender: TObject);
begin
  nomeAplicacao := ParamStr(1);

  //mudando o caption do label
  LbVerificandoAtualizacoes.Caption := 'Verificando Atualizações...';

  if not verificaConfig then
    begin
      MessageDlg( 'A chave para a atualização não foi definida',
        mtError, [ mbOK ] , 0 );
      TmAtualizacao.Enabled := false;

      Application.Terminate;
    end;

  if verificaAtualizacao then
    begin
      try
        RenameFile( local, ExtractFilePath( Application.ExeName ) + '\' +
          FormatDateTime( 'dd-mm-yyyy-HH-MM-SS' , now ) + '-' + nomeAplicacao );

        CopyFile( PChar( remoto ), PChar( local ), false );
      finally
        ShellExecute(Handle, 'open', PChar(local), nil, nil, SW_SHOW);
        TmAtualizacao.Enabled := false;

        Application.Terminate;
      end;
    end
  else
    begin
      ShellExecute(Handle, 'open', PChar(local), nil, nil, SW_SHOW);
      TmAtualizacao.Enabled := false;

      Application.Terminate;
    end;
end;

function TFrmAtualizacaoLocal.verificaAtualizacao: boolean;
var
   arquivoOrigem  : integer;
   arquivoDestino : integer;
begin
  result := false;

  remoto := remoto + nomeAplicacao;
  local := local + nomeAplicacao;

  if not FileExists( local ) then
    begin
      MessageDlg( 'O arquivo local não esta configurado de maneira incorreta. ' +
        #13 + 'Não existe o arquivo: ' + nomeAplicacao, mtError, [mbOK], 0 );
      TmAtualizacao.Enabled := false;

      Application.Terminate;
    end;

  try
    arquivoOrigem := FileAge( remoto );
    arquivoDestino := FileAge( local );

    if FileDateToDateTime(arquivoOrigem) <>
         FileDateToDateTime(arquivoDestino) then
      result := true;
  except
    TmAtualizacao.Enabled := false;
    result := false;
  end;
end;

function TFrmAtualizacaoLocal.verificaConfig: boolean;
var
   IniFile : TIniFile;
begin
  result := true;

  //abrindo o arquivo ini para o carregamento das variáveis
  IniFile := TIniFile.Create( GetCurrentDir + '\' + 'Atualizacao.ini');

  //pegando a origem do arquivo
  remoto  := IniFile.ReadString( 'ATUALIZACAO', 'SERVER', '' );
  //pegando o destino do arquivo
  local  := IniFile.ReadString( 'ATUALIZACAO', 'CLIENT', '' );

  if ( remoto = '' ) or ( local = '' ) then
    result := false;

  IniFile.Free;
end;

end.
