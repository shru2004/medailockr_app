const fs = require('fs');
const c = fs.readFileSync('c:/Users/ADMIN/Downloads/medailockr--simple-secure-smarter-healthcare-version-5.00/flutter_mediqly/lib/screens/health_passport/passport_screen.dart', 'utf8');

const refs = [...c.matchAll(/GeminiService/g)];
console.log('GeminiService refs:', refs.length);
refs.forEach(m => console.log('  at', m.index, ':', c.slice(m.index - 20, m.index + 60).replace(/\r?\n/g, '↵')));

console.log('Has dart:convert:', c.indexOf("import 'dart:convert';") !== -1);
console.log('Has http package:', c.indexOf("import 'package:http/http.dart' as http;") !== -1);
console.log('Has gemini import:', c.indexOf("import '../../services/gemini_service.dart';") !== -1);
console.log('Has backendUrl:', c.indexOf('backendUrl') !== -1);
console.log('Has MultipartRequest:', c.indexOf('MultipartRequest') !== -1);
console.log('');
console.log('First 16 lines:');
console.log(c.split('\n').slice(0, 16).join('\n'));
