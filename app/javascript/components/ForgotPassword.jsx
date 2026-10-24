import React, { useState } from "react"
import { api, errorMessage } from "../api_client"
import { AuthCard, ErrorBanner, generatePassword, PasswordField } from "../ui_helpers"

export default function ForgotPassword() {
  const [email, setEmail] = useState("")
  const [password, setPassword] = useState(generatePassword)
  const [step, setStep] = useState("email")
  const [error, setError] = useState("")
  const [notice, setNotice] = useState("")

  async function submit(event) {
    event.preventDefault()
    setError("")
    setNotice("")
    try {
      const payload = await api("/api/password_resets", {
        method: "POST",
        body: step === "staff" ? { email, password, password_confirmation: password } : { email }
      })
      if (payload.data.result === "staff") {
        setStep("staff")
      } else if (payload.data.result === "reset") {
        setNotice("Password updated. You can sign in with the new password.")
        setStep("done")
      } else if (payload.data.result === "requested") {
        setNotice("Request sent. Your company HR and admin can set a new password from their Password resets page.")
        setStep("done")
      }
    } catch (err) {
      setError(errorMessage(err.payload))
    }
  }

  return (
    <AuthCard
      title="Forgot password"
      subtitle="Company admins and HR can set a new password. Employees send a request to their company admin or HR."
      onSubmit={submit}
    >
        <ErrorBanner message={error} />
        {notice && <p className="rounded-lg bg-emerald-50 px-3 py-2 text-sm text-emerald-800">{notice}</p>}
        {step !== "done" && (
          <label className="block text-base font-medium">Email
            <input className="field mt-2 py-3.5 text-base" type="email" required value={email} onChange={(event) => setEmail(event.target.value)} readOnly={step === "staff"} />
          </label>
        )}
        {step === "staff" && (
          <PasswordField label="New password" value={password} onChange={(event) => setPassword(event.target.value)} />
        )}
        {step !== "done" && (
          <button className="btn-primary w-full py-3.5 text-base" type="submit">
            {step === "staff" ? "Save password" : "Continue"}
          </button>
        )}
        <p className="text-center text-sm text-stone-500">
          <a className="font-semibold text-ink underline-offset-2 hover:underline" href="/login">Back to sign in</a>
        </p>
    </AuthCard>
  )
}
