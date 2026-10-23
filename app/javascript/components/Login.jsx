import React, { useEffect, useState } from "react"
import { useNavigate } from "react-router-dom"
import { api, errorMessage } from "../api_client"
import { useAuth } from "../auth_context"
import { AuthCard, ErrorBanner } from "../ui_helpers"

export default function Login() {
  const { setUser, user } = useAuth()
  const navigate = useNavigate()
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState("")
  const [error, setError] = useState("")

  useEffect(() => {
    if (user) navigate(user.role === "employee" ? "/me" : user.role === "super_admin" ? "/site-admin" : "/", { replace: true })
  }, [user, navigate])

  async function submit(event) {
    event.preventDefault()
    setError("")
    try {
      const payload = await api("/api/session", { method: "POST", body: { email, password } })
      setUser(payload.data)
      navigate(payload.data.role === "employee" ? "/me" : "/")
    } catch (err) {
      setError(errorMessage(err.payload || { errors: { base: ["Invalid email or password"] } }))
    }
  }

  return (
    <AuthCard title="Salary management" subtitle="Sign in with your HR or employee account." onSubmit={submit}>
      <ErrorBanner message={error} />
      <label className="block text-base font-medium">Email
        <input className="field mt-2 py-3.5 text-base" type="email" required value={email} onChange={(event) => setEmail(event.target.value)} />
      </label>
      <label className="block text-base font-medium">Password
        <input className="field mt-2 py-3.5 text-base" type="password" required value={password} onChange={(event) => setPassword(event.target.value)} />
      </label>
      <button className="btn-primary w-full py-3.5 text-base" type="submit">Sign in</button>
    </AuthCard>
  )
}
