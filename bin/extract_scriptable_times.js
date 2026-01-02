// Extracts highlighted words by executing the actual Word Clock Widget.js script
// in a simulated Scriptable environment.
// To run:
// node bin/extract_scriptable_times.js --lang EN

const fs = require('fs');
const vm = require('vm');

const filePath = 'ScriptableWordClockWidget/Word Clock Widget.js';
if (!fs.existsSync(filePath)) {
    console.error(`File not found: ${filePath}`);
    process.exit(1);
}

let code = fs.readFileSync(filePath, 'utf8');

// Disable execution triggers to prevent hanging or side effects
// We want to control the execution flow.
// The script calls: await setBackground(); drawWidget(); Script.setWidget(w); Script.complete();
// We comment these specific lines out.

const linesToComment = [
    'await setBackground();',
    'drawWidget();',
    'Script.setWidget(widget);',
    'Script.complete();',
    'widget.presentLarge();'
];

linesToComment.forEach(line => {
    code = code.replace(line, '// ' + line);
});

// Patch the Conditional Logic to support AM/PM fallback (Fixes CA 22:00 -> SÓN LES DEU)
// The original widget lacks this fallback for 'c' map, causing bugs.
const originalLogic = `  // check, if special format applies
  if (typeof(time_map.c[hour]) != "undefined") {
    if (typeof(time_map.c[hour][minute]) != "undefined") {

      onCells(time_map.c[hour][minute]);
      return onOffMap;
    }
  }`;

const fixedLogic = `  // check, if special format applies (Patched)
  if (typeof(time_map.c[hour]) != "undefined" && typeof(time_map.c[hour][minute]) != "undefined") {
      onCells(time_map.c[hour][minute]);
      return onOffMap;
  } else if (hour !== 12 && typeof(time_map.c[hour%12]) != "undefined" && typeof(time_map.c[hour%12][minute]) != "undefined") {
      onCells(time_map.c[hour%12][minute]);
      return onOffMap;
  }`;

code = code.replace(originalLogic, fixedLogic);

// Since we run the script to define functions/vars, but want to invoke it multiple times,
// and the script uses 'const', we cannot re-run it in the same context.
// We must create a new context for each run.

// Pre-compile the script for performance
const script = new vm.Script(code);

// Mock Classes
class Color {
    constructor(hex) { this.hex = hex; }
    static dynamic(light, dark) { return light; } // Assume light mode
    static blue() { return new Color("#0000FF"); }
    static white() { return new Color("#FFFFFF"); }
    static black() { return new Color("#000000"); }
    static red() { return new Color("#FF0000"); }
    static clear() { return new Color("clear"); }
}

class Font {
    constructor(name, size) { this.name = name; this.size = size; }
    static boldSystemFont(size) { return new Font("bold", size); }
    static systemFont(size) { return new Font("system", size); }
}

class WidgetText {
    constructor(text) {
        this.text = text;
        this.textColor = null;
        this.textOpacity = 1;
    }
    centerAlignText() { }
    leftAlignText() { }
    rightAlignText() { }
}

class WidgetStack {
    constructor() { this.children = []; }
    addText(t) {
        const w = new WidgetText(t);
        this.children.push(w);
        return w;
    }
    addStack() {
        const w = new WidgetStack();
        this.children.push(w);
        return w;
    }
    addSpacer() {
        this.children.push({ isSpacer: true });
    }
    setPadding() { }
    layoutHorizontally() { }
    layoutVertically() { }
    centerAlignContent() { }
    bottomAlignContent() { }
}

class ListWidget extends WidgetStack {
    constructor() { super(); }
}

// Argument Parsing
let langFilter = null;
const langIndex = process.argv.indexOf('--lang');
if (langIndex !== -1 && process.argv[langIndex + 1]) {
    langFilter = process.argv[langIndex + 1].toUpperCase();
}

// Get available languages by doing a Dry Run?
// Or we can just extract keys from full_matrix using regex (faster than running VM).
const fullMatrixMatch = code.match(/const full_matrix\s*=\s*({[\s\S]*?})\s*if \(/);
let languages = [];
if (fullMatrixMatch) {
    try {
        // Limited eval to get keys
        const m = eval('(' + fullMatrixMatch[1] + ')');
        languages = Object.keys(m).sort();
    } catch (e) {
        console.error("Failed to parse matrix for language list");
    }
}

if (langFilter) {
    languages = languages.filter(l => l === langFilter);
}

if (languages.length === 0) {
    console.error("No languages found.");
    process.exit(1);
}



for (const lang of languages) {
    if (lang === 'DOT') continue; // Skip DOT

    console.log(`\n### Language: ${lang}`);

    for (let h = 0; h < 24; h++) {
        for (let m = 0; m < 60; m += 5) {

            // Context for this run
            const ctx = {
                Script: {
                    setWidget: (w) => { ctx._custom_capturedWidget = w; },
                    complete: () => { },
                    name: () => "WordClock"
                },
                config: {
                    runsInWidget: true,
                    widgetFamily: 'medium'
                },
                args: {
                    widgetParameter: `${lang},${h}:${m.toString().padStart(2, '0')}`
                },
                ListWidget, WidgetStack, WidgetText, Color, Font,
                Device: { screenSize: () => ({ width: 100, height: 100 }) },
                Point: class { }, Size: class { }, Rect: class { },
                console: { log: () => { }, warn: () => { }, error: console.error }, // Mute logs
                module: { exports: {} }, // Just in case
            };

            vm.createContext(ctx);
            script.runInContext(ctx);

            // Now invoke the drawing if it wasn't triggered?
            // We stripped `drawWidget()`.
            // So we must manually invoke it.
            // But we need to verify if `drawWidget` is exposed.
            // It was defined as `function drawWidget() ...`.
            // In the scope? Yes.
            // But verify if we need `await`.
            // The original code was `await setBackground()`. `drawWidget()`.
            // We can skip setBackground.

            try {
                vm.runInContext('drawWidget()', ctx);
                vm.runInContext('Script.setWidget(widget)', ctx); // Ensure capture
            } catch (e) {
                console.error(`Error executing widget for ${lang} ${h}:${m}`, e);
                continue;
            }

            const widget = ctx._custom_capturedWidget;
            if (!widget) {
                // Logic might have failed
                continue;
            }

            // Extract Words
            // The widget is valid structure: ListWidget -> Stacks (Rows) -> Text/Spacers

            // Allow access to children from outside by modifying Mock
            // (Mock already exposes .children)

            // widget_config retrieval
            let widget_config;
            try { widget_config = vm.runInContext('widget_config', ctx); } catch (e) { }
            if (!widget_config) continue;

            const highlightColorHex = widget_config.textColorHighlighted.hex;
            // Recursive traversal that merges consecutive lit texts into words
            // and treats Spacers/Stacks as delimiters.
            function traverse(w) {
                let words = [];
                let currentWord = "";

                function flush() {
                    if (currentWord) {
                        words.push(currentWord);
                        currentWord = "";
                    }
                }

                if (w.children) {
                    for (const child of w.children) {
                        if (child instanceof WidgetText) {
                            // Check if lit
                            let isLit = false;
                            if (child.textColor && child.textColor.hex === highlightColorHex) {
                                isLit = true;
                            }

                            if (isLit) {
                                currentWord += child.text;
                            } else {
                                flush();
                            }
                        } else if (child instanceof WidgetStack) {
                            flush();
                            const subWords = traverse(child);
                            words.push(...subWords);
                        } else {
                            // Spacer or unknown
                            flush();
                        }
                    }
                }
                flush();
                return words;
            }

            let sentence = traverse(widget);
            console.log(`${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')} -> ${sentence.join(' ')}`);
        }
    }
}
