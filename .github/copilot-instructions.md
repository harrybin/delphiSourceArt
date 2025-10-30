# DelphiSourceArt - AI Coding Assistant Instructions

## Project Overview
DelphiSourceArt is a Delphi VCL application that analyzes Delphi source files (.pas) and visualizes them as an interactive "code galaxy". Classes appear as colored circles arranged radially, with methods as smaller orbiting elements. The visualization uses real-time animation with fade-in effects and interactive tooltips.

**Language**: Object Pascal (Delphi)  
**Framework**: VCL (Visual Component Library)  
**Target**: Windows desktop application

## Architecture

### Core Components
- **MainForm.pas/dfm**: Single-form application containing all UI and logic
  - Parser: Analyzes .pas files using string-based line-by-line parsing
  - Visualizer: Renders "code galaxy" using TPaintBox with GDI+ canvas
  - Animator: TTimer-driven fade-in system (50ms intervals, 20 FPS)
  
### Data Flow
1. User selects .pas file → `btnAnalyzeClick`
2. `AnalyzeSourceFile` loads file into `TStringList`
3. `ParseDelphiUnit` extracts classes/methods → `TClassMetrics` records
4. `PrepareVisualization` creates `TVisualElement` records with positions
5. `Timer` increments alpha values for fade-in effect
6. `PaintBoxPaint` renders current animation state
7. `PaintBoxMouseMove` detects hover → shows tooltips

### Key Data Structures
```delphi
TClassMetrics = record       // Parsed class data
  Name, LineCount, Methods: TList<TMethodMetrics>
end;

TVisualElement = record      // Rendering state
  ClassMetrics, X, Y, Radius, Color, Alpha, Visible
end;
```

## Development Workflow

### Building
Use VS Code tasks (`.vscode/tasks.json` configured):
- **🔨 Build**: `Ctrl+Shift+B` → runs `build.bat` (dcc32 compilation only)
- **🚀 Build and Start**: Compiles and launches `.\bin\DelphiSourceArt.exe`

**Manual compilation**:
```powershell
cd DelphiSourceArt
.\build.bat           # Compile only
.\build_and_start.bat # Compile + launch
```

**Critical**: Use batch files, not direct dcc32 commands in PowerShell (backslash escaping issues).

### Output Directories
- `bin/` - Compiled executable
- `dcu/` - Compiled unit files
Both are auto-created by build scripts.

### Testing
Use `SampleUnit.pas` (3 classes: TPerson, TDataProcessor, TComplexCalculator) to verify parsing and visualization.

## Parser Implementation

### Type Section Detection
The parser MUST recognize Delphi's `type` section:
```delphi
type
  TClassName = class
    // members
  end;
```

**Critical patterns**:
- Track `InTypeSection` flag (toggles on `type`, resets on `implementation`/`var`/`const`)
- Class detection: `Pos('= class', LowerCase(Line)) > 0`
- Ignore forward declarations: `= class;` or `= class of`
- Method detection: Only inside classes, starts with `procedure`/`function`/`constructor`/`destructor`

### Known Parsing Limitations
- No nested class support
- No generics handling
- String-based (not AST), can be confused by comments
- Assumes well-formed code

## Visualization Patterns

### Color Scheme (Complexity-Based)
```delphi
< 50 lines   → RGB(100, 200, 100)  // Green
50-100 lines → RGB(200, 200, 100)  // Yellow
100-200      → RGB(200, 150, 100)  // Orange
> 200        → RGB(200, 100, 100)  // Red
```

### Layout Algorithm
- **Center**: Unit name (30px radius circle)
- **Classes**: Radial distribution at 60% of max canvas radius
- **Methods**: Small circles (5px) orbiting each class at `radius + 15px`
- **Angle calculation**: `(2 * Pi * index) / count`

### Animation System
- Timer interval: 50ms (20 FPS)
- 2 animation steps per class (staggered appearance)
- Alpha blending: 0 → 255 in steps of 15
- Disable timer when all visible

## Delphi-Specific Conventions

### String Operations
Use Delphi RTL functions, not modern alternatives:
- `Pos()` for substring search (1-indexed, returns 0 if not found)
- `Copy()` for substring extraction
- `Trim()` for whitespace removal
- `LowerCase()` for case-insensitive comparisons

### Memory Management
**Critical**: Manually free generic collections:
```delphi
// FormDestroy MUST free nested TList<T>
for ClassMetrics in FClasses do
  ClassMetrics.Methods.Free;
FClasses.Free;
```

### Record Types
Used for value semantics (no heap allocation):
- `TMethodMetrics`, `TClassMetrics`, `TVisualElement` are records
- Modified via temporary variables, then assigned back to lists

## Common Issues

### PowerShell Build Problems
❌ Don't use: `dcc32 -E.\bin` (backslash escaping fails)  
✅ Use: Batch files (`build.bat`) that handle escaping

### Parser Failures
- **No classes found**: Check for `type` section detection
- **Methods not counted**: Verify `InClass` flag is true
- **Wrong line counts**: Ensure `end;` detection catches class end

### Canvas Rendering
- Always call `PaintBox.Invalidate` to trigger repaint
- Use `Application.ProcessMessages` for UI updates during long operations
- Alpha blending requires RGB manipulation: `Color * Alpha div 255`

## File Naming & Structure
- **Units**: PascalCase with `.pas` extension (e.g., `MainForm.pas`)
- **Forms**: Matching `.dfm` binary resource file (automatically generated by IDE)
- **Project**: `.dpr` (program entry point), `.dproj` (RAD Studio project)

## When Adding Features

### New Metrics
1. Add field to `TClassMetrics` or `TMethodMetrics`
2. Update parsing in `ParseDelphiUnit` 
3. Modify visualization in `GetColorForComplexity` or `PrepareVisualization`
4. Update tooltip in `PaintBoxPaint` hover section

### New Visualizations
1. Add to `TVisualElement` if per-class state
2. Implement in `PaintBoxPaint` after existing drawing code
3. Respect `VisElement.Visible` and `Alpha` for animation

### Animation Changes
Modify `TimerTimer` step calculation and `PrepareVisualization` initial state.

## Testing Your Changes
1. Build with `Ctrl+Shift+B`
2. Run and analyze `SampleUnit.pas`
3. Verify: 3 classes visible, correct method counts, tooltip shows data
4. Check animation smoothness (no flicker)

## References
- Documentation: `DelphiSourceArt/README.md` (German, comprehensive)
- Development log: `PROMPTS.md` (chronological problem-solving history)
- Test data: `SampleUnit.pas` (known-good parsing input)
