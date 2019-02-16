unit extlink;

interface

uses windows,sysutils,graphics,classes;

type
  tLinkToExtWindow=class(tInterfacedObject)
  private
    ShadowRect:tRect;
    ShadowBMP:tBitmap;
  protected
    WinHandle:tHandle;
    ExtCanvas:tCanvas;
    ScreenWorkCounter:integer;
    procedure SaveRange(x,y:integer);
    function SuitableName(Name:string):boolean;virtual;abstract;
    procedure GetFromScreen(bmp: tBitmap;deltax,deltay:integer);
    function DiffColors(color1,color2:tColor):Boolean;virtual;
    function SameShapeOnCanvas(bmp: tBitmap;canvas:tCanvas;deltax,deltay:integer):boolean;
    function SameBMPOnCanvas(bmp: tBitmap;canvas:tCanvas;deltax,deltay:integer):boolean;
    function SameShapeOnScreen(bmp: tBitmap;deltax,deltay:integer):boolean;
    function FindBMPOnCanvas(bmp: tBitmap;canvas:tCanvas;var deltax,deltay:integer;RectToFind:tRect):boolean;
    function FindBMPOnScreen(bmp: tBitmap;var deltax,deltay:integer;RectToFind:tRect):boolean;
    function FindBMPFileOnScreen(fn:string;var deltax,deltay:integer;RectToFind:tRect):boolean;
    procedure SaveToFile(Rect:tRect;fn:string);
    procedure CreateShadowBMP(Rect:tRect);
    procedure StartScreenWork;
    procedure StopScreenWork;
  public
    constructor create;
    destructor destroy;override;
    procedure Init;virtual;
  end;

implementation

uses Types;

{ tLinkToExtWindow }

constructor tLinkToExtWindow.create;
begin
  ExtCanvas:=tCanvas.Create;
end;

destructor tLinkToExtWindow.destroy;
begin
  ExtCanvas.Free;
  inherited;
end;

function EnumFunc(h:tHandle;Param:tLinkToExtWindow):BOOL;stdcall;
var namebuf:array[0..1024] of char;
begin
  Result:=True;
  GetWindowText(h,@NameBuf,sizeof(namebuf)-1);
  if Param.SuitableName(namebuf) then begin
    Param.WinHandle:=h;
    Result:=False;
  end;
end;

procedure tLinkToExtWindow.SaveRange(x,y:integer);
var tmp:tBitmap;
begin
    tmp:=tBitmap.create;
    tmp.Width:=21;
    tmp.height:=21;
    tmp.canvas.CopyRect(rect(0,0,21,21),ExtCanvas,rect(x-10,y-10,x+10,y+10));
    tmp.savetofile('zr.bmp');
    tmp.free;
end;

procedure tLinkToExtWindow.GetFromScreen(bmp: tBitmap;deltax,deltay:integer);
begin
  StartScreenWork;
  try
      bmp.canvas.CopyRect(rect(0,0,bmp.Width+1,bmp.Height+1),ExtCanvas,
                                  rect(deltax,deltay,bmp.Width+1+deltax,bmp.Height+1+deltay));
  finally
    StopScreenWork;
  end;
end;

procedure tLinkToExtWindow.Init;
begin
  WinHandle:=0;
  EnumWindows(@EnumFunc,integer(self));
  if WinHandle=0 then
    raise exception.Create('Window not found')
end;

function tLinkToExtWindow.FindBMPOnScreen(bmp: tBitmap; var deltax,
  deltay: integer;RectToFind:tRect): boolean;
var
    tmp:tBitmap;
    tmpdeltax,
    tmpdeltay: integer;
begin
  StartScreenWork;
  try
    if (ShadowBMP<>nil) and (ShadowRect.Left<=RectToFind.Left) and
                            (ShadowRect.Top<=RectToFind.Top) and
                            (ShadowRect.Right>=RectToFind.Right) and
                            (ShadowRect.Bottom>=RectToFind.Bottom) then begin
      OffsetRect(RectToFind,-ShadowRect.Left,-ShadowRect.Top);
      Result:=FindBMPOnCanvas(bmp,ShadowBMP.canvas,tmpdeltax,tmpdeltay,RectToFind);
      if Result then begin
        Deltax:=tmpDeltax+ShadowRect.Left;
        DeltaY:=TmpDeltaY+ShadowRect.Top;
      end;
    end else begin
      tmp:=tBitmap.Create;
      try
        tmp.Height:=RectToFind.Bottom-RectToFind.Top;
        tmp.Width:=RectToFind.Right-RectToFind.Left;
        tmp.canvas.CopyRect(rect(0,0,tmp.Width,tmp.Height),ExtCanvas,
                                  RectToFind);
  //          Result:=FindBMPOnCanvas(bmp,ExtCanvas,deltax,deltay,RectToFind);
        Result:=FindBMPOnCanvas(bmp,tmp.canvas,tmpdeltax,tmpdeltay,rect(0,0,tmp.Width,tmp.Height));
        if Result then begin
          Deltax:=tmpDeltax+RectToFind.Left;
          DeltaY:=TmpDeltaY+RectToFind.Top;
        end;
      finally
        tmp.Free;
      end;
  end;
  finally
    StopScreenWork;
  end;
end;

function tLinkToExtWindow.FindBMPFileOnScreen(fn: string; var deltax: integer;
  var deltay: integer; RectToFind: tRect): boolean;
var bmp:tBitmap;
begin
  bmp:=tBitmap.Create;
  try
    bmp.LoadFromFile(fn);
    Result:=FindBMPOnScreen(bmp,deltax,deltay,RectToFind);
  finally
    bmp.Free;
  end;
end;

function tLinkToExtWindow.FindBMPOnCanvas(bmp: tBitmap; canvas: tCanvas;
  var deltax, deltay: integer; RectToFind: tRect): boolean;
begin
        Result:=False;
        deltay:=0;
        while deltay<=RectToFind.Bottom-bmp.Height do begin
          deltax:=0;
          while deltax<=RectToFind.Right-bmp.Width do begin
            if SameShapeOnCanvas(bmp,Canvas,deltax,deltay) then begin
              Result:=True;
              exit;
            end;
            inc(Deltax);
          end;
          inc(deltay);
        end;
end;

function tLinkToExtWindow.SameShapeOnCanvas(bmp: tBitmap; canvas: tCanvas;
  deltax, deltay: integer): boolean;
var
    i,j:integer;
begin
        Result:=True;
        for i:=0 to bmp.width-1 do
          for j:=0 to bmp.height-1 do
            if DiffColors(Canvas.Pixels[deltax+i,deltay+j],bmp.Canvas.Pixels[i,j]) then begin
              Result:=False;
              exit;
            end;
end;

function tLinkToExtWindow.SameBMPOnCanvas(bmp: tBitmap; canvas: tCanvas;
  deltax, deltay: integer): boolean;
var
    i,j:integer;
begin
        Result:=True;
        for i:=0 to bmp.width-1 do
          for j:=0 to bmp.height-1 do
            if Canvas.Pixels[deltax+i,deltay+j]<>bmp.Canvas.Pixels[i,j] then begin
              Result:=False;
              exit;
            end;
end;

procedure tLinkToExtWindow.StartScreenWork;
var h:tHandle;
begin
  if ScreenWorkCounter=0 then begin
    h:=GetDCEx(WinHandle,0,DCX_LOCKWINDOWUPDATE or DCX_WINDOW	{or DCX_CACHE});
    if h=0 then
      raise exception.Createfmt('GetDC error %d',[GetLastError]);
    ExtCanvas.Handle:=h;
    if ShadowBMP<>nil then
      ShadowBMP.canvas.CopyRect(rect(0,0,ShadowBMP.Width,ShadowBMP.Height),ExtCanvas,
                                ShadowRect);
  end;
  inc(ScreenWorkCounter);
end;

procedure tLinkToExtWindow.StopScreenWork;
begin
  dec(ScreenWorkCounter);
  if ScreenWorkCounter=0 then begin
    ReleaseDC(WinHandle,ExtCanvas.Handle);
    ExtCanvas.Handle:=0;
  end;
end;

function tLinkToExtWindow.SameShapeOnScreen(bmp: tBitmap; deltax,
  deltay: integer): boolean;
begin
  if bmp=nil then begin
    Result:=False;
    exit;
  end;
  StartScreenWork;
  try
    if (ShadowBMP<>nil) and (ShadowRect.Left<=deltax) and
                            (ShadowRect.Top<=deltay) and
                            (ShadowRect.Right>=deltax+bmp.width) and
                            (ShadowRect.Bottom>=deltay+bmp.Height) then
      Result:=SameShapeOnCanvas(bmp,ShadowBMP.Canvas,deltax-ShadowRect.Left,deltay-ShadowRect.Top)
    else
      Result:=SameShapeOnCanvas(bmp,ExtCanvas,deltax,deltay);
  finally
    StopScreenWork;
  end;
end;

procedure tLinkToExtWindow.CreateShadowBMP(Rect: tRect);
begin
  ShadowRect:=Rect;
  if (Rect.Left=Rect.Right) or (Rect.Top=Rect.Bottom) then
    ShadowBMP.Free
  else begin
    if ShadowBMP=nil then
      ShadowBMP:=tBitmap.Create;
    ShadowBMP.Width:=rect.Right-rect.Left;
    ShadowBMP.Height:=rect.Bottom-rect.Top;
  end;
end;

function tLinkToExtWindow.DiffColors(color1, color2: tColor): Boolean;
begin
  Result:=color1<>color2;
end;

procedure tLinkToExtWindow.SaveToFile(Rect: tRect; fn: string);
var image:tBitmap;
begin
  StartScreenWork;
  try
    image:=tBitmap.Create;
    try
      image.Width:=rect.Right-rect.Left;
      image.Height:=rect.Bottom-rect.Top;
      GetFromScreen(image,rect.Left,rect.Top);
      image.SaveToFile(fn);
    finally
      image.Free;
    end;
  finally
    StopScreenWork;
  end;
end;

end.
