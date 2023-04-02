unit functions;

interface
uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ExtCtrls, ComCtrls;
function ctie(s:string):boolean;
Function ps:string;
Function max(a,b:integer):integer;
Function min(a,b:integer):integer;
Function in_(a,b,c:integer):boolean;
Function between(a,b,c:TPoint):boolean;
function pch(s:string):pchar;
function myvalue(s:string):integer;
Function x4(x:real):real;
type
 sgntype=-1..1;
Function sgn(x:real):sgntype;
{Function awa(l:trectline):real;}
Function tan(x:real):real;
function d(a,b:tpoint):real;
function myval(var s:string):integer;
function mrv(var s:string):real;
function vr(s:string):real;
function mySTR(R:REAL):string;
//Function median(t:ttriangle):tline;
//Function midpoint(t:ttriangle):tpoint;
//Function seredyna(t:tline):tpoint;
function its(R:integer):string;
//Function centerpoint(sender:TMo):tpoint;
Procedure copyfile(var f1,f2:textfile);
implementation
function pch(s:string):pchar;
var
  A: array[0..79] of Char;
begin
  StrPCopy(A, S);
  pch:=a;
end;

function myvalue(s:string):integer;
begin
 myvalue:=myval(s);
end;

Function x4(x:real):real;
begin
 x4:=x*x*x*x;
end;

Function sgn(x:real):sgntype;
begin
 if x=0 then
  sgn:=0
 else
  if x>0 then
   sgn:=1
  else
   sgn:=-1;
end;

{Function awa(l:trectline):real;
begin
 if l.mode=vertical then
  awa:=90
 else
  awa:=arctan(l.k)/pi*180;
end;}

Function tan(x:real):real;
begin
 tan:=0;
 if cos(x)<>0 then
 tan:=sin(x)/cos(x);
end;

function d(a,b:tpoint):real;
begin
 d:=sqrt(sqr(a.x-b.x)+sqr(a.y-b.y));
end;

function myval(var s:string):integer;
var
 v,ec:integer;
 s1:string;
begin
 val(s,v,ec);
 if ec>0 then
  begin
   s1:=copy(s,1,ec//length(s)-ec
   -1);
   s:=copy(s,ec,length(s));
   val(s1,v,ec);
  end;
 myval:=v;
end;

function ctie(s:string):boolean;
var
 v,ec:integer;
begin
 val(s,v,ec);
 if v=0 then
 ctie:=ec>0
 else
 ctie:=ec>0
end;

function mrv(var s:string):real;
var
 ec:integer;
 v:real;
 s1:string;
begin
 val(s,v,ec);
 if ec>0 then
  begin
   s1:=copy(s,1,ec//length(s)-ec
   -1);
   s:=copy(s,ec,length(s));
   val(s1,v,ec);
  end;
 mrv:=v;
end;

function vr(s:string):real;
begin
 vr:=mrv(s);
end;

function mySTR(R:REAL):string;
var
 s:string;
begin
 STR(R:20:20,s);
 mySTR:=S;
end;

{Function median(t:ttriangle):tline;
begin
 median.create;
 median.v:=false;
 median.a:=t.a;
 median.b:=t.b;
end;
}
{Function midpoint(t:ttriangle):tpoint;
begin
 midpoint.x:=(t.a.x+t.b.x+t.c.x) div 3;
 midpoint.y:=(t.a.y+t.b.y+t.c.y) div 3;
end;

Function seredyna(t:tline):tpoint;
begin
 seredyna.x:=(t.a.x+t.b.x) div 2;
 seredyna.y:=(t.a.y+t.b.y) div 2;
end;

    Function centerpoint;
begin
 case ot of
  '3':centerpoint:=midpoint(sender as ttriangle);//t.a.x:=value(ve.text);
  '2':centerpoint:=seredyna(sender as tline);//t.a.x:=value(ve.text);
  'r':centerpoint:=seredyna((sender as trectangle).ac);//t.a.x:=value(ve.text);
  'ï':centerpoint:=seredyna((sender as tparalelogram).ac);//t.a.x:=value(ve.text);
  'o':centerpoint:=(sender as o).o;
  'e':centerpoint:=(sender as tellipse).o;
 end;
end;}

function its(R:integer):string;
var
 s:string;
begin
 STR(R,s);
 its:=S;
end;

Function max(a,b:integer):integer;
begin
 if a>b then
  max:=a
 else
  max:=b
end;

Function min(a,b:integer):integer;
begin
 if a<b then
  min:=a
 else
  min:=b
end;

Function in_(a,b,c:integer):boolean;
begin
 in_:= (c >= min(a,b)) and (c <= max(a,b));
end;

Function between(a,b,c:TPoint):boolean;
begin
 between:=in_(a.x,b.x,c.x) and in_(a.y,b.y,c.y);
end;

{Function awa(l:trectline):real;
begin
 if l.mode=vertical then
  awa:=90
 else
  awa:=arctan(l.k)/pi*180;
end;

Function midpoint(t:ttriangle):tpoint;
begin
 midpoint.x:=(t.a.x+t.b.x+t.c.x) div 3;
 midpoint.y:=(t.a.y+t.b.y+t.c.y) div 3;
end;

Function seredyna(t:tline):tpoint;
begin
 seredyna.x:=(t.a.x+t.b.x) div 2;
 seredyna.y:=(t.a.y+t.b.y) div 2;
end;

Function centerpoint;
begin
 case sender.ot of
  '3':centerpoint:=midpoint(sender as ttriangle);//t.a.x:=value(ve.text);
  '2':centerpoint:=seredyna(sender as tline);//t.a.x:=value(ve.text);
  'r':centerpoint:=seredyna((sender as trectangle).ac);//t.a.x:=value(ve.text);
  'ï':centerpoint:=seredyna((sender as tparalelogram).ac);//t.a.x:=value(ve.text);
  'o':centerpoint:=(sender as o).o;
  'e':centerpoint:=(sender as tellipse).o;
 end;
end;}

Procedure copyfile(var f1,f2:textfile);
var
 s:String;
begin
 reset(f1);
 rewrite(f2);
 repeat
  readln(f1,s);
  writeln(f2,s);
 until eof(f1);
 closefile(f1);
 closefile(f2);
end;

Function ps;
var
 i:byte;
 s:string;
begin
 s:='';
 for i:=1 to paramcount do
  s:=s+paramstr(i)+' ';
 ps:=s;
end;

end.
