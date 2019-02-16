unit fmmain;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, Grids, g2048types, StdCtrls, Buttons, typinfo,strat,botcommon;

type
  TForm1 = class(TForm)
    Grid: TDrawGrid;
    BitBtn1: TSpeedButton;
    BitBtn2: TSpeedButton;
    BitBtn3: TSpeedButton;
    BitBtn4: TSpeedButton;
    CheckRandom: TCheckBox;
    BitBtn5: TSpeedButton;
    Button1: TSpeedButton;
    SpeedButton1: TSpeedButton;
    Label1: TLabel;
    SpeedButton2: TSpeedButton;
    SpeedButton3: TSpeedButton;
    SpeedButton4: TSpeedButton;
    SpeedButton5: TSpeedButton;
    procedure GridDrawCell(Sender: TObject; ACol, ARow: Integer;
      Rect: TRect; State: TGridDrawState);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure BitBtn3Click(Sender: TObject);
    procedure BitBtn4Click(Sender: TObject);
    procedure BitBtn2Click(Sender: TObject);
    procedure BitBtn1Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure GridMouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure BitBtn5Click(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure SpeedButton2Click(Sender: TObject);
    procedure SpeedButton3Click(Sender: TObject);
    procedure SpeedButton4Click(Sender: TObject);
    procedure SpeedButton5Click(Sender: TObject);
    procedure CheckRandomClick(Sender: TObject);
  private
    fGameField,GameParsed:tGameField;
    val2count,val4count:integer;
    bot:iBotCommon;

    procedure SetGameField(const Value: tGameField);
    { Private declarations }
    procedure kd(var m:tMessage);message WM_KEYDOWN;
  public
    NextAction:t2048Action;
    { Public declarations }
    property GameField:tGameField read fGameField write SetGameField;
  end;

var
  Form1: TForm1;

implementation

uses linktoblue2048,linkstacker,linkofficial;

{$R *.dfm}

procedure TForm1.GridDrawCell(Sender: TObject; ACol, ARow: Integer;
  Rect: TRect; State: TGridDrawState);
begin
  try
  grid.Canvas.Brush.Color:=clWindow;
  grid.Canvas.Font.color:=clWindowText;
  grid.Canvas.FillRect(Rect);
  grid.Canvas.TextOut(Rect.Left+5,Rect.Top+2,values[GameField.Data[arow,acol]]);
  except
  end;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  FreeAndNil(Grid);
end;

procedure TForm1.SetGameField(const Value: tGameField);
begin
  fGameField := Value;
  grid.Invalidate;
end;

procedure TForm1.BitBtn3Click(Sender: TObject);
begin
  if GameField.DoAction(taUp) then begin
    if CheckRandom.Checked then
      GameField.FillRandom;
    grid.Invalidate;
    Button1.Caption:='';
  end;
end;

procedure TForm1.BitBtn4Click(Sender: TObject);
begin
  if GameField.DoAction(taDown) then begin
    if CheckRandom.Checked then
      GameField.FillRandom;
    grid.Invalidate;
    Button1.Caption:='';
  end;
end;

procedure TForm1.BitBtn2Click(Sender: TObject);
begin
  if GameField.DoAction(taRight) then begin
    if CheckRandom.Checked then
      GameField.FillRandom;
    grid.Invalidate;
    Button1.Caption:='';
  end;
end;

procedure TForm1.BitBtn1Click(Sender: TObject);
begin
  if GameField.DoAction(taLeft) then begin
    if CheckRandom.Checked then
      GameField.FillRandom;
    grid.Invalidate;
    Button1.Caption:='';
  end;
end;

procedure TForm1.FormCreate(Sender: TObject);
begin
  fGameField:=tGameField.Create;
end;

procedure TForm1.GridMouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
var c:TGridCoord;
begin
  c:=Grid.MouseCoord(X, Y);
  case fGameField.Data[c.Y,c.X] of
  0: begin
       fGameField.Data[c.Y,c.X]:=1;
       inc(val2count);
     end;
  1:begin
       fGameField.Data[c.Y,c.X]:=2;
       dec(val2count);
       inc(val4count);
    end;
  2:begin
       fGameField.Data[c.Y,c.X]:=3;
       dec(val4count);
    end;
  3..13:fGameField.Data[c.Y,c.X]:=fGameField.Data[c.Y,c.X]+1;
  14,15,16:fGameField.Data[c.Y,c.X]:=0;
  end;
  Grid.Invalidate;
  if val2count+val4count>0 then
    Label1.Caption:=formatfloat('0.######',val4count/(val2count+val4count));
  if not fGameField.UndefinedExists then
    BitBtn5Click(nil);
end;

procedure TForm1.BitBtn5Click(Sender: TObject);
var
    res:double;
    n:integer;
begin
  NextAction:=BestAction(fGameField,res,n,10);
  Button1.caption:=inttostr(n)+':'+GetEnumName(TypeInfo(t2048Action),ord(NextAction))+' '+FormatFloat('######.##',res);
end;

procedure TForm1.Button1Click(Sender: TObject);
var NextGameField:tGameField;
    x,y:integer;
    tries:integer;
begin
  if GameField.DoAction(NextAction) then begin
    if bot<>nil then begin
      sleep(2000);
      NextGameField:=tGameField.Create;
      try
        tries:=0;
        repeat
          NextGameField.Assign(GameField);
          bot.SendAction(NextAction);
          Application.ProcessMessages;
          repeat
            bot.ParseScreen(GameParsed);
            GameField.Assign(GameParsed);
            if fGameField.UndefinedExists then begin
              sleep(500);
              bot.ParseScreen(GameParsed);
              GameField.Assign(GameParsed);
            end;
            grid.Invalidate;
            if fGameField.UndefinedExists then begin
              for x:=0 to 3 do
                for y:=0 to 3 do
                  if (GameParsed.Data[y,x]=ValueUnknown) and bot.NeedSaveNewCell(x,y,NextGameField.Data[y,x]) then begin
                    bot.SaveNewCell(x,y,NextGameField.Data[y,x]);
                    GameField.Data[y,x]:=NextGameField.Data[y,x];
                  end;
            end;
            inc(tries);
          until not fGameField.UndefinedExists or bot.CheckNeedContinue or (tries>1);
          if fGameField.UndefinedExists then break;
          BitBtn5Click(nil);
        until not GameField.DoAction(NextAction);
      finally
        NextGameField.Free;
      end;
    end else begin
      if CheckRandom.Checked then
        GameField.FillRandom;
      grid.Invalidate;
      BitBtn5Click(nil);
    end;
  end;
end;

procedure TForm1.SpeedButton2Click(Sender: TObject);
begin
  if bot<>nil then exit;
  bot:=linktoblue2048.StartBot;
  if GameParsed=nil then
    GameParsed:=tGameField.Create;
  SpeedButton2.Enabled:=False;
  SpeedButton3.Enabled:=True;
  bot.ParseScreen(GameParsed);
  GameField.Assign(GameParsed);
  grid.Invalidate;
  if not fGameField.UndefinedExists then
    BitBtn5Click(nil);
end;

procedure TForm1.SpeedButton3Click(Sender: TObject);
var x,y:integer;
begin
  if bot=nil then exit;
  for x:=0 to 3 do
    for y:=0 to 3 do
      if (GameParsed.Data[y,x]=ValueUnknown) and (GameField.Data[y,x]<>ValueUnknown) then
        bot.SaveNewCell(x,y,GameField.Data[y,x]);
end;

procedure TForm1.kd(var m: tMessage);
begin
  m.WParam:=m.WParam+1;
end;

procedure TForm1.SpeedButton4Click(Sender: TObject);
begin
  if bot<>nil then exit;
  bot:=linkstacker.StartStackerBot;
  if GameParsed=nil then
    GameParsed:=tGameField.Create;
  SpeedButton2.Enabled:=False;
  SpeedButton3.Enabled:=True;
  bot.ParseScreen(GameParsed);
  GameField.Assign(GameParsed);
  grid.Invalidate;
  if not fGameField.UndefinedExists then
    BitBtn5Click(nil);
end;

procedure TForm1.SpeedButton5Click(Sender: TObject);
begin
  if bot<>nil then exit;
  bot:=linkofficial.StartOfficial;
  if GameParsed=nil then
    GameParsed:=tGameField.Create;
  SpeedButton2.Enabled:=False;
  SpeedButton3.Enabled:=True;
  bot.ParseScreen(GameParsed);
  GameField.Assign(GameParsed);
  grid.Invalidate;
  if not fGameField.UndefinedExists then
    BitBtn5Click(nil);
end;

procedure TForm1.CheckRandomClick(Sender: TObject);
begin
  if CheckRandom.Checked then begin
    GameField.FillRandom;
    grid.Invalidate;
  end;
end;

end.
