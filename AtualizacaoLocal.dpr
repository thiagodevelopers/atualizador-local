program AtualizacaoLocal;

uses
  Forms,
  uFrmPrincipal in 'uFrmPrincipal.pas' {FrmAtualizacaoLocal};

{$R *.res}

begin
  Application.Initialize;
  //Application.MainFormOnTaskbar := True;
  Application.Title := 'Atualiza��o dos Sistemas';
  Application.CreateForm(TFrmAtualizacaoLocal, FrmAtualizacaoLocal);
  Application.Run;
end.
