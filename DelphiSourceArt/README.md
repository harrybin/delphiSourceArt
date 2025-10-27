# DelphiSourceArt

**Vom Quellcode zum Kunstwerk**

Eine innovative Delphi VCL-Anwendung, die Delphi-Quelldateien (.pas) analysiert und als dynamisches, interaktives Kunstwerk visualisiert. Die Applikation erstellt in Echtzeit eine visuelle Struktur, die die Komplexität und internen Abhängigkeiten des Codes widerspiegelt.

## 🎨 Konzept

DelphiSourceArt transformiert unsichtbare Code-Strukturen in eine "Code-Galaxie":
- **Jede Klasse** wird als geometrische Form visualisiert
- **Methoden und Prozeduren** erscheinen als kleinere Elemente innerhalb der Klassen
- **Größe, Position und Farbe** korrelieren mit Metriken wie Zeilenzahl und Methodenanzahl
- **Radiale Anordnung** um das Unit-Zentrum herum

## ✨ Features

### Analyse-Engine
- Parst Delphi-Units (.pas-Dateien)
- Erkennt Klassen-Deklarationen automatisch
- Identifiziert Methoden (procedure, function, constructor, destructor)
- Sammelt Metriken: Zeilenzahl, Methodenanzahl, Code-Komplexität

### Visualisierung
- **Dynamische Code-Galaxie**: Zentrale Unit mit radialer Klassen-Anordnung
- **Farbcodierung nach Komplexität**:
  - 🟢 Grün: < 50 Zeilen (einfach)
  - 🟡 Gelb: 50-100 Zeilen (mittel)
  - 🟠 Orange: 100-200 Zeilen (komplex)
  - 🔴 Rot: > 200 Zeilen (sehr komplex)
- **Methoden-Visualisierung**: Kleinere Kreise um jede Klasse herum

### Interaktivität
- **Animation**: Schrittweiser Aufbau mit Fade-In-Effekt (TTimer-basiert)
- **Interaktive Tooltips**: Hover über Klassen zeigt Details an
  - Klassenname
  - Zeilenzahl
  - Anzahl der Methoden
- **Echtzeit-Feedback**: Statusleiste zeigt Analyseprozess

## 🏗️ Architektur

### Datenstrukturen
```delphi
TMethodMetrics = record
  Name: string;
  LineCount: Integer;
  StartLine: Integer;
  EndLine: Integer;
end;

TClassMetrics = record
  Name: string;
  LineCount: Integer;
  StartLine: Integer;
  EndLine: Integer;
  Methods: TList<TMethodMetrics>;
end;

TVisualElement = record
  ClassMetrics: TClassMetrics;
  X, Y: Integer;
  Radius: Integer;
  Color: TColor;
  Alpha: Byte;  // für Fade-In Effekt
  Visible: Boolean;
end;
```

### Komponenten
- **TButton**: Dateiauswahl-Dialog öffnen
- **TOpenDialog**: .pas-Datei auswählen
- **TPaintBox**: Dynamische Zeichenfläche für Visualisierung
- **TTimer**: Animation und schrittweiser Aufbau
- **TLabel**: Statusanzeige

## 🚀 Verwendung

1. **Projekt öffnen**: `DelphiSourceArt.dproj` in RAD Studio laden
2. **Kompilieren**: F9 oder Build-Menü
3. **Ausführen**: Anwendung startet mit schwarzer Zeichenfläche
4. **Datei analysieren**: Button "Datei analysieren..." klicken
5. **Unit auswählen**: Eine beliebige .pas-Datei auswählen
6. **Animation genießen**: Code-Galaxie wird aufgebaut
7. **Interaktion**: Maus über Klassen bewegen für Details

## 📋 Anforderungen

- **Embarcadero RAD Studio** (10.3 Sydney oder neuer empfohlen)
- **Windows** (VCL-basiert)
- Delphi-Compiler mit VCL-Framework
- Standard-Bibliotheken:
  - `System.Generics.Collections`
  - `Vcl.Graphics`
  - `Vcl.Forms`
  - `Vcl.Dialogs`
  - `Vcl.ExtCtrls`

## 🎯 Implementierungs-Roadmap

✅ **Phase 1**: Benutzeroberfläche (UI)
- TButton, TOpenDialog, TPaintBox platziert
- Panel für Steuerung und Status

✅ **Phase 2**: Datenstrukturen
- TClassMetrics und TMethodMetrics definiert
- Generische Listen für effiziente Speicherung

✅ **Phase 3**: Analyse-Logik (Parser)
- String-basiertes Parsing von .pas-Dateien
- Erkennung von Klassen und Methoden
- Metriken-Sammlung

✅ **Phase 4**: Visualisierung
- OnPaint-Event mit geometrischen Formen
- Radiale Anordnung der Klassen
- Dynamische Farbcodierung

✅ **Phase 5**: Animation
- TTimer für schrittweisen Aufbau
- Fade-In-Effekt mit Alpha-Blending

✅ **Phase 6**: Interaktivität
- OnMouseMove für Hover-Detection
- Tooltip-System mit Details
- Visuelle Hervorhebung

## 🎪 "Wow"-Faktoren

1. **Live-Animation**: Der Code "erwacht zum Leben"
2. **Intuitive Visualisierung**: Komplexität wird sofort sichtbar
3. **Interaktive Exploration**: Tooltips enthüllen Details
4. **Ästhetische Darstellung**: Wissenschaftlich und künstlerisch zugleich
5. **Praktischer Nutzen**: Schneller Überblick über Code-Strukturen

## 🔧 Technische Details

### Parser-Logik
- Zeilenweise Verarbeitung mit `TStringList`
- String-Methoden: `Trim`, `StartsWith`, `Pos`
- Keyword-Erkennung: `class`, `procedure`, `function`
- Hierarchische Strukturerkennung

### Visualisierungs-Algorithmus
1. Berechne Mittelpunkt der TPaintBox
2. Verteile Klassen gleichmäßig im Kreis (360° / Anzahl)
3. Zeichne Verbindungslinien zum Zentrum
4. Erstelle Klassen-Kreise mit dynamischem Radius
5. Platziere Methoden-Kreise um Klassen herum

### Animation-Timing
- 50ms Timer-Intervall (20 FPS)
- Schrittweise Einblendung (Alpha: 0 → 255)
- 2 Frames pro Klasse für sanften Aufbau

## 📝 Lizenz

Dieses Projekt ist Open Source und kann frei verwendet werden.

## 🤝 Beiträge

Verbesserungsvorschläge und Erweiterungen sind willkommen!

Mögliche Erweiterungen:
- Export als Bild/Video
- Weitere Metriken (zyklomatische Komplexität)
- Zoom und Pan
- Multiple Unit-Visualisierung
- 3D-Darstellung
- Dunkle/Helle Themes

## 📧 Kontakt

Entwickelt mit ❤️ und Delphi RAD Studio

---

**DelphiSourceArt** - *Code ist Kunst, und Kunst ist Code* 🎨
