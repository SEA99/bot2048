unit linktoblue2048;

interface

uses windows,sysutils,graphics,classes,extlink,g2048types,botcommon,messages;


function StartBot:iBotCommon;

implementation

type tBotClass=class(tLinkToExtWindow,iBotCommon)
       deltax,deltay:integer;
       images:array[0..15] of array[0..3] of tBitmap;
       procedure init;override;
       function NeedSaveNewCell(x,y:integer;value:byte):boolean;
       function DiffColors(color1,color2:tColor):Boolean;override;
       function CellImageName(name:string;xIndex,Value:Integer):string;
       function FindCase(xIndex,ScreenX,Screeny:integer):byte;
       procedure ParseScreen(g:tGameField);
       function SuitableName(Name:string):boolean;override;
       procedure SaveNewCell(x,y:integer;value:byte);
       procedure SendAction(Action:t2048Action);
       function CheckNeedContinue:boolean;
     end;

{ tBotClass }

var shiftx:array[0..3] of integer=(553-534+8,674-534+8,796-534+8,917-534+8);
    shifty:array[0..3] of integer=(374-326,495-326,617-326,738-326);

function StartBot:iBotCommon;
var Bot:tBotClass;
begin
  Bot:=tBotClass.Create;
  Result:=Bot;
  Bot.Init;
end;

function tBotClass.CellImageName(name:string;xIndex, Value: Integer): string;
begin
  Result:=format('%simages\%s%s_%d.bmp',[ExtractFilePath(ParamStr(0)),name,values[value],xIndex]);
end;

function tBotClass.CheckNeedContinue: boolean;
begin
  Result:=False;
end;

function tBotClass.DiffColors(color1, color2: tColor): Boolean;
var Delta:integer;
begin
  delta:=abs(integer(color1 and $ff) - integer(color2 and $ff));
  color1:=color1 shr 8;
  color2:=color2 shr 8;
  delta:=delta+abs(integer(color1 and $ff) - integer(color2 and $ff));
  color1:=color1 shr 8;
  color2:=color2 shr 8;
  delta:=delta+abs(integer(color1 and $ff) - integer(color2 and $ff));
  Result:=delta>50;
end;

function tBotClass.FindCase(xIndex,ScreenX, Screeny: integer): byte;
var
    i:integer;
begin
  StartScreenWork;
  try
    Result:=ValueUnknown;
    for i:=0 to 14 do begin
      if images[i][xIndex]=nil then begin
        if FileExists(CellImageName('im',xIndex,i)) then begin
          images[i][xIndex]:=tBitmap.Create;
          images[i][xIndex].LoadFromFile(CellImageName('im',xIndex,i));
        end;
      end;
      if SameShapeOnScreen(images[i][xIndex],ScreenX,ScreenY) then begin
        Result:=i;
        exit;
      end;
    end;
  finally
    StopScreenWork;
  end;
end;

procedure tBotClass.init;
begin
  inherited;
  if not FindBMPFileOnScreen('angle2.bmp',deltax,deltay,rect(400,200,700,400)) then
    raise exception.Create('angle not found');
  deltay:=deltay+(318-267);
  CreateShadowBMP(rect(deltax,deltay,deltax+504,deltay+536));
end;                     

function tBotClass.NeedSaveNewCell(x, y: integer; value: byte): boolean;
begin
  Result:=(Value<ValueUnknown) and (images[Value][x]=nil) and not FileExists(CellImageName('im',x,Value));
end;

procedure tBotClass.ParseScreen(g:tGameField);
var WasUndefined:boolean;
    x,y:integer;
begin
  StartScreenWork;
  try
{    try
      SaveToFile(Bounds(deltax,deltay,800,800),'full.bmp');
    except
    end;}
    for y:=0 to 3 do
      for x:=0 to 3 do begin
        g.Data[y,x]:=FindCase(x,deltax+shiftx[x],deltay+shifty[y]);
        if g.Data[y,x]=ValueUnknown then
          SaveToFile(Bounds(deltax+shiftx[x],deltay+shifty[y],89,38),CellImageName('err',x,14));
      end;
  finally
    StopScreenWork;
  end;
end;

procedure tBotClass.SaveNewCell(x, y: integer; value: byte);
begin
  SaveToFile(Bounds(deltax+shiftx[x],deltay+shifty[y],89,38),CellImageName('im',x,value));
end;

procedure tBotClass.SendAction(Action: t2048Action);
begin
{  case Action of
  taUp:PostMessage(WinHandle,WM_CHAR,VK_UP,0);
  taDown:PostMessage(WinHandle,WM_CHAR,VK_DOWN,0);
  taLeft:PostMessage(WinHandle,WM_CHAR,VK_LEFT,0);
  taRight:PostMessage(WinHandle,WM_CHAR,VK_RIGHT,0);
  end;}
  case Action of
  taUp:PostMessage(WinHandle,WM_KEYDOWN,VK_UP,21495809);
  taDown:PostMessage(WinHandle,WM_KEYDOWN,VK_DOWN,22020097);
  taLeft:PostMessage(WinHandle,WM_KEYDOWN,VK_LEFT,21692417);
  taRight:PostMessage(WinHandle,WM_KEYDOWN,VK_RIGHT,21823489);
  end;
  sleep(800);
end;

function tBotClass.SuitableName(Name:string):boolean;
begin
  Result:=pos('2048 ',name)=1;
end;

end.
