---
name: vue3-composition-api
description: Vue 3 Composition API patterns and conventions. Use when writing or reviewing Vue 3 components.
---

# Vue 3 Composition API

## Component Structure
Always use `<script setup>` — no Options API.

```vue
<script setup lang="ts">
import { ref, computed, onMounted } from 'vue'
import { useUserStore } from '@/stores/user'

const props = defineProps<{ userId: number }>()
const emit = defineEmits<{ updated: [user: User] }>()

const store = useUserStore()
const loading = ref(false)

const user = computed(() => store.getById(props.userId))

onMounted(async () => {
  loading.value = true
  await store.fetch(props.userId)
  loading.value = false
})
</script>
```

## State Management (Pinia)
```ts
// stores/user.ts
export const useUserStore = defineStore('user', () => {
  const users = ref<User[]>([])
  const getById = computed(() => (id: number) => users.value.find(u => u.id === id))

  async function fetch(id: number) {
    const { data } = await api.get(`/users/${id}`)
    users.value.push(data)
  }

  return { users, getById, fetch }
})
```

## Composables
Extract reusable logic into composables in `composables/`:
```ts
// composables/useAsync.ts
export function useAsync<T>(fn: () => Promise<T>) {
  const data = ref<T | null>(null)
  const loading = ref(false)
  const error = ref<Error | null>(null)

  async function execute() {
    loading.value = true
    error.value = null
    try { data.value = await fn() }
    catch (e) { error.value = e as Error }
    finally { loading.value = false }
  }

  return { data, loading, error, execute }
}
```

## Rules
- Props are typed with generics, not `PropType`
- Emits are typed with generics
- No `this` — everything is reactive refs or computed
- `v-model` on custom components uses `defineModel()` (Vue 3.4+)
- Keep components under 200 lines; extract sub-components otherwise
