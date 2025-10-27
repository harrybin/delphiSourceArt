unit MainForm;

interface

uses
  Winapi.Windows, Winapi.Messages, System.SysUtils, System.Variants, 
  System.Classes, System.Generics.Collections, Vcl.Graphics, Vcl.Controls, 
  Vcl.Forms, Vcl.Dialogs, Vcl.StdCtrls, Vcl.ExtCtrls;

type
  // Datenstruktur für Methoden-Metriken
  TMethodMetrics = record
    Name: string;
    LineCount: Integer;
    StartLine: Integer;
    EndLine: Integer;
  end;

  // Datenstruktur für Klassen-Metriken
  TClassMetrics = record
    Name: string;
    LineCount: Integer;
    StartLine: Integer;
    EndLine: Integer;
    Methods: TList<TMethodMetrics>;
  end;

  // Visualisierungselement für Animation
  TVisualElement = record
    ClassMetrics: TClassMetrics;
    X, Y: Integer;
    Radius: Integer;
    Color: TColor;
    Alpha: Byte;  // für Fade-In Effekt
    Visible: Boolean;
  end;

  TFormMain = class(TForm)
    btnAnalyze: TButton;
    OpenDialog: TOpenDialog;
    PaintBox: TPaintBox;
    Panel1: TPanel;
    Timer: TTimer;
    lblStatus: TLabel;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure btnAnalyzeClick(Sender: TObject);
    procedure PaintBoxPaint(Sender: TObject);
    procedure PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
    procedure TimerTimer(Sender: TObject);
  private
    FClasses: TList<TClassMetrics>;
    FVisualElements: TList<TVisualElement>;
    FAnimationStep: Integer;
    FUnitName: string;
    FHoverElement: Integer;
    FMouseX, FMouseY: Integer;
    
    procedure AnalyzeSourceFile(const FileName: string);
    procedure ParseDelphiUnit(Lines: TStringList);
    function ExtractClassName(const Line: string): string;
    function ExtractMethodName(const Line: string): string;
    function IsClassDeclaration(const Line: string): Boolean;
    function IsMethodDeclaration(const Line: string): Boolean;
    procedure PrepareVisualization;
    function GetColorForComplexity(LineCount: Integer): TColor;
    function FindElementAtPosition(X, Y: Integer): Integer;
  public
  end;

var
  FormMain: TFormMain;

implementation

{$R *.dfm}

uses
  System.Math, System.UITypes;

procedure TFormMain.FormCreate(Sender: TObject);
begin
  FClasses := TList<TClassMetrics>.Create;
  FVisualElements := TList<TVisualElement>.Create;
  FAnimationStep := 0;
  FHoverElement := -1;
  
  // OpenDialog konfigurieren
  OpenDialog.Filter := 'Delphi Units (*.pas)|*.pas|All Files (*.*)|*.*';
  OpenDialog.Title := 'Delphi Quelldatei auswählen';
  
  // Timer für Animation
  Timer.Interval := 50;  // 20 FPS
  Timer.Enabled := False;
  
  // PaintBox Einstellungen
  PaintBox.Align := alClient;
  PaintBox.Color := clBlack;
  
  lblStatus.Caption := 'Bereit - Bitte eine .pas-Datei auswählen';
end;

procedure TFormMain.FormDestroy(Sender: TObject);
var
  ClassMetrics: TClassMetrics;
begin
  // Speicher freigeben
  for ClassMetrics in FClasses do
    ClassMetrics.Methods.Free;
    
  FClasses.Free;
  FVisualElements.Free;
end;

procedure TFormMain.btnAnalyzeClick(Sender: TObject);
begin
  if OpenDialog.Execute then
  begin
    lblStatus.Caption := 'Analysiere ' + ExtractFileName(OpenDialog.FileName) + '...';
    Application.ProcessMessages;
    
    FUnitName := ChangeFileExt(ExtractFileName(OpenDialog.FileName), '');
    AnalyzeSourceFile(OpenDialog.FileName);
    PrepareVisualization;
    
    lblStatus.Caption := Format('%d Klassen gefunden - Animation läuft', [FClasses.Count]);
    
    // Animation starten
    FAnimationStep := 0;
    Timer.Enabled := True;
  end;
end;

procedure TFormMain.AnalyzeSourceFile(const FileName: string);
var
  Lines: TStringList;
begin
  Lines := TStringList.Create;
  try
    Lines.LoadFromFile(FileName);
    ParseDelphiUnit(Lines);
  finally
    Lines.Free;
  end;
end;

procedure TFormMain.ParseDelphiUnit(Lines: TStringList);
var
  i: Integer;
  Line, TrimmedLine: string;
  CurrentClass: TClassMetrics;
  CurrentMethod: TMethodMetrics;
  InClass: Boolean;
  InTypeSection: Boolean;
  ClassMetrics: TClassMetrics;
  ClassEndKeywords: Boolean;
begin
  // Vorherige Daten löschen
  for ClassMetrics in FClasses do
    ClassMetrics.Methods.Free;
  FClasses.Clear;
  
  InClass := False;
  InTypeSection := False;
  
  for i := 0 to Lines.Count - 1 do
  begin
    Line := Lines[i];
    TrimmedLine := Trim(Line);
    
    // Type-Sektion erkennen
    if (LowerCase(TrimmedLine) = 'type') then
    begin
      InTypeSection := True;
      Continue;
    end;
    
    // Ende der Type-Sektion
    if InTypeSection and ((LowerCase(TrimmedLine) = 'implementation') or 
                          (LowerCase(TrimmedLine) = 'var') or
                          (LowerCase(TrimmedLine) = 'const')) then
    begin
      if InClass then
      begin
        CurrentClass.EndLine := i - 1;
        CurrentClass.LineCount := CurrentClass.EndLine - CurrentClass.StartLine + 1;
        FClasses.Add(CurrentClass);
        InClass := False;
      end;
      InTypeSection := False;
      Continue;
    end;
    
    // Klassendeklaration erkennen (nur in Type-Sektion)
    if InTypeSection and IsClassDeclaration(TrimmedLine) then
    begin
      // Vorherige Klasse abschließen
      if InClass and (CurrentClass.Methods <> nil) then
      begin
        CurrentClass.EndLine := i - 1;
        CurrentClass.LineCount := CurrentClass.EndLine - CurrentClass.StartLine + 1;
        FClasses.Add(CurrentClass);
      end;
      
      CurrentClass.Name := ExtractClassName(TrimmedLine);
      CurrentClass.StartLine := i;
      CurrentClass.Methods := TList<TMethodMetrics>.Create;
      InClass := True;
    end;
    
    // Methodendeklaration erkennen (nur innerhalb einer Klasse)
    if InClass and IsMethodDeclaration(TrimmedLine) then
    begin
      CurrentMethod.Name := ExtractMethodName(TrimmedLine);
      CurrentMethod.StartLine := i;
      CurrentMethod.EndLine := i;
      CurrentMethod.LineCount := 1;
      CurrentClass.Methods.Add(CurrentMethod);
    end;
    
    // Ende der Klasse erkennen
    ClassEndKeywords := (TrimmedLine = 'end;') or 
                        (Pos('= class', LowerCase(TrimmedLine)) > 0);
    
    if InClass and (TrimmedLine = 'end;') then
    begin
      CurrentClass.EndLine := i;
      CurrentClass.LineCount := CurrentClass.EndLine - CurrentClass.StartLine + 1;
      FClasses.Add(CurrentClass);
      InClass := False;
    end;
  end;
  
  // Letzte Klasse hinzufügen, falls noch offen
  if InClass then
  begin
    CurrentClass.EndLine := Lines.Count - 1;
    CurrentClass.LineCount := CurrentClass.EndLine - CurrentClass.StartLine + 1;
    FClasses.Add(CurrentClass);
  end;
end;

function TFormMain.IsClassDeclaration(const Line: string): Boolean;
var
  TrimmedLine: string;
  LowerLine: string;
begin
  TrimmedLine := Trim(Line);
  LowerLine := LowerCase(TrimmedLine);
  
  // Erkennt "TClassName = class" oder "TClassName = class(TParent)"
  Result := (Pos('= class', LowerLine) > 0) or
            (Pos('= class(', LowerLine) > 0);
  
  // Ignoriere forward declarations und andere Keywords
  if Result then
  begin
    Result := (Pos('= class;', LowerLine) = 0) and
              (Pos('= class of', LowerLine) = 0);
  end;
end;

function TFormMain.IsMethodDeclaration(const Line: string): Boolean;
var
  LowerLine: string;
begin
  LowerLine := LowerCase(Trim(Line));
  Result := (Pos('procedure ', LowerLine) = 1) or
            (Pos('function ', LowerLine) = 1) or
            (Pos('constructor ', LowerLine) = 1) or
            (Pos('destructor ', LowerLine) = 1);
end;

function TFormMain.ExtractClassName(const Line: string): string;
var
  StartPos, EndPos: Integer;
  TrimmedLine: string;
begin
  TrimmedLine := Trim(Line);
  
  // Suche nach "= class"
  StartPos := Pos('=', TrimmedLine);
  if StartPos > 0 then
  begin
    Result := Trim(Copy(TrimmedLine, 1, StartPos - 1));
  end
  else
    Result := 'UnknownClass';
end;

function TFormMain.ExtractMethodName(const Line: string): string;
var
  StartPos, EndPos: Integer;
  TrimmedLine: string;
begin
  TrimmedLine := Trim(Line);
  
  // Überspringe Schlüsselwort
  StartPos := Pos(' ', TrimmedLine);
  if StartPos > 0 then
  begin
    TrimmedLine := Trim(Copy(TrimmedLine, StartPos + 1, Length(TrimmedLine)));
    
    // Finde Ende des Methodennamens
    EndPos := Pos('(', TrimmedLine);
    if EndPos = 0 then
      EndPos := Pos(':', TrimmedLine);
    if EndPos = 0 then
      EndPos := Pos(';', TrimmedLine);
      
    if EndPos > 0 then
      Result := Trim(Copy(TrimmedLine, 1, EndPos - 1))
    else
      Result := TrimmedLine;
  end
  else
    Result := 'UnknownMethod';
end;

procedure TFormMain.PrepareVisualization;
var
  i: Integer;
  ClassMetrics: TClassMetrics;
  VisElement: TVisualElement;
  CenterX, CenterY: Integer;
  Angle, Radius: Double;
  MaxRadius: Integer;
begin
  FVisualElements.Clear;
  
  if FClasses.Count = 0 then
    Exit;
    
  CenterX := PaintBox.Width div 2;
  CenterY := PaintBox.Height div 2;
  MaxRadius := Min(CenterX, CenterY) - 100;
  
  // Erstelle visuelle Elemente für jede Klasse (radiale Anordnung)
  for i := 0 to FClasses.Count - 1 do
  begin
    ClassMetrics := FClasses[i];
    
    Angle := (2 * Pi * i) / FClasses.Count;
    Radius := MaxRadius * 0.6;
    
    VisElement.ClassMetrics := ClassMetrics;
    VisElement.X := CenterX + Round(Radius * Cos(Angle));
    VisElement.Y := CenterY + Round(Radius * Sin(Angle));
    VisElement.Radius := 20 + (ClassMetrics.Methods.Count * 5);
    VisElement.Color := GetColorForComplexity(ClassMetrics.LineCount);
    VisElement.Alpha := 0;
    VisElement.Visible := False;
    
    FVisualElements.Add(VisElement);
  end;
end;

function TFormMain.GetColorForComplexity(LineCount: Integer): TColor;
begin
  // Farbcodierung basierend auf Komplexität
  if LineCount < 50 then
    Result := RGB(100, 200, 100)  // Grün - einfach
  else if LineCount < 100 then
    Result := RGB(200, 200, 100)  // Gelb - mittel
  else if LineCount < 200 then
    Result := RGB(200, 150, 100)  // Orange - komplex
  else
    Result := RGB(200, 100, 100); // Rot - sehr komplex
end;

procedure TFormMain.TimerTimer(Sender: TObject);
var
  i: Integer;
  VisElement: TVisualElement;
begin
  Inc(FAnimationStep);
  
  // Elemente nach und nach einblenden
  if FAnimationStep <= FVisualElements.Count * 2 then
  begin
    for i := 0 to FVisualElements.Count - 1 do
    begin
      if i * 2 < FAnimationStep then
      begin
        VisElement := FVisualElements[i];
        VisElement.Visible := True;
        if VisElement.Alpha < 255 then
          VisElement.Alpha := Min(255, VisElement.Alpha + 15);
        FVisualElements[i] := VisElement;
      end;
    end;
    PaintBox.Invalidate;
  end
  else
  begin
    // Animation beenden
    Timer.Enabled := False;
    lblStatus.Caption := Format('%d Klassen visualisiert - Bewegen Sie die Maus für Details', 
                                [FClasses.Count]);
  end;
end;

procedure TFormMain.PaintBoxPaint(Sender: TObject);
var
  i, j: Integer;
  VisElement: TVisualElement;
  CenterX, CenterY: Integer;
  MethodAngle: Double;
  MethodX, MethodY: Integer;
  OldBrushStyle: TBrushStyle;
  OldPenWidth: Integer;
begin
  with PaintBox.Canvas do
  begin
    // Hintergrund
    Brush.Color := clBlack;
    FillRect(PaintBox.ClientRect);
    
    if FVisualElements.Count = 0 then
    begin
      Font.Color := clWhite;
      Font.Size := 14;
      TextOut(20, 20, 'Keine Daten - Bitte eine .pas-Datei analysieren');
      Exit;
    end;
    
    CenterX := PaintBox.Width div 2;
    CenterY := PaintBox.Height div 2;
    
    // Zeichne Unit-Zentrum
    Brush.Color := RGB(150, 150, 200);
    Pen.Color := RGB(200, 200, 255);
    Pen.Width := 3;
    Ellipse(CenterX - 30, CenterY - 30, CenterX + 30, CenterY + 30);
    
    Font.Color := clWhite;
    Font.Size := 10;
    Font.Style := [fsBold];
    TextOut(CenterX - TextWidth(FUnitName) div 2, 
            CenterY - TextHeight(FUnitName) div 2, 
            FUnitName);
    
    // Zeichne Klassen
    for i := 0 to FVisualElements.Count - 1 do
    begin
      VisElement := FVisualElements[i];
      
      if not VisElement.Visible then
        Continue;
        
      // Verbindungslinie zum Zentrum
      Pen.Color := RGB(80, 80, 100);
      Pen.Width := 1;
      MoveTo(CenterX, CenterY);
      LineTo(VisElement.X, VisElement.Y);
      
      // Klassen-Kreis
      if i = FHoverElement then
      begin
        Pen.Color := RGB(255, 255, 255);
        Pen.Width := 3;
      end
      else
      begin
        Pen.Color := RGB(
          GetRValue(VisElement.Color) * VisElement.Alpha div 255,
          GetGValue(VisElement.Color) * VisElement.Alpha div 255,
          GetBValue(VisElement.Color) * VisElement.Alpha div 255
        );
        Pen.Width := 2;
      end;
      
      Brush.Color := VisElement.Color;
      Brush.Style := bsSolid;
      
      Ellipse(VisElement.X - VisElement.Radius,
              VisElement.Y - VisElement.Radius,
              VisElement.X + VisElement.Radius,
              VisElement.Y + VisElement.Radius);
      
      // Klassenname
      Font.Color := clWhite;
      Font.Size := 9;
      Font.Style := [];
      TextOut(VisElement.X - TextWidth(VisElement.ClassMetrics.Name) div 2,
              VisElement.Y + VisElement.Radius + 5,
              VisElement.ClassMetrics.Name);
      
      // Zeichne Methoden als kleinere Kreise um die Klasse
      if VisElement.ClassMetrics.Methods.Count > 0 then
      begin
        for j := 0 to VisElement.ClassMetrics.Methods.Count - 1 do
        begin
          MethodAngle := (2 * Pi * j) / VisElement.ClassMetrics.Methods.Count;
          MethodX := VisElement.X + Round((VisElement.Radius + 15) * Cos(MethodAngle));
          MethodY := VisElement.Y + Round((VisElement.Radius + 15) * Sin(MethodAngle));
          
          Brush.Color := RGB(150, 150, 200);
          Pen.Color := RGB(200, 200, 255);
          Pen.Width := 1;
          
          Ellipse(MethodX - 5, MethodY - 5, MethodX + 5, MethodY + 5);
        end;
      end;
    end;
    
    // Tooltip anzeigen
    if (FHoverElement >= 0) and (FHoverElement < FVisualElements.Count) then
    begin
      VisElement := FVisualElements[FHoverElement];
      
      // Tooltip-Hintergrund
      Brush.Color := RGB(40, 40, 60);
      Pen.Color := RGB(150, 150, 200);
      Pen.Width := 2;
      
      Font.Color := clWhite;
      Font.Size := 10;
      
      var TooltipX := FMouseX + 20;
      var TooltipY := FMouseY + 20;
      var TooltipW := 250;
      var TooltipH := 80;
      
      Rectangle(TooltipX, TooltipY, TooltipX + TooltipW, TooltipY + TooltipH);
      
      // Tooltip-Text
      TextOut(TooltipX + 10, TooltipY + 10, 
              'Klasse: ' + VisElement.ClassMetrics.Name);
      TextOut(TooltipX + 10, TooltipY + 30, 
              Format('Zeilen: %d', [VisElement.ClassMetrics.LineCount]));
      TextOut(TooltipX + 10, TooltipY + 50, 
              Format('Methoden: %d', [VisElement.ClassMetrics.Methods.Count]));
    end;
  end;
end;

procedure TFormMain.PaintBoxMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
var
  NewHoverElement: Integer;
begin
  FMouseX := X;
  FMouseY := Y;
  
  NewHoverElement := FindElementAtPosition(X, Y);
  
  if NewHoverElement <> FHoverElement then
  begin
    FHoverElement := NewHoverElement;
    PaintBox.Invalidate;
  end;
end;

function TFormMain.FindElementAtPosition(X, Y: Integer): Integer;
var
  i: Integer;
  VisElement: TVisualElement;
  Distance: Double;
begin
  Result := -1;
  
  for i := 0 to FVisualElements.Count - 1 do
  begin
    VisElement := FVisualElements[i];
    
    if not VisElement.Visible then
      Continue;
      
    Distance := Sqrt(Sqr(X - VisElement.X) + Sqr(Y - VisElement.Y));
    
    if Distance <= VisElement.Radius then
    begin
      Result := i;
      Break;
    end;
  end;
end;

end.
