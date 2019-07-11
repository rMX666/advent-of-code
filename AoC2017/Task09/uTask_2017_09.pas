unit uTask_2017_09;

interface

uses
  uTask;

type
  TTask_AoC = class (TTask)
  private
    FGroupsScore: Integer;
    FGarbageChars: Integer;
    procedure ProcessStream(const S: String);
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.Generics.Collections, System.SysUtils, System.Math;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  with Input do
    try
      ProcessStream(Text.Trim);
    finally
      Free;
    end;

  OK(Format('Part 1: %d, Part 2: %d', [ FGroupsScore, FGarbageChars ]));
end;

procedure TTask_AoC.ProcessStream(const S: String);
type
  TState = ( stNone, stGarbage, stGroup );
  TStateStack = TStack<TState>;
var
  I, CurrentScore: Integer;
  Stack: TStateStack;
begin
  I := 1;
  CurrentScore := 0;
  Stack := TStateStack.Create;
  Stack.Push(stNone);
  FGroupsScore := 0;
  FGarbageChars := 0;

  try
    while I <= S.Length do
      begin
        case Stack.Peek of
          stNone:
            case S[I] of
              '!': Inc(I);
              '<': Stack.Push(stGarbage);
              '{':
                begin
                  Stack.Push(stGroup);
                  Inc(CurrentScore);
                  Inc(FGroupsScore, CurrentScore);
                end;
            end;
          stGarbage:
            case S[I] of
              '!': Inc(I);
              '>': Stack.Pop;
              else Inc(FGarbageChars);
            end;
          stGroup:
            case S[I] of
              '!': Inc(I);
              '<': Stack.Push(stGarbage);
              '{':
                begin
                  Stack.Push(stGroup);
                  Inc(CurrentScore);
                  Inc(FGroupsScore, CurrentScore);
                end;
              '}':
                begin
                  Stack.Pop;
                  Dec(CurrentScore);
                end;
            end;
        end;
        Inc(I);
      end;
  finally
    Stack.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2017, 9, 'Stream Processing');

finalization
  GTask.Free;

end.
