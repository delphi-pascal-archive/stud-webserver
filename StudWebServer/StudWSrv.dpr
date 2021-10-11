program StudWSrv;

uses
  Forms,
  uMain in 'uMain.pas' {fmMain};

{$R *.RES}

begin
  Application.Title:='StudWebServer v1.0 - by V.Kadyshev & StudForum.ru';
  Application.Initialize;
  Application.CreateForm(TfmMain, fmMain);
  Application.Run;
end.
