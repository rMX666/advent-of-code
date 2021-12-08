unit uTask_2020_18;

interface

uses
  System.Classes, uTask;

type
  TTask_AoC = class (TTask)
  private
    FExamples: TStrings;
    function Eval(S: String; const Part: Integer = 1): Int64;
    function EvalAll(const Part: Integer): Int64;
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
  try
    FExamples := Input;
    Ok('Part 1: %d', [ EvalAll(1), EvalAll(2) ]);
  finally
    FExamples.Free;
  end;
end;

function TTask_AoC.Eval(S: String; const Part: Integer): Int64;
type
  TLastOp = ( loNone, loAdd, loMult );

  function SkipUntilBracket(const Index: Integer; const S: String): Integer;
  var
    I, BC: Integer;
  begin
    BC := 0;
    Result := -1;
    for I := Index to S.Length do
      begin
        if      S[I] = '(' then Inc(BC)
        else if S[I] = ')' then Dec(BC);
        if BC = 0 then
          Exit(I);
      end;
  end;

var
  I, Tmp: Integer;
  LastOp: TLastOp;
begin
  // Remove spaces as they're irrelevant
  S := S.Replace(' ', '');

  // HACK: Include additions into brackets so that
  //       they evaluate before miltiplications
  if Part = 2 then
    begin
      I := 1;
      while I <= S.Length - 2 do
        begin
          // Num + Num
          if CharInSet(S[I], ['0'..'9']) and (S[I + 1] = '+') and CharInSet(S[I + 2], ['0'..'9']) then
            begin
              S := S.Insert(I - 1, '(').Insert(I + 3, ')');
              Inc(I, 4);
            end
          else if S[I] = '(' then
            begin
              Tmp := SkipUntilBracket(I, S);
              if S[Tmp + 1] = '+' then
                begin
                  S := S.Insert(I - 1, '(').Insert(Tmp + 3, ')');
                  Inc(I);
                end;
            end
          else if CharInSet(S[I], ['0'..'9']) and (S[I + 1] = '+') and (S[I + 2] = '(') then
            begin
              Tmp := SkipUntilBracket(I + 2, S);
              S := S.Insert(I - 1, '(').Insert(Tmp + 1, ')');
              Inc(I);
            end;

          Inc(I);
        end;
    end;

  I := 1;
  Result := 0;
  LastOp := loNone;
  while I <= S.Length do
    begin
      case S[I] of
        '(': // Skip until corresponding ')' and run Eval on this part
          begin
            Tmp := SkipUntilBracket(I, S);
            case LastOp of
              loNone: Result :=          Eval(S.Substring(I, Tmp - I - 1));
              loAdd:  Result := Result + Eval(S.Substring(I, Tmp - I - 1));
              loMult: Result := Result * Eval(S.Substring(I, Tmp - I - 1));
            end;
            I := Tmp;
          end;
        '0'..'9':
          case LastOp of
            loNone: Result := String(S[I]).ToInt64;
            loAdd:  Result := Result + String(S[I]).ToInt64;
            loMult: Result := Result * String(S[I]).ToInt64;
          end;
        '+': LastOp := loAdd;
        '*': LastOp := loMult;
      end;
      Inc(I);
    end;
end;

function TTask_AoC.EvalAll(const Part: Integer): Int64;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FExamples.Count - 1 do
    Inc(Result, Eval(FExamples[I], Part));
end;

initialization
  GTask := TTask_AoC.Create(2020, 18, 'Operation Order');

finalization
  GTask.Free;

end.
