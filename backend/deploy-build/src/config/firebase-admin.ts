import admin from 'firebase-admin';

// Inicializar Firebase Admin SDK
// Nota: Em produção, use um service account JSON
// Por enquanto, usa as credenciais padrão do ambiente
if (!admin.apps.length) {
  admin.initializeApp({
    projectId: process.env.FIREBASE_PROJECT_ID || 'cadastro-beneficios',
  });
}

export const auth = admin.auth();
export default admin;
