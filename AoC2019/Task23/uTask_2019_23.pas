unit uTask_2019_23;

interface

uses
  uTask, IntCode, System.Generics.Collections;

type
  TTask_AoC = class (TTask)
  private
    FInitialState: TIntCode;
    procedure LoadProgram;
    function RunNetwork(const WithNAT: Boolean): Int64;
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
  LoadProgram;
  try
    OK('Part 1: %d, Part 2: %d', [ RunNetwork(False), RunNetwork(True) ]);
  finally
    FInitialState.Free;
  end;
end;

procedure TTask_AoC.LoadProgram;
begin
  with Input do
    try
      FInitialState := TIntCode.Create(Text);
    finally
      Free;
    end;
end;

function TTask_AoC.RunNetwork(const WithNAT: Boolean): Int64;
var
  Net: TObjectList<TIntCode>;
  I, J: Integer;
  NatX, NatY, NatCnt: Int64;
  IsIdle: Boolean;
begin
  Net := TObjectList<TIntCode>.Create;
  NatX := 0;
  NatY := 0;
  NatCnt := -1;

  try
    // Initialize network
    for I := 0 to 49 do
      begin
        Net.Add(TIntCode.Create(FInitialState));
        Net.Last.AddInput(I);
      end;

    while True do
      begin
        IsIdle := True;
        for I := 0 to Net.Count - 1 do
          with Net[I] do
            begin
              if Execute = erWaitForInput then
                AddInput(-1);
              if Output.Count > 0 then
                begin
                  IsIdle := False;
                  J := 0;
                  while J < Output.Count do
                    begin
                      // Address can be either 255 - NAT, or 0..49 - any computer in the Net
                      if Output[J] = 255 then
                        begin
                          if WithNAT then
                            begin
                              // Remember last packet sent to NAT
                              NatX := Output[J + 1];
                              NatY := Output[J + 2];
                              // Reset NAT packet counter
                              NatCnt := 0;
                            end
                          else
                            Exit(Output[J + 2]);
                        end
                      else
                        begin
                          Net[Output[J]].AddInput(Output[J + 1]);
                          Net[Output[J]].AddInput(Output[J + 2]);
                        end;
                      Inc(J, 3);
                    end;
                  Output.Clear;
                end;
            end;
        if WithNAT and IsIdle and (NatCnt > -1) then
          begin
            // Send NAT packet to 0 address
            Net.First.AddInput(NatX);
            Net.First.AddInput(NatY);
            Inc(NatCnt);
            if NatCnt > 1 then
              Exit(NatY);
          end;
      end;
  finally
    Net.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2019, 23, 'Category Six');

finalization
  GTask.Free;

end.
