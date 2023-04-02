program tn;

uses
  Forms,
  nt2 in 'nt2.pas' {troley},
  atn in 'atn.pas' {ant},
  hlp in 'hlp.pas' {h},
  re in 're.pas' {r};

{$R *.RES}

begin
  Application.Initialize;
  Application.CreateForm(Ttroley, troley);
  Application.CreateForm(Tant, ant);
  Application.CreateForm(Th, h);
  Application.CreateForm(Tr, r);
  Application.Run;
end.
