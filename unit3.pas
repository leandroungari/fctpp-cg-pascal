unit Unit3;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm3 }

  TForm3 = class(TForm)
    buttonCalcular: TButton;
    ia: TEdit;
    il: TEdit;
    ka: TEdit;
    kd: TEdit;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;

    procedure buttonCalcularClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    lambert:Boolean;
    iav,ilv,kdv,kav:real;
  end;

var
  Form3: TForm3;

implementation

{$R *.lfm}

{ TForm3 }

uses unit1,unit4;

procedure TForm3.buttonCalcularClick(Sender: TObject);
begin
     Form3.lambert:=True;
     Form4.phong:=false;
     Form1.pontoLuz[1]:=150;
     Form1.pontoLuz[2]:=0;
     Form1.pontoLuz[3]:=100;
     Form1.pontoLuz[4]:=1;

     iav:=StrToFloat(ia.Text);
    ilv:=StrToFloat(il.Text);
    kdv:=StrToFloat(kd.Text);
    kav:=StrToFloat(ka.Text);

    Form1.inicializarZBuffer();
    Form1.ativarIluminacao:=True;
    Form1.desenharPlano(50,50,0,200,200,clGray);
    Form1.desenharEsfera(150,150,0,50,clRed);

end;

procedure TForm3.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Form1.ativarIluminacao:=False;
  lambert:=False;
end;

procedure TForm3.FormCreate(Sender: TObject);
begin
  Form3.iav:=1.2;Form3.ilv:=1.6;Form3.kdv:=0.7;Form3.kav:=0.9;
  Form1.pontoLuz[1]:=150;
  Form1.pontoLuz[2]:=0;
  Form1.pontoLuz[3]:=100;
  Form1.pontoLuz[4]:=1;
end;


procedure TForm3.FormShow(Sender: TObject);
begin
  Form3.iav:=1.2;Form3.ilv:=1.6;Form3.kdv:=0.7;Form3.kav:=0.9;
  Form1.pontoLuz[1]:=150;
  Form1.pontoLuz[2]:=0;
  Form1.pontoLuz[3]:=100;
  Form1.pontoLuz[4]:=1;

  Form1.inicializarZBuffer();
  Form1.ativarIluminacao:=True;
  Form3.lambert:=True;
  Form1.desenharPlano(50,50,0,200,200,clGray);
  Form1.desenharEsfera(150,150,0,50,clRed);
end;

end.

