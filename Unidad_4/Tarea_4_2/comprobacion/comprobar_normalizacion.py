#!/usr/bin/env python3
"""Comprobación analítica reproducible. No se conecta ni ejecuta SQL Server.
Reglas y datos son los declarados en el reporte; no infiere DF desde una muestra.
Uso: python comprobar_normalizacion.py
"""
from pathlib import Path
from itertools import combinations
import json,csv,re
BASE=Path(__file__).resolve().parent
R=set('P N U S FS FL E C T NT D CS'.split())
F=[({'P'},{'U','FS','FL'}),({'U'},{'S'}),({'E'},{'C','T'}),({'C'},{'E'}),({'T'},{'NT','D'}),({'P','N'},{'E','CS'}),({'P','E'},{'N'})]
results=[]
def record(name,passed,detail):
 assert passed, name
 results.append({'comprobacion':name,'resultado':'CORRECTO','detalle':detail})
def closure(x,dependencies):
 out=set(x)
 while True:
  prev=out.copy()
  for left,right in dependencies:
   if left<=out:out|=right
  if out==prev:return out

def powerset(x):
 seq=sorted(x)
 for n in range(len(seq)+1):
  yield from (set(a) for a in combinations(seq,n))
def keys(attrs,dependencies):
 out=[]
 for x in powerset(attrs):
  if not any(k<=x for k in out) and attrs<=closure(x,dependencies):out.append(x)
 return out
found=keys(R,F)
record('Claves de R1',{frozenset(x) for x in found}=={frozenset('PN'),frozenset('PE'),frozenset('PC')},'Se enumeraron todos los subconjuntos de los 12 atributos: PN, PE y PC son las únicas candidatas.')
record('Cierres de las tres claves',all(closure(x,F)==R for x in found),'Cada clave obtiene los 12 atributos y no tiene un subconjunto que lo haga.')
record('Dependencia parcial en 1FN',{'FS'}<=closure({'P'},F) and not R<=closure({'P'},F),'P determina FS sin ser una clave de R1; P es parte propia de PN, PE y PC.')
H=set('P U S FS FL'.split());I=set('E C T NT D'.split());DE=set('P N E CS'.split())
UR=set('U S'.split());PR=set('P U FS FL'.split());ER=set('E C T'.split());TR=set('T NT D'.split())
remainder=set('P N E C T NT D CS'.split())
for name,whole,a,b in [('Extraer cabecera',R,H,remainder),('Extraer inventario',remainder,I,DE),('Extraer usuario',H,UR,PR),('Extraer tipo',I,TR,ER)]:
 common=a&b
 record('Sin pérdida '+name,a|b==whole and (a<=closure(common,F) or b<=closure(common,F)),'La intersección '+','.join(sorted(common))+' determina una de las relaciones.')
parts=[UR,PR,ER,TR,DE]
# Derive every projected DF with one RHS attribute, then check preservation.
projected=[]
for attrs in parts:
 for x in powerset(attrs):
  for a in (closure(x,F)&attrs)-x:projected.append((x,{a}))
record('Conservación de todas las DF',all(y<=closure(x,projected) for x,y in F),'Las DF de R1 se deducen de la unión de sus proyecciones normalizadas.')
record('FNBC de la proyección',all(not ((closure(x,F)&attrs)-x) or attrs<=closure(x,F) for attrs in parts for x in powerset(attrs)),'Se revisaron todos los determinantes posibles de cada una de las cinco relaciones de la proyección.')
# A small fictitious instance of R1; historic repeated piece after return is allowed.
cols='P N U S FS FL E C T NT D CS'.split()
values=[(101,1,1,'Ana','2026-10-30','2026-11-01',501,'BAL01',10,'Balón','Básquetbol','Bueno'),(101,2,1,'Ana','2026-10-30','2026-11-01',502,'BAL02',10,'Balón','Básquetbol','Bueno'),(102,1,1,'Ana','2026-11-02','2026-11-04',501,'BAL01',10,'Balón','Básquetbol','Usado')]
rows=[dict(zip(cols,x)) for x in values]
def project(rows,attrs):return {tuple((c,r[c]) for c in sorted(attrs)) for r in rows}
def join(left,right):
 out=set()
 for x in left:
  a=dict(x)
  for y in right:
   b=dict(y)
   if all(a[k]==b[k] for k in a.keys()&b.keys()):out.add(tuple(sorted((a|b).items())))
 return out
reconstructed=project(rows,parts[0])
for part in parts[1:]:reconstructed=join(reconstructed,project(rows,part))
record('Reconstrucción de ejemplo',reconstructed==project(rows,R),'Se recuperan exactamente las tres filas ficticias, sin pérdida ni tuplas espurias. El criterio general se comprobó antes mediante DF.')
# Verify real SQL keys/columns against the nine normalised relations.
sql=(BASE.parent/'sql/normalized_schema.sql').read_text(encoding='utf-8-sig')
expected={
'Usuario':[['idUsuario']], 'UsuarioTelefono':[['idUsuario','telefono']],
'Alumno':[['idUsuario'],['matricula']], 'Trabajador':[['idUsuario'],['numeroEmpleado']],
'TipoMaterial':[['idTipo']], 'Ejemplar':[['idEjemplar'],['codigoInventario']],
'Prestamo':[['idPrestamo']], 'DetallePrestamo':[['idPrestamo','numeroRenglon'],['idPrestamo','idEjemplar']],
'Incidencia':[['idIncidencia']]}
blocks=dict(re.findall(r'CREATE TABLE dbo\.(\w+)\s*\((.*?)\n\);',sql,re.S))
columncount=0
for name,ks in expected.items():
 b=blocks[name]
 attrs=set(re.findall(r'^\s*(\w+)\s+(?:int|bit|date|datetime2|nvarchar|varchar)\b',b,re.M));columncount+=len(attrs)
 actual=[set(s.replace(' ','').split(',')) for s in re.findall(r'CONSTRAINT \w+ (?:PRIMARY KEY|UNIQUE)\s*\(([^)]+)\)',b)]
 assert {frozenset(x) for x in actual}=={frozenset(x) for x in ks},name
 fd=[(set(k),attrs-set(k)) for k in ks]
 assert all(not (closure(x,fd)-x) or attrs<=closure(x,fd) for x in powerset(attrs)),name
record('Correspondencia y FNBC de nueve tablas',len(blocks)==9 and columncount==39,'Claves PK/UNIQUE y 39 columnas coinciden con el reporte. FNBC se calcula bajo las DF declaradas; no demuestra reglas de negocio no especificadas.')
# Independent illustrative examples used in task 4.1.
FB=[({'sesion','instructor'},{'sala'}),({'sala'},{'instructor'})];RB={'sesion','instructor','sala'}
kb=keys(RB,FB);prime=set().union(*kb)
record('Ejemplo 3FN sin FNBC',prime==RB and closure({'sala'},FB)!=RB and closure({'sala'},FB)>={'instructor'},'Todas las columnas son primas, pero sala no es superclave y determina instructor.')
preferences=[{'U':1,'tel':t,'deporte':d} for t in ['111','222'] for d in ['Fútbol','Básquetbol']]
record('Ejemplo de DMV',join(project(preferences,{'U','tel'}),project(preferences,{'U','deporte'}))==project(preferences,{'U','tel','deporte'}),'Dos teléfonos independientes de dos deportes se reconstruyen en cuatro combinaciones; el ejemplo no añade esa regla al proyecto.')
supply=[dict(zip(['P','T','S'],x)) for x in [('p1','balón','cancha'),('p1','red','cancha'),('p2','balón','cancha'),('p2','balón','gimnasio')]]
record('Ejemplo de reunión ternaria',join(join(project(supply,{'P','T'}),project(supply,{'P','S'})),project(supply,{'T','S'}))==project(supply,{'P','T','S'}),'El ejemplo satisface la regla declarada de compatibilidad de los tres pares. No demuestra una regla universal por observación de una muestra.')
with (BASE/'resultados_analiticos.json').open('w',encoding='utf-8') as f:json.dump({'tipo':'Cálculos analíticos en Python, sin ejecución de SQL Server','comprobaciones':results},f,ensure_ascii=False,indent=2)
with (BASE/'R1_ejemplo.csv').open('w',encoding='utf-8-sig',newline='') as f:
 w=csv.DictWriter(f,fieldnames=cols);w.writeheader();w.writerows(rows)
print(str(len(results))+' comprobaciones analíticas correctas. No se ejecutó SQL Server.')
