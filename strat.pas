unit strat;

interface

uses windows,g2048types;

function BestAction(GameField:tGameField;var res:double;var n:integer;MaxLevel:Integer=10):t2048Action;
var TimeLimit:DWord=100;

implementation

uses cache;

var LineValues1,LineValues2,LineValues3,LineValues4:array[0..65535] of integer;
    GameCache:tGameCache;
const
    Empty1Coef=1;
    LossResult=-100000;

const MaxLevel=50;
type
  tCalc=class
    LevelFields:Array[0..MaxLevel] of tGameField;
    constructor Create;
    destructor Destroy;override;
  private
    function EstimateAllRandom(n, Level: Integer): double;
    function EstimatePosition(g: tGameField): double;
    procedure FindBestAction(n, Level: integer;
      var res: double;var action: t2048Action);
    procedure FreeLevelFields;
    procedure InitLevelFields;
  end;

var MainCalc:tCalc;

function tCalc.EstimatePosition(g:tGameField):double;
var l1,l2,l3,l4,l5,l6,l7,l8,v1:integer;
begin
  l1:=g.EncodeLine(0,1,2,3);
  l2:=g.EncodeLine(4,5,6,7);
  l3:=g.EncodeLine(8,9,10,11);
  l4:=g.EncodeLine(12,13,14,15);
  l5:=g.EncodeLine(0,4,8,12);
  l6:=g.EncodeLine(1,5,9,13);
  l7:=g.EncodeLine(2,6,10,14);
  l8:=g.EncodeLine(3,7,11,15);
  v1:=LineValues1[l1]+
      LineValues1[l2]+
      LineValues1[l3]+
      LineValues1[l4]+
      LineValues1[l5]+
      LineValues1[l6]+
      LineValues1[l7]+
      LineValues1[l8];
  if v1<=Empty1Coef*2 then
    Result:=-1000
  else begin
    if v1>Empty1Coef*3 then
      v1:=Empty1Coef*3 div 2+v1 div 2;
    Result:=(v1+
      LineValues2[l1]+
      LineValues3[l2]+
      LineValues3[l3]+
      LineValues2[l4]+
      LineValues2[l5]+
      LineValues3[l6]+
      LineValues3[l7]+
      LineValues2[l8]+
      LineValues4[g.EncodeLine(0,3,15,12)])/10;
    if v1<=Empty1Coef*2 then
      Result:=Result-70
    else
      if Result<-20 then
        Result:=-20+(Result+20)*2
  end;
end;

procedure tCalc.FindBestAction(n, Level: integer;
      var res: double;var action: t2048Action);
var i:integer;
    tmpRes:double;
begin
  if (n>0) then begin
    if GameCache.GetHash(LevelFields[Level],n,True,action,Res) then exit;
  end;
  res:=LossResult;
  for i:=0 to 3 do begin
    LevelFields[Level+1].Assign(LevelFields[Level]);
    if LevelFields[Level+1].DoAction(t2048Action(i)) then begin
      if n>0 then
        tmpRes:=EstimateAllRandom(n-1,Level+1)
      else
        tmpRes:=EstimatePosition(LevelFields[Level+1]);
      if tmpRes>res then begin
        action:=t2048Action(i);
        res:=tmpRes;
      end;
    end;
  end;
  if (n>0) then
    GameCache.AddToHash(LevelFields[Level],n,True,action,Res);
end;

function tCalc.EstimateAllRandom(n:integer;Level:Integer):double;
var nEmpty:integer;
    i:integer;
    res:double;
    action:t2048Action;
begin
  if GameCache.GetHash(LevelFields[Level],n,False,action,Result) then exit;
  nEmpty:=0;
  for i:=0 to high(LevelFields[Level].RawData) do
    if LevelFields[Level].RawData[i]=0 then
      inc(nEmpty);
  if nEmpty=0 then begin
    Result:=LossResult;
    exit;
  end;
  Result:=0;
  for i:=0 to high(LevelFields[Level].RawData) do
    if LevelFields[Level].RawData[i]=0 then begin
      LevelFields[Level+1].Assign(LevelFields[Level]);
      LevelFields[Level+1].RawData[i]:=1;
      FindBestAction(n,Level+1,res,action);
      if (n<=1) and (nEmpty<5) or (nEmpty<4) then begin
        Result:=Result+res*(1-Prop4)/nEmpty;
        LevelFields[Level+1].Assign(LevelFields[Level]);
        LevelFields[Level+1].RawData[i]:=2;
        FindBestAction(n,Level+1,res,action);
        Result:=Result+res*Prop4/nEmpty;
      end else
        Result:=Result+res/nEmpty;
    end;
  GameCache.AddToHash(LevelFields[Level],n,False,action,Result);
end;

function BestAction(GameField:tGameField;var res:double;var n:integer;MaxLevel:Integer=10):t2048Action;
var
    StartDT,dt:DWord;
begin
  n:=1;
  Result:=taUp;
  GameCache.Clear;
  repeat
    StartDT:=GetTickCount;
    MainCalc.LevelFields[0].Assign(GameField);
    MainCalc.FindBestAction(n,0,res,Result);
    dt:=GetTickCount-StartDT;
    if (dt>TimeLimit*30) or
       (dt>TimeLimit*10) and (Res>-5) or
       (dt>TimeLimit*3) and (Res>-3) or
       (dt>TimeLimit) and (Res>-1) then break;
    inc(n);
  until n>MaxLevel;
end;

procedure tCalc.InitLevelFields;
var i:integer;
begin
  for i:=0 to MaxLevel do
    LevelFields[i]:=tGameField.Create;
end;
procedure tCalc.FreeLevelFields;
var i:integer;
begin
  for i:=0 to MaxLevel do
    LevelFields[i].Free;
end;
constructor tCalc.Create;
begin
  InitLevelFields;
end;

destructor tCalc.Destroy;
begin
  inherited;
  FreeLevelFields;
end;

function Estimate1(v,v1,v2,v3:byte):integer;
begin
  Result:=(ord(v=0)+ord(v1=0)+ord(v2=0)+ord(v3=0))*Empty1Coef;
end;

function Delta(v1,v2:integer):integer;
begin
  if (v1=v2) then begin
    if v1>4 then
      Result:=(v1-4)*2
    else
      Result:=0;
  end else begin
    if (v1=0) or (v2=0) then
      Result:=-(abs(v1-v2)-1) div 2
    else begin
      Result:=-abs(v1-v2)+1;
    end;
    if Result>0 then
      Result:=0
  end;
end;
function Delta3(v1,v2:Integer):integer;
begin
  Result:=Delta(v1,v2);
  if Result<0 then
    Result:=-round(sqrt(-2*Result));
end;

function CellValue(v:integer):integer;
begin
  case v of
  0:Result:=1;
  4..15:Result:=-(v-3);
  else
  Result:=0;
  end;
end;
function BaseValue(v,v1,v2,v3:integer):integer;
begin
  Result:=CellValue(v)+
          CellValue(v1)+
          CellValue(v2)+
          CellValue(v3);
  if (v1=0) and (v>3) then begin
    if (v=v2) then
      Result:=Result+(v-3);
    if (v2=0) and (v=v3) then
      Result:=Result+(v-4);
  end;
  if (v2=0) and (v1>3) and (v1=v3) then
    Result:=Result+(v1-3);
end;
function Estimate2(v,v1,v2,v3:integer):integer;
var ar:array[0..3] of integer;
    i,bestind,best2:integer;
begin
  if (v2<5) and (v3<5) and (v>v1) and (v1<8) or
     (v<5) and (v1<5) and (v2>v3) and (v2<8) then
    Result:=Delta3(v,v1)+Delta3(v1,v2)+Delta3(v2,v3)
  else
    Result:=Delta(v,v1)+Delta(v1,v2)+Delta(v2,v3);
  Result:=Result+BaseValue(v,v1,v2,v3);
  ar[0]:=v;
  ar[1]:=v1;
  ar[2]:=v2;
  ar[3]:=v3;
  bestind:=0;
  for i:=1 to 3 do
    if ar[i]>ar[bestind] then
      bestind:=i;
  if (bestind in [1,2]) then begin
    if ar[bestind]>5 then
      Result:=Result-ar[bestind]+5;
  end else begin
    best2:=1;
    for i:=0 to 3 do
      if (i<>bestind) and (ar[i]>ar[best2]) then
        best2:=i;
    if ar[best2]>5 then
      Result:=Result-ar[best2]+5;
  end;
  if v>7 then
    Result:=Result+(v-7);
  if v3>7 then
    Result:=Result+(v3-7);
  Result:=Result+5;
end;
function Estimate3(v,v1,v2,v3:integer):integer;
begin
  Result:=Delta3(v,v1)+Delta3(v1,v2)+Delta3(v2,v3)+BaseValue(v,v1,v2,v3);
  if v1>4 then
    Result:=Result-(v1-4);
  if v1>6 then
    Result:=Result-(v1-6);
  if v2>4 then
    Result:=Result-(v2-4);
  if v2>6 then
    Result:=Result-(v2-6);
  Result:=Result+10;
end;
function Estimate4(v,v1,v2,v3:integer):integer;
begin
  Result:=0;
  if v+v2>14 then
    Result:=Result-5*(v+v2-14);
  if v1+v3>14 then
    Result:=Result-5*(v1+v3-14);
end;
procedure FillLineValues;
var GF:tGameField;
    i:integer;
begin
  GF:=tGameField.Create;
  for i:=0 to high(LineValues1) do begin
    GF.DecodeLine(0,1,2,3,i);
    LineValues2[i]:=Estimate2(GF.RawData[0],GF.RawData[1],GF.RawData[2],GF.RawData[3]);
    LineValues3[i]:=Estimate3(GF.RawData[0],GF.RawData[1],GF.RawData[2],GF.RawData[3]);
    LineValues4[i]:=Estimate4(GF.RawData[0],GF.RawData[1],GF.RawData[2],GF.RawData[3]);
    if GF.IntShiftLine(0,1,2,3) then
      GF.IntShiftLine(0,1,2,3);
    LineValues1[i]:=Estimate1(GF.RawData[0],GF.RawData[1],GF.RawData[2],GF.RawData[3]);
  end;
  GF.Free;
end;


initialization
  MainCalc:=tCalc.Create;
  GameCache:=tGameCache.Create(10000000);
  FillLineValues;
finalization
  MainCalc.Free;
  GameCache.Free;
end.
