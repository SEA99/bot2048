unit botcommon;

interface

uses g2048types,extlink;

type iBotCommon=interface
       procedure ParseScreen(g:tGameField);
       function NeedSaveNewCell(x,y:integer;value:byte):boolean;
       procedure SaveNewCell(x,y:integer;value:byte);
       procedure SendAction(Action:t2048Action);
       function CheckNeedContinue:boolean;
     end;


implementation

end.
