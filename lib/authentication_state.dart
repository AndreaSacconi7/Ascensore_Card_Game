enum AuthenticationState {
  // Nothing checked yet
  unknown,
  // Checking the saved session or waiting for the server
  loading,
  authenticated,
  // Signed out: the login form is shown
  unauthenticated,
  // Sign-in or sign-up failed
  error,
}
