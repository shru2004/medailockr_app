const fs = require('fs');
const f = 'c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/backend/server.js';
let c = fs.readFileSync(f, 'utf8');
if (c.includes('verify-id')) {
  console.log('Already has verify-id, skipping');
  process.exit(0);
}
const idx = c.lastIndexOf('/api/passport/discharge');
const rowEnd = c.indexOf('</tr>', idx) + '</tr>'.length;
const newRow = '\n    <tr><td class="method post">POST</td><td class="path">/api/passport/verify-id</td><td class="desc">Verify government ID (passport / driving licence / national ID) via AI</td></tr>';
c = c.slice(0, rowEnd) + newRow + c.slice(rowEnd);
fs.writeFileSync(f, c, 'utf8');
console.log('verify-id row added to API docs');
