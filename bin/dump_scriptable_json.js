const fs = require('fs');

const filePath = 'ScriptableWordClockWidget/Word Clock Widget.js';
if (!fs.existsSync(filePath)) {
    console.error(`File not found: ${filePath}`);
    process.exit(1);
}

const content = fs.readFileSync(filePath, 'utf8');

// Extract the full_matrix object definition
const fullMatrixStart = content.indexOf('const full_matrix = {');
const fullMatrixEnd = content.indexOf('if (language in full_matrix) {');

if (fullMatrixStart === -1 || fullMatrixEnd === -1) {
    console.error("Could not find full_matrix in the source file.");
    process.exit(1);
}

let fullMatrixStr = content.substring(fullMatrixStart, fullMatrixEnd).trim();

try {
    // Remove the 'const full_matrix =' part and wrap in parens to make it an expression
    // Note: The file might contain comments or other non-JSON JS. eval handles this.
    const objectBody = fullMatrixStr.replace(/^const full_matrix\s*=\s*/, '');
    const full_matrix = eval('(' + objectBody + ')');

    // Custom pretty print: Collapse arrays of strings/numbers to one line
    const json = JSON.stringify(full_matrix, null, 2);
    const formatted = json.replace(/\[\s+((?:(?:"[^"]+"|\d+)(?:\s*,\s*(?:"[^"]+"|\d+))*))\s+\]/g, (match, content) => {
        return '[' + content.replace(/\s*\n\s*/g, ' ') + ']';
    });

    console.log(formatted);
} catch (e) {
    console.error("Failed to eval full_matrix:", e);
    process.exit(1);
}
