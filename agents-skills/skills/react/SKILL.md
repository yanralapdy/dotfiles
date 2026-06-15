---
name: react-patterns
description: React 18 patterns and conventions. Use when writing or reviewing React components.
---

# React Patterns

## Component Structure
Functional components only. TypeScript interfaces for props.

```tsx
interface UserCardProps {
  userId: number
  onUpdate?: (user: User) => void
}

export function UserCard({ userId, onUpdate }: UserCardProps) {
  const { data: user, loading } = useUser(userId)

  if (loading) return <Spinner />
  if (!user) return null

  return <div>{user.name}</div>
}
```

## Custom Hooks
Extract data fetching and logic into hooks in `hooks/`:
```ts
// hooks/useUser.ts
export function useUser(id: number) {
  const [user, setUser] = useState<User | null>(null)
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let cancelled = false
    api.get<User>(`/users/${id}`).then(({ data }) => {
      if (!cancelled) setUser(data)
    }).finally(() => {
      if (!cancelled) setLoading(false)
    })
    return () => { cancelled = true }
  }, [id])

  return { user, loading }
}
```

## State Management
- Local state: `useState`
- Shared state: Zustand or React Context (for low-frequency updates only)
- Server state: React Query / TanStack Query

```ts
// Zustand store
export const useUserStore = create<UserStore>((set) => ({
  users: [],
  addUser: (user) => set((s) => ({ users: [...s.users, user] })),
}))
```

## Rules
- No class components
- Cleanup side effects in `useEffect` return function
- Memoize expensive computations with `useMemo`; callbacks with `useCallback` only when passed to memoized children
- Keep components under 150 lines; extract sub-components otherwise
- Co-locate component, styles, and tests in the same directory
