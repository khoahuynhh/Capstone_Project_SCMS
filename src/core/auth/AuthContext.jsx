import { useEffect, useMemo, useState } from "react";
import { serverApi } from "../api/server_api";
import { AuthContext } from "./context.js";

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null);
  const [checking, setChecking] = useState(true);

  const isAuthenticated = !!user;

  // Check session cookie
  const checkSession = async () => {
    try {
      const me = await serverApi.me(); // Backend reads cookie -> return user
      setUser(me);                     // Example: {id,email,role,...}
      return me;
    } catch {
      setUser(null);
      return false;
    } finally {
      setChecking(false);
    }
  };

  // When opening app / refreshing page
  useEffect(() => {
    checkSession();
  }, []);

  const value = useMemo(
    () => ({
      user,
      checking,
      isAuthenticated,
      checkSession,
      setUser,
    }),
    [user, checking, isAuthenticated]
  );

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>;
}
