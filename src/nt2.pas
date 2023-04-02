unit nt2;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Menus,functions;
const
 {Константи напрямку}
  toleft=1;
  right=2;
  down=3;
  up=4;

 {Константи кольору}
 c1=$00FFFF;
 c2=$FF0000;
 p1=$00FF00;
 p2=$FF00FF;

type
 {Спосіб гри}
 TMode=(L_L,L_C,C_L);
 {Масив клітинок, куди може пересунутися фішка}
  a1=array[1..2,1..4]of boolean;
 {Головне вікно}
  Ttroley = class(TForm)
    mm: TMainMenu;
    bng: TMenuItem;
    gm: TMenuItem;
    go: TMenuItem;
    help: TMenuItem;
    hp: TMenuItem;
    N6: TMenuItem;
    ab: TMenuItem;
    N8: TMenuItem;
    undo: TMenuItem;
    redo: TMenuItem;
    op: TMenuItem;
    N9: TMenuItem;
    cgm: TMenuItem;
    ll: TMenuItem;
    cl: TMenuItem;
    lc: TMenuItem;
    N15: TMenuItem;
    undoall: TMenuItem;
    redoall: TMenuItem;
    sh: TMenuItem;
    procedure FormShow(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ShowChessBoard;
    procedure newgame;
    procedure ShowCur;
    function zelen:boolean;
    function cherv:boolean;
    function CanMove(i,j:integer;var p:a1):boolean;
    //Записує у змінну p всі можливості для пересування
    //фішки у клітинці з координатами i,j
    //Якщо хоч одна можливість є, то повертає значення true;
    //інакше повертає значення false
    function MayMove(i,j:integer;p:a1):boolean;
    //Перевіряє, чи належить клітинка з координатами i,j
    //масиву p можливостям для пересування фішки
    function MayCompMove(di,dj:integer;p:a1):boolean;
    function sumcolor(c,k:tcolor):tcolor;
    function incolor(c:tcolor):tcolor;
    procedure ShowLastCur(Last:tpoint);
    procedure FormPaint(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure FormMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure FormMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure goClick(Sender: TObject);
    procedure bngClick(Sender: TObject);
    procedure abClick(Sender: TObject);
    procedure hpClick(Sender: TObject);
    procedure newmovetofile(i,j,k,l:integer;b:boolean);
    procedure disableredo;
    procedure undoClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure redoClick(Sender: TObject);
    procedure undoallClick(Sender: TObject);
    procedure redoallClick(Sender: TObject);
    procedure clClick(Sender: TObject);
    procedure lcClick(Sender: TObject);
    procedure llClick(Sender: TObject);
    procedure shClick(Sender: TObject);
    procedure CompMove;
  private
    { Private declarations }
  public
    { Public declarations }
  end;

function equivalention(a,b:boolean):boolean;
var
  troley: Ttroley;
 {Головне вікно}
  a:array[1..8,1..8]of 0..2;
  {шахова дошка 1..8 - горизонтально
  1..8 - вертикально
  0 - відсутність фішки
  1 - присутність рожевої фішки
  2 - присутність зеленої фішки
   }
//  c1,c2,p1,p2:tcolor;
  d:integer;
  hz{чи хід зелених}
  ,lm,ft:boolean;
  clm:tpoint;
  cur:tpoint;
  CompMay,
  may:a1;//всі можливості для пересування фішки,
  //що може бути пересунута
  px,py:integer; {координати клітинки, де розміщена фішка,
  що може бути пересунута}
  f,g:textfile;
  mode:TMode;
const
 kolo=1;
implementation

uses atn, hlp;

{$R *.DFM}

function Ttroley.sumcolor(c,k:tcolor):tcolor;
var
 r,g,b:byte;
begin
 if c mod 256+k mod 256>256 then
  b:=abs(c mod 256-k mod 256)
 else
  b:=c mod 256+k mod 256;
 if c div 256 mod 256+k div 256 mod 256>256 then
  r:=abs(c div 256 mod 256-k div 256 mod 256)
 else
  r:=c div 256 mod 256+k div 256 mod 256;
 if c div 256 * 256+k div 256 * 256>256 then
  g:=abs(c div 256 * 256-k div 256 * 256)
 else
  g:=(c div (256 * 256))+k div 256 * 256;
 g:=g mod 256;
 sumcolor:=g*256*256+r*256+b;
end;

function Ttroley.incolor(c:tcolor):tcolor;
var
 r,g,b:byte;
begin
 b:=256-c mod 256;
 r:=256-c div 256 mod 256;
 g:=256-(c div (256 * 256)) mod 256;
 incolor:=g*256*256+r*256+b;
end;

procedure Ttroley.FormShow(Sender: TObject);
begin
 ft:=false;
 ShowChessBoard;
end;

procedure Ttroley.newgame;
var
 i,j:1..8;
begin
 rewrite(f);
 rewrite(g);
 closefile(f);
 closefile(g);
 redo.enabled:=false;
 undo.Enabled:=false;
 redoall.enabled:=false;
 undoall.Enabled:=false;
 for i:=1 to 8 do
  for j:=1 to 8 do
   a[i,j]:=0;
 for i:=5 to 8 do
  for j:=1 to 4 do
   a[i,j]:=1;
 for i:=5 to 8 do
  for j:=5 to 8 do
   a[i,j]:=2;
 hz:=true;
 if mode=C_L then
  compMove;
end;

procedure Ttroley.ShowChessBoard;
var
 i,j:1..8;
// k,l,m,n:integer;
begin
 for i:=1 to 8 do
  for j:=1 to 8 do
   if odd(i+j) then
    begin
     canvas.Brush.Color:=c1;
     canvas.Rectangle((i-1)*d,(j-1)*d,i*d,j*d);
    end
   else
    begin
     canvas.Brush.Color:=c2;
     canvas.Rectangle((i-1)*d,(j-1)*d,i*d,j*d);
    end;
 for i:=1 to 8 do
  for j:=1 to 8 do
   if a[i,j]=1 then
    begin
     canvas.Brush.Color:=p2;
     canvas.Ellipse((i-1)*d,(j-1)*d,i*d,j*d);
    end
   else
   if a[i,j]=2 then
    begin
     canvas.Brush.Color:=p1;
     canvas.Ellipse((i-1)*d,(j-1)*d,i*d,j*d);
    end;
   showcur;
{   k:=cur.x div d;
   l:=cur.y div d;
   m:=k+1;
   n:=l+1;
   canvas.Brush.Color:=$C0C0C0;
   canvas.Ellipse(d*k,d*l,d*m,d*n);}
// canvas.Brush.Style:=bsclear;
end;

procedure Ttroley.ShowCur;
var
 k,l,m,n:integer;
begin
   k:=cur.x div d;
   l:=cur.y div d;
   m:=k+1;
   n:=l+1;
   if a[m,n]=2 then
{     if p1>$C0C0C0 then
     canvas.Brush.Color:=p1-$C0C0C0
     else}
     canvas.Brush.Color:=sumcolor(p1,$C0C0C0
     )
   else
    if a[m,n]=1 then
{     if p2>$C0C0C0 then
     canvas.Brush.Color:=p2-$C0C0C0
     else}
     canvas.Brush.Color:=sumcolor(p2,$C0C0C0
     )
   else
   if odd(k+l) then
 {    if c1>$C0C0C0 then
     canvas.Brush.Color:=c1-$C0C0C0
     else}
     canvas.Brush.Color:=sumcolor(c1,$C0C0C0
     )
   else
{     if c2>$C0C0C0 then
    canvas.Brush.Color:=c2-$C0C0C0
     else}
    canvas.Brush.Color:=sumcolor(c2,$C0C0C0
    );
//   canvas.Brush.Color:=$C0C0C0;
   canvas.Ellipse(d*k,d*l,d*m,d*n);
end;

procedure Ttroley.ShowLastCur(Last:tpoint);
var
 k,l,m,n:integer;
begin
   k:=last.x div d;
   l:=last.y div d;
   m:=k+1;
   n:=l+1;
   if a[m,n]=2 then
    begin
     canvas.Brush.Color:=p1;
     canvas.Ellipse(d*k,d*l,d*m,d*n);
    end
   else
    if a[m,n]=1 then
    begin
     canvas.Brush.Color:=p2;
     canvas.Ellipse(d*k,d*l,d*m,d*n);
    end
   else
   if odd(k+l) then
    begin
     canvas.Brush.Color:=c1;
     canvas.Rectangle(d*k,d*l,d*m,d*n);
    end
   else
    begin
     canvas.Brush.Color:=c2;
     canvas.Rectangle(d*k,d*l,d*m,d*n);
    end;
end;

procedure Ttroley.FormCreate(Sender: TObject);
begin
 assignfile(f,'tn.tn');
 assignfile(g,'nt.tn');
 newgame;
 cur.x:=0;
 cur.y:=0;
 d:=50;
 screen.Cursors[kolo]:=loadCursor(hinstance,'n');
 cursor:=kolo;
 hz:=true;
 lm:=false;
 mode:=L_L;
// showcursor(false);
// canvas.pen.Color:=$C0C0C0;
end;

procedure Ttroley.FormPaint(Sender: TObject);
begin
// if not ft then
 ShowChessBoard;
// ft:=true;
end;

procedure Ttroley.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
var
 o:a1;
 i,j:integer;
 p:tpoint;
begin
 case key of
  39:{right}
   begin
    showlastcur(cur);
    if cur.x<7*d then
     cur.x:=cur.x+d
    else
     cur.x:=0;
    showcur;
   end;
  37:{toleft}
   begin
    showlastcur(cur);
    if cur.x>0 then
     cur.x:=cur.x-d
    else
     cur.x:=cur.x+7*d;
    showcur;
   end;
  38://up
   begin
    showlastcur(cur);
    if cur.y>0 then
     cur.y:=cur.y-d
    else
     cur.y:=cur.y+7*d;
    showcur;
   end;
  40://down
   begin
    showlastcur(cur);
    if cur.y<7*d then
     cur.y:=cur.y+d
    else
     cur.y:=0;
    showcur;
   end;
  13://take
  with cur do
   begin
    i:=(x div d)+1;
    j:=(y div d)+1;
    if a[i,j]>0 then
     if CanMove(i,j,o) then
      begin
       may:=o;
       px:=i;
       py:=j;
      end
   end;
  32://put
  with cur do
   begin
    i:=(x div d)+1;
    j:=(y div d)+1;
    showlastcur(cur);
 if maymove(i,j,may) and((((a[px,py]=2)=hz) or ((a[px,py]=1)=not hz)) or
 (lm and (px=clm.x) and (py=clm.y) and ((abs(py-j)=2)or (abs(px-i)=2))))
then
  begin
   a[i,j]:=a[px,py];
   a[px,py]:=0;
   p.x:=d*(i-1);
   p.y:=d*(j-1);
   newmovetofile(i,j,px,py,hz);
   disableredo;
   showlastcur(p);
   p.x:=d*(px-1);
   p.y:=d*(py-1);
   showlastcur(p);
   if not (lm and (px=clm.x) and (py=clm.y) and ((abs(py-j)=2)or (abs(px-i)=2))) then
   begin
   hz:=not hz;
  if mode<>l_l then
   compMove;
   end;
 if ((abs(py-j)=2)or (abs(px-i)=2)) then
  begin
   lm:=true;
   clm.x:=i;
   clm.y:=j;
  end
  else
 if lm then
  lm:=false;
 end;
 if zelen then
  messagebox(0,'Зелені виграли!','',64);
 if cherv then
  messagebox(0,'Рожеві виграли!','',64);
 if zelen or cherv then
  begin
   newgame;
   ShowChessBoard;
  end;
    showcur;
   ShowChessBoard;
    end
 end;
end;

procedure Ttroley.FormMouseMove(Sender: TObject; Shift: TShiftState; X,
  Y: Integer);
{var
 k,l,m,n:integer;
}begin
 if (abs(cur.x-x)/d>0)or(abs(cur.y-y)/d>0)then
  begin
   showlastcur(cur);
   cur.x:=d*(x div d);
   cur.y:=d*(y div d);
{   k:=cur.x div d;
   l:=cur.y div d;
}   showcur;
{   m:=k+1;
   n:=l+1;
   canvas.Brush.Color:=$C0C0C0;
   canvas.Ellipse(d*k,d*l,d*m,d*n);
 } end;
end;

procedure Ttroley.FormMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 i,j
// ,k,l,m,n
 :integer;
 o:a1;
// p:tpoint;
begin
 i:=(x div d)+1;
 j:=(y div d)+1;
 if a[i,j]>0 then
  if CanMove(i,j,o) then
   begin
{   showlastcur(cur);
   cur.x:=d*(x div d);
   cur.y:=d*(y div d);
   k:=cur.x div d;
   l:=cur.y div d;
   m:=k+1;
   n:=l+1;
   canvas.Brush.Color:=$C0C0C0;
   canvas.Ellipse(d*k,d*l,d*m,d*n);}
    may:=o;
    px:=i;
    py:=j;
   end;
end;

function Ttroley.CanMove;
var
 k,l:integer;
begin
 canmove:=false;
 for k:=1 to 2 do
  for l:=toleft to up do
   p[k,l]:=false;

 if i>0 then   //Якщо не лівий край
  if a[i-1,j]=0 then //якщо зліва вільно
   p[1,toleft]:=true;
 if i<8 then   //Якщо не правий край
  if a[i+1,j]=0 then //якщо справа вільно
   p[1,right]:=true;
 if j>0 then   //Якщо не верх
  if a[i,j-1]=0 then //якщо зверху вільно
   p[1,down]:=true;
 if j<8 then   //Якщо не низ
  if a[i,j+1]=0 then //якщо знизу вільно
   p[1,up]:=true;

 if i>1 then   //Якщо зліва не лівий край
  if (a[i-2,j]=0)and(a[i-1,j]>0) then
  //Якщо зліва зайнято і двічі зліва вільно
   p[2,toleft]:=true;
 if i<7 then   //Якщо справа не правий край
  if (a[i+2,j]=0)and(a[i+1,j]>0) then
  //Якщо справа зайнято і двічі справа вільно
   p[2,right]:=true;
 if j>1 then   //Якщо зверху не верх
  if (a[i,j-2]=0)and(a[i,j-1]>0) then
  //Якщо зверху зайнято і двічі зверху вільно
   p[2,down]:=true;
 if j<7 then   //Якщо знизу не низ
  if (a[i,j+2]=0)and(a[i,j+1]>0) then
  //Якщо знизу зайнято і двічі знизу вільно
   p[2,up]:=true;

 for k:=1 to 2 do
  for l:=toleft to up do
   if p[k,l] then
    canmove:=true;
end;

procedure Ttroley.newmovetofile;
begin
 append(f);
 if b then
 writeln(f,i,' ',j,' ',k,' ',l,' 1')
 else
 writeln(f,i,' ',j,' ',k,' ',l,' 0');
 closefile(F);
 undo.Enabled:=true;
 undoall.Enabled:=true;
end;

procedure Ttroley.disableredo;
begin
 rewrite(g);
 closefile(g);
 redo.enabled:=false;
 redoall.enabled:=false;
end;

procedure Ttroley.FormMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var
 i,j
// ,k,l,m,n
 :integer;
// i,j,k,l,m,n:integer;
// o:a1;
 p:tpoint;
begin
 i:=(x div d+1);
 j:=(y div d+1);
 if maymove(i,j,may) and
((((a[px,py]=2)=hz) or
 ((a[px,py]=1)=not hz))
 or (lm and (px=clm.x) and (py=clm.y) and ((abs(py-j)=2)or (abs(px-i)=2))))
then
  begin
   a[i,j]:=a[px,py];
   a[px,py]:=0;
   p.x:=d*(i-1);
   p.y:=d*(j-1);
   newmovetofile(i,j,px,py,hz);
   disableredo;
   showlastcur(p);
   p.x:=d*(px-1);
   p.y:=d*(py-1);
   showlastcur(p);
   if not (lm and (px=clm.x) and (py=clm.y) and ((abs(py-j)=2)or (abs(px-i)=2))) then
   if not (lm and (px=clm.x) and (py=clm.y) and ((abs(py-j)=2)or (abs(px-i)=2))) then
   begin
   hz:=not hz;
  if mode<>l_l then
   compMove;
   end;
 if ((abs(py-j)=2)or (abs(px-i)=2)) then
  begin
   lm:=true;
   clm.x:=i;
   clm.y:=j;
  end
  else
 if lm then
  lm:=false;
 end;
 if zelen then
  messagebox(0,'Зелені виграли!','',64);
 if cherv then
  messagebox(0,'Рожеві виграли!','',64);
 if zelen or cherv then
  begin
   newgame;
   ShowChessBoard;
  end;
    showcur;
   ShowChessBoard;
end;

function Ttroley.zelen;
var
 i,j:integer;
begin
 zelen:=true;
 for i:=5 to 8 do
  for j:=1 to 4 do
   if not (a[i,j]=2) then
    zelen:=false;
end;

function Ttroley.cherv;
var
 i,j:integer;
begin
 cherv:=true;
 for i:=5 to 8 do
  for j:=5 to 8 do
   if not (a[i,j]=1) then
    cherv:=false;
end;

function Ttroley.MayMove;
{var
 k,l:integer;}
begin
 maymove:=false;
 if (i-px=0)and (j-py=0)then //якщо ця а початкова
 else if (abs(py-j)<3)and (abs(px-i)<3) then
 //якщо ця клітинка на відстані, меншій за 3 від початкової
  if i-px=0 then
  //якщо ця клітинка на вертикалі початкової клітинки
   begin
    if j>py then
     begin//якщо ця клітинка нижче від початкової
      if p[abs(py-j),up] then//і сюди можна преміститися
       maymove:=true
     end
    else//якщо ця клітинка вище від початкової
     if j<py then
      if p[abs(py-j),down] then//і сюди можна преміститися
       maymove:=true;
   end
  else
   if j-py=0 then
  //якщо ця клітинка на горизонталі початкової клітинки
    if i>px then
     begin//якщо ця клітинка правіше від початкової
      if p[abs(px-i),right] then
       maymove:=true//і сюди можна преміститися
     end
    else//якщо ця клітинка лівіше від початкової
     if i<px then
      if p[abs(px-i),toleft] then
       maymove:=true;//і сюди можна преміститися

end;

function Ttroley.MayCompMove;
{var
 k,l:integer;}
begin
 MayCompMove:=false;
 if (di=0)and (dj=0)then //якщо ця а початкова
 else if (abs(dj)<3)and (abs(di)<3) then
 //якщо ця клітинка на відстані, меншій за 3 від початкової
  if di=0 then
  //якщо ця клітинка на вертикалі початкової клітинки
   begin
    if dj>0 then
     begin//якщо ця клітинка нижче від початкової
      if p[abs(dj),up] then//і сюди можна преміститися
       MayCompMove:=true
     end
    else//якщо ця клітинка вище від початкової
     if dj<0 then
      if p[abs(dj),down] then//і сюди можна преміститися
       MayCompMove:=true;
   end
  else
   if dj=0 then
  //якщо ця клітинка на горизонталі початкової клітинки
    if di>0 then
     begin//якщо ця клітинка правіше від початкової
      if p[abs(di),right] then
       MayCompMove:=true//і сюди можна преміститися
     end
    else//якщо ця клітинка лівіше від початкової
     if di<0 then
      if p[abs(di),toleft] then
       MayCompMove:=true;//і сюди можна преміститися
end;

function equivalention(a,b:boolean):boolean;
begin
 equivalention:=((not a) or b) and ((not b) or a);
end;

procedure Ttroley.goClick(Sender: TObject);
begin
 close
end;

procedure Ttroley.bngClick(Sender: TObject);
begin
 newgame;
 showchessboard;
end;

procedure Ttroley.abClick(Sender: TObject);
begin
 ant.showmodal;
end;

procedure Ttroley.hpClick(Sender: TObject);
begin
 h.show;
end;

procedure Ttroley.undoClick(Sender: TObject);
var
 f2:textfile;
 s,t:string;
 i,j,k,l,m:integer;
 p:tpoint;
begin
 assignfile(f2,'tn.old');
 rewrite(f2);
 reset(f);
 t:='';
 if not eof(f) then
 repeat
  readln(f,s);
  if (s<>'') and (t<>'') then
  writeln(f2,t);
  t:=s;
 until eof(f) or (s='');
 s:=t;
 i:=myval(s);
 j:=myval(s);
 k:=myval(s);
 l:=myval(s);
 m:=myval(s);
 if i>0 then
 if j>0 then
 if k>0 then
 if l>0 then
 if i<9 then
 if j<9 then
 if k<9 then
 if l<9 then
  begin
   a[k,l]:=a[i,j];
   a[i,j]:=0;
   p.x:=d*(i-1);
   p.y:=d*(j-1);
   showlastcur(p);
   p.x:=d*(k-1);
   p.y:=d*(l-1);
   showlastcur(p);
   hz:=m=1
  end;
 closefile(f);
 closefile(f2);
 reset(f2);
 if not eof(f2) then
  begin
   readln(f2,s);
   redo.Enabled:=true;
   redoall.Enabled:=true;
  end
 else
  begin
   undo.Enabled:=false;
   undoall.Enabled:=false;
  end;
 if s='' then
  begin
   undo.Enabled:=false;
   undoall.Enabled:=false;
  end
 else
  begin
   redo.Enabled:=true;
   redoall.Enabled:=true;
  end;
 closefile(f2);
 append(g);
 writeln(g,t);
 closefile(g);
 rewrite(f);
 reset(f2);
 if not eof(f2) then
  repeat
  readln(f2,s);
  writeln(f,s);
  until eof(f2);
 closefile(f);
 closefile(f2);
 erase(f2);
end;

procedure Ttroley.FormClose(Sender: TObject; var Action: TCloseAction);
begin
 erase(f);
 erase(g);
end;

procedure Ttroley.redoClick(Sender: TObject);
var
 f2:textfile;
 s,t:string;
 i,j,k,l,m:integer;
 p:tpoint;
begin
 assignfile(f2,'nt.old');
 rewrite(f2);
 reset(g);
 t:='';
 if not eof(g) then
 repeat
  readln(g,s);
  if (s<>'') and (t<>'') then
  writeln(f2,t);
  t:=s;
 until eof(g) or (s='');
 s:=t;
 i:=myval(s);
 j:=myval(s);
 k:=myval(s);
 l:=myval(s);
 m:=myval(s);
 if i>0 then
 if j>0 then
 if k>0 then
 if l>0 then
 if i<9 then
 if j<9 then
 if k<9 then
 if l<9 then
  begin
   a[i,j]:=a[k,l];
   a[k,l]:=0;
   p.x:=d*(i-1);
   p.y:=d*(j-1);
   showlastcur(p);
   p.x:=d*(k-1);
   p.y:=d*(l-1);
   showlastcur(p);
   hz:=m=1
  end;
 closefile(g);
 closefile(f2);
 newmovetofile(i,j,k,l,m=1);
 reset(f2);
 if not eof(f2) then
  begin
   readln(f2,s);
  end
 else
  begin
   redo.Enabled:=false;
   redoall.Enabled:=false;
  end;
 if s='' then
  begin
   redo.Enabled:=false;
   redoall.Enabled:=false;
  end;
 closefile(f2);

{ append(g);
 writeln(g,s);
 closefile(g);}
 rewrite(g);
 reset(f2);
 if not eof(f2) then
  repeat
  readln(f2,s);
  writeln(g,s);
  until eof(f2);
 closefile(g);
 closefile(f2);
 erase(f2);
end;

procedure Ttroley.undoallClick(Sender: TObject);
begin
 while undo.Enabled do
  undo.Click
end;

procedure Ttroley.redoallClick(Sender: TObject);
begin
 while redo.Enabled do
  redo.Click
end;

procedure Ttroley.clClick(Sender: TObject);
begin
 if messagebox(0,'Закінчити гру і почати нову?','Так?',32+4)=idyes then
  begin
   mode:=C_L;
   newgame;
   showchessboard;
   cl.Checked:=true
  end
end;

procedure Ttroley.lcClick(Sender: TObject);
begin
 if messagebox(0,'Закінчити гру і почати нову?','Так?',32+4)=idyes then
  begin
   mode:=L_C;
   newgame;
   showchessboard;
   lc.Checked:=true
  end
end;

procedure Ttroley.llClick(Sender: TObject);
begin
 if messagebox(0,'Закінчити гру і почати нову?','Так?',32+4)=idyes then
  begin
   mode:=L_L;
   newgame;
   showchessboard;
   ll.Checked:=true
  end
end;

procedure Ttroley.shClick(Sender: TObject);
begin
 sh.Checked:=not sh.Checked;
 showhint:=sh.Checked;
end;

procedure TTroley.CompMove;
var
 i,j,k,l:1..8;
 made:boolean;
begin
 made:=false;
 if hz then
  begin                  //Перш за все вверх
   for i:=8 downto 1 do
    for j:=2 to 8 do
     if not made then
      if a[i,j]=2 then   //На одну клітинку
       if canmove(i,j,CompMay) then
        if MayCompMove(0,-1,CompMay) then
         begin
          ShowLastCur(cur);
          made:=true;
          k:=i;
          l:=j-1;
          a[i,j-1]:=a[i,j];
          a[i,j]:=0;
          ShowChessBoard;
          Showcur;
         end
        else
        if j>2 then      //Чи на дві
         if MayCompMove(0,-2,CompMay) then
          begin
           ShowLastCur(cur);
           made:=true;
           k:=i;
           l:=j-2;
           a[i,j-2]:=a[i,j];
           a[i,j]:=0;
           ShowChessBoard;
           Showcur;
          end;
   if not made then
    for i:=1 to 7 do
     for j:=1 to 8 do
      if not made then
       if a[i,j]=2 then
        if canmove(i,j,CompMay) then
         if MayCompMove(1,0,CompMay) then
          begin           //На одну клітинку
           ShowLastCur(cur);
           made:=true;
           a[i+1,j]:=a[i,j];
           a[i,j]:=0;
           k:=i+1;
           l:=j;
           ShowChessBoard;
           Showcur;
          end
         else
          if i<7 then
           if MayCompMove(2,0,CompMay) then
            begin
             ShowLastCur(cur);
             made:=true;
             a[i+2,j]:=a[i,j];
             a[i,j]:=0;
             k:=i+2;
             l:=j;
             ShowChessBoard;
             Showcur;
            end;
   if not made then
    for i:=2 to 8 do
     for j:=1 to 8 do
      if not made then
       if a[i,j]=2 then
        if canmove(i,j,CompMay) then
         if MayCompMove(-1,0,CompMay) then
          begin        //На одну клітинку
           ShowLastCur(cur);
           made:=true;
           a[i-1,j]:=a[i,j];
           a[i,j]:=0;
           k:=i-1;
           l:=j;
           ShowChessBoard;
           Showcur;
          end
         else
          if i>2 then
           if MayCompMove(-2,0,CompMay) then
            begin
             ShowLastCur(cur);
             made:=true;
             a[i-2,j]:=a[i,j];
             a[i,j]:=0;
             k:=i-2;
             l:=j;
             ShowChessBoard;
             Showcur;
            end;
   if not made then
    begin
     messagebox(0,'Помилка в програмі!','Помилка!',16);
     close
    end
   else
    begin
     newmovetofile(i,j,k,l,hz);
     hz:=not hz;
    end;
  end
 else
  begin
   for i:=8 downto 1 do
    for j:=1 to 7 do
     if not made then
      if a[i,j]=1 then
       if canmove(i,j,CompMay) then
        if MayCompMove(0,1,CompMay) then
         begin            //На одну клітинку
          ShowLastCur(cur);
          made:=true;
          a[i,j+1]:=a[i,j];
          a[i,j]:=0;
          k:=i;
          l:=j+1;
          ShowChessBoard;
          Showcur;
         end
        else
        if j<7 then
         if MayCompMove(0,2,CompMay) then
          begin
           ShowLastCur(cur);
           made:=true;
           a[i,j+2]:=a[i,j];
           a[i,j]:=0;
           k:=i;
           l:=j+2;
           ShowChessBoard;
           Showcur;
          end;
   if not made then
    for i:=1 to 7 do
     for j:=1 to 8 do
      if not made then
       if a[i,j]=1 then
        if canmove(i,j,CompMay) then
         if MayCompMove(1,0,CompMay) then
          begin
           ShowLastCur(cur);
           made:=true;
           a[i+1,j]:=a[i,j];
           a[i,j]:=0;
           k:=i+1;
           l:=j;
           ShowChessBoard;
           Showcur;
          end
         else
          if i<7 then
           if MayCompMove(2,0,CompMay) then
            begin
             ShowLastCur(cur);
             made:=true;
             a[i+2,j]:=a[i,j];
             a[i,j]:=0;
             k:=i+2;
             l:=j;
             ShowChessBoard;
             Showcur;
            end;
   if not made then
    for i:=2 to 8 do
     for j:=8 downto 1 do
      if not made then
       if a[i,j]=1 then
        if canmove(i,j,CompMay) then
         if MayCompMove(-1,0,CompMay) then
          begin
           ShowLastCur(cur);
           made:=true;
           a[i-1,j]:=a[i,j];
           a[i,j]:=0;
           k:=i-1;
           l:=j;
           ShowChessBoard;
           Showcur;
          end
         else
          if i>2 then
           if MayCompMove(-2,0,CompMay) then
            begin
             ShowLastCur(cur);
             made:=true;
             a[i-2,j]:=a[i,j];
             a[i,j]:=0;
             k:=i-2;
             l:=j;
             ShowChessBoard;
             Showcur;
            end;
   if not made then
    begin
     messagebox(0,'Помилка в програмі!','Помилка!',16);
     close
    end
   else
    begin
     newmovetofile(i,j,k,l,hz);
     hz:=not hz;
    end;
  end;
 if (hz and zelen) then
  messagebox(0,'Комп''ютер виграв!','',64);
 if (not hz) and cherv then
  messagebox(0,'Людина виграла!','',64);
end;

end.