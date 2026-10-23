import React, { createContext, useContext, useEffect, useMemo, useState } from "react"
import { useNavigate } from "react-router-dom"
import { api } from "./api_client"

const AuthContext = createContext(null)

export function useAuth() {
  return useContext(AuthContext)
}

export function AuthProvider({ children }) {
  const [user, setUser] = useState(null)
  const [ready, setReady] = useState(false)

  useEffect(() => {
    api("/api/session")
      .then((payload) => setUser(payload.data))
      .catch(() => setUser(null))
      .finally(() => setReady(true))
  }, [])

  useEffect(() => {
    applyCompanyTheme(user?.company?.setting)
  }, [user])

  const value = useMemo(() => ({ user, setUser, ready }), [user, ready])
  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useSignOut(path = "/login") {
  const { setUser } = useAuth()
  const navigate = useNavigate()
  return async () => {
    await api("/api/session", { method: "DELETE" })
    setUser(null)
    applyCompanyTheme(null)
    navigate(path)
  }
}

export function applyCompanyTheme(setting) {
  const root = document.documentElement
  const colors = {
    "--ink": setting?.primary_color,
    "--clay": setting?.accent_color,
    "--sand": setting?.background_color
  }
  Object.entries(colors).forEach(([name, hex]) => {
    const channels = hexToChannels(hex)
    if (channels) root.style.setProperty(name, channels)
    else root.style.removeProperty(name)
  })
}

function hexToChannels(hex) {
  const match = /^#([0-9a-f]{6})$/i.exec(hex || "")
  if (!match) return null
  const value = parseInt(match[1], 16)
  return `${(value >> 16) & 255} ${(value >> 8) & 255} ${value & 255}`
}
