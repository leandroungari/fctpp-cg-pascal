unit Unit2;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm2 }

  TForm2 = class(TForm)
    Button1: TButton;
    textFieldAngulo: TEdit;
    textFieldEixo: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    procedure Button1Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
  private
    { private declarations }
  public
    { public declarations }
  end;

var
  Form2: TForm2;

implementation
uses unit1;
{$R *.lfm}

{ TForm2 }



procedure TForm2.Button1Click(Sender: TObject);
var eixo:string;
    valor:integer;
    matriz:T4Array;
    meio:Vector4;
begin

  //aplicar deslocamento para origem para rotacionar no centro
  Form1.meioTrapezio(meio);
  Form1.translacao(matriz,-meio[1], -meio[2],-meio[3]);
  Form1.aplicarTrapezio(matriz);

  eixo:=textFieldEixo.Text;
  valor:=StrToInt(textFieldAngulo.Text);
  eixo:=LowerCase(eixo);

  if eixo = 'x' then
  begin
      Form1.rotacaoX(matriz, valor);
  end;
  if eixo = 'y' then
  begin
      Form1.rotacaoY(matriz, valor);
  end;
  if eixo = 'z' then
  begin
      Form1.rotacaoZ(matriz, valor);
  end;

  //rotacionar
  Form1.aplicarTrapezio(matriz);

  //devolver no ponto de origem
  Form1.translacao(matriz, meio[1], meio[2], meio[3]);
  Form1.aplicarTrapezio(matriz);
  Form1.inicializarZBuffer();
  Form1.processarPontos();

end;

procedure TForm2.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Form1.ativarIluminacao:=False;
end;

end.

