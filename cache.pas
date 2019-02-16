unit cache;

interface

uses g2048types,syncobjs;

type
  tHashRecord=packed record
    CompressedData:int64;
    Estimation:Double;
    Level:Byte;
    BestAction:t2048Action;
    ForMyAction:Boolean;
    IsFilled:Boolean;
  end;
  tGameCache=class
    private
    Filled:Integer;
    HashTable:array of tHashRecord;
    cs:TCriticalSection;
    public
    constructor Create(HashSize:Integer);
    destructor destroy;override;
    procedure CompressGame(g: tGameField; AForMyAction: Boolean; var CompressedData: Int64; var HashValue:Integer);
    procedure Clear;
    procedure AddToHash(g:tGameField;ALevel:Byte;AForMyAction:Boolean;ABestAction:t2048Action;AEstimation:Double);
    function GetHash(g:tGameField;ALevel:Byte;AForMyAction:Boolean;var BestAction:t2048Action;var Estimation:Double):Boolean;
  end;
implementation

{ tGameCache }

procedure tGameCache.AddToHash(g: tGameField; ALevel: Byte;
  AForMyAction: Boolean; ABestAction: t2048Action; AEstimation: Double);
var CompressedData: Int64;
    HashValue:Integer;
begin
  cs.Enter;
  try
    CompressGame(g, AForMyAction, CompressedData, HashValue);
    if Filled>(length(HashTable)*7) div 8 then begin
      while HashTable[HashValue].IsFilled and (HashTable[HashValue].Level>=ALevel) do begin
        inc(HashValue);
        if HashValue>High(HashTable) then
          HashValue:=0;
      end;
      if not HashTable[HashValue].IsFilled then exit;
    end else begin
      while HashTable[HashValue].IsFilled and ((HashTable[HashValue].CompressedData<>CompressedData) or (HashTable[HashValue].ForMyAction<>AForMyAction)) do begin
        inc(HashValue);
        if HashValue>High(HashTable) then
          HashValue:=0;
      end;
      if not HashTable[HashValue].IsFilled then begin
        inc(Filled);
        HashTable[HashValue].IsFilled:=True;
      end;
    end;
    HashTable[HashValue].Level:=ALevel;
    HashTable[HashValue].CompressedData:=CompressedData;
    HashTable[HashValue].BestAction:=ABestAction;
    HashTable[HashValue].Estimation:=AEstimation;
  finally
    cs.Leave;
  end;
end;

procedure tGameCache.Clear;
var i:Integer;
begin
  cs.Enter;
  try
    for i:=0 to high(HashTable) do
      HashTable[i].IsFilled:=False;
    Filled:=0;
  finally
    cs.Leave;
  end;
end;

procedure tGameCache.CompressGame(g: tGameField; AForMyAction: Boolean; var CompressedData: Int64;
  var HashValue: Integer);
var
  data:record
    case integer of
    0:(long:int64);
    1:(c1,c2:cardinal);
    end;
  hv:Integer;
begin
  data.c1:=cardinal(g.EncodeLine(0,1,2,3)) shl 16 or g.EncodeLine(4,5,6,7);
  data.c2:=cardinal(g.EncodeLine(8,9,10,11)) shl 16 or g.EncodeLine(12,13,14,15);
  CompressedData:=data.long;
  randseed:=integer(data.c1);
  hv:=random(1000000000);
  if AForMyAction then
    hv:=hv+Random(100000000);
  randseed:=integer(data.c2);
  HashValue:=(hv+random(1000000000)) mod length(HashTable);
end;

constructor tGameCache.Create(HashSize: Integer);
begin
  SetLength(HashTable,HashSize);
  cs:=TCriticalSection.Create;
  Clear;
end;

destructor tGameCache.destroy;
begin
  cs.Free;
  inherited;
end;

function tGameCache.GetHash(g: tGameField; ALevel: Byte;
  AForMyAction: Boolean; var BestAction: t2048Action;
  var Estimation: Double): Boolean;
var CompressedData: Int64;
    HashValue:Integer;
begin
  cs.Enter;
  try
    CompressGame(g, AForMyAction, CompressedData, HashValue);
    while HashTable[HashValue].IsFilled and ((HashTable[HashValue].CompressedData<>CompressedData) or (HashTable[HashValue].ForMyAction<>AForMyAction)) do begin
      inc(HashValue);
      if HashValue>High(HashTable) then
        HashValue:=0;
    end;
    Result:=HashTable[HashValue].IsFilled and (HashTable[HashValue].Level>=ALevel);
    if not Result then exit;
    BestAction:=HashTable[HashValue].BestAction;
    Estimation:=HashTable[HashValue].Estimation;
  finally
    cs.Leave;
  end;
end;

end.
