unit g2048types;

interface

const ValueUnknown=16;
type
  tGameFieldData=array[0..15] of byte;
  t2048Action=(taUp,taDown,taLeft,taRight);
  tGameField=class
  private
    function GetData(row, col: integer): byte;
    procedure SetData(row, col: integer; const Value: byte);
    public
      RawData:tGameFieldData;
      function EncodeLine(x,x1,x2,x3:integer):word;
      procedure DecodeLine(x,x1,x2,x3:integer;value:word);
      function Shift(x0,x0step,shift:integer):boolean;
      function IntShiftLine(x,x1,x2,x3:integer):Boolean;
      function ShiftLine(x,shift:integer):Boolean;
      function DoAction(Action:t2048Action):boolean;
      procedure FillRandom;
      function UndefinedExists:boolean;
      procedure Assign(otherField:tGameField);
      property Data[row,col:integer]:byte read GetData write SetData;
  end;
var
  values:array[0..16] of string=('','2','4','8','16','32','64','128','256','512',
    '1024','2048','4096','8192','16383','32766','?');
  Prop4:double=1/10;

implementation

var AllShifts:array[0..65535] of word;

{ tGameField }

procedure tGameField.Assign(otherField: tGameField);
begin
  RawData:=OtherField.RawData;
end;

procedure tGameField.FillRandom;
var nEmpty:integer;
    AllEmpty:array[0..15] of byte;
    i:integer;
    ToSet:byte;
begin
  nEmpty:=0;
  for i:=0 to 15 do
    if RawData[i]=0 then begin
      AllEmpty[nEmpty]:=i;
      inc(nEmpty);
    end;
  if nEmpty=0 then exit;
  if Random<Prop4 then
    ToSet:=2
  else
    ToSet:=1;
  if nEmpty=1 then
    RawData[AllEmpty[0]]:=ToSet
  else
    RawData[AllEmpty[Random(nEmpty)]]:=ToSet;
end;

function tGameField.GetData(row, col: integer): byte;
begin
  Result:=RawData[row*4+col];
end;

function tGameField.Shift(x0, x0step, shift: integer):boolean;
begin
  Result:=ShiftLine(x0,shift);
  inc(x0,x0step);
  if ShiftLine(x0,shift) then
    Result:=True;
  inc(x0,x0step);
  if ShiftLine(x0,shift) then
    Result:=True;
  inc(x0,x0step);
  if ShiftLine(x0,shift) then
    Result:=True;
end;

function tGameField.ShiftLine(x, shift: integer):Boolean;
var x1,x2,x3:integer;
    v1,v2:integer;
begin
  Result:=False;
  x1:=x+shift;
  x2:=x1+shift;
  x3:=x2+shift;
  v1:=EncodeLine(x,x1,x2,x3);
  v2:=AllShifts[v1];
  Result:=v1<>v2;
  DecodeLine(x,x1,x2,x3,v2);
//  Result:=IntShiftLine(x,x1,x2,x3);
end;

procedure tGameField.SetData(row, col: integer; const Value: byte);
begin
  RawData[row*4+col]:=Value;
end;

function tGameField.DoAction(Action: t2048Action): boolean;
begin
  case Action of
  taUp:Result:=shift(0,1,4);
  taDown:Result:=shift(12,1,-4);
  taLeft:Result:=shift(0,4,1);
  taRight:Result:=shift(3,4,-1);
  end;
end;

procedure tGameField.DecodeLine(x, x1, x2, x3: integer; value: word);
begin
  RawData[x]:=value and $f;
  value:=value shr 4;
  RawData[x1]:=value and $f;
  value:=value shr 4;
  RawData[x2]:=value and $f;
  RawData[x3]:=value shr 4;
end;

function tGameField.EncodeLine(x, x1, x2, x3: integer): word;
begin
  Result:=RawData[x]+RawData[x1] shl 4+RawData[x2] shl 8+RawData[x3] shl 12;
end;

function tGameField.IntShiftLine(x, x1, x2, x3: integer): Boolean;
begin
  if RawData[x]=0 then begin
    RawData[x]:=RawData[x1];
    RawData[x1]:=RawData[x2];
    RawData[x2]:=RawData[x3];
    RawData[x3]:=0;
    if RawData[x]=0 then begin
      RawData[x]:=RawData[x1];
      RawData[x1]:=RawData[x2];
      RawData[x2]:=0;
      if RawData[x]=0 then begin
        RawData[x]:=RawData[x1];
        RawData[x1]:=0;
        if RawData[x]=0 then exit;
      end;
    end;
    Result:=True;
  end;
  if RawData[x1]=0 then begin
    RawData[x1]:=RawData[x2];
    RawData[x2]:=RawData[x3];
    RawData[x3]:=0;
    if RawData[x1]=0 then begin
      RawData[x1]:=RawData[x2];
      RawData[x2]:=0;
      if RawData[x1]=0 then exit;
    end;
    Result:=True;
  end;
  if RawData[x2]=0 then begin
    RawData[x2]:=RawData[x3];
    if RawData[x2]<>0 then
      Result:=True;
    RawData[x3]:=0;
  end;
  if RawData[x]=RawData[x1] then begin
    inc(RawData[x]);
    Result:=True;
    if (RawData[x2]=RawData[x3]) and (RawData[x2]<>0) then begin
      RawData[x1]:=RawData[x2]+1;
      RawData[x2]:=0;
    end else begin
      RawData[x1]:=RawData[x2];
      RawData[x2]:=RawData[x3];
    end;
    RawData[x3]:=0;
  end else begin
    if (RawData[x1]=RawData[x2]) and (RawData[x1]<>0) then begin
      inc(RawData[x1]);
      Result:=True;
      RawData[x2]:=RawData[x3];
      RawData[x3]:=0;
    end else
    if (RawData[x2]=RawData[x3]) and (RawData[x2]<>0) then begin
      Result:=True;
      inc(RawData[x2]);
      RawData[x3]:=0;
    end;
  end;
end;

procedure FillAllShifts;
var GF:tGameField;
    i:integer;
begin
  GF:=tGameField.Create;
  for i:=0 to high(AllShifts) do begin
    GF.DecodeLine(0,1,2,3,i);
    GF.IntShiftLine(0,1,2,3);
    AllShifts[i]:=GF.EncodeLine(0,1,2,3);
  end;
  GF.Free;
end;

function tGameField.UndefinedExists: boolean;
var i:integer;
begin
  for i:=0 to high(RawData) do
    if RawData[i]=ValueUnknown then begin
      Result:=True;
      exit;
    end;
  Result:=False;
end;

initialization
  FillAllShifts;
end.
