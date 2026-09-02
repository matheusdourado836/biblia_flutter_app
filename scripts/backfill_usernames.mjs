/**
 * Preenche a coleção `usernames` a partir dos usuários já existentes.
 *
 * A coleção é o índice público que permite checar disponibilidade de nome
 * durante o cadastro (quando a pessoa ainda não está autenticada e portanto
 * não pode ler `users`). Usuários criados antes dessa mudança não têm entrada,
 * então sem este backfill um cadastro novo conseguiria tomar um nome já em uso.
 *
 * Uso:
 *   npm i firebase-admin
 *   # autentique-se antes (uma das opções):
 *   #   gcloud auth application-default login
 *   #   export GOOGLE_APPLICATION_CREDENTIALS=/caminho/service-account.json
 *
 *   node scripts/backfill_usernames.mjs            # simulação (não grava nada)
 *   node scripts/backfill_usernames.mjs --apply    # grava de verdade
 */
import { initializeApp, applicationDefault } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';

const APPLY = process.argv.includes('--apply');
const PROJECT_ID = process.env.FIREBASE_PROJECT_ID ?? 'biblia-online-a1a06';

// Mesma normalização de UserService.normalizeUsername (Dart).
const normalize = (name) => (name ?? '').trim().toLowerCase();

initializeApp({ credential: applicationDefault(), projectId: PROJECT_ID });
const db = getFirestore();

const usuarios = await db.collection('users').get();
console.log(`usuários encontrados: ${usuarios.size}`);

const porNome = new Map();
const semNome = [];

for (const docSnap of usuarios.docs) {
  const nome = normalize(docSnap.data().username);
  if (!nome) {
    semNome.push(docSnap.id);
    continue;
  }
  if (!porNome.has(nome)) porNome.set(nome, []);
  porNome.get(nome).push(docSnap.id);
}

// O app nunca impôs unicidade, então pode haver nomes repetidos. Eles precisam
// de decisão humana: o script reserva para o primeiro e lista os demais.
const duplicados = [...porNome.entries()].filter(([, uids]) => uids.length > 1);

const jaExistentes = [];
const aCriar = [];
for (const [nome, uids] of porNome) {
  const ref = db.collection('usernames').doc(nome);
  const existente = await ref.get();
  if (existente.exists) {
    jaExistentes.push(nome);
  } else {
    aCriar.push({ nome, uid: uids[0] });
  }
}

console.log(`sem username........: ${semNome.length}`);
console.log(`já reservados.......: ${jaExistentes.length}`);
console.log(`a reservar..........: ${aCriar.length}`);
console.log(`nomes duplicados....: ${duplicados.length}`);

if (duplicados.length) {
  console.log('\n!! nomes usados por mais de uma conta (reservados para o primeiro uid):');
  for (const [nome, uids] of duplicados) {
    console.log(`   ${nome} -> ${uids.join(', ')}`);
  }
  console.log('   resolva manualmente: os demais precisam escolher outro nome.\n');
}

if (!APPLY) {
  console.log('\nsimulação — nada foi gravado. rode com --apply para efetivar.');
  process.exit(0);
}

let gravados = 0;
for (let i = 0; i < aCriar.length; i += 400) {
  const lote = db.batch();
  for (const { nome, uid } of aCriar.slice(i, i + 400)) {
    lote.create(db.collection('usernames').doc(nome), { uid });
  }
  await lote.commit();
  gravados += Math.min(400, aCriar.length - i);
  console.log(`  ${gravados}/${aCriar.length}`);
}

console.log(`\npronto: ${gravados} nomes reservados.`);
process.exit(0);
