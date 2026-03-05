const fs = require('fs');
const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/flutter_mediqly/lib/screens/health_passport/passport_screen.dart';
let c = fs.readFileSync(f, 'utf8');

// Fix 1: 'ID Rejected: $reason\n\nOnly...' — literal newlines in single-quoted string
// Find the exact sequence with literal CRLF newlines embedded
const BAD1   = "'ID Rejected: $reason\r\n\r\nOnly passport, driving licence, or national ID are accepted.'";
const GOOD1  = "'ID Rejected: $reason\\n\\nOnly passport, driving licence, or national ID are accepted.'";
const ALT_1  = "'ID Rejected: $reason\n\nOnly passport, driving licence, or national ID are accepted.'";

if (c.includes(BAD1)) {
  c = c.replace(BAD1, GOOD1);
  console.log('Fixed ID Rejected string (CRLF)');
} else if (c.includes(ALT_1)) {
  c = c.replace(ALT_1, GOOD1);
  console.log('Fixed ID Rejected string (LF)');
} else {
  // Use regex to find string with embedded newlines
  c = c.replace(
    /'ID Rejected: \$reason[\r\n]+[\r\n]*Only passport, driving licence, or national ID are accepted\.'/,
    "'ID Rejected: $reason\\n\\nOnly passport, driving licence, or national ID are accepted.'"
  );
  console.log('Fixed ID Rejected string (regex)');
}

// Fix 2: 'Cannot reach verification server.\nMake sure...' — already fixed by earlier replace_string_in_file
// But verify it's clean:
const bad2check = /verification server\.\r?\nMake sure/;
if (bad2check.test(c)) {
  c = c.replace(
    /('Cannot reach verification server\.)\r?\n(Make sure the backend is running on port 4000\.')/,
    "$1\\n$2"
  );
  console.log('Fixed "Cannot reach" string');
} else {
  console.log('"Cannot reach" string already clean');
}

fs.writeFileSync(f, c, 'utf8');
console.log('passport_screen.dart fixed. Size:', c.length);
