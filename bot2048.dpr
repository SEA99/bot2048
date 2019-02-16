program bot2048;

uses
  Forms,
  fmmain in 'fmmain.pas' {Form1},
  g2048types in 'g2048types.pas',
  strat in 'strat.pas',
  cache in 'cache.pas',
  linktoblue2048 in 'linktoblue2048.pas',
  extlink in 'extlink.pas',
  botcommon in 'botcommon.pas',
  linkofficial in 'linkofficial.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TForm1, Form1);
  Application.Run;
end.
