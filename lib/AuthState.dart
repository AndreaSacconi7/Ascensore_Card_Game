enum AuthState {
  unknown, // Stato iniziale
  loading, // Sta controllando il token o attendendo il server
  authenticated, // Login riuscito
  unauthenticated, // Nessun token, pronto per il login
  error // Errore di login
}