unit Unit1;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  Menus, Unit2, Unit3, Unit4, Math;

type
  Vector4 = array[1..4] of Integer;
  T4Array= array[1..4,1..4] of Real;
  Figure = array[1..5] of Vector4;
  Aresta = array[1..2] of Integer;
  Tabela = array[1..5] of Aresta;

  PontoBufferZ = record
      z:integer;
      cor:tcolor
  end;

  Ponto = array[1..4] of integer;
  Quadrilatero = record
      pontos: array[1..4] of Integer;
      cor:tcolor
  end;

  Trapezio = record
      face: array[1..5] of Quadrilatero;
      ponto:array[1..10] of Ponto
  end;

  MatrizZBuffer = array[1..784,1..562] of PontoBufferZ;

  { TForm1 }

  TForm1 = class(TForm)

    imagePrincipal: TImage;
    MainMenu1: TMainMenu;
    MenuItem1: TMenuItem;
    MenuItem10: TMenuItem;
    MenuItem11: TMenuItem;
    MenuItem12: TMenuItem;
    MenuItem13: TMenuItem;
    MenuItem14: TMenuItem;
    MenuItem2: TMenuItem;
    MenuItem3: TMenuItem;
    MenuItem4: TMenuItem;
    MenuItem5: TMenuItem;
    MenuItem6: TMenuItem;
    MenuItem7: TMenuItem;
    MenuItem8: TMenuItem;
    MenuItem9: TMenuItem;

    procedure FormCreate(Sender: TObject);
    procedure imagePrincipalMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure imagePrincipalMouseMove(Sender: TObject; Shift: TShiftState; X,
      Y: Integer);
    procedure imagePrincipalMouseUp(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure MenuItem11Click(Sender: TObject);
    procedure MenuItem12Click(Sender: TObject);
    procedure MenuItem14Click(Sender: TObject);
    procedure MenuItem2Click(Sender: TObject);
    procedure MenuItem4Click(Sender: TObject);
    procedure MenuItem5Click(Sender: TObject);
    procedure MenuItem7Click(Sender: TObject);
    procedure MenuItem8Click(Sender: TObject);
    procedure MenuItem9Click(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    pontoLuz:Vector4;
    ativarIluminacao:Boolean;
    procedure retaBressenham( x1, y1, x2, y2: Integer);

    procedure desenharFiguraFloodFill();
    procedure floodfill4(x,y:Integer);
    procedure floodfill8(x,y:Integer);
    procedure desenharInversaoDeCores();
    procedure construir(var figura:Figure; var table:Tabela);
    procedure preenchimentoInversaoDeCores(figura:Figure;tamanho:Integer; tabela: Tabela; num:Integer);

    procedure inicializarZBuffer();
    procedure desenharCone(x,y,z,altura:integer; cor:TColor);
    procedure desenharEsfera(x,y,z:integer;r:real;cor:tcolor);
    procedure desenharObjeto01(cor:tcolor);
    procedure desenharObjeto02(cor:tcolor);
    procedure desenharCuboParaleloEixos(x,y,z:integer;lado:real;cor:tcolor);
    procedure assignZBuffer(x,y,z:integer;cor:tcolor);

    procedure superficieBilinear();
    procedure multiplicarEscalar(ponto:Ponto; escalar:Real;var resultado:Ponto);
    procedure processarPontos();
    procedure somarPontos(p1,p2,p3,p4:Ponto; var resultado:Ponto);
    procedure inicializarTrapezio(var trap:Trapezio);
    procedure aplicarTrapezio(matriz:T4Array);
    procedure meioTrapezio(var meio:Vector4);

    procedure rotacaoX(var matrizXY:T4Array;graus: Integer);
    procedure rotacaoY(var matrizXY:T4Array;graus: Integer);
    procedure rotacaoZ(var matrizXY:T4Array;graus: Integer);
    procedure translacao(var matrizXY:T4Array; l,m,n:Real);
    procedure multiplicacao(var ponto: Vector4; matrizXY: T4Array; var result: Vector4);

    procedure varreduraRotacao();

    procedure desenharPlano(x,y,z,l,m:integer;cor:TColor);
    function cosseno(v1,v2:Vector4):real;
    function distancia(v1,v2:Vector4):real;
    function modulo(v:Vector4):real;
    function produtoEscalar(v1,v2:Vector4):real;

  end;

var
  Form1: TForm1;
  colorPrincipal:TColor;
  entradaX,entradaY,saidaX,saidaY, opcaoRotacional, posicaoLista, tamanhoLista:Integer;
  opcaoFloodFill4, opcaoFloodFill8, opcaoBilinear:Boolean;
  buffer:MatrizZBuffer;
  inicial,final, comecoDesenho:Vector4;
  listaPontos:array of Vector4;
  t: Trapezio;




implementation

{$R *.lfm}

{ TForm1 }
procedure TForm1.desenharPlano(x,y,z,l,m:integer;cor:TColor);
var i,j:integer;
begin

    for i:=0 to l do
    begin
        for j:=0 to m do
        begin
            assignZBuffer(x+i,y+j,z, cor);
        end;
    end;
end;

/////////////////////////
{inicializa o z-buffer}
procedure TForm1.inicializarZBuffer();
var x,y:integer;
begin
     imagePrincipal.Canvas.Brush.Color:=clBlack;
     imagePrincipal.Canvas.Clear;
     for x:=1 to 784 do
         for y:=1 to 562 do
         begin
             buffer[x,y].cor:=clBlack;
             buffer[x,y].z:=-MaxInt;
         end;
end;

{desenhar cone}
procedure TForm1.desenharCone(x,y,z,altura:integer; cor:TColor);
var t, pi2, alfa, passo:Real;
    xp,yp,zp:integer;
begin
   {cone amarelo}
   pi2:= 2*pi;
   passo:=pi2/360;
   t:=0;
   while (t <= altura) do
   begin
        alfa:=0;
        while (alfa <= pi2) do
        begin

            xp:=round(x+t*cos(alfa));
            yp:=round(y+t*sin(alfa));
            zp:=round(z+t);

            assignZBuffer(xp,yp,zp, cor);

            alfa:=alfa+passo;
        end;
        t:=t+0.01;
   end;
end;

{desenhar esfera}
procedure TForm1.desenharEsfera(x,y,z:integer;r:real;cor:tcolor);
var xp,yp,zp:integer;
    alfa, beta, pi2, passoAlfa, passoBeta:real;
begin
    alfa:=0;
    pi2:=2*pi;
    passoAlfa:=pi2/720; passoBeta:=pi2/360;
    while alfa <= pi2 do
        begin
            beta:=-pi;
            while beta <= pi do
                begin
                    xp:=round(x+r*cos(alfa)*cos(beta));
                    yp:=round(y+r*cos(alfa)*sin(beta));
                    zp:=round(z+r*sin(alfa));

                    assignZBuffer(xp,yp,zp,cor);

                    beta:=beta+passoBeta;
                end;
            alfa:=alfa+passoAlfa;
        end;
end;

{desenhar objeto 01}
procedure TForm1.desenharObjeto01(cor:tcolor);
var zp, i, j:integer;
begin
     for i:=10 to 30 do
         for j:=20 to 40 do
         begin
              zp:=i*i+j;
              assignZBuffer(i,j,zp,cor);
         end;
end;

{desenhar objeto 02}
procedure TForm1.desenharObjeto02(cor:tcolor);
var zp, i, j:integer;
begin
     for i:=50 to 100 do
         for j:=30 to 80 do
             begin
                 zp:=3*i-2*j+5;
                 assignZBuffer(i,j,zp,cor);

             end;

end;

{desenhar cubo}
procedure TForm1.desenharCuboParaleloEixos(x,y,z:integer;lado:real;cor:tcolor);
var xp,yp,zp,xq,yq,zq,i,j,k:integer;
begin
     xp:=round(x-(lado/2)); xq:=round(x+(lado/2));
     yp:=round(y-(lado/2)); yq:=round(y+(lado/2));
     zp:=round(z-(lado/2)); zq:=round(z+(lado/2));

     //face z maior
     for i:=xp to xq do
         for j:=yp to yq do
             for k:=zq to zq do
                 assignZBuffer(i,j,k,cor);

     //face z menor
     for i:=xp to xq do
         for j:=yp to yq do
             for k:=zp to zp do
                 assignZBuffer(i,j,k,cor);

     //face y maior
     for i:=xp to xq do
         for j:=yq to yq do
             for k:=zp to zq do
                 assignZBuffer(i,j,k,cor);

     //face y menor
     for i:=xp to xq do
         for j:=yp to yp do
             for k:=zp to zq do
                assignZBuffer(i,j,k,cor);

     //face x maior
     for i:=xq to xq do
         for j:=yp to yq do
             for k:=zp to zq do
                 assignZBuffer(i,j,k,cor);

     //face x menor
     for i:=xp to xp do
         for j:=yp to yq do
             for k:=zp to zq do
                 assignZBuffer(i,j,k,cor);


end;

{atribuir valor do ponto na matriz do ZBuffer}
procedure TForm1.assignZBuffer(x,y,z:integer;cor:tcolor);
var r,g,b:integer;
    intensidade:real;
    ponto:Vector4;
begin
    if ((x > 0) and (x <= 784) and (y > 0) and (y <= 562)) then
       if (z > buffer[x,y].z) then
       begin

            if ativarIluminacao = True  then
            begin
                 ponto[1]:=x;ponto[2]:=y;ponto[3]:=z;

                 //decompor cor
                 R := cor and 255;
                 G := (cor div 256) and 255;
                 B := (cor div 65536) and 255;

                 //calculo de cor
                 if Form3.lambert = True then
                 begin
                      intensidade:=Form3.iav*Form3.kav+Form3.ilv*Form3.kdv*cosseno(Form1.pontoLuz,ponto);

                      R := round(R*intensidade);
                      G := round(G*intensidade);
                      B := round(B*intensidade);
                 end
                 else if Form4.phong = True then
                 begin
                      intensidade:=Form4.iav*Form4.kav+(Form4.ilv/(distancia(pontoLuz,ponto)+Form4.kv))*(Form4.kdv*cosseno(pontoLuz,ponto)+Form4.ksv*power(cos(2*pi),Form4.nv));
                      R := round(R*intensidade);
                      G := round(G*intensidade);
                      B := round(B*intensidade);
                 end;

                 //cor resultante
                 cor := R + 256 * G + 65536 * B;
            end;

            buffer[x,y].z := z;
            buffer[x,y].cor:=cor;
            imagePrincipal.Canvas.Pixels[x,y]:=cor;
       end;
end;

function TForm1.produtoEscalar(v1,v2:Vector4):real;
begin

    produtoEscalar:=v1[1]*v2[1]+v1[2]*v2[2]+v1[3]*v2[3];
end;

function TForm1.modulo(v:Vector4):real;
begin
    modulo:=sqrt(v[1]*v[1]+v[2]*v[2]+v[3]*v[3]);
end;

function TForm1.cosseno(v1,v2:Vector4):real;
begin
    cosseno:=(produtoEscalar(v1,v2)/(modulo(v1)*modulo(v2)));
end;

function TForm1.distancia(v1,v2:Vector4):real;
begin
    distancia:=sqrt(power(v1[1]-v2[1],2)+power(v1[2]-v2[2],2)+power(v1[3]-v2[3],2));
end;


///////////////////////////////////////////////
{desenha a superficie bilinear}
procedure TForm1.superficieBilinear();
begin

     inicializarZBuffer();
     inicializarTrapezio(t);
     processarPontos();
end;

procedure TForm1.processarPontos();
var i,j,f:real;
    p1,p2,p3,p4, r:Ponto;
begin
    f:=1;
     while f<=5 do
     begin
         i:=0;
         while i<=1 do
         begin
             j:=0;
             while j<=1 do
             begin

                 multiplicarEscalar(t.ponto[t.face[round(f)].pontos[1]], (1-i)*(1-j),p1);
                 multiplicarEscalar(t.ponto[t.face[round(f)].pontos[2]], (1-i)*j,p2);
                 multiplicarEscalar(t.ponto[t.face[round(f)].pontos[3]], i*(1-j),p3);
                 multiplicarEscalar(t.ponto[t.face[round(f)].pontos[4]], i*j,p4);

                 somarPontos(p1,p2,p3,p4,r);
                 assignZBuffer(r[1],r[2],r[3], t.face[round(f)].cor);
                 j:=j+0.002;
             end;
             i:=i+0.002;
         end;
         f:=f+1;
     end;
end;

procedure TForm1.multiplicarEscalar(ponto:Ponto; escalar:Real;var resultado:Ponto);
begin
  resultado[1]:=round(ponto[1]*escalar);
  resultado[2]:=round(ponto[2]*escalar);
  resultado[3]:=round(ponto[3]*escalar);
  resultado[4]:=1;
end;

procedure TForm1.somarPontos(p1,p2,p3,p4:Ponto; var resultado:Ponto);
begin
     resultado[1]:=p1[1]+p2[1]+p3[1]+p4[1];
     resultado[2]:=p1[2]+p2[2]+p3[2]+p4[2];
     resultado[3]:=p1[3]+p2[3]+p3[3]+p4[3];
     resultado[4]:=1;
end;

procedure TForm1.inicializarTrapezio(var trap:Trapezio);
begin
     trap.ponto[1,1]:=100;trap.ponto[1,2]:=100;trap.ponto[1,3]:=0;trap.ponto[1,4]:=1;
     trap.ponto[2,1]:=140;trap.ponto[2,2]:=100;trap.ponto[2,3]:=0;trap.ponto[2,4]:=1;
     trap.ponto[3,1]:=100;trap.ponto[3,2]:=140;trap.ponto[3,3]:=0;trap.ponto[3,4]:=1;
     trap.ponto[4,1]:=140;trap.ponto[4,2]:=140;trap.ponto[4,3]:=0;trap.ponto[4,4]:=1;
     trap.ponto[5,1]:=100;trap.ponto[5,2]:=100;trap.ponto[5,3]:=160;trap.ponto[5,4]:=1;
     trap.ponto[6,1]:=140;trap.ponto[6,2]:=100;trap.ponto[6,3]:=160;trap.ponto[6,4]:=1;
     trap.ponto[7,1]:=100;trap.ponto[7,2]:=140;trap.ponto[7,3]:=160;trap.ponto[7,4]:=1;
     trap.ponto[8,1]:=140;trap.ponto[8,2]:=140;trap.ponto[8,3]:=160;trap.ponto[8,4]:=1;
     trap.ponto[9,1]:=180;trap.ponto[9,2]:=100;trap.ponto[9,3]:=0;trap.ponto[9,4]:=1;
     trap.ponto[10,1]:=180;trap.ponto[10,2]:=140;trap.ponto[10,3]:=0;trap.ponto[10,4]:=1;

     trap.face[1].pontos[1]:=1;
     trap.face[1].pontos[2]:=3;
     trap.face[1].pontos[3]:=2;
     trap.face[1].pontos[4]:=4;
     trap.face[1].cor:=clGreen;

     trap.face[2].pontos[1]:=5;
     trap.face[2].pontos[2]:=7;
     trap.face[2].pontos[3]:=6;
     trap.face[2].pontos[4]:=8;
     trap.face[2].cor:=clPurple;

     trap.face[3].pontos[1]:=2;
     trap.face[3].pontos[2]:=4;
     trap.face[3].pontos[3]:=6;
     trap.face[3].pontos[4]:=8;
     trap.face[3].cor:=clYellow;

     trap.face[4].pontos[1]:=2;
     trap.face[4].pontos[2]:=4;
     trap.face[4].pontos[3]:=9;
     trap.face[4].pontos[4]:=10;
     trap.face[4].cor:=clRed;

     trap.face[5].pontos[1]:=9;
     trap.face[5].pontos[2]:=10;
     trap.face[5].pontos[3]:=6;
     trap.face[5].pontos[4]:=8;
     trap.face[5].cor:=clBlue;
end;

{aplica rotacao no x}
procedure TForm1.rotacaoX(var matrizXY:T4Array;graus: Integer);
begin
       matrizXY[1,1] := 1;
       matrizXY[1,2] := 0;
       matrizXY[1,3] := 0;
       matrizXY[1,4] := 0;
       matrizXY[2,1] := 0;
       matrizXY[2,2] := cos(Pi*graus/180);
       matrizXY[2,3] := -sin(Pi*graus/180);
       matrizXY[2,4] := 0;
       matrizXY[3,1] := 0;
       matrizXY[3,2] := sin(Pi*graus/180);
       matrizXY[3,3] := cos(Pi*graus/180);
       matrizXY[3,4] := 0;
       matrizXY[4,1] := 0;
       matrizXY[4,2] := 0;
       matrizXY[4,3] := 0;
       matrizXY[4,4] := 1;
end;

{aplica rotacao no y}
procedure TForm1.rotacaoY(var matrizXY:T4Array; graus: Integer);
begin
       matrizXY[1,1] := cos(Pi*graus/180);
       matrizXY[1,2] := 0;
       matrizXY[1,3] := sin(Pi*graus/180);
       matrizXY[1,4] := 0;
       matrizXY[2,1] := 0;
       matrizXY[2,2] := 1;
       matrizXY[2,3] := 0;
       matrizXY[2,4] := 0;
       matrizXY[3,1] := -sin(Pi*graus/180);
       matrizXY[3,2] := 0;
       matrizXY[3,3] := cos(Pi*graus/180);
       matrizXY[3,4] := 0;
       matrizXY[4,1] := 0;
       matrizXY[4,2] := 0;
       matrizXY[4,3] := 0;
       matrizXY[4,4] := 1;
end;

{rotacao no z}
procedure TForm1.rotacaoZ(var matrizXY: T4Array; graus: Integer);
begin
       matrizXY[1,1] := cos(Pi*graus/180);
       matrizXY[1,2] := -sin(Pi*graus/180);
       matrizXY[1,3] := 0;
       matrizXY[1,4] := 0;
       matrizXY[2,1] := sin(Pi*graus/180);
       matrizXY[2,2] := cos(Pi*graus/180);
       matrizXY[2,3] := 0;
       matrizXY[2,4] := 0;
       matrizXY[3,1] := 0;
       matrizXY[3,2] := 0;
       matrizXY[3,3] := 1;
       matrizXY[3,4] := 0;
       matrizXY[4,1] := 0;
       matrizXY[4,2] := 0;
       matrizXY[4,3] := 0;
       matrizXY[4,4] := 1;
end;

{aplica a translacao}
procedure TForm1.translacao(var matrizXY:T4Array; l,m,n:Real);
begin
       matrizXY[1,1] := 1;
       matrizXY[1,2] := 0;
       matrizXY[1,3] := 0;
       matrizXY[1,4] := 0;
       matrizXY[2,1] := 0;
       matrizXY[2,2] := 1;
       matrizXY[2,3] := 0;
       matrizXY[2,4] := 0;
       matrizXY[3,1] := 0;
       matrizXY[3,2] := 0;
       matrizXY[3,3] := 1;
       matrizXY[3,4] := 0;
       matrizXY[4,1] := l;
       matrizXY[4,2] := m;
       matrizXY[4,3] := n;
       matrizXY[4,4] := 1;
 end;

{função de multiplicao do ponto pela matriz}
procedure TForm1.multiplicacao(var ponto: Vector4; matrizXY: T4Array; var result: Vector4);
var a,b:Integer;
  soma:Real;
begin
  for a:= 1 to 4 do
      begin
           soma:=0;
           for b:= 1 to 4 do
               begin
                    soma:=soma+ponto[b]*matrizXY[b,a];
               end;
               result[a] := round(soma);
      end;
end;

procedure TForm1.aplicarTrapezio(matriz:T4Array);
var i:integer;
  entrada,saida:Vector4;
begin

    for i:=1 to 10 do
    begin
        entrada[1]:=t.ponto[i,1];
        entrada[2]:=t.ponto[i,2];
        entrada[3]:=t.ponto[i,3];
        entrada[4]:=t.ponto[i,4];
        multiplicacao(entrada,matriz,saida);
        t.ponto[i,1]:=saida[1];
        t.ponto[i,2]:=saida[2];
        t.ponto[i,3]:=saida[3];
        t.ponto[i,4]:=saida[4];
    end;
end;

procedure TForm1.meioTrapezio(var meio:Vector4);
var i:integer;
begin

    meio[1]:=0;meio[2]:=0;meio[3]:=0;meio[4]:=1;

    for i:=1 to 10 do
    begin
         meio[1]:=meio[1]+t.ponto[i,1];
         meio[2]:=meio[2]+t.ponto[i,2];
         meio[3]:=meio[3]+t.ponto[i,3];
    end;

    meio[1]:=round(meio[1]/10);
    meio[2]:=round(meio[2]/10);
    meio[3]:=round(meio[3]/10);
    meio[4]:=1;
end;

////////////////////////////////////////////////
{flood fill 4}
procedure TForm1.floodfill4(x,y:Integer);
begin

    if imagePrincipal.Canvas.Pixels[x,y] <> clYellow then
        begin
             imagePrincipal.Canvas.Pixels[x,y] := clYellow;
             floodfill4(x+1,y);
             floodfill4(x,y+1);
             floodfill4(x-1,y);
             floodfill4(x,y-1);
        end
end;

{flood fill 8}
procedure TForm1.floodfill8(x,y:Integer);
begin
     if imagePrincipal.Canvas.Pixels[x,y] <> clYellow then
        begin
             imagePrincipal.Canvas.Pixels[x,y] := clYellow;
             floodfill8(x-1,y+1);
             floodfill8(x,y+1);
             floodfill8(x+1,y+1);
             floodfill8(x,y-1);
             floodfill8(x,y+1);
             floodfill8(x-1,y-1);
             floodfill8(x,y-1);
             floodfill8(x+1,y-1);
        end
end;

{desenha a figura padrão do flood fill}
procedure TForm1.desenharFiguraFloodFill();
begin
     imagePrincipal.Picture.Clear;
     colorPrincipal:=clYellow;
     retaBressenham(100,100,302,100);
     retaBressenham(100,100,100,300);
     retaBressenham(100,300,300,300);
     retaBressenham(302,100,302,298);
     retaBressenham(302,298,500,298);
     retaBressenham(300,300,300,500);
     retaBressenham(300,500,500,500);
     retaBressenham(500,298,500,500);
end;

{desenha a figura padrão do inversão de cores}
procedure TForm1.desenharInversaoDeCores();
begin
     imagePrincipal.Picture.Clear;
     colorPrincipal:=clYellow;
     retaBressenham(100,100,100,500);
     retaBressenham(100,500,500,500);
     retaBressenham(500,500,500,200);
     retaBressenham(500,200,350,350);
     retaBressenham(350,350,100,100);
end;

{monta a tabela de retas do inversão de cores}
procedure TForm1.construir(var figura:Figure; var table:Tabela);
begin
     figura[1,1] := 100; figura[1,2] := 100; figura[1,3] := 0;
     figura[2,1] := 100; figura[2,2] := 500; figura[2,3] := 0;
     figura[3,1] := 500; figura[3,2] := 500; figura[3,3] := 0;
     figura[4,1] := 500; figura[4,2] := 200; figura[4,3] := 0;
     figura[5,1] := 350; figura[5,2] := 350; figura[5,3] := 0;

     table[1,1]:= 1; table[1,2]:= 2;
     table[2,1]:= 2; table[2,2]:= 3;
     table[3,1]:= 3; table[3,2]:= 4;
     table[4,1]:= 4; table[4,2]:= 5;
     table[5,1]:= 5; table[5,2]:= 1;
end;

{algoritmo inversão de cores}
procedure TForm1.preenchimentoInversaoDeCores(figura:Figure;tamanho:Integer; tabela: Tabela; num:Integer);
var pontoMax, pontoMin, a,b:Vector4;
  i,j, valor, base, min, max:Integer;
  m:Real;
begin

  pontoMax:= figura[1];
  pontoMin:= figura[1];
  for i:= 1 to tamanho do
      begin
           if (figura[i,1] < pontoMin[1]) then pontoMin[1]:=figura[i,1]
           else if (figura[i,1] > pontoMax[1]) then pontoMax[1]:=figura[i,1];

           if (figura[i,2] < pontoMin[2]) then pontoMin[2]:=figura[i,2]
           else if (figura[i,2] > pontoMax[2]) then pontoMax[2]:=figura[i,2];

      end;

  //Margem de segurança
  pontoMin[1]:= pontoMin[1] - 2;
  pontoMin[2]:= pontoMin[2] - 2;
  pontoMax[1]:= pontoMax[1] + 2;
  pontoMax[2]:= pontoMax[2] + 2;

  for i:=1 to num do
      begin
           //recuperando os pontos que compõem a aresta
           a:=figura[tabela[i,1]];
           b:=figura[tabela[i,2]];

           if (b[2] = a[2]) then continue;

           m:=(b[1]-a[1])/(b[2]-a[2]);

           if (b[2] > a[2]) then
              begin
                   max:=round(b[2]);
                   min:=round(a[2]);
                   base:=round(a[1]);
              end
           else
              begin
                   min:=round(b[2]);
                   max:=round(a[2]);
                   base:=round(b[1]);
              end;

           for j:= 0 to (max-min) do
               begin
                   valor:=round(j*m+base);

                   while valor <= pontoMax[1] do
                       begin
                           if imagePrincipal.Canvas.Pixels[valor, j+min] = clBlack then imagePrincipal.Canvas.Pixels[valor, j+min]:=clYellow
                           else imagePrincipal.Canvas.Pixels[valor, j+min]:=clBlack;
                           valor:=valor+1;
                       end;
               end;

      end;

end;

procedure TForm1.MenuItem4Click(Sender: TObject);
begin

     Form1.ativarIluminacao:=False;
     Form3.lambert:=False;
     Form4.phong:=False;
     desenharFiguraFloodFill();
     opcaoFloodFill4:=True;
     opcaoFloodFill8:=False;
     opcaoRotacional:=0;
     opcaoBilinear:=False;
end;

procedure TForm1.MenuItem5Click(Sender: TObject);
begin
     Form1.ativarIluminacao:=False;
     Form3.lambert:=False;
     Form4.phong:=False;
     desenharFiguraFloodFill();
     opcaoFloodFill4:=False;
     opcaoFloodFill8:=True;
     opcaoRotacional:=0;
     opcaoBilinear:=False;

end;

procedure TForm1.MenuItem7Click(Sender: TObject);
begin
  Form1.ativarIluminacao:=False;
     Form3.lambert:=False;
     Form4.phong:=False;
  opcaoFloodFill4:=False;
  opcaoFloodFill8:=False;
  opcaoRotacional:=0;
  opcaoBilinear:=False;

   inicializarZBuffer();

   desenharCone(30,50,10,50,clYellow);
   desenharEsfera(100,50,20,30,clGreen);
   desenharObjeto01(clBlue);
   desenharObjeto02(clRed);
   desenharCuboParaleloEixos(0,0,0,40,clWhite);
end;

procedure TForm1.MenuItem8Click(Sender: TObject);
begin
     Form1.ativarIluminacao:=False;
     Form3.lambert:=False;
     Form4.phong:=False;
     opcaoFloodFill4:=False;
   opcaoFloodFill8:=False;
   opcaoRotacional:=0;
   opcaoBilinear:=True;

   superficieBilinear();
   Form2.Show;
end;

procedure TForm1.MenuItem9Click(Sender: TObject);
begin
  Form1.ativarIluminacao:=False;
  Form3.lambert:=False;
  Form4.phong:=False;
  opcaoFloodFill4:=False;
  opcaoFloodFill8:=False;
  opcaoRotacional:=1;
  opcaoBilinear:=False;
  imagePrincipal.Canvas.Brush.Color:=clBlack;

  colorPrincipal:=clYellow;
  inicializarZBuffer();
  retaBressenham(397, 1, 397, 562);

end;

procedure TForm1.imagePrincipalMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if opcaoFloodFill4 = True then
       begin
           floodfill4(x,y);
       end;

   if opcaoFloodFill8 = True then
       begin
           floodfill8(x,y);
       end;

   if opcaoRotacional = 1 then
      begin
          imagePrincipal.Canvas.Pen.Color:=clRed;
          inicial[1]:=X; inicial[2]:=Y;

          SetLength(listaPontos, 50);
          tamanhoLista:=50;
          posicaoLista:=0;
          listaPontos[posicaoLista, 1]:=inicial[1]; listaPontos[posicaoLista, 2]:=inicial[2];
          posicaoLista:=posicaoLista+1;
          opcaoRotacional:=2;
      end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  ativarIluminacao:=False;
end;


procedure TForm1.imagePrincipalMouseMove(Sender: TObject; Shift: TShiftState;
  X, Y: Integer);
begin
  if opcaoRotacional = 2 then
     begin
         final[1]:=X; final[2]:=Y;

         imagePrincipal.Canvas.moveTo(inicial[1],inicial[2]);
         imagePrincipal.Canvas.lineTo(final[1], final[2]);

         inicial[1]:=final[1];
         inicial[2]:=final[2];

         listaPontos[posicaoLista, 1]:=inicial[1]; listaPontos[posicaoLista, 2]:=inicial[2];
         posicaoLista:=posicaoLista+1;

         if posicaoLista > (tamanhoLista-1) then
            begin
                tamanhoLista:=tamanhoLista+50;
                SetLength(listaPontos, tamanhoLista);
            end;
     end;
end;

procedure TForm1.varreduraRotacao();
var z, x, y:integer;
  i,j,raio:integer;
  p1,p2:Vector4;
  u,passo:real;
begin
     for i:=1 to posicaoLista-1 do
     begin
          p1:=listaPontos[i-1];
          p2:=listaPontos[i];
          u:=0; passo:=1/(abs(p1[2]-p2[2])+1);
          while(u<=1) do
          begin
              x:=round(p1[1]*(1-u)+p2[1]*u);
              y:=round(p1[2]*(1-u)+p2[2]*u);
              raio:=abs(x-397);
              for j:=(397-raio) to (397+raio) do
              begin
                  z:=round(sqrt(power(raio,2)-power(j-397,2)));
                  assignZBuffer(j,y,z,clRed);
              end;
              u:=u+passo;
          end;


     end;
end;



procedure TForm1.imagePrincipalMouseUp(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if opcaoRotacional = 2 then
     begin
         imagePrincipal.Canvas.Pen.Color:=clYellow;
         opcaoRotacional:=0;

         varreduraRotacao();

     end;
end;

procedure TForm1.MenuItem11Click(Sender: TObject);
begin


  Form3.Show;

end;

procedure TForm1.MenuItem12Click(Sender: TObject);
begin


  Form4.Show;

end;

procedure TForm1.MenuItem14Click(Sender: TObject);
begin
  inicializarZBuffer();
end;

procedure TForm1.MenuItem2Click(Sender: TObject);
var f:Figure;
    t:Tabela;
begin

     Form1.ativarIluminacao:=False;
     Form3.lambert:=False;
     Form4.phong:=False;

     opcaoFloodFill4:=False;
     opcaoFloodFill8:=False;
     opcaoRotacional:=0;
     opcaoBilinear:=False;

     desenharInversaoDeCores();
     construir(f,t);
     preenchimentoInversaoDeCores(f,5,t,5);
end;

{desenho de reta com bressenham original}
procedure TForm1.retaBressenham( x1, y1, x2, y2: Integer);
var cont, ax, ay, d, dx, dy, ae, ane, aux, incy1, incx1, incy2, incx2 : Integer;
begin
       entradaX := x1;
       entradaY := y1;
       saidaX := x2;
       saidaY := y2;
       incy1 :=0;
       incx1 :=0;
       incx2 :=1;

       dx := abs(saidaX-entradaX);
       dy := abs(saidaY-entradaY);

       if(dx>dy) then
         begin
              if(saidaX<entradaX) then
                begin
                     incx2 := -1;
                     incx1 := -1;
                end
              else
                begin
                     incx2 := 1;
                     incx1 := 1;
                end;
              if(saidaY<entradaY) then
                begin
                    incy2 := -1;
                end
              else
                  begin
                       incy2 := 1;
                  end;
         end
       else
           begin
                aux := dx;
                dx := dy;
                dy := aux;

                if(saidaY<entradaY) then
                  begin
                     incy2 := -1;
                     incy1 := -1;
                  end
                else
                  begin
                     incy2 := 1;
                     incy1 := 1;
                  end;
                if(saidaX<entradaX) then
                  begin
                       incx2 := -1;
                  end
                else
                  begin
                       incx2 := 1;
                  end;
           end;


       d := (2*dy) - dx;
       ae := 2*dy;
       ane := 2*(dy-dx);
       ax := entradaX;
       ay := entradaY;

       //pegar maior
       if(dx>dy) then
         begin
              aux := dx;
         end
       else
         begin
              aux := dy;
         end;

       imagePrincipal.Canvas.Pixels[ax,ay] := colorPrincipal;

       for cont := 0 to aux do
           begin
                if(d<=0) then
                   begin
                        d := d+ae;
                        ay := ay+incy1;
                        ax := ax+incx1;
                   end
                 else
                   begin
                        d := d+ane;
                        ay := ay+incy2;
                        ax := ax+incx2;
                   end;
                imagePrincipal.Canvas.Pixels[ax,ay] := colorPrincipal;
           end;
end;



end.
