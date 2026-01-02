// Extracts all the valid values from ScriptableWordClockWidget/Word Clock Widget.js
// To run:
// node bin/extract_scriptable_highlights.js --lang EN

const fs = require('fs');

const filePath = 'ScriptableWordClockWidget/Word Clock Widget.js';
const content = fs.readFileSync(filePath, 'utf8');

// Extract the full_matrix object definition
const fullMatrixStart = content.indexOf('const full_matrix = {');
const fullMatrixEnd = content.indexOf('if (language in full_matrix) {');

if (fullMatrixStart === -1 || fullMatrixEnd === -1) {
    console.error("Could not find full_matrix in the source file.");
    process.exit(1);
}

let fullMatrixStr = content.substring(fullMatrixStart, fullMatrixEnd).trim();

// Use a safer way to eval the object by making it an expression
let full_matrix;
try {
    // Remove the 'const full_matrix =' part and wrap in parens to make it an expression
    const objectBody = fullMatrixStr.replace(/^const full_matrix\s*=\s*/, '');
    full_matrix = eval('(' + objectBody + ')');
} catch (e) {
    console.error("Failed to eval full_matrix:", e);
    process.exit(1);
}

const languagesToExtract = Object.keys(full_matrix);

// Simple argument parsing
let langFilter = null;
const langIndex = process.argv.indexOf('--lang');
if (langIndex !== -1 && process.argv[langIndex + 1]) {
    langFilter = process.argv[langIndex + 1].toUpperCase();
}

const languages = langFilter
    ? languagesToExtract.filter(l => l.toUpperCase() === langFilter)
    : languagesToExtract.filter(l => full_matrix[l] && full_matrix[l].r);

if (langFilter && languages.length === 0) {
    console.error(`Language "${langFilter}" not found. Available languages: ${languagesToExtract.join(', ')}`);
    process.exit(1);
}

function onCells(onOffMap, cells, offset_x = 0, offset_y = 0) {
    if (!cells) return;
    for (let cell_nr in cells) {
        const line = cells[cell_nr][0] + offset_y;
        const start = cells[cell_nr][1] + offset_x;
        let length = cells[cell_nr][2];

        if (length === undefined) {
            length = 0;
        }
        for (let i = start; i <= (start + length); i++) {
            if (onOffMap[line] && onOffMap[line][i] !== undefined) {
                onOffMap[line][i] = true;
            }
        }
    }
}

function getHighlightedWordsForTime(language, hour, minute) {
    const matrix = full_matrix[language];
    if (!matrix) return [];

    const widget_word_matrix = matrix.a;
    const time_map = matrix.r;
    if (!time_map) {
        // console.warn(`Warning: matrix.r (time_map) is undefined for language ${language}. Skipping.`);
        return "";
    }
    // Default to 35 if not defined (matching Widget logic)
    const hour_display_limit = (typeof matrix.b !== 'undefined') ? matrix.b : 35;

    const onOffMap = [];
    for (let i = 0; i < widget_word_matrix.length; i++) {
        onOffMap[i] = [];
        for (let j = 0; j < widget_word_matrix[i].length; j++) {
            onOffMap[i][j] = false;
        }
    }

    // highlight IT & IS
    if (time_map.i) {
        onCells(onOffMap, time_map.i);
    }

    // check, if special format applies
    if (time_map.c && time_map.c[hour] && time_map.c[hour][minute]) {
        onCells(onOffMap, time_map.c[hour][minute]);
    } else {
        let h = hour;
        if (minute >= hour_display_limit) {
            h = hour + 1;
        }

        // trim hours by 12 if needed
        if (!time_map.e.hasOwnProperty(h)) {
            h = h % 12;
        }


        // display minute
        if (time_map.d && time_map.d[minute]) {
            onCells(onOffMap, time_map.d[minute]);
        }

        // display hour
        if (time_map.e && time_map.e[h]) {
            onCells(onOffMap, time_map.e[h]);
        }
    }

    const words = [];
    for (let i = 0; i < widget_word_matrix.length; i++) {
        let currentWord = "";
        for (let j = 0; j < widget_word_matrix[i].length; j++) {
            if (onOffMap[i][j]) {
                currentWord += widget_word_matrix[i][j];
            } else {
                if (currentWord.length > 0) {
                    words.push(currentWord);
                    currentWord = "";
                }
            }
        }
        if (currentWord.length > 0) {
            words.push(currentWord);
        }
    }
    return words.join(' ');
}

// Iterate through all languages and times
for (const lang of languages) {
    console.log(`\n### Language: ${lang}`);
    for (let h = 0; h < 24; h++) {
        for (let m = 0; m < 60; m += 5) {
            const result = getHighlightedWordsForTime(lang, h, m);
            console.log(`${h.toString().padStart(2, '0')}:${m.toString().padStart(2, '0')} -> ${result}`);
        }
    }
}
