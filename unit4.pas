unit Unit4;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, StdCtrls;

type

  { TForm4 }

  TForm4 = class(TForm)
    buttonCalcular: TButton;
    ia: TEdit;
    il: TEdit;
    n: TEdit;
    ka: TEdit;
    kd: TEdit;
    ks: TEdit;
    k: TEdit;

    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;


    procedure buttonCalcularClick(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
  private
    { private declarations }
  public
    { public declarations }
    phong:Boolean;
    iav,ilv,kdv,kav,kv,ksv,nv:real;
  end;

var
  Form4: TForm4;

implementation

{$R *.lfm}

{ TForm4 }

uses UNIT1;

procedure TForm4.buttonCalcularClick(Sender: TObject);
begin

    iav:=StrToFloat(ia.Text);
    ilv:=StrToFloat(il.Text);
    kdv:=StrToFloat(kd.Text);
    kav:=StrToFloat(ka.Text);
    kv:=StrToFloat(k.Text);
    ksv:=StrToFloat(ks.Text);
    nv:=StrToFloat(n.Text);

    Form1.inicializarZBuffer();
    Form1.ativarIluminacao:=True;
    Form4.phong:=true;
    Form1.desenharPlano(50,50,0,200,200,clGray);
    Form1.desenharEsfera(150,150,0,50,clRed);



end;

procedure TForm4.FormClose(Sender: TObject; var CloseAction: TCloseAction);
begin
  Form1.ativarIluminacao:=False;
  phong:=False;
end;

procedure TForm4.FormCreate(Sender: TObject);
begin

  iav:=1;ilv:=1;kdv:=1;kav:=1;kv:=1;ksv:=1;nv:=1;
  Form1.pontoLuz[1]:=150;
  Form1.pontoLuz[2]:=0;
  Form1.pontoLuz[3]:=100;
  Form1.pontoLuz[4]:=1;


end;

procedure TForm4.FormShow(Sender: TObject);
begin
  Form1.inicializarZBuffer();
  Form1.ativarIluminacao:=True;
  Form4.phong:=True;
  Form1.desenharEsfera(150,150,0,50,clRed);
  Form1.desenharPlano(50,50,0,200,200,clGray);

end;

end.
