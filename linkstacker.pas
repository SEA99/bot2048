unit linkstacker;

interface

uses windows,sysutils,graphics,classes,extlink,g2048types,botcommon,messages;


function StartStackerBot:iBotCommon;

implementation

type tBotClass=class(tLinkToExtWindow,iBotCommon)
       deltax,deltay:integer;
       images:array[0..15] of tBitmap;
       procedure init;override;
       function NeedSaveNewCell(x,y:integer;value:byte):boolean;
       function DiffColors(color1,color2:tColor):Boolean;override;
       function CellImageName(name:string;Value:Integer):string;
       function FindCase(xIndex,ScreenX,Screeny:integer):byte;
       procedure ParseScreen(g:tGameField);
       function SuitableName(Name:string):boolean;override;
       procedure SaveNewCell(x,y:integer;value:byte);
       procedure SendAction(Action:t2048Action);
       function CheckNeedContinue:boolean;
     end;

{ tBotClass }

var shiftx:array[0..3] of integer=(450-441,571-441,692-441,813-441);
    shifty:array[0..3] of integer=(275-170,396-170,517-170,638-170);

function StartStackerBot:iBotCommon;
var Bot:tBotClass;
begin
  Bot:=tBotClass.Create;
  Result:=Bot;
  Bot.Init;
end;

function tBotClass.CellImageName(name:string;Value: Integer): string;
begin
  Result:=format('%sstimages\%s%s.bmp',[ExtractFilePath(ParamStr(0)),name,values[value]]);
end;

function tBotClass.CheckNeedContinue: boolean;
var x,y:integer;
    p:tPoint;
begin
  Result:= FindBMPFileOnScreen('st_imtocontuinue.bmp',x,y,rect(400,400,700,700));
  if Result then begin
    p.X:=x;
    p.Y:=y;
    Mapwindowpoints(WinHandle,0,p,1);
    ScreenToClient(WinHandle,p);
    PostMessage(WinHandle,WM_LBUTTONDOWN,MK_LBUTTON,p.x or (p.y shl 16));
  end;
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
    for i:=0 to 15 do begin
      if images[i]=nil then begin
        if FileExists(CellImageName('im',i)) then begin
          images[i]:=tBitmap.Create;
          images[i].LoadFromFile(CellImageName('im',i));
        end;
      end;
      if SameShapeOnScreen(images[i],ScreenX,ScreenY) then begin
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
  if not FindBMPFileOnScreen('anglest.bmp',deltax,deltay,rect(300,100,600,500)) then
    raise exception.Create('angle not found');
  CreateShadowBMP(rect(deltax,deltay+100,deltax+500,deltay+600));
end;                     

function tBotClass.NeedSaveNewCell(x, y: integer; value: byte): boolean;
begin
  Result:=(Value<ValueUnknown) and (images[Value]=nil) and not FileExists(CellImageName('im',Value));
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
          SaveToFile(Bounds(deltax+shiftx[x],deltay+shifty[y],84,38),CellImageName('err',14));
      end;
  finally
    StopScreenWork;
  end;
end;

procedure tBotClass.SaveNewCell(x, y: integer; value: byte);
begin
  SaveToFile(Bounds(deltax+shiftx[x],deltay+shifty[y],84,38),CellImageName('im',value));
end;

procedure tBotClass.SendAction(Action: t2048Action);
begin
{  case Action of
  taUp:PostMessage(WinHandle,WM_CHAR,VK_UP,0);
  taDown:PostMessage(WinHandle,WM_CHAR,VK_DOWN,0);
  taLeft:PostMessage(WinHandle,WM_CHAR,VK_LEFT,0);
  taRight:PostMessage(WinHandle,WM_CHAR,VK_RIGHT,0);
  end;}
  mouse_Event(MOUSEEVENTF_MOVE,1,1,0,0);
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
  Result:=pos('2048+ ',name)=1;
end;

end.
