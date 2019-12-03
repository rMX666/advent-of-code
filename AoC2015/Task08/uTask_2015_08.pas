unit uTask_2015_08;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    function EscapeString(const S: String): String;
    function CalculateEscapes(const S: String): Integer;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

function TTask_AoC.CalculateEscapes(const S: String): Integer;
var
  I, L: Integer;
begin
  I := 1;
  L := S.Length;
  Result := 0;

  while I < L do
    begin
      case S[I] of
        '"':
          begin
            Inc(I);
            Continue;
          end;
        '\':
          begin
            Inc(I);
            case S[I] of
              'x': Inc(I, 2);
            end;
          end;
      end;

      Inc(I);
      Inc(Result);
    end;

  Result := S.Length - Result;
end;

procedure TTask_AoC.DoRun;
var
  I: Integer;
  Part1, Part2: Integer;
begin
  Part1 := 0;
  Part2 := 0;

  with Input do
    try
      for I := 0 to Count - 1 do
        Inc(Part1, CalculateEscapes(Strings[I]));

      OK('Part 1: %d', [ Part1 ]);

      for I := 0 to Count - 1 do
        Inc(Part2, CalculateEscapes(EscapeString(Strings[I])));

      OK('Part 2: %d', [ Part2 ]);
    finally
      Free;
    end;
end;

function TTask_AoC.EscapeString(const S: String): String;
var
  I: Integer;
begin
  Result := '';

  for I := 1 to S.Length do
    case S[I] of
      '"', '\': Result := Result + '\' + S[I];
      else      Result := Result + S[I];
    end;

  Result := '"' + Result + '"';
end;

initialization
  GTask := TTask_AoC.Create(2015, 8, 'Matchsticks');

finalization
  GTask.Free;

end.
