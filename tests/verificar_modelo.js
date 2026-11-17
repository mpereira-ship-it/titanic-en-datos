/** Prueba automatizada sin dependencias: node tests/verificar_modelo.js */
'use strict';
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const assert = require('node:assert/strict');
const base = path.resolve(__dirname, '..');
const r = fs.readFileSync(path.join(base, 'fuente_R', 'model_pred.R'), 'utf8');
const html = fs.readFileSync(path.join(base, 'index.html'), 'utf8');
const s = html.match(/const coef=Object\.freeze\(\{[^;]+;[\s\S]*?function logistic\(p\)\{[^}]+\}/);
if (!s) throw Error('No se pudo extraer el motor de prediccion de index.html');
const ctx = vm.createContext({Math, Number});
vm.runInContext(s[0]+'\nthis.obtener=logistic;this.coefRWeb=coef;this.etaWeb=eta;', ctx);
const coefs = ctx.coefRWeb;
const entries = [...r.matchAll(/^\s*([a-zA-Z][a-zA-Z0-9_]*)\s*=\s*(-?\d+\.\d+)\s*,?$/gm)];
const rCoef = Object.fromEntries(entries.map(m=>[m[1], Number(m[2])]));
assert.equal(Object.keys(coefs).length,11,'El modelo web debe tener 11 coeficientes');
for (const [key,val] of Object.entries(coefs)) {
  assert.ok(Object.hasOwn(rCoef,key), 'Coeficiente ausente en R: '+key);
  assert.equal(val,rCoef[key], 'Valor distinto en '+key);
}
const data = fs.readFileSync(path.join(base,'tests','cuatro_perfiles.csv'),'utf8').trim().split(/\r?\n/).slice(1).map(line=>{
  const [perfil,sex,pclass,p] = line.split(',');return{perfil,sex,pclass:Number(pclass),p:Number(p)};
});
for (const x of data){
 const calculated=ctx.obtener({pclass:x.pclass, sex:x.sex,age:25,fare:15,fsize:1,embarked:'S'});
 assert.ok(Math.abs(calculated-x.p)<1e-12, `${x.perfil}: ${calculated} != ${x.p}`);
 console.log(`${x.perfil}: ${(100*calculated).toFixed(2)} % OK`);
}
for(const age of [1,17,18,25,80])for(const pclass of [1,2,3])for(const sex of ['female','male'])for(const embarked of ['C','Q','S'])for(const fsize of [1,2,4,5,7])for(const fare of [0,15,90,200]){
  const p=ctx.obtener({age,pclass,sex,embarked,fsize,fare});
  assert.ok(Number.isFinite(p)&&p>=0&&p<=1);
}
const specific=ctx.etaWeb({pclass:3,sex:'female',age:25,fare:15,fsize:1,embarked:'S'});
assert.ok(Math.abs(specific - 0.325302)<1e-10);
console.log('Los 11 coeficientes coinciden con model_pred.R.');
console.log('4 predicciones de referencia y 1800 combinaciones adicionales: OK.');
