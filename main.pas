unit EncTest;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, StdCtrls, Grids, Windows,
  ExtCtrls, lib, lazUTF8, LCLType;

type

  { TfEncTest }

  TfEncTest = class(TForm)
    bBack: TButton;
    bEnd: TButton;
    bEnter: TButton;
    bQ1: TButton;
    bQ2: TButton;
    bQ3: TButton;
    bQ4: TButton;
    bQ5: TButton;
    eAns: TEdit;
    eQuest: TEdit;
    Key1: TStringGrid;
    Key2: TStringGrid;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    lQNum: TLabel;
    Panel1: TPanel;
    procedure bBackClick(Sender: TObject);
    procedure testResult(Sender: TObject);
    procedure bEnterClick(Sender: TObject);
    procedure bQClick(Sender: TButton);
    procedure eAnsChange(Sender: TObject);
    procedure FormClose(Sender: TObject; var CloseAction: TCloseAction);
    procedure FormShow(Sender: TObject);
  private

  public

  end;

var
  fEncTest: TfEncTest;
  uAns: array[1..5] of string;  //Ответы пользователя
  rAns: array[1..5] of string;  //Правильные ответы
  Keys1: array[1..5] of string;  //Все Ключи 1
  Keys2: array[1..5] of string;  //Все Ключи 2
  sKey1, sKey2 :string;  //Ключи текущие
  cQNum: byte;

implementation

{$R *.lfm}

{ TfEncTest }

procedure TfEncTest.FormShow(Sender: TObject);  //Конструктор
var i: byte;
    maxWidth: integer;
    TempButton: LongInt;
begin
  TempButton:=GetWindowLong(bEnd.Handle, GWL_STYLE);  //Заголовок кнопки в две строки
  SetWindowLong(bEnd.Handle, GWL_STYLE, TempButton or BS_MULTILINE);

  lQNum.Caption := '1';

  bEnter.Enabled := false;
  bEnd.Enabled := false;
  maxWidth := 62;
  cQNum := 1;
  sKey1 := '';
  sKey2 := '';

  keygen(sKey1);
  SGFill(sKey1, 1, Key1);
  keygen(sKey2);
  SGFill(sKey2, 1, Key2);

  Keys1[1] := sKey1;
  Keys2[1] := sKey2;

  eQuest.Text := test[1];
  EncString(test[1], Keys1[1], Keys2[1], rAns[1]);

  for i := 1 to 5 do
    if UTF8Length(test[i]) > maxWidth then maxWidth := UTF8Length(test[i]);

  if maxWidth > 62 then
  begin
    eQuest.Anchors := [akLeft,akBottom];
    eAns.Anchors := [akLeft,akBottom];
    if(maxWidth * 14 + 16 <= 1900) then
    begin
      eQuest.Width := maxWidth * 14 - 16;
      eAns.Width := eQuest.Width;
      fEncTest.Width := eQuest.Width + 16;
    end
    else
    begin
      eQuest.Width := 1870;
      eAns.Width := eQuest.Width;
      fEncTest.Width := 1900;
    end;
  end;
  eQuest.Anchors := [akLeft,akRight,akBottom];
  eAns.Anchors := [akLeft,akRight,akBottom];
  fEncTest.Position := poDesktopCenter;
end;

procedure TfEncTest.bQClick(Sender: TButton);  //Выбор задания
var QNum: byte;  //Номер задания
begin
  QNum := StrToInt(Sender.caption[length(Sender.caption)]);
  if Keys1[QNum] = '' then
  begin
    keygen(sKey1);
    SGFill(sKey1, 1, Key1);
    keygen(sKey2);
    SGFill(sKey2, 1, Key2);

    Keys1[QNum] := sKey1;
    Keys2[QNum] := sKey2;
  end
  else
  begin
    SGFill(Keys1[QNum], 1, Key1);
    SGFill(Keys2[QNum], 1, Key2);
  end;
  lQNum.Caption := IntToStr(QNum);
  eAns.Clear;
  if uAns[QNum] <> '' then
  begin
    eAns.Text := uAns[QNum];
    bEnter.Enabled := false;
  end;
  eQuest.Text := test[QNum];
  EncString(test[QNum], Keys1[QNum], Keys2[QNum], rAns[QNum]);
  cQNum := QNum;

  eAns.SetFocus;
  //Label3.Caption := rAns[QNum]; //Ответы
end;

procedure TfEncTest.eAnsChange(Sender: TObject);  //Ввод ответа
begin
  if eAns.Text <> '' then
    bEnter.Enabled := true
  else
    bEnter.Enabled := false;

  if eAns.Text = uAns[cQNum] then
    bEnter.Enabled := false;
end;

procedure TfEncTest.testResult(Sender: TObject);  //Результаты
var i, j: byte;
    Err: array [1..5] of integer;
    uStr, rStr, result: string;
begin
  For i := 1 to 5 do
    Err[i] := 0;

  for i := 1 to 5 do
  begin
    if uAns[i] <> rAns[i] then
    begin
      uStr := uAns[i];
      rStr := rAns[i];

      if utf8length(uStr) < utf8length(rStr) then
      begin
        Err[i] := Err[i] + utf8length(rStr) - utf8length(uStr);
        for j := 1 to utf8length(uStr) do
          if UTF8Copy(uStr, j, 1) <> UTF8Copy(rStr, j, 1) then inc(Err[i]);
      end;

      if utf8length(uStr) > utf8length(rStr) then
      begin
        Err[i] := Err[i] + utf8length(uStr) - utf8length(rStr);
        for j := 1 to utf8length(rStr) do
          if UTF8Copy(uStr, j, 1) <> UTF8Copy(rStr, j, 1) then inc(Err[i]);
      end;

      if utf8length(uStr) = utf8length(rStr) then
        for j := 1 to utf8length(rStr) do
          if UTF8Copy(uStr, j, 1) <> UTF8Copy(rStr, j, 1) then inc(Err[i]);
    end;
  end;

  result := 'Результат выполнения контрольной работы по шифрованию: ' + #13#10;
  for i := 1 to 5 do
  begin
    if Err[i] = 0 then
    result := result + 'Задание ' + IntToStr(i) + ' - ВЕРНО (символов: ' + IntToStr(UTF8Length(Test[i])) +')'  + #13#10;
    if Err[i] <> 0 then
    begin
      result := result + 'Задание ' + intToStr(i) + ' - НЕВЕРНО' + #13#10;
      result := result + '-Всего символов в задании: ' + IntToStr(UTF8Length(Test[i])) + #13#10;
      result := result + '-Символов введено неверно: ' + IntToStr(Err[i]) + #13#10;
    end;
  end;
  if messageDlg('Результат', Result, mtInformation, [mbOk], 0) <> mrYes then close;
end;

procedure TfEncTest.bEnterClick(Sender: TObject); //Ответить
var i, n: byte;
begin
  n := 0;

  eAns.Text := UTF8UpperCase(eAns.Text);
  uAns[cQNum] := eAns.Text;

  for i := 1 to 5 do  //разблокировка завершения
    if uAns[i] <> '' then inc(n);
  if n = 5 then bEnd.Enabled := true;

  bEnter.Enabled := false;

  case cQNum of
    1: bQClick(bQ2);
    2: bQClick(bQ3);
    3: bQClick(bQ4);
    4: bQClick(bQ5);
  end;
end;

procedure TfEncTest.bBackClick(Sender: TObject);  //В меню
begin
  close
end;

procedure TfEncTest.FormClose(Sender: TObject; var CloseAction: TCloseAction);  //Деструктор
var i: byte;
begin
  for i := 1 to 5 do
  begin
    uAns[i] := '';
    rAns[i] := '';
    Keys1[i] := '';
    Keys2[i] := '';
  end;

  eAns.Clear;
end;

end.

