const fs = require('fs');
const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/_patch_twin3.js';
let s = fs.readFileSync(f, 'utf8');
s = s.replace("if (c.includes('_VoiceAssistantSheet'))", "if (c.includes('class _VoiceAssistantSheet'))");
fs.writeFileSync(f, s, 'utf8');
console.log('Fixed check in _patch_twin3.js');
