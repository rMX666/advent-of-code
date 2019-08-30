unit uTask_2017_19;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FMap: TArray<String>;
    FPath: String;
    FPathLength: Integer;
    procedure LoadMap;
    procedure TracePath;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  LoadMap;
  TracePath;
  OK(Format('Part 1: %s, Part 2: %d', [ FPath, FPathLength ]));
end;

procedure TTask_AoC.LoadMap;
var
  I: Integer;
begin
  with Input do
    try
      SetLength(FMap, Count);
      for I := 0 to Count - 1 do
        FMap[I] := Strings[I];
    finally
      Free;
    end;
end;

procedure TTask_AoC.TracePath;

  function GetNextDirection(const X, Y: Integer; const Dirs: String): Char;
  var
    I: Integer;
  begin
    Result := #0;

    for I := 1 to Dirs.Length do
      case Dirs[I] of
        'U':
          if Y - 1 >= 0 then
            if CharInSet(FMap[Y - 1][X], ['|', 'A'..'Z']) then
              Exit(Dirs[I]);
        'D':
          if Y + 1 < Length(FMap) then
            if CharInSet(FMap[Y + 1][X], ['|', 'A'..'Z']) then
              Exit(Dirs[I]);
        'L':
          if X - 1 > 0 then
            if CharInSet(FMap[Y][X - 1], ['-', 'A'..'Z']) then
              Exit(Dirs[I]);
        'R':
          if X + 1 <= FMap[Y].Length then
            if CharInSet(FMap[Y][X + 1], ['-', 'A'..'Z']) then
              Exit(Dirs[I]);
      end;
  end;

var
  X, Y: Integer;
  D: Char; // U D L R
begin
  FPath := '';
  FPathLength := 0;

  // We start at the upper edge directed down
  Y := 0;
  X := FMap[Y].IndexOf('|') + 1;
  D := 'D';

  //    Top-Bottom edge check            // Left-Right edge check              // Corect dir // Still on path
  while (Y >= 0) and (Y < Length(FMap)) and (X > 0) and (X <= FMap[Y].Length) and (D <> #0) and (FMap[Y][X] <> ' ') do
    begin
      case FMap[Y][X] of
        // Write down the path
        'A'..'Z':
          FPath := FPath + FMap[Y][X];
        // Decide turn
        '+':
          case D of
            'U', 'D': D := GetNextDirection(X, Y, 'LR');
            'L', 'R': D := GetNextDirection(X, Y, 'UD');
          end;
      end;

      // Simply walk in direction
      case D of
        'U': Dec(Y);
        'D': Inc(Y);
        'L': Dec(X);
        'R': Inc(X);
        #0: Break;
      end;

      Inc(FPathLength);
    end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 19, 'A Series of Tubes');

finalization
  GTask.Free;

end.
