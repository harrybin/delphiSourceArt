program DelphiSourceArt;

uses
  Vcl.Forms,
  MainForm in 'MainForm.pas' {FormMain};

{$R *.res}

begin
  Application.Initialize;
  Application.MainFormOnTaskbar := True;
  Application.Title := 'DelphiSourceArt - Code Visualisierung';
  Application.CreateForm(TFormMain, FormMain);
  Application.Run;
end.
