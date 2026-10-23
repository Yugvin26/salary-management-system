export function csrfToken() {
  const row = document.cookie.split("; ").find((part) => part.startsWith("CSRF-TOKEN="))
  return row ? decodeURIComponent(row.split("=").slice(1).join("=")) : ""
}

export async function api(path, { method = "GET", body } = {}) {
  const headers = { Accept: "application/json" }
  if (body !== undefined) headers["Content-Type"] = "application/json"
  if (method !== "GET" && method !== "HEAD") headers["X-CSRF-Token"] = csrfToken()

  const response = await fetch(path, {
    method,
    headers,
    credentials: "include",
    body: body === undefined ? undefined : JSON.stringify(body)
  })

  if (response.status === 204) return {}
  const text = await response.text()
  const payload = text ? JSON.parse(text) : {}
  if (!response.ok) {
    const error = new Error(errorMessage(payload))
    error.status = response.status
    error.payload = payload
    throw error
  }
  return payload
}

export function errorMessage(payload) {
  const errors = payload?.errors
  if (!errors) return "Something went wrong"
  if (Array.isArray(errors)) return errors.join(", ")
  return Object.entries(errors)
    .flatMap(([field, messages]) => {
      const list = Array.isArray(messages) ? messages : [messages]
      return list.map((message) => (field === "base" ? message : `${field} ${message}`))
    })
    .join(". ")
}
