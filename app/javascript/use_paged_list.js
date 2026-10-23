import { useRef, useState } from "react"
import { api } from "./api_client"

export function usePagedList({ cache = false } = {}) {
  const [rows, setRows] = useState([])
  const [meta, setMeta] = useState({ page: 1, per_page: 25, total: 0 })
  const [error, setError] = useState("")
  const [loading, setLoading] = useState(true)
  const cacheRef = useRef(new Map())
  const inFlightRef = useRef(new Map())

  function apply(payload, onSuccess) {
    setRows(payload.data)
    setMeta(payload.meta)
    setError("")
    onSuccess?.(payload)
    setLoading(false)
  }

  async function load(path, { onSuccess } = {}) {
    if (cache && cacheRef.current.has(path)) {
      apply(cacheRef.current.get(path), onSuccess)
      return
    }

    if (cache && inFlightRef.current.has(path)) {
      apply(await inFlightRef.current.get(path), onSuccess)
      return
    }

    setLoading(true)
    const request = api(path)
    if (cache) inFlightRef.current.set(path, request)
    request.then((payload) => {
      if (cache) cacheRef.current.set(path, payload)
      apply(payload, onSuccess)
    }).catch((err) => setError(err.message))
      .finally(() => {
        if (cache) inFlightRef.current.delete(path)
        setLoading(false)
      })
  }

  return { rows, meta, error, setError, loading, load }
}
