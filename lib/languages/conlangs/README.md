# Languages and Scripts

This table documents the fictional and constructed languages supported by Word Clock, their corresponding language codes, script codes, and recommended fonts.

| Language Family | Specific Language | Language Code (ISO/BCP 47) | Script | Script Code (ISO 15924) | Description | Recommended Font |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| **Klingon** | Klingon | `tlh` | Latin (xifan hol) | `Latn` | Standard Klingon transliteration. | Noto Sans |
| | Klingon | `tlh-Piqd` | pIqaD | `Piqd` | The native Klingon script. | [pIqaD](https://github.com/KlingonLanguageInstitute/pIqaD) |
| **Elvish** | Sindarin | `sjn` | Tengwar | `Teng` | One of the two main Elvish languages. | [Alcarin](https://www.tosche.net/fonts/alcarin-tengwar) |
| | Quenya | `qya` | Tengwar | `Teng` | The other main Elvish language ("High Elven"). | [Alcarin](https://www.tosche.net/fonts/alcarin-tengwar) |
| **Black Speech** | Black Speech | `mis-mrd` | Tengwar (Cirth?) | `Teng` | The language of Mordor (e.g., the One Ring inscription). Often written in Tengwar script. | [Alcarin](https://www.tosche.net/fonts/alcarin-tengwar) |

## Notes on Scripts

*   **Tengwar (`Teng`)**: A script created by J.R.R. Tolkien used to write many languages of Middle-earth, including Sindarin, Quenya, and even Black Speech (as seen on the One Ring).
*   **Cirth (`Cirt`)**: Another script by Tolkien, primarily used for Dwarvish languages but sometimes for Sindarin.
*   **pIqaD (`Piqd`)**: The native script for the Klingon language.

## Font Strategy

For **Tengwar**, we recommend using a CSUR (ConScript Unicode Registry) compliant font like **Alcarin**. This ensures that the characters are mapped to the correct Private Use Area (PUA) Unicode code points (U+E000–U+F8FF), allowing for interchangeable font usage and proper text rendering.
