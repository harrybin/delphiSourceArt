unit SampleUnit;

interface

uses
  System.SysUtils, System.Classes;

type
  // Eine einfache Beispiel-Klasse für die Visualisierung
  TPerson = class
  private
    FName: string;
    FAge: Integer;
    FEmail: string;
  public
    constructor Create(const AName: string; AAge: Integer);
    destructor Destroy; override;
    function GetInfo: string;
    procedure SetEmail(const AEmail: string);
    property Name: string read FName write FName;
    property Age: Integer read FAge write FAge;
    property Email: string read FEmail;
  end;

  // Eine komplexere Klasse mit mehr Methoden
  TDataProcessor = class
  private
    FData: TStringList;
    FProcessed: Boolean;
    function ValidateData: Boolean;
    procedure ClearCache;
  public
    constructor Create;
    destructor Destroy; override;
    procedure LoadData(const FileName: string);
    procedure ProcessData;
    function GetResult: string;
    procedure ExportToFile(const FileName: string);
    function CountItems: Integer;
    procedure AddItem(const Item: string);
    procedure RemoveItem(const Item: string);
    property Processed: Boolean read FProcessed;
  end;

  // Eine sehr komplexe Klasse für Visualisierung
  TComplexCalculator = class
  private
    FValue: Double;
    FHistory: TList<Double>;
    FPrecision: Integer;
    function InternalCalculate(const A, B: Double): Double;
    procedure LogOperation(const Operation: string);
    procedure UpdateHistory(const Value: Double);
    procedure ValidateResult(const Value: Double);
  public
    constructor Create;
    destructor Destroy; override;
    function Add(const A, B: Double): Double;
    function Subtract(const A, B: Double): Double;
    function Multiply(const A, B: Double): Double;
    function Divide(const A, B: Double): Double;
    function Power(const Base, Exponent: Double): Double;
    function SquareRoot(const Value: Double): Double;
    function Logarithm(const Value: Double): Double;
    function Sine(const Angle: Double): Double;
    function Cosine(const Angle: Double): Double;
    function Tangent(const Angle: Double): Double;
    procedure ClearHistory;
    function GetHistoryCount: Integer;
    function GetHistoryItem(Index: Integer): Double;
    property Value: Double read FValue write FValue;
    property Precision: Integer read FPrecision write FPrecision;
  end;

implementation

{ TPerson }

constructor TPerson.Create(const AName: string; AAge: Integer);
begin
  inherited Create;
  FName := AName;
  FAge := AAge;
  FEmail := '';
end;

destructor TPerson.Destroy;
begin
  inherited;
end;

function TPerson.GetInfo: string;
begin
  Result := Format('%s (%d)', [FName, FAge]);
end;

procedure TPerson.SetEmail(const AEmail: string);
begin
  FEmail := AEmail;
end;

{ TDataProcessor }

constructor TDataProcessor.Create;
begin
  inherited Create;
  FData := TStringList.Create;
  FProcessed := False;
end;

destructor TDataProcessor.Destroy;
begin
  FData.Free;
  inherited;
end;

function TDataProcessor.ValidateData: Boolean;
begin
  Result := FData.Count > 0;
end;

procedure TDataProcessor.ClearCache;
begin
  // Cache-Logik hier
end;

procedure TDataProcessor.LoadData(const FileName: string);
begin
  if FileExists(FileName) then
    FData.LoadFromFile(FileName);
end;

procedure TDataProcessor.ProcessData;
var
  i: Integer;
begin
  if ValidateData then
  begin
    for i := 0 to FData.Count - 1 do
    begin
      // Datenverarbeitung
    end;
    FProcessed := True;
  end;
end;

function TDataProcessor.GetResult: string;
begin
  if FProcessed then
    Result := FData.Text
  else
    Result := '';
end;

procedure TDataProcessor.ExportToFile(const FileName: string);
begin
  FData.SaveToFile(FileName);
end;

function TDataProcessor.CountItems: Integer;
begin
  Result := FData.Count;
end;

procedure TDataProcessor.AddItem(const Item: string);
begin
  FData.Add(Item);
end;

procedure TDataProcessor.RemoveItem(const Item: string);
var
  Index: Integer;
begin
  Index := FData.IndexOf(Item);
  if Index >= 0 then
    FData.Delete(Index);
end;

{ TComplexCalculator }

constructor TComplexCalculator.Create;
begin
  inherited Create;
  FHistory := TList<Double>.Create;
  FValue := 0;
  FPrecision := 2;
end;

destructor TComplexCalculator.Destroy;
begin
  FHistory.Free;
  inherited;
end;

function TComplexCalculator.InternalCalculate(const A, B: Double): Double;
begin
  Result := A + B;
  UpdateHistory(Result);
end;

procedure TComplexCalculator.LogOperation(const Operation: string);
begin
  // Logging-Logik
end;

procedure TComplexCalculator.UpdateHistory(const Value: Double);
begin
  FHistory.Add(Value);
  if FHistory.Count > 100 then
    FHistory.Delete(0);
end;

procedure TComplexCalculator.ValidateResult(const Value: Double);
begin
  if IsNan(Value) or IsInfinite(Value) then
    raise Exception.Create('Ungültiges Ergebnis');
end;

function TComplexCalculator.Add(const A, B: Double): Double;
begin
  Result := A + B;
  LogOperation('Add');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.Subtract(const A, B: Double): Double;
begin
  Result := A - B;
  LogOperation('Subtract');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.Multiply(const A, B: Double): Double;
begin
  Result := A * B;
  LogOperation('Multiply');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.Divide(const A, B: Double): Double;
begin
  if B = 0 then
    raise Exception.Create('Division durch Null');
  Result := A / B;
  LogOperation('Divide');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.Power(const Base, Exponent: Double): Double;
begin
  Result := System.Power(Base, Exponent);
  LogOperation('Power');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.SquareRoot(const Value: Double): Double;
begin
  if Value < 0 then
    raise Exception.Create('Negative Wurzel');
  Result := Sqrt(Value);
  LogOperation('SquareRoot');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.Logarithm(const Value: Double): Double;
begin
  if Value <= 0 then
    raise Exception.Create('Logarithmus von negativer Zahl');
  Result := Ln(Value);
  LogOperation('Logarithm');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.Sine(const Angle: Double): Double;
begin
  Result := Sin(Angle);
  LogOperation('Sine');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.Cosine(const Angle: Double): Double;
begin
  Result := Cos(Angle);
  LogOperation('Cosine');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

function TComplexCalculator.Tangent(const Angle: Double): Double;
begin
  Result := Tan(Angle);
  LogOperation('Tangent');
  UpdateHistory(Result);
  ValidateResult(Result);
end;

procedure TComplexCalculator.ClearHistory;
begin
  FHistory.Clear;
end;

function TComplexCalculator.GetHistoryCount: Integer;
begin
  Result := FHistory.Count;
end;

function TComplexCalculator.GetHistoryItem(Index: Integer): Double;
begin
  if (Index >= 0) and (Index < FHistory.Count) then
    Result := FHistory[Index]
  else
    Result := 0;
end;

end.
