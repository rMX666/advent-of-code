unit uTask_2018_02;

interface

uses
  System.Generics.Collections, uTask;

type
  TTask_AoC = class (TTask)
  private
    FIDs: TList<String>;
    procedure LoadIDs;
    function GetCheckSum: Integer;
    function GetBoxID: String;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadIDs;

    OK(Format('Part 1: %d, Part 2: %s', [ GetCheckSum, GetBoxID ]));
  finally
    FIDs.Free;
  end;
end;

function TTask_AoC.GetBoxID: String;

  function HasOneDiff(const S1, S2: String; out Pos: Integer): Boolean;
  var
    I: Integer;
  begin
    Result := False;

    for I := 1 to S1.Length do
      if not Result and (S1[I] <> S2[I]) then
        begin
          Result := True;
          Pos := I;
        end
      else if Result and (S1[I] <> S2[I]) then
        begin
          Exit(False);
          Pos := -1;
        end;
  end;

var
  I, J, DiffPos: Integer;
begin
  for I := 0 to FIDs.Count - 1 do
    for J := 0 to FIDs.Count - 1 do
      if HasOneDiff(FIDs[I], FIDs[J], DiffPos) then
        Exit(FIDs[I].Remove(DiffPos - 1, 1));
end;

function TTask_AoC.GetCheckSum: Integer;

  function GetCounts(const S: String; const Num: Integer): Integer;
  var
    A: Array [ 'a'..'z' ] of Integer;
    I: Integer;
    C: Char;
  begin
    FillChar(A, SizeOf(A), 0);

    for I := 1 to S.Length do
      Inc(A[S[I]]);

    for C := 'a' to 'z' do
      if A[C] = Num then
        Exit(1);

    Result := 0;
  end;

var
  I, Count2, Count3: Integer;
begin
  Count2 := 0;
  Count3 := 0;

  for I := 0 to FIDs.Count - 1 do
    begin
      Inc(Count2, GetCounts(FIDs[I], 2));
      Inc(Count3, GetCounts(FIDs[I], 3));
    end;

  Result := Count2 * Count3;
end;

procedure TTask_AoC.LoadIDs;
begin
  with Input do
    try
      FIDs := TList<String>.Create;
      FIDs.AddRange(ToStringArray);
    finally
      Free;
    end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 2, 'Inventory Management System');

finalization
  GTask.Free;

end.
