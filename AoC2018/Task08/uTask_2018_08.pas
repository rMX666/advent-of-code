unit uTask_2018_08;

interface

uses
  System.Generics.Collections, uTask;

type
  TNode = class;
  TChildren = TObjectList<TNode>;
  TMetadata = TList<Integer>;

  TNode = class
    ChildCount, MetaCount: Integer;
    Children: TChildren;
    Metadata: TMetadata;
    constructor Create(const AChildCount, AMetaCount: Integer);
    destructor Destroy; override;
    function Checksum: Integer;
    function NodeValue: Integer;
  end;

  TTask_AoC = class (TTask)
  private
    FRoot: TNode;
    procedure LoadTree;
  protected
    procedure DoRun; override;
  end;

implementation

uses
  System.SysUtils;

var
  GTask: TTask_AoC;

{ TNode }

function TNode.Checksum: Integer;
var
  I: Integer;
begin
  Result := 0;

  for I := 0 to ChildCount - 1 do
    Inc(Result, Children[I].Checksum);

  for I := 0 to MetaCount - 1 do
    Inc(Result, Metadata[I]);
end;

constructor TNode.Create(const AChildCount, AMetaCount: Integer);
begin
  ChildCount := AChildCount;
  MetaCount := AMetaCount;
  Children := TChildren.Create;
  Metadata := TMetadata.Create;
end;

destructor TNode.Destroy;
begin
  Children.Free;
  Metadata.Free;
  inherited;
end;

function TNode.NodeValue: Integer;
var
  I: Integer;
begin
  Result := 0;

  if ChildCount > 0 then
    begin
      for I := 0 to MetaCount - 1 do
        if Metadata[I] > 0 then
          if Metadata[I] <= ChildCount then
            Inc(Result, Children[Metadata[I] - 1].NodeValue)
    end
  else
    for I := 0 to MetaCount - 1 do
      Inc(Result, Metadata[I]);
end;

{ TTask_AoC }

procedure TTask_AoC.DoRun;
begin
  try
    LoadTree;

    OK('Part 1: %d, Part 2: %d', [ FRoot.Checksum, FRoot.NodeValue ]);
  finally
    FRoot.Free;
  end;
end;

procedure TTask_AoC.LoadTree;
var
  I: Integer;
  Raw: TList<Integer>;
  A: TArray<String>;

  function GetNodeFromRaw: TNode;
  var
    I: Integer;
  begin
    Result := TNode.Create(Raw[0], Raw[1]);
    Raw.DeleteRange(0, 2);
    for I := 0 to Result.ChildCount - 1 do
      Result.Children.Add(GetNodeFromRaw);
    for I := 0 to Result.MetaCount - 1 do
      Result.Metadata.Add(Raw[I]);
    Raw.DeleteRange(0, Result.MetaCount);
  end;

begin
  Raw := TList<Integer>.Create;
  try
    with Input do
      try
        A := Text.Trim.Split([' ']);
        for I := 0 to Length(A) - 1 do
          Raw.Add(A[I].ToInteger);
      finally
        Free;
      end;

    FRoot := GetNodeFromRaw;
  finally
    Raw.Free;
  end;
end;

initialization
  GTask := TTask_AoC.Create(2018, 8, 'Memory Maneuver');

finalization
  GTask.Free;

end.
