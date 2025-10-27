# DelphiSourceArt - AI Coding Agent Instructions

## Project Overview

DelphiSourceArt is a Delphi VCL application that visualizes Delphi source code as interactive art. It parses `.pas` files and displays classes as a radial "code galaxy" with real-time animation, color-coded complexity, and interactive tooltips.

## Architecture & Key Components

### Single-Form VCL Application

- **Entry Point**: `DelphiSourceArt.dpr` - standard VCL program structure
- **Main UI**: `MainForm.pas` - contains all logic (no separate parser units)
- **Test Data**: `SampleUnit.pas` - example unit for testing visualization

### Core Data Structures (in `MainForm.pas`)

```delphi
TMethodMetrics = record      // Individual method info
TClassMetrics = record        // Class + its methods (owns TList<TMethodMetrics>)
TVisualElement = record       // Rendering data for animation (includes TClassMetrics)
```

**Critical Memory Management**: `TClassMetrics.Methods` is a dynamically allocated `TList<TMethodMetrics>` - MUST be freed in `FormDestroy` when iterating through `FClasses`.

### Parsing Strategy

- **String-based parsing** (no AST or lexer) - analyzes line-by-line with `Trim()`, `Pos()`, and `LowerCase()`
- **Type section focus**: Only parses classes declared in `type` section (ignores `implementation`, `var`, `const`)
- **Class detection**: Looks for `= class` or `= class(TParent)` patterns (ignores forward declarations with `= class;`)
- **Method detection**: Identifies `procedure`, `function`, `constructor`, `destructor` keywords at line start
- **No scope tracking**: Parser is intentionally simple - counts lines between `= class` and `end;`

## Build & Development Workflow

### Build System (Command-line DCC32)

```batch
# Build only (outputs to bin\, DCU files to dcu\)
build.bat → dcc32 DelphiSourceArt.dpr -B -E.\bin -N.\dcu

# Build + launch executable
build_and_start.bat → compiles then runs bin\DelphiSourceArt.exe
```

**VS Code Tasks**: Use `🔨 Build DelphiSourceArt (DCC32)` or `🚀 Build and Start DelphiSourceArt` tasks (don't invoke DCC32 directly in terminal).

**No IDE Required**: Project uses batch scripts with DCC32 compiler - can build without opening RAD Studio.

### Output Directories

- `bin\` - compiled `.exe` files
- `dcu\` - compiled units (`.dcu` files)
- Both created automatically by build scripts if missing

## Visualization Algorithm

### Radial Layout ("Code Galaxy")

1. **Center**: Unit name displayed in fixed circle (radius 30px)
2. **Classes**: Distributed evenly in a circle around center at 60% of max radius
   - Angle calculation: `(2 * Pi * i) / ClassCount`
   - Lines connect each class to center
3. **Methods**: Small circles (5px radius) arranged radially around parent class
   - Offset: `ClassRadius + 15px` from class center
4. **Sizing**: Class radius = `20 + (MethodCount * 5)` pixels

### Color Coding (Complexity by Line Count)

- **Green** (RGB 100,200,100): < 50 lines (simple)
- **Yellow** (RGB 200,200,100): 50-100 lines (medium)
- **Orange** (RGB 200,150,100): 100-200 lines (complex)
- **Red** (RGB 200,100,100): > 200 lines (very complex)

### Animation System

- **Timer**: 50ms interval (20 FPS), controlled by `Timer.Enabled`
- **Phased reveal**: Elements appear sequentially (2 frames per class) with alpha fade-in (0→255, increment +15)
- **State tracking**: `TVisualElement.Visible` and `.Alpha` control rendering during animation
- **Stop condition**: `FAnimationStep > FVisualElements.Count * 2`

## Delphi-Specific Patterns

### VCL Event Handlers

All UI interactions use VCL event model:

- `FormCreate/FormDestroy` - initialization/cleanup with manual memory management
- `btnAnalyzeClick` - file selection via `TOpenDialog`
- `PaintBoxPaint` - custom rendering (no invalidation in this method)
- `PaintBoxMouseMove` - hover detection (call `PaintBox.Invalidate` to redraw)
- `TimerTimer` - animation frame updates

### Canvas Drawing (in `PaintBoxPaint`)

```delphi
// All drawing on PaintBox.Canvas
Brush.Color := ...; Brush.Style := ...;  // Fill settings
Pen.Color := ...; Pen.Width := ...;      // Stroke settings
Ellipse(x1, y1, x2, y2);                 // Circles/ellipses
TextOut(x, y, text);                      // Text rendering
MoveTo/LineTo                             // Lines
```

**Alpha Blending**: Manual calculation during animation: `Color * Alpha div 255`

### Generics Usage

```delphi
uses System.Generics.Collections;
FClasses: TList<TClassMetrics>;          // Type-safe lists
```

## Code Conventions

### Naming

- **Types**: `TClassMetrics`, `TVisualElement` (T-prefix for types/classes)
- **Fields**: `FClasses`, `FAnimationStep` (F-prefix for private fields)
- **Parameters**: `AName`, `AAge` (A-prefix in constructors)
- **Local vars**: `ClassMetrics`, `VisElement` (no prefix)

### String Operations

- Always `Trim()` before parsing lines
- Use `LowerCase()` for keyword matching (case-insensitive)
- `Pos()` for substring search (1-indexed, returns 0 if not found)
- `Copy()` for substrings (also 1-indexed)

### UI Updates

- `Application.ProcessMessages` - allow UI refresh during long operations
- `PaintBox.Invalidate` - trigger repaint (calls `PaintBoxPaint`)
- `lblStatus.Caption` - update status messages for user feedback

## Testing the Application

1. Run `build_and_start.bat` or use VS Code task
2. Click "Datei analysieren..." button
3. Select a `.pas` file (try `SampleUnit.pas` for demo)
4. Watch animation build the code galaxy
5. Hover over class circles to see tooltip details

## Extending the Project

### Adding New Metrics

1. Add fields to `TMethodMetrics` or `TClassMetrics` records
2. Update `ParseDelphiUnit` to extract data
3. Modify `GetColorForComplexity` or visualization logic in `PrepareVisualization`

### Improving Parser

- Parser is intentionally simple (no proper lexer/AST)
- Consider limitations: doesn't handle nested types, generics constraints, or inline var declarations
- When enhancing, maintain line-by-line string analysis approach for consistency

### UI Enhancements

- Export feature: Use `SaveToFile` with `TPicture` or `TBitmap`
- Zoom/Pan: Modify `PrepareVisualization` to apply transform matrix to X/Y coordinates
- Dark/Light theme: Change `PaintBox.Color` and RGB values in `GetColorForComplexity`

## Common Issues

**Memory Leaks**: Always free `TClassMetrics.Methods` (TList) before clearing `FClasses`
**Parsing Failures**: Check `type` section boundaries - parser stops at `implementation`, `var`, `const`
**Animation Glitches**: Ensure `Timer.Enabled := False` after animation completes to stop redraws
**Build Errors**: Verify DCC32 is in PATH; check that `bin\` and `dcu\` directories are writable
