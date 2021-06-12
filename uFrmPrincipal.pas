unit uFrmPrincipal;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ComCtrls, StdCtrls, IniFiles, Vcl.ExtCtrls;

type
  TFrmAtualizacaoLocal = class(TForm)
    LbVerificandoAtualizacoes: TLabel;
    Timer1: TTimer;
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure FormCreate(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
  private
    { Private declarations }
  public
    HoraFechar : boolean;

    function Executa (Arquivo : String; Estado : Integer) : Integer;
  end;

var
  FrmAtualizacaoLocal: TFrmAtualizacaoLocal;

implementation

{$R *.dfm}

function TFrmAtualizacaoLocal.Executa(Arquivo: String;
  Estado: Integer): Integer;
var
  Programa    : array [0..512] of char;
  CurDir      : array [0..255] of char;
  WorkDir     : String;
  StartupInfo : TStartupInfo;
  ProcessInfo : TProcessInformation;
  teste       : Cardinal;
begin
  StrPCopy (Programa, Arquivo);
  GetDir (0, WorkDir);
  StrPCopy (CurDir, WorkDir);
  FillChar (StartupInfo, Sizeof (StartupInfo), #0);
  StartupInfo.cb := sizeof (StartupInfo);
  StartupInfo.dwFlags := STARTF_USESHOWWINDOW;
  StartupInfo.wShowWindow := Estado;
  if not CreateProcess (nil, Programa, nil, nil, false, CREATE_NEW_CONSOLE or NORMAL_PRIORITY_CLASS, nil, nil, StartupInfo, ProcessInfo) then
    Result := -1
  else
    begin
      WaitForSingleObject (ProcessInfo.hProcess, Infinite);
      GetExitCodeProcess (ProcessInfo.hProcess, teste);
    end;
end;

procedure TFrmAtualizacaoLocal.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  CanClose := HoraFechar;
end;

procedure TFrmAtualizacaoLocal.FormCreate(Sender: TObject);
begin
  HoraFechar := false;
end;

procedure TFrmAtualizacaoLocal.Timer1Timer(Sender: TObject);
var
   IniFile        : TIniFile;
   Server, Client : string;
   nomeAplicacao  : string;
   arquivoOrigem  : integer;
   arquivoDestino : integer;
begin
  try
    nomeAplicacao := ParamStr(1);
    nomeAplicacao := 'Administrativo.exe';

    //mudando o caption do label
    LbVerificandoAtualizacoes.Caption := 'Verificando Atualizações...';

    //necessario para o usuário visualizar a copia do arqivo
    Application.ProcessMessages;

    //abrindo o arquivo ini para o carregamento das variáveis
    IniFile := TIniFile.Create( GetCurrentDir + '\' + 'Atualizacao.ini');

    //pegando a origem do arquivo
    Server  := IniFile.ReadString( 'ATUALIZACAO', 'SERVER', '' );
    //pegando o destino do arquivo
    Client  := IniFile.ReadString( 'ATUALIZACAO', 'CLIENT', '' );

    if ( Server = '' ) or ( Client = '' ) then
      begin
        //se a chave não estiver definida, mostra a mensagem e finaliza o sistema
        MessageDlg( 'A chave para a atualização não foi definida', mtError, [ mbOK ] , 0 );

        HoraFechar := true;
        Close;
      end
    else
      begin
        try
          server := server + nomeAplicacao;
          client := client + nomeAplicacao;
          //se o arquivo cliente não existir o sistema ira copiar sem verificar
          //qual é o mais atual, senão, ira verificar qual e o arquivo mais atual
          //e copiar se o arquivo do servidor for mais atual do arquivo cliente
          if not FileExists( Client ) then
            CopyFile( PChar( Server ), PChar( Client ), false )
          else
            arquivoOrigem := FileAge( Server );
            arquivoDestino := FileAge( Client );

            if FileDateToDateTime(arquivoOrigem) <>
                 FileDateToDateTime(arquivoDestino) then
              begin
                RenameFile( Client, ExtractFilePath( Application.ExeName ) + '\' +
                  FormatDateTime( 'dd-mm-yyyy-HH-MM-SS' , now ) + nomeAplicacao );

                CopyFile( PChar( Server ), PChar( Client ), false );
              end;

          WinExec( PAnsiChar(Client), SW_SHOW );

          HoraFechar := true;
          Close;
        except
          Application.Terminate;
        end;
      end;

    IniFile.Free;
  finally
    Application.Terminate;
  end;
end;

end.
